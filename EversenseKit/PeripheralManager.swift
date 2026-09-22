import CoreBluetooth

class PeripheralManager: NSObject {
    private let logger = EversenseLogger(category: "PeripheralManager")
    private let peripheral: CBPeripheral
    private let cgmManager: EversenseCGMManager
    private var connectCompletion: ((ConnectFailure?) -> Void)?

    private var securityHandshakeCompleted = false
    private var service: CBService?
    private var requestCharacteristic: CBCharacteristic?
    private var responseCharacteristic: CBCharacteristic?

    private var buffer = Data([])
    private var packet: (any BasePacket)?
    private var writeQueue: EversenseKitDispatchGroup?
    private var writeResponse: AnyObject?
    private var isCleaningUp = false
    private let writeSerialQueue = DispatchQueue(label: "com.bastiaanv.eversensekit.peripheralWriteQueue")

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
        try writeSerialQueue.sync { [self] in
            // cleanup() may have run while we were queued waiting for the queue
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

    /// Signals the pending write that its response (or error) has arrived.
    /// Returns false when there is no pending write.
    private func signalPendingWrite() -> Bool {
        writeLock.lock()
        let stream = writeQueue
        writeLock.unlock()

        guard let stream else {
            logger.warning("No pending writeQueue", type: .receive)
            return false
        }

        stream.leave()
        return true
    }

    private func failConnect(_ reason: ConnectFailure) {
        connectCompletion?(reason)
        connectCompletion = nil
    }

    private func succeedConnect() {
        connectCompletion?(nil)
        connectCompletion = nil
    }
}

extension PeripheralManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        if let error = error {
            logger.error("Got error while discovering services: \(error.localizedDescription)")
            failConnect(ConnectFailure.failedToDiscoverServices)
            return
        }

        self.service = peripheral.services?.first { $0.uuid == CBUUID.serviceUUID }
        guard let service = self.service else {
            logger.error("Service not found: \(peripheral.services?.map(\.uuid.uuidString) ?? [])")
            failConnect(ConnectFailure.failedToDiscoverServices)
            return
        }

        logger.debug("Start discovering characteristics...")
        peripheral.discoverCharacteristics(nil, for: service)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        if let error = error {
            logger.error("Got error while discovering characteristics: \(error.localizedDescription)")
            failConnect(ConnectFailure.failedToDiscoverCharacteristics)
            return
        }

        // Ordered: `.none` is checked first, then falls back to the secure tiers.
        let tiers: [(security: SecurityType, requestUUID: CBUUID, responseUUID: CBUUID, log: String)] = [
            (
                .none,
                CBUUID.requestCharacteristicUUID,
                CBUUID.responseCharacteristicUUID,
                "[NONE security] Discovering completed -> Enabling notifing & send bleBondingInformation..."
            ),
            (
                .v2,
                CBUUID.requestCharacteristicSecureV2UUID,
                CBUUID.responseCharacteristicSecureV2UUID,
                "[V2 security] Discovering completed -> Enabling notifing..."
            )
        ]

        for tier in tiers {
            guard let requestCharacteristic = service.characteristics?.first(where: { $0.uuid == tier.requestUUID }),
                  let responseCharacteristic = service.characteristics?.first(where: { $0.uuid == tier.responseUUID })
            else {
                continue
            }

            cgmManager.updateState { $0.security = tier.security }
            self.requestCharacteristic = requestCharacteristic
            self.responseCharacteristic = responseCharacteristic

            logger.debug(tier.log)
            peripheral.setNotifyValue(true, for: responseCharacteristic)
            return
        }

        logger.error("Characteristics could not found: \(service.characteristics ?? [])")
        failConnect(ConnectFailure.failedToDiscoverCharacteristics)
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
        guard PacketFraming.appendReceivedChunk(data, to: &buffer, isE3: isE3) else {
            return
        }
        var actualData = Data(buffer)

        if !isE3, securityHandshakeCompleted {
            // Only decrypt if packet is for 365 & not for Authentication
            actualData = CryptoUtil.shared.decrypt(data: actualData)
            guard !actualData.isEmpty else {
                logger.error("Failed to decrypt payload", type: .receive)
                buffer = Data()
                return
            }
        }

        logger.debug("Decrypted payload: \(actualData.hexString())", type: .receive)
        buffer = Data()

        if handleKeepAlive(actualData) {
            return
        }

        if handleAlarm(actualData) {
            return
        }

        if handleErrorResponse(
            id: EversenseE3.PacketIds.errorResponseId.rawValue,
            handler: EversenseE3.handleError,
            data: actualData
        ) {
            return
        }

        if handleErrorResponse(
            id: Eversense365.PacketIds.ErrorResponseId.rawValue,
            handler: Eversense365.handleError,
            data: actualData
        ) {
            return
        }

        // From here we assume it is a normal packet
        handleNormalPacket(actualData, isE3: isE3)
    }

    // E3 keepalive + 365 push handling. Returns true when the packet was handled.
    private func handleKeepAlive(_ data: Data) -> Bool {
        if data[0] == EversenseE3.PacketIds.keepAlivePush.rawValue {
            // TODO: Detect alarm notification
            logger.debug("[E3] Got keep alive message", type: .receive)

            if cgmManager.state.recentGlucoseDateTime == nil || cgmManager.state.recentGlucoseDateTime!
                .addingTimeInterval(.minutes(4.5)) > Date.now
            {
                cgmManager.heartbeathOperation()
            }
            return true
        }

        guard PacketFraming.matchesNotification(data, pushId: .KeepAlive) else {
            return false
        }

        let packet = Eversense365.PushKeepAlivePacket()
        let response = packet.parseResponse(data: data)

        logger.debug(
            "[365] Got keep alive message - mostRecentGlucoseDatetime: \(response.mostRecenteGlucoseDatetime)",
            type: .receive
        )
        if response.mostRecenteGlucoseDatetime > (cgmManager.state.recentGlucoseDateTime ?? .distantPast) {
            cgmManager.heartbeathOperation()
        }

        return true
    }

    // 365 alarm-with-data. Returns true when the packet was handled.
    private func handleAlarm(_ data: Data) -> Bool {
        guard PacketFraming.matchesNotification(data, pushId: .AlarmWithData) else {
            return false
        }

        let packet = Eversense365.PushAlarmWithDataPacket(currentGlucose: cgmManager.state.recentGlucoseInMgDl ?? 0)
        let response = packet.parseResponse(data: data)
        guard response.alarm.code != .unknown else {
            logger.warning("[365] Received unknown alarm: \(response.alarmRaw)", type: .receive)
            return true
        }

        cgmManager.updateState { $0.activeAlarms = [response.alarm] }

        logger.debug("[365] Received alarm", type: .receive)
        return true
    }

    // E3 (id 128) and 365 (id 255) error responses share the same shape; the ids are
    // exclusive to each family. Returns true when this packet was an error response.
    private func handleErrorResponse(id: UInt8, handler: (Data) -> Void, data: Data) -> Bool {
        guard data[0] == id else {
            return false
        }

        handler(data)
        _ = signalPendingWrite()
        return true
    }

    // Checksum, parse and signal the pending write. Assumes a normal packet.
    private func handleNormalPacket(_ data: Data, isE3: Bool) {
        var actualData = data

        writeLock.lock()
        let activePacket = packet
        writeLock.unlock()

        guard let activePacket else {
            logger.error("No active packet - data: \(actualData.hexString())", type: .receive)
            return
        }

        guard activePacket.checkPacket(data: actualData, doChecksum: isE3) else {
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

        let parsedResponse = activePacket.parseResponse(data: actualData) as AnyObject

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
            succeedConnect()
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
            failConnect(.preconditionFailed(reason: "Failed to generate keypair..."))
            return
        }

        do {
            if cgmManager.state.certificateV2 == nil {
                guard
                    let credentials = cgmManager.keychain.getEversenseCredentials(),
                    let publicKey = cgmManager.state.publicKeyV2
                else {
                    logger.error("Missing credentials...")
                    failConnect(.preconditionFailed(reason: "Missing credentials..."))
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
                    failConnect(.preconditionFailed(reason: "FleetSecret is empty..."))
                    return
                }

                cgmManager.updateState { $0.certificateV2 = certificate }
                guard let certificateData = Data(hexString: certificate) else {
                    logger.error("Could not parse certificate - data: \(certificate)")
                    failConnect(.preconditionFailed(reason: "No cert available..."))
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
                failConnect(.preconditionFailed(reason: "Signature failed..."))
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
                failConnect(.preconditionFailed(reason: "Auth flow failed"))
                return
            }

            try CryptoUtil.shared.generateSessionKey(
                sessionPublicKey: startResponse.sessionPublicKey,
                privateKey: ephemPrivateKey,
                salt: salt
            )

            securityHandshakeCompleted = true
            Eversense365.fullSync(peripheralManager: self, cgmManager: cgmManager)
            succeedConnect()

        } catch {
            cgmManager.updateState { $0.certificateV2 = nil }

            logger.error("Failed to write Auth v2 - \(error.localizedDescription)")
            failConnect(.failedToFetchFleetKey(reason: "Failed to write Auth v2 - \(error.localizedDescription)"))
            return
        }
    }
}
