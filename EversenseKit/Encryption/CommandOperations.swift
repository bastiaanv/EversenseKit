//
//  CommandOperations.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

enum FlashMemory: UInt32 {
    case sensorFieldCurrent = 0x00000408
    case sensorFieldCurrentRaw = 0x0000049D
    case batteryVoltage = 0x00000404
    case batteryPercentage = 0x00000406
    
    case hysteresisPercentage = 0x00000093
    case hysteresisValue = 0x00000094
    case hysteresisPredictivePercentage = 0x00000095
    case hysteresisPredictiveValue = 0x00000096
    
    case transmitterModelNumber = 0x00000006
    case transmitterSoftwareVersion = 0x0000000A
    case transmitterSoftwareVersionExt = 0x000000A2
    
    case isOneCalPhase = 0x00000496
    case calibrationsMadeInThisPhase = 0x000008A1
    case currentCalibrationPhase = 0x0000089C
    
    case algorithmParameterFormatVersion = 0x00000480
    case communicationProtocolVersion = 0x0000000E
    
    case mostRecentCalibrationDate = 0x000008A3
    case mostRecentCalibrationTime = 0x000008A5
    case startDateOfCalibrationPhase = 0x000089D
    case startTimeOfCalibrationPhase = 0x0000089F
    case transmitterOperationStartDate = 0x00000490
    case transmitterOperationStartTime = 0x0000049F
    
    case accelerometerValues = 0x0000042A
    case accelerometerTemp = 0x00000430
    
    case linkedSensorId = 0x0000088C
    case unlinkedSensorId = 0x00000416
    
    case mmaFeatures = 0x00000137
    case dayStartTime = 0x00001110
    case nightStartTime = 0x00001112
    case lowGlucoseAlarmRepeatIntervalDayTime = 0x00001032
    case highGlucoseAlarmRepeatIntervalDayTime = 0x00001033
    case lowGlucoseAlarmRepeatIntervalNightTime = 0x0000110E
    case highGlucoseAlarmRepeatIntervalNightTime = 0x0000110F
    
    case mepSavedValue = 0x000000B3
    case mepSavedRefChannelMetric = 0x000000B7
    case mepSavedDriftMetric = 0x000000BB
    case mepSavedLowRefMetric = 0x000000BF
    case mepSavedSpike = 0x000000C3
    case eep24MSP = 0x00000A20
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
    
    static func writeTwoByteSerialFlashRegister(memoryAddress: FlashMemory, data: Data) -> Data {
        var data = Data([0x2D, UInt8(memoryAddress.rawValue), UInt8(memoryAddress.rawValue >> 8), UInt8(memoryAddress.rawValue >> 16), data[0], data[1]])
        let checksum = BinaryOperations.generateChecksumCRC16(data: data)
        data.append(BinaryOperations.dataFrom16Bits(value: checksum))
        
        return data
    }
}
