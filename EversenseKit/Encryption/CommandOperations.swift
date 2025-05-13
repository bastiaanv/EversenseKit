//
//  CommandOperations.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

enum FlashMemory: UInt32 {
    case sensorFieldCurrentAddress = 0x00000408
    case sensorFieldCurrentRawAddress = 0x0000049D
    case batteryVoltageAddress = 0x00000404
    case batteryPercentageAddress = 0x00000406
    
    case hysteresisPercentageAddress = 0x00000093
    case hysteresisValueAddress = 0x00000094
    case hysteresisPredictivePercentageAddress = 0x00000095
    case hysteresisPredictiveValueAddress = 0x00000096
    
    case transmitterModelNumber = 0x00000006
    case transmitterSoftwareVersionAddress = 0x0000000A
    case transmitterSoftwareVersionExtAddress = 0x000000A2
    
    case mostRecentCalibrationDateAddress = 0x000008A3
    case mostRecentCalibrationTimeAddress = 0x000008A5
    case startDateOfCalibrationPhaseAddress = 0x000089D
    case startTimeOfCalibrationPhaseAddress = 0x0000089F
    
    case accelerometerValuesAddress = 0x0000042A
    case accelerometerTempAddress = 0x00000430
}

class CommandOperations {
    static func readFourByteSerialFlashRegister(memoryAddress: FlashMemory) -> Data {
        var data = Data([0x2E, UInt8(memoryAddress.rawValue), UInt8(memoryAddress.rawValue >> 8), UInt8(memoryAddress.rawValue >> 16)])
        let checksum = BinaryOperations.generateChecksumCRC16(data: data)
        data.append(BinaryOperations.dataFrom16Bits(value: checksum))
        
        return data
    }
    
    static func readTwoByteSerialFlashRegister(memoryAddress: FlashMemory) -> Data {
        var data = Data([0x2C, UInt8(memoryAddress.rawValue), UInt8(memoryAddress.rawValue >> 8), UInt8(memoryAddress.rawValue >> 16)])
        let checksum = BinaryOperations.generateChecksumCRC16(data: data)
        data.append(BinaryOperations.dataFrom16Bits(value: checksum))
        
        return data
    }
    
    static func readSingleByteSerialFlashRegister(memoryAddress: FlashMemory) -> Data {
        var data = Data([0x2A, UInt8(memoryAddress.rawValue), UInt8(memoryAddress.rawValue >> 8), UInt8(memoryAddress.rawValue >> 16)])
        let checksum = BinaryOperations.generateChecksumCRC16(data: data)
        data.append(BinaryOperations.dataFrom16Bits(value: checksum))
        
        return data
    }
}
