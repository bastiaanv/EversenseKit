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

    private var buffer = Data([])
    private var packet: (any BasePacket)?
    private var writeQueue: EversenseKitDispatchGroup?
    private let writeSemaphore = DispatchSemaphore(value: 1)
    private var writeResponse: AnyObject?
    private var isCleaningUp = false
    /// Protects `packet`, `writeQueue`, `writeResponse` and `isCleaningUp`, which are
    /// touched both by the thread performing the write and by the CoreBluetooth delegate.
    private let writeLock = NSRecursiveLock()

    private let maxPacketSize: Int

    init(peripheral: CBPeripheral, cgmManager: EversenseCGMManager, connectCompletion: @escaping (ConnectFailure?) -> Void) {
        self.peripheral = peripheral
        self.cgmManager = cgmManager
        self.connectCompletion = connectCompletion

        // Need the MTU for the 365 transmitter
        maxPacketSize = self.peripheral.maximumWriteValueLength(for: .withoutResponse)
        super.init()

        self.peripheral.delegate = self
    }

    func cleanup() {
        writeLock.lock()
        isCleaningUp = true
        let writeAction = writeQueue
        writeLock.unlock()

        writeAction?.leave()
    }

    func write<T>(_ packet: any BasePacket, timeout: TimeInterval = .seconds(5)) throws -> T {
        writeLock.lock()
        let alreadyCleaningUp = isCleaningUp
        writeLock.unlock()

        if alreadyCleaningUp {
            throw NSError(domain: "PeripheralManager cleaned up", code: -1)
        }

        // Wait until previous write calls have been completed
        writeSemaphore.wait()

        defer { writeSemaphore.signal() }

        // cleanup() may have run while we were waiting for the lock
        writeLock.lock()
        let cleaningUp = isCleaningUp
        writeLock.unlock()

        guard !cleaningUp else {
            throw NSError(domain: "PeripheralManager cleaned up", code: -1)
        }

        guard let characteristic = requestCharacteristic else {
            logger.error("Not connected anymore...", type: .send)
            throw NSError(domain: "Not connected anymore...", code: 0, userInfo: nil)
        }

        let writeQ = EversenseKitDispatchGroup()
        writeQ.enter()

        writeLock.lock()
        self.packet = packet
        writeQueue = writeQ
        writeResponse = nil
        writeLock.unlock()

        let data = packet.getRequestData()
        if cgmManager.state.security == .none {
            logger.debug("[RAW] Writing data -> \(data.hexString())", type: .send)
            peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
        } else {
            let encodedMessage = EncodingOperations.encode(data: data, chunkSize: maxPacketSize)

            for message in EncodingOperations.split(data: encodedMessage, chunkSize: maxPacketSize) {
                logger.debug("[ENCODED] Writing data -> \(message.hexString())", type: .send)

                peripheral.writeValue(message, for: characteristic, type: .withoutResponse)
                Thread.sleep(forTimeInterval: .milliseconds(100))
            }
        }

        // Wait for response or timeout timer...
        _ = writeQ.wait(timeout: .now().advanced(by: .seconds(Int(timeout))))

        writeLock.lock()
        writeQueue = nil
        let response = writeResponse as? T
        writeResponse = nil
        writeLock.unlock()

        guard let response else {
            throw NSError(domain: "Timeout has been hit...", code: 0, userInfo: nil)
        }

        return response
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

        if let requestCharacteristic = service.characteristics?.first(where: { $0.uuid == self.requestCharacteristicUUID }),
           let responseCharacteristic = service.characteristics?
           .first(where: { $0.uuid == self.responseCharacteristicUUID })
        {
            cgmManager.updateState { $0.security = .none }
            self.requestCharacteristic = requestCharacteristic
            self.responseCharacteristic = responseCharacteristic

            logger.debug("[NONE security] Discovering completed -> Enabling notifing & send bleBondingInformation...")
            peripheral.setNotifyValue(true, for: responseCharacteristic)
            return
        }

        if let requestCharacteristic = service.characteristics?
            .first(where: { $0.uuid == self.requestCharacteristicSecureV2UUID }),
            let responseCharacteristic = service.characteristics?
            .first(where: { $0.uuid == self.responseCharacteristicSecureV2UUID })
        {
            cgmManager.updateState { $0.security = .v2 }
            self.requestCharacteristic = requestCharacteristic
            self.responseCharacteristic = responseCharacteristic

            logger.debug("[V2 security] Discovering completed -> Enabling notifing...")
            peripheral.setNotifyValue(true, for: responseCharacteristic)
            return
        }

        if let requestCharacteristic = service.characteristics?
            .first(where: { $0.uuid == self.requestCharacteristicSecureUUID }),
            let responseCharacteristic = service.characteristics?
            .first(where: { $0.uuid == self.responseCharacteristicSecureUUID })
        {
            cgmManager.updateState { $0.security = .v1 }
            self.requestCharacteristic = requestCharacteristic
            self.responseCharacteristic = responseCharacteristic

            logger.debug("[V1 security] Discovering completed -> Enabling notifing...")
            peripheral.setNotifyValue(true, for: responseCharacteristic)
            return
        }

        logger.error("Characteristics could not found: \(service.characteristics ?? [])")
        connectCompletion?(ConnectFailure.failedToDiscoverCharacteristics)
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
                    writeNoneSecurity()
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
            logger.error("Received error on value update: \(error.localizedDescription)", type: .receive)
            connectCompletion?(ConnectFailure.unknown(reason: "Received error on value update: \(error.localizedDescription)"))
            return
        }

        guard let data = characteristic.value else {
            logger.warning("Empty data received", type: .receive)
            return
        }

        let isE3 = cgmManager.state.security == .none
        if isE3 {
            buffer.append(data)
        } else {
            buffer.append(data.subdata(in: (buffer.isEmpty ? 3 : 2) ..< data.count))
        }
        var actualData = Data(buffer)

        if !isE3 {
            if data[0] != data[1] {
                // Data is chuncked, lets store this and wait
                return
            }

            if buffer[0] != Eversense365.PacketIds.AuthenticateV2ResponseId.rawValue {
                // Only decrypt if packet is not for Authentication
                actualData = CryptoUtil.shared.decrypt(data: actualData)
                guard !actualData.isEmpty else {
                    logger.error("Failed to decrypt payload", type: .receive)
                    buffer = Data()
                    return
                }
            }
        }

        logger.debug("Decrypted payload: \(actualData.hexString())", type: .receive)
        buffer = Data()

        if actualData[0] == EversenseE3.PacketIds.keepAlivePush.rawValue {
            // TODO: Detect alarm notification
            logger.debug("[E3] Got keep alive message", type: .receive)

            if cgmManager.state.recentGlucoseDateTime == nil || cgmManager.state.recentGlucoseDateTime!
                .addingTimeInterval(.minutes(4.5)) > Date.now
            {
                cgmManager.heartbeathOperation()
            }
            return
        }

        if actualData[0] == Eversense365.PacketIds.NotificationId.rawValue,
           actualData[1] == Eversense365.PushIds.KeepAlive.rawValue
        {
            let packet = Eversense365.PushKeepAlivePacket()
            let response = packet.parseResponse(data: actualData)

            logger.debug(
                "[365] Got keep alive message - mostRecentGlucoseDatetime: \(response.mostRecenteGlucoseDatetime)",
                type: .receive
            )
            if response.mostRecenteGlucoseDatetime > (cgmManager.state.recentGlucoseDateTime ?? .distantPast) {
                cgmManager.heartbeathOperation()
            }

            return
        }

        if actualData[0] == Eversense365.PacketIds.NotificationId.rawValue,
           actualData[1] == Eversense365.PushIds.AlarmWithData.rawValue
        {
            let packet = Eversense365.PushAlarmWithDataPacket(currentGlucose: cgmManager.state.recentGlucoseInMgDl ?? 0)
            let response = packet.parseResponse(data: actualData)
            guard response.alarm.code != .unknown else {
                logger.warning("[365] Received unknown alarm: \(response.alarm.codeRaw)", type: .receive)
                return
            }

            self.cgmManager.updateState { $0.activeAlarms = [response.alarm] }

            logger.debug("[365] Received alarm", type: .receive)
            return
        }

        if actualData[0] == EversenseE3.PacketIds.errorResponseId.rawValue {
            EversenseE3.handleError(data: actualData)

            writeLock.lock()
            let stream = writeQueue
            writeLock.unlock()

            guard let stream else {
                logger.warning("No pending writeQueue", type: .receive)
                return
            }

            stream.leave()
            return
        }

        if actualData[0] == Eversense365.PacketIds.ErrorResponseId.rawValue {
            Eversense365.handleError(data: actualData)

            writeLock.lock()
            let stream = writeQueue
            writeLock.unlock()

            guard let stream else {
                logger.warning("No pending writeQueue", type: .receive)
                return
            }

            stream.leave()
            return
        }

        // From here we assume it is a normal packet
        writeLock.lock()
        let packet = self.packet
        writeLock.unlock()

        guard let packet else {
            logger.error("No active packet - data: \(actualData.hexString())", type: .receive)
            return
        }

        guard packet.checkPacket(data: actualData, doChecksum: isE3) else {
            logger
                .warning(
                    "Received invalid response, invalid response code or checksum failed - data: \(actualData.hexString())",
                    type: .receive
                )
            return
        }

        if isE3 {
            actualData = actualData.subdata(in: 1 ..< actualData.count - 2)
        }

        let parsedResponse = packet.parseResponse(data: actualData) as AnyObject

        writeLock.lock()
        writeResponse = parsedResponse
        let stream = writeQueue
        writeQueue = nil
        writeLock.unlock()

        guard let stream else {
            logger.warning("No pending writeQueue - data: \(actualData.hexString())", type: .receive)
            return
        }

        stream.leave()
    }
}

// Eversense E3 specific auth flow
extension PeripheralManager {
    private func writeNoneSecurity() {
        do {
            let _: EversenseE3.SaveBleBondingInformationResponse = try write(EversenseE3.SaveBleBondingInformationPacket())

            EversenseE3.fullSync(peripheralManager: self, cgmManager: cgmManager)
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
            cgmManager.updateState {
                $0.publicKeyV2 = newPublicKey
                $0.privateKeyV2 = newPrivateKey
                $0.clientIdV2 = newClientId
            }
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
            if cgmManager.state.certificateV2 == nil {
                guard
                    let credentials = cgmManager.keychain.getEversenseCredentials(),
                    let publicKey = cgmManager.state.publicKeyV2
                else {
                    logger.error("Missing credentials...")
                    connectCompletion?(.preconditionFailed(reason: "Missing credentials..."))
                    connectCompletion = nil
                    return
                }

                let whoAmIResponse: Eversense365.AuthWhoAmIResponse =
                    try write(Eversense365.AuthWhoAmIPacket(secret: clientId))

                let accessResponse = try await AuthenticationApi.login(
                    cgmManager: cgmManager,
                    username: credentials.username,
                    password: credentials.password
                )

                let fleetSecret = await KeyVaultApi.getFleetSecretV2(
                    cgmManager: cgmManager,
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

                cgmManager.updateState { $0.certificateV2 = certificate }
                guard let certificateData = Data(hexString: certificate) else {
                    logger.error("Could not parse certificate - data: \(certificate)")
                    connectCompletion?(.preconditionFailed(reason: "No cert available..."))
                    connectCompletion = nil
                    return
                }

                logger.debug("Sending IDENTITY...")
                let _: Eversense365
                    .AuthIdentityResponse = try write(Eversense365.AuthIdentityPacket(secret: certificateData))
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
            let startResponse: Eversense365.AuthStartResponse = try write(Eversense365.AuthStartPacket(
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

            Eversense365.fullSync(peripheralManager: self, cgmManager: cgmManager)
            connectCompletion?(nil)
            connectCompletion = nil

        } catch {
            cgmManager.updateState { $0.certificateV2 = nil }

            logger.error("Failed to write Auth v2 - \(error.localizedDescription)")
            connectCompletion?(.failedToFetchFleetKey(reason: "Failed to write Auth v2 - \(error.localizedDescription)"))
            return
        }
    }
}
