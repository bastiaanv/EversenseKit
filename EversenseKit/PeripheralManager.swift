//
//  PeripheralManager.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 13/05/2025.
//

import CoreBluetooth

class PeripheralManager: NSObject {
    private let logger = EversenseLogger(category: "PeripheralManager")
    private let peripheral: CBPeripheral
    private let cgmManager: EversensCGMManager
    private let connectCompletion: ((Result<Void, ConnectFailure>) -> Void)?
    
    private let serviceUUID = CBUUID(string: "c3230001-9308-47ae-ac12-3d030892a211")
    private let requestCharacteristicUUID = CBUUID(string: "6eb0f021-a7ba-7e7d-66c9-6d813f01d273")
    private let responseCharacteristicUUID = CBUUID(string: "6eb0f024-bd60-7aaa-25a7-0029573f4f23")
    
    private var service: CBService?
    private var requestCharacteristic: CBCharacteristic?
    private var responseCharacteristic: CBCharacteristic?
    
    private var packet: (any BasePacket)?
    private var writeQueue: [UInt8: AsyncThrowingStream<AnyClass, Error>.Continuation] = [:]
    
    init(peripheral: CBPeripheral, cgmManager: EversensCGMManager, connectCompletion: @escaping (Result<Void, ConnectFailure>) -> Void) {
        self.peripheral = peripheral
        self.connectCompletion = connectCompletion
        
        self.peripheral.delegate = self
    }
    
    func write<T>(_ packet: any BasePacket) async throws -> T {
        guard writeQueue[packet.response.rawValue] == nil, let characteristic = self.requestCharacteristic else {
            throw NSError(domain: "Command already running", code: 0)
        }
        
        let stream = AsyncThrowingStream<AnyClass, Error> { continuation in
            writeQueue[packet.response.rawValue] = continuation
            peripheral.writeValue(packet.getRequestData(), for: characteristic, type: .withResponse)
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
}

extension PeripheralManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        if let error = error {
            self.logger.error("Got error while discovering services: \(error.localizedDescription)")
            self.connectCompletion?(.failure(.failedToDiscoverServices))
            return
        }
        
        self.service = peripheral.services?.first { $0.uuid == self.serviceUUID }
        guard let service = self.service else {
            self.logger.error("Service not found: \(peripheral.services?.map { $0.uuid.uuidString } ?? [])")
            self.connectCompletion?(.failure(.failedToDiscoverServices))
            return
        }
        
        self.logger.debug("Start discovering characteristics...")
        peripheral.discoverCharacteristics(nil, for: service)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        if let error = error {
            self.logger.error("Got error while discovering characteristics: \(error.localizedDescription)")
            self.connectCompletion?(.failure(.failedToDiscoverCharacteristics))
            return
        }
        
        self.requestCharacteristic = service.characteristics?.first { $0.uuid == self.requestCharacteristicUUID }
        self.responseCharacteristic = service.characteristics?.first { $0.uuid == self.responseCharacteristicUUID }
        guard let _ = self.requestCharacteristic, let responseCharacteristic = self.responseCharacteristic else {
            self.logger.error("One or both characteristics not found: \(self.responseCharacteristic != nil), \(self.requestCharacteristic != nil)")
            self.connectCompletion?(.failure(.failedToDiscoverCharacteristics))
            return
        }
        
        self.logger.debug("Discovering completed -> Enabling notifing...")
        peripheral.setNotifyValue(true, for: responseCharacteristic)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            self.logger.error("Received error on value update: \(error.localizedDescription)")
            self.connectCompletion?(.failure(.unknown(error: error)))
            return
        }
        
        guard let data = characteristic.value else {
            self.logger.warning("Empty data received")
            return
        }
        
        self.logger.debug("Received data: \(data.hexString())")
        
        if data[0] == PacketIds.saveBLEBondingInformationResponseId.rawValue {
            guard SaveBleBondingInformationPacket().checkPacket(data: data) else {
                self.logger.error("Checksum failed for SaveBleBondingInformationPacket - \(data.hexString())")
                return
            }
            
            self.fullTransmitterSync()
            return
        }
        
        if data[0] == PacketIds.errorResponseId.rawValue {
            guard data.count >= 4 else {
                self.logger.error("Invalid error response length - length: \(data.count), data: \(data.hexString())")
                return
            }
            
            let code = UInt16(data[3] << 8) | UInt16(data[2])
            guard let error = CommandError(rawValue: code) else {
                self.logger.error("Received unknown error - code: \(code), data: \(data.hexString())")
                return
            }
            
            // TODO: Emit error
            self.logger.warning("Received error from transmitter - error: \(error), data: \(data.hexString())")
            return
        }
        
        // Parse normal packet
        guard let packet = self.packet, packet.checkPacket(data: data), let response = packet.parseResponse(data: data.subdata(in: 1..<data.count-2)) as? AnyClass else {
            self.logger.warning("Received invalid response, invalid response code or checksum failed - data: \(data.hexString())")
            return
        }
        
        guard let stream = self.writeQueue[packet.response.rawValue] else {
            self.logger.warning("No pending write for response code \(packet.response.rawValue) - data: \(data.hexString())")
            return
        }
        
        stream.yield(response)
        stream.finish()
    }
}

extension PeripheralManager {
    func fullTransmitterSync() {
        Task {
            do {
                // Get MMA Features
                let mmaResponse: GetMmaFeaturesPacketResponse = try await self.write(GetMmaFeaturesPacket())
                cgmManager.state.mmaFeatures = mmaResponse.value
                
                // Get battery voltage
                let batteryResponse: GetBatteryVoltagePacketResponse = try await self.write(GetBatteryVoltagePacket())
                cgmManager.state.batteryVoltage = batteryResponse.value
                
                // TODO: Write morningCalibrationTime
                // TODO: Write eveningCalibrationTime
                
                // Set day startTime
                let setDayStartTimePacket = SetDayStartTimePacket(dayStartTime: cgmManager.state.dayStartTime)
                let _: SetDayStartTimePacketResponse = try await self.write(setDayStartTimePacket)
                
                // Set night startTime
                let setNightStartTimePacket = SetNightStartTimePacket(nightStartTime: cgmManager.state.nightStartTime)
                let _: SetNightStartTimePacketResponse = try await self.write(setNightStartTimePacket)
                
                // Do Ping
                let _: PingPacketResponse = try await self.write(PingPacket())
                
                // Get Transmitter model
                let modelResponse: GetModelPacketResponse = try await self.write(GetModelPacket())
                cgmManager.state.model = modelResponse.model
                
                // Get Transmitter version & extended Version
                let versionResponse: GetVersionPacketResponse = try await self.write(GetVersionPacket())
                let versionExtendedResponse: GetVersionExtendedPacketResponse = try await self.write(GetVersionExtendedPacket())
                cgmManager.state.version = versionResponse.version
                cgmManager.state.extVersion = versionExtendedResponse.extVersion
                
                // Get phase start datetime
                let phaseStartDate: GetPhaseStartDatePacketResponse = try await self.write(GetPhaseStartDatePacket())
                let phaseStartTime: GetPhaseStartTimePacketResponse = try await self.write(GetPhaseStartTimePacket())
                cgmManager.state.lastCalibration = Date.fromComponents(
                    date: phaseStartDate.date,
                    time: phaseStartTime.time
                )
                
                // Get last calibration datetime
                let lastCalibrationDate: GetLastCalibrationDatePacketResponse = try await self.write(GetLastCalibrationDatePacket())
                let lastCalibrationTime: GetLastCalibrationTimePacketResponse = try await self.write(GetLastCalibrationTimePacket())
                cgmManager.state.lastCalibration = Date.fromComponents(
                    date: lastCalibrationDate.date,
                    time: lastCalibrationTime.time
                )
                
                // TODO: Get current calibration phase
                
                // Get hysteresis
                let hysteresisPercentage: GetHysteresisPercentagePacketResponse = try await self.write(GetHysteresisPercentagePacket())
                let hysteresisValue: GetHysteresisValuePacketResponse = try await self.write(GetHysteresisValuePacket())
                cgmManager.state.hysteresisPercentage = hysteresisPercentage.value
                cgmManager.state.hysteresisValueInMgDl = hysteresisValue.valueInMgDl
            } catch {
                logger.error("Something went wrong during full sync: \(error)")
            }
        }
    }
}
