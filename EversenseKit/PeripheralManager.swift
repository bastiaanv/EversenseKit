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
    private let connectCompletion: ((Result<Void, ConnectFailure>) -> Void)?
    
    private let serviceUUID = CBUUID(string: "c3230001-9308-47ae-ac12-3d030892a211")
    private let requestCharacteristicUUID = CBUUID(string: "6eb0f021-a7ba-7e7d-66c9-6d813f01d273")
    private let responseCharacteristicUUID = CBUUID(string: "6eb0f024-bd60-7aaa-25a7-0029573f4f23")
    
    private var service: CBService?
    private var requestCharacteristic: CBCharacteristic?
    private var responseCharacteristic: CBCharacteristic?
    
    init(peripheral: CBPeripheral, connectCompletion: @escaping (Result<Void, ConnectFailure>) -> Void) {
        self.peripheral = peripheral
        self.connectCompletion = connectCompletion
        
        self.peripheral.delegate = self
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
            guard SaveBleBondingInformationPacket.checkPacket(data: data) else {
                self.logger.error("Checksum failed for SaveBleBondingInformationPacket - \(data.hexString())")
                return
            }
            
            // TODO: Start transmitter state sync'ing
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
        
        // TODO: Parse normal packet
    }
}
