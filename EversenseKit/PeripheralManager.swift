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
    private let connectCompletion: ((ConnectFailure?) -> Void)?

    private let serviceUUID = CBUUID(string: "c3230001-9308-47ae-ac12-3d030892a211")
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
    private var writeQueue: [UInt8: AsyncThrowingStream<AnyClass, Error>.Continuation] = [:]

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

        let stream = AsyncThrowingStream<AnyClass, Error> { continuation in
            writeQueue[packet.response.rawValue] = continuation

            if case security = .none {
                peripheral.writeValue(packet.getRequestData(), for: characteristic, type: .withResponse)
            } else {
                // TODO: Secure data write
            }
        }

        return try await firstValue(from: stream)
    }

    private func firstValue<T>(from stream: AsyncThrowingStream<AnyClass, Error>) async throws -> T {
        for try await value in stream {
            if let value = value as? T {
                return value
            }

            throw NSError(domain: "Got invalid data type", code: 0)
        }
        throw NSError(domain: "Got no response. Most likely an encryption issue", code: 0)
    }

    private func startTimeoutTimer(packet: any BasePacket) {
        writeTimeoutTask = Task {
            do {
                try await Task.sleep(nanoseconds: UInt64(.seconds(2)) * 1_000_000_000)
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

        self.service = peripheral.services?.first { $0.uuid == self.serviceUUID }
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

                self.logger.debug("[NONE security] Discovering completed -> Enabling notifing...")
                peripheral.setNotifyValue(true, for: responseCharacteristic)

                // Response will be handled by didUpdateValueFor
                let _: SaveBleBondingInformationResponse = try await self.write(SaveBleBondingInformationPacket())
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

                // TODO: Get fleetKey from API & send it
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

                // TODO: Need to send whoAmI or sendStart command here
                return
            }

            self.logger.error("Characteristics could not found: \(service.characteristics ?? [])")
            self.connectCompletion?(ConnectFailure.failedToDiscoverCharacteristics)
        }
    }

    func peripheral(_: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            logger.error("Received error on value update: \(error.localizedDescription)")
            connectCompletion?(ConnectFailure.unknown(error: error))
            return
        }

        guard let data = characteristic.value else {
            logger.warning("Empty data received")
            return
        }

        logger.debug("Received data: \(data.hexString())")

        if data[0] == PacketIds.saveBLEBondingInformationResponseId.rawValue {
            guard SaveBleBondingInformationPacket().checkPacket(data: data) else {
                logger.error("Checksum failed for SaveBleBondingInformationPacket - \(data.hexString())")
                return
            }

            TransmitterStateSync.fullSync(peripheralManager: self, cgmManager: cgmManager, connectCompletion: connectCompletion)
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
        guard let packet = self.packet, packet.checkPacket(data: data),
              let response = packet.parseResponse(data: data.subdata(in: 1 ..< data.count - 2)) as? AnyClass
        else {
            logger.warning("Received invalid response, invalid response code or checksum failed - data: \(data.hexString())")
            return
        }

        guard let stream = writeQueue[packet.response.rawValue] else {
            logger.warning("No pending write for response code \(packet.response.rawValue) - data: \(data.hexString())")
            return
        }

        writeTimeoutTask?.cancel()
        writeTimeoutTask = nil

        stream.yield(response)
        stream.finish()
    }
}
