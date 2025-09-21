import CoreBluetooth

class PeripheralManager: NSObject {
    private let logger = EversenseLogger(category: "PeripheralManager")
    private let peripheral: CBPeripheral
    private let cgmManager: EversenseCGMManager
    private var connectCompletion: ((ConnectFailure?) -> Void)?

    public static let serviceUUID = CBUUID(string: "c3230001-9308-47ae-ac12-3d030892a211")
    private let requestCharacteristicUUID = CBUUID(string: "6eb0f021-a7ba-7e7d-66c9-6d813f01d273")
    private let requestCharacteristicSecureUUID = CBUUID(string: "6eb0f025-bd60-7aaa-25a7-0029573f4f23")
    private let requestCharacteristicSecureV2UUID = CBUUID(string: "c3230002-9308-47ae-ac12-3d030892a211")
    private let responseCharacteristicUUID = CBUUID(string: "6eb0f024-bd60-7aaa-25a7-0029573f4f23")
    private let responseCharacteristicSecureUUID = CBUUID(string: "6eb0f027-a7ba-7e7d-66c9-6d813f01d273")
    private let responseCharacteristicSecureV2UUID = CBUUID(string: "c3230003-9308-47ae-ac12-3d030892a211")

    private var service: CBService?
    private var requestCharacteristic: CBCharacteristic?
    private var responseCharacteristic: CBCharacteristic?

    private var packet: (any BasePacket)?
    private var writeTimeoutTask: Task<Void, Never>?
    private var writeQueue: (AsyncThrowingStream<AnyObject, Error>.Continuation)?

    private let maxPacketSize: Int

    init(peripheral: CBPeripheral, cgmManager: EversenseCGMManager, connectCompletion: @escaping (ConnectFailure?) -> Void) {
        self.peripheral = peripheral
        self.cgmManager = cgmManager
        self.connectCompletion = connectCompletion

        // Need the MTU for the 365 transmitter
        maxPacketSize = self.peripheral.maximumWriteValueLength(for: .withoutResponse)
        cgmManager.state.security = .none
        super.init()

        self.peripheral.delegate = self
    }

    func write<T>(_ packet: any BasePacket) async throws -> T {
        guard writeQueue == nil, let characteristic = requestCharacteristic else {
            throw NSError(domain: "Command already running", code: 0)
        }

        self.packet = packet
        let stream = AsyncThrowingStream<AnyObject, Error> { continuation in
            writeQueue = continuation
        }

        let data = packet.getRequestData()
        if case cgmManager.state.security = .none {
            logger.debug("[RAW] Writing data -> \(data.hexString())")
            peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
        } else {
            let encodedMessage = EncodingOperations.encode(data: data, chunkSize: maxPacketSize)
            logger.debug("[ENCODED] Writing data -> \(encodedMessage.hexString())")

            for message in EncodingOperations.split(data: encodedMessage, chunkSize: maxPacketSize) {
                peripheral.writeValue(message, for: characteristic, type: .withoutResponse)
                try await Task.sleep(nanoseconds: 100_000_000) // 100ms
            }
        }

        startTimeoutTimer(packet: packet)
        return try await firstValue(from: stream)
    }

    private func firstValue<T>(from stream: AsyncThrowingStream<AnyObject, Error>) async throws -> T {
        for try await value in stream {
            if let value = value as? T {
                return value
            }

            throw NSError(domain: "Got invalid data type", code: 0)
        }
        throw NSError(domain: "Got no response", code: 0)
    }

    private func startTimeoutTimer(packet _: any BasePacket) {
        writeTimeoutTask = Task {
            do {
                try await Task.sleep(nanoseconds: UInt64(.seconds(5)) * 1_000_000_000)
                guard let stream = self.writeQueue else {
                    // We did what we must, so exist and be happy :)
                    return
                }

                stream.finish()

                self.writeQueue = nil
                self.writeTimeoutTask = nil
            } catch {
                // Task was cancelled because message has been received
            }
        }
    }
}

extension PeripheralManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        if let error = error {
            logger.error("Got error while discovering services: \(error.localizedDescription)")
            connectCompletion?(ConnectFailure.failedToDiscoverServices)
            return
        }

        self.service = peripheral.services?.first { $0.uuid == PeripheralManager.serviceUUID }
        guard let service = self.service else {
            logger.error("Service not found: \(peripheral.services?.map(\.uuid.uuidString) ?? [])")
            connectCompletion?(ConnectFailure.failedToDiscoverServices)
            return
        }

        logger.debug("Start discovering characteristics...")
        peripheral.discoverCharacteristics(nil, for: service)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        if let error = error {
            logger.error("Got error while discovering characteristics: \(error.localizedDescription)")
            connectCompletion?(ConnectFailure.failedToDiscoverCharacteristics)
            return
        }

        Task {
            if let requestCharacteristic = service.characteristics?.first(where: { $0.uuid == self.requestCharacteristicUUID }),
               let responseCharacteristic = service.characteristics?
               .first(where: { $0.uuid == self.responseCharacteristicUUID })
            {
                cgmManager.state.security = .none
                self.requestCharacteristic = requestCharacteristic
                self.responseCharacteristic = responseCharacteristic

                self.logger.debug("[NONE security] Discovering completed -> Enabling notifing & send bleBondingInformation...")
                peripheral.setNotifyValue(true, for: responseCharacteristic)
                return
            }

            if let requestCharacteristic = service.characteristics?
                .first(where: { $0.uuid == self.requestCharacteristicSecureV2UUID }),
                let responseCharacteristic = service.characteristics?
                .first(where: { $0.uuid == self.responseCharacteristicSecureV2UUID })
            {
                cgmManager.state.security = .v2
                self.requestCharacteristic = requestCharacteristic
                self.responseCharacteristic = responseCharacteristic

                self.logger.debug("[V2 security] Discovering completed -> Enabling notifing...")
                peripheral.setNotifyValue(true, for: responseCharacteristic)
                return
            }

            if let requestCharacteristic = service.characteristics?
                .first(where: { $0.uuid == self.requestCharacteristicSecureUUID }),
                let responseCharacteristic = service.characteristics?
                .first(where: { $0.uuid == self.responseCharacteristicSecureUUID })
            {
                cgmManager.state.security = .v1
                self.requestCharacteristic = requestCharacteristic
                self.responseCharacteristic = responseCharacteristic

                self.logger.debug("[V1 security] Discovering completed -> Enabling notifing...")
                peripheral.setNotifyValue(true, for: responseCharacteristic)
                return
            }

            self.logger.error("Characteristics could not found: \(service.characteristics ?? [])")
            self.connectCompletion?(ConnectFailure.failedToDiscoverCharacteristics)
        }
    }

    func peripheral(_: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        if let error = error {
            logger.error("Failed to write to uuid: \(characteristic.uuid.uuidString) - Error: \(error.localizedDescription)")
        }
    }

    func peripheral(_: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: (any Error)?) {
        if let error = error {
            logger.error("Failed to enable notify for \(characteristic.uuid.uuidString): \(error.localizedDescription)")
        } else {
            logger.info("Successfully enabled notify for \(characteristic.uuid.uuidString)")

            Task {
                switch cgmManager.state.security {
                case .none:
                    await writeNoneSecurity()
                case .v1:
//                    await getFleetKey()
                    return
                case .v2:
                    await authFlowV2()
                }
            }
        }
    }

    func peripheral(_: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            logger.error("Received error on value update: \(error.localizedDescription)")
            connectCompletion?(ConnectFailure.unknown(reason: "Received error on value update: \(error.localizedDescription)"))
            return
        }

        guard var data = characteristic.value else {
            logger.warning("Empty data received")
            return
        }

        logger.debug("Received data: \(data.hexString())")
        let isE3 = cgmManager.state.security == .none

        if !isE3 {
            logger.debug("Stripping header from received data")
            data = data.subdata(in: 3 ..< data.count)

            if data[0] != Eversense365.PacketIds.AuthenticateV2ResponseId.rawValue {
                // Only decrypt if packet is not for Authentication
                logger.debug("Decrypting payload...")

                data = CryptoUtil.shared.decrypt(data: data)
                guard !data.isEmpty else {
                    logger.error("Failed to decrypt payload")
                    return
                }

                logger.debug("Decrypted payload: \(data.hexString())")
            }
        }

        if data[0] == EversenseE3.PacketIds.keepAlivePush.rawValue || data[0] == Eversense365.PacketIds.NotificationId.rawValue {
            logger.debug("Got keep alive message")
            cgmManager.heartbeathOperation()
            return
        }

        if data[0] == EversenseE3.PacketIds.errorResponseId.rawValue {
            EversenseE3.handleError(data: data)

            guard let stream = writeQueue else {
                logger.warning("No pending writeQueue")
                return
            }

            stream.finish()
            return
        }

        if data[0] == Eversense365.PacketIds.ErrorResponseId.rawValue {
            Eversense365.handleError(data: data)

            guard let stream = writeQueue else {
                logger.warning("No pending writeQueue")
                return
            }

            stream.finish()
            return
        }

        // From here we assume it is a normal packet
        guard let packet = self.packet, packet.checkPacket(data: data, doChecksum: isE3) else {
            logger.warning("Received invalid response, invalid response code or checksum failed - data: \(data.hexString())")
            return
        }

        if isE3 {
            data = data.subdata(in: 1 ..< data.count - 2)
        }

        let response = packet.parseResponse(data: data) as AnyObject

        guard let stream = writeQueue else {
            logger.warning("No pending writeQueue - data: \(data.hexString())")
            return
        }

        writeTimeoutTask?.cancel()
        writeTimeoutTask = nil
        writeQueue = nil

        stream.yield(response)
        stream.finish()
    }
}

// Eversense E3 specific auth flow
extension PeripheralManager {
    private func writeNoneSecurity() async {
        do {
            let _: EversenseE3.SaveBleBondingInformationResponse = try await write(EversenseE3.SaveBleBondingInformationPacket())

            await EversenseE3.fullSync(peripheralManager: self, cgmManager: cgmManager)
            connectCompletion?(nil)
            connectCompletion = nil
        } catch {
            logger.error("Failed to SaveBleBondingInformationResponse: \(error.localizedDescription)")
            connectCompletion?(.failedToFetchFleetKey(reason: error.localizedDescription))
        }
    }
}

// Eversense 365 specific auth flow
extension PeripheralManager {
    private func authFlowV2() async {
        if cgmManager.state.publicKeyV2 == nil || cgmManager.state.privateKeyV2 == nil || cgmManager.state.clientIdV2 == nil {
            let (newPrivateKey, newPublicKey, newClientId) = CryptoUtil.generateKeyPair()
            cgmManager.state.publicKeyV2 = newPublicKey
            cgmManager.state.privateKeyV2 = newPrivateKey
            cgmManager.state.clientIdV2 = newClientId
        }

        guard
            let clientId = cgmManager.state.clientIdV2,
            let privateKey = cgmManager.state.privateKeyV2
        else {
            logger.error("Failed to generate keypair")
            connectCompletion?(.preconditionFailed(reason: "Failed to generate keypair..."))
            connectCompletion = nil
            return
        }

        do {
            if cgmManager.state.certificateV2 == nil || cgmManager.state.fleetKeyPublicKeyV2 == nil {
                guard
                    let username = cgmManager.state.username,
                    let password = cgmManager.state.password,
                    let publicKey = cgmManager.state.publicKeyV2
                else {
                    logger.error("Missing credentials...")
                    connectCompletion?(.preconditionFailed(reason: "Missing credentials..."))
                    connectCompletion = nil
                    return
                }

                logger.info("Sending WhoAmI - clientID: \(clientId.hexString())")

                let whoAmIResponse: Eversense365.AuthWhoAmIResponse =
                    try await write(Eversense365.AuthWhoAmIPacket(secret: clientId))

                let accessResponse = try await AuthenticationApi.login(username: username, password: password)

                let fleetSecret = await KeyVaultApi.getFleetSecretV2(
                    accessToken: accessResponse.accessToken,
                    serialNumber: whoAmIResponse.serialNumber.base64Safe(),
                    nonce: whoAmIResponse.nonce.base64Safe(),
                    flags: whoAmIResponse.flags,
                    kpClientUniqueId: publicKey.subdata(in: 27 ..< publicKey.count).base64Safe()
                )

                guard let fleetSecret = fleetSecret,
                      fleetSecret.status == "Success",
                      let certificate = fleetSecret.result.certificate
                else {
                    logger.error("FleetSecret is empty or is missing information...")
                    connectCompletion?(.preconditionFailed(reason: "FleetSecret is empty..."))
                    connectCompletion = nil
                    return
                }

                cgmManager.state.certificateV2 = certificate
                guard let certificateData = Data(hexString: certificate) else {
                    logger.error("Could not parse certificate - data: \(certificate)")
                    connectCompletion?(.preconditionFailed(reason: "No cert available..."))
                    connectCompletion = nil
                    return
                }

                logger.debug("Sending IDENTITY...")
                let _: Eversense365
                    .AuthIdentityResponse = try await write(Eversense365.AuthIdentityPacket(secret: certificateData))
            } else {
                logger.info("Skipping online keyVault call, certificate already set")
            }

            let (ephemPrivateKey, ephemPublicKey, salt, digitalSignature) = try CryptoUtil.generateEphem(privateKey: privateKey)
            guard digitalSignature.count == 64 else {
                logger.error("Generated an invalid signature - length: \(digitalSignature.count)")
                connectCompletion?(.preconditionFailed(reason: "Signature failed..."))
                connectCompletion = nil
                return
            }

            logger.debug("Sending START...")
            let startResponse: Eversense365.AuthStartResponse = try await write(Eversense365.AuthStartPacket(
                clientId: clientId,
                ephemPublicKey: ephemPublicKey,
                salt: salt,
                digitalSignature: digitalSignature
            ))

            guard startResponse.sessionPublicKey.count > 6 else {
                connectCompletion?(.preconditionFailed(reason: "Auth flow failed"))
                connectCompletion = nil
                return
            }

            try CryptoUtil.shared.generateSessionKey(
                sessionPublicKey: startResponse.sessionPublicKey,
                privateKey: ephemPrivateKey,
                salt: salt
            )

            await Eversense365.fullSync(peripheralManager: self, cgmManager: cgmManager)
            connectCompletion?(nil)
            connectCompletion = nil

        } catch {
            logger.error("Failed to write Auth v2 - \(error.localizedDescription)")
            connectCompletion?(.failedToFetchFleetKey(reason: "Failed to write Auth v2 - \(error.localizedDescription)"))
            return
        }
    }
}
