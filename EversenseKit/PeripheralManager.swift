import CoreBluetooth

enum SecurityType {
    case none
    case v1
    case v2
}

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
    private var writeQueue: [UInt8: AsyncThrowingStream<AnyObject, Error>.Continuation] = [:]

    private let maxPacketSize: Int
    private var security: SecurityType

    public var isTransmitter365: Bool {
        security == .v1 || security == .v2
    }

    init(peripheral: CBPeripheral, cgmManager: EversenseCGMManager, connectCompletion: @escaping (ConnectFailure?) -> Void) {
        self.peripheral = peripheral
        self.cgmManager = cgmManager
        self.connectCompletion = connectCompletion

        // Need the MTU for the 365 transmitter
        maxPacketSize = self.peripheral.maximumWriteValueLength(for: .withoutResponse)
        security = .none
        super.init()

        self.peripheral.delegate = self
    }

    func write<T>(_ packet: any BasePacket) async throws -> T {
        guard writeQueue[packet.response.rawValue] == nil, let characteristic = requestCharacteristic else {
            throw NSError(domain: "Command already running", code: 0)
        }

        self.packet = packet
        let stream = AsyncThrowingStream<AnyObject, Error> { continuation in
            writeQueue[packet.response.rawValue] = continuation
        }

        let data = packet.getRequestData()
        if case security = .none {
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

    private func startTimeoutTimer(packet: any BasePacket) {
        writeTimeoutTask = Task {
            do {
                try await Task.sleep(nanoseconds: UInt64(.seconds(5)) * 1_000_000_000)
                guard let stream = self.writeQueue[packet.response.rawValue] else {
                    // We did what we must, so exist and be happy :)
                    return
                }

                stream.finish()

                self.writeQueue.removeValue(forKey: packet.response.rawValue)
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
                self.security = .none
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
                self.security = .v2
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
                self.security = .v1
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
                switch security {
                case .none:
                    await writeNoneSecurity()
                case .v1:
                    await getFleetKey()
                case .v2:
                    await writeWhoAmI()
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

        if security != .none {
            logger.debug("Stripping header from received data")
            data = data.subdata(in: 3 ..< data.count)
        }

        if data[0] == PacketIds.keepAlivePush.rawValue {
            logger.debug("Got keep alive message")
            return
        }

        if data[0] == PacketIds.authenticateResponseId.rawValue {
            guard let packet = self.packet as? Authenticatev1Packet else {
                logger.error("Unexpected authenticate response")
                return
            }

            guard packet.checkHmac(data: data) else {
                logger.error("HMAC check failed...")
                return
            }

            TransmitterStateSync.fullSync(peripheralManager: self, cgmManager: cgmManager, connectCompletion: connectCompletion)
            connectCompletion = nil
            return
        }

        if data[0] == PacketIds.errorResponseId.rawValue {
            guard data.count >= 4 else {
                logger.error("Invalid error response length - length: \(data.count), data: \(data.hexString())")
                return
            }

            let code = (UInt16(data[3]) << 8) | UInt16(data[2])
            guard let error = CommandError(rawValue: code) else {
                logger.error("Received unknown error - code: \(code), data: \(data.hexString())")
                return
            }

            // TODO: Emit error
            logger.warning("Received error from transmitter - error: \(error), data: \(data.hexString())")
            return
        }

        // Parse normal packet
        guard let packet = self.packet, packet.checkPacket(data: data, doChecksum: security == .none) else {
            logger.warning("Received invalid response, invalid response code or checksum failed - data: \(data.hexString())")
            return
        }

        if security == .none {
            data = data.subdata(in: 1 ..< data.count - 2)
        }

        let response = packet.parseResponse(data: data) as AnyObject

        guard let stream = writeQueue[packet.response.rawValue] else {
            logger.warning("No pending write for response code \(packet.response.rawValue) - data: \(data.hexString())")
            return
        }

        writeTimeoutTask?.cancel()
        writeTimeoutTask = nil
        writeQueue[packet.response.rawValue] = nil

        stream.yield(response)
        stream.finish()
    }
}

// Eversense 365 specific methods
extension PeripheralManager {
    private func writeNoneSecurity() async {
        do {
            let _: SaveBleBondingInformationResponse = try await write(SaveBleBondingInformationPacket())

            TransmitterStateSync.fullSync(peripheralManager: self, cgmManager: cgmManager, connectCompletion: connectCompletion)
            connectCompletion = nil
        } catch {
            logger.error("Failed to SaveBleBondingInformationResponse: \(error.localizedDescription)")
            connectCompletion?(.failedToFetchFleetKey(reason: error.localizedDescription))
        }
    }

    private func getFleetKey() async {
        if let fleetKey = cgmManager.state.fleetKey {
            await writeAuth(fleetKey)
            return
        }

        do {
            if let accessToken = cgmManager.state.accessToken, let expires = cgmManager.state.accessTokenExpiration,
               expires >= Date()
            {
                let securityResponse = try await KeyVaultApi.getFleetSecret(accessToken: accessToken)
                guard let txFleetKey = securityResponse.result.txFleetKey else {
                    logger.error("Failed to fetch fleet key")
                    connectCompletion?(.failedToFetchFleetKey(reason: "Failed to fetch fleet key"))
                    return
                }
                cgmManager.state.fleetKey = txFleetKey
                cgmManager.notifyStateDidChange()

                await writeAuth(txFleetKey)
                return
            }

            if let username = cgmManager.state.username, let password = cgmManager.state.password {
                let sessionResponse = try await AuthenticationApi.login(username: username, password: password)
                cgmManager.state.accessToken = sessionResponse.accessToken
                cgmManager.state.accessTokenExpiration = Date().addingTimeInterval(.seconds(Double(sessionResponse.expiresIn)))

                let securityResponse = try await KeyVaultApi.getFleetSecret(accessToken: sessionResponse.accessToken)
                guard let txFleetKey = securityResponse.result.txFleetKey else {
                    logger.error("Failed to fetch fleet key")
                    connectCompletion?(.failedToFetchFleetKey(reason: "Failed to fetch fleet key"))
                    return
                }
                cgmManager.state.fleetKey = txFleetKey
                cgmManager.notifyStateDidChange()

                await writeAuth(txFleetKey)
                return
            }

            logger.error("User is unauthenticated...")
            connectCompletion?(.failedToFetchFleetKey(reason: "User is unauthenticated"))
        } catch {
            logger.error("Failed to fetch fleet key: \(error.localizedDescription)")
            connectCompletion?(.failedToFetchFleetKey(reason: error.localizedDescription))
        }
    }

    private func writeAuth(_ fleetKey: String) async {
        guard let (sessionKey, salt) = CryptoUtil.generateSession(fleetKey: fleetKey) else {
            logger.error("Failed to generate session key...")
            connectCompletion?(.failedToFetchFleetKey(reason: "Failed to generate session key..."))
            return
        }

        do {
            let _: Authenticatev1Response = try await write(Authenticatev1Packet(sessionKey: sessionKey, salt: salt))
        } catch {
            logger.error("Failed to write Auth v1 - \(error.localizedDescription)")
            connectCompletion?(.failedToFetchFleetKey(reason: "Failed to write Auth v1 - \(error.localizedDescription)"))
            return
        }
    }

    private func writeWhoAmI() async {
        if cgmManager.state.publicKeyV2 == nil || cgmManager.state.privateKeyV2 == nil || cgmManager.state.clientIdV2 == nil {
            let (newPrivateKey, newPublicKey, newClientId) = CryptoUtil.generateKeyPair()
            cgmManager.state.publicKeyV2 = newPublicKey
            cgmManager.state.privateKeyV2 = newPrivateKey
            cgmManager.state.clientIdV2 = newClientId
        }

        guard
            let accessToken = cgmManager.state.accessToken,
            let clientId = cgmManager.state.clientIdV2,
            let publicKey = cgmManager.state.publicKeyV2
        else {
            logger.error("Failed to generate key pair")
            return
        }

        do {
            logger.info("Sending WhoAmI")
            let whoAmIResponse: AuthenticateV2Response =
                try await write(AuthenticateV2Packet(type: AuthType.WhoAmI, secret: clientId))

            if cgmManager.state.certificateV2 == nil ||
                cgmManager.state.fleetKeyPublicKeyV2 == nil ||
                cgmManager.state.noneV2 == nil ||
                cgmManager.state.noneV2 != whoAmIResponse.nonce
            {
                logger
                    .debug(
                        "Fetching certificate, local nonce: \(cgmManager.state.noneV2?.hexString() ?? "nil"), received nonce: \(whoAmIResponse.nonce.hexString())"
                    )

                logger.debug("public key full: \(publicKey.hexString())")
                logger.debug("public key: \(publicKey.subdata(in: 27 ..< publicKey.count).hexString())")
                logger.debug("Public key length: \(publicKey.subdata(in: 27 ..< publicKey.count).count)")
                let fleetSecret = await KeyVaultApi.getFleetSecretV2(
                    accessToken: accessToken,
                    serialNumber: whoAmIResponse.serialNumber.base64Safe(),
                    nonce: whoAmIResponse.nonce.base64Safe(),
                    flags: whoAmIResponse.flags,
                    kpClientUniqueId: publicKey.subdata(in: 27 ..< publicKey.count).base64Safe()
                )

                guard let fleetSecret = fleetSecret,
                      fleetSecret.status == "Success",
                      let certificate = fleetSecret.result.certificate,
                      let kpTxUniqueId = fleetSecret.result.kpTxUniqueId,
                      let decryptedPublicKey = CryptoUtil.decryptPublicKey(fleetKey: kpTxUniqueId)
                else {
                    logger.error("FleetSecret is empty or is missing information...")
                    return
                }

                cgmManager.state.certificateV2 = certificate
                cgmManager.state.fleetKeyPublicKeyV2 = decryptedPublicKey.rawRepresentation
                cgmManager.state.noneV2 = whoAmIResponse.nonce
            } else {
                logger.info("Skipping online keyVault call, certificate already set")
            }

            return

//            guard let certificate = cgmManager.state.certificateV2, let certificateData = Data(hexString: certificate) else {
//                logger.error("No certificate available...")
//                return
//            }
//
//            logger.debug("Sending IDENTITY...")
//            let identityResponse: AuthenticateV2Response =
//                try await write(AuthenticateV2Packet(type: AuthType.Identity, secret: certificateData))
//            logger.debug("Identity status: \(identityResponse.status)")

        } catch {
            logger.error("Failed to write Auth v2 - \(error.localizedDescription)")
            connectCompletion?(.failedToFetchFleetKey(reason: "Failed to write Auth v2 - \(error.localizedDescription)"))
            return
        }
    }
}
