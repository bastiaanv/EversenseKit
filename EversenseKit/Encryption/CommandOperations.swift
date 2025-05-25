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
    case minCalibrationThreshold = 0x00000912
    case maxCalibrationThreshold = 0x00000914
    
    case lowGlucoseTarget = 0x00001102
    case highGlucoseTarget = 0x00001104
    case highGlucoseAlarmEnabled = 0x00001029
    case highGlucoseAlarmThreshold = 0x0000110C
    case lowGlucoseAlarmThreshold = 0x0000110A
    case predictiveAlert = 0x00001020
    case predictiveFallingTime = 0x00001021
    case predictiveRisingTime = 0x00001022
    case predictiveLowAlert = 0x00001027
    case predictiveHighAlert = 0x00001028
    case rateAlert = 0x00001010
    case rateFallingAlert = 0x00001025
    case rateRisingAlert = 0x00001026
    case rateFallingThreshold = 0x00001011
    case rateRisingThreshold = 0x00001012
    
    case warmUpDuration = 0x00000016
    case clinicalMode = 0x00000B49
    case clinicalModeDuration = 0x00000098
    case appVersion = 0x00000B4B
    case vibrateMode = 0x000000902
    case sensorGlucoseSamplingInterval = 0x00000012
    case atccalCrcAddress = 0x0000048C
    
    case algorithmParameterFormatVersion = 0x00000480
    case communicationProtocolVersion = 0x0000000E
    case delayBLEDisconnectAlarm = 0x000008B2
    
    case mostRecentCalibrationDate = 0x000008A3
    case mostRecentCalibrationTime = 0x000008A5
    case startDateOfCalibrationPhase = 0x000089D
    case startTimeOfCalibrationPhase = 0x0000089F
    case transmitterOperationStartDate = 0x00000490
    case transmitterOperationStartTime = 0x0000049F
    case sensorInsertionDate = 0x00000890
    case sensorInsertionTime = 0x00000892
    case mostRecentGlucoseDate = 0x00000410
    case mostRecentGlucoseTime = 0x00000412
    case mostRecentGlucoseValue = 0x00000414
    
    case morningCalibrationTime = 0x00000898
    case eveningCalibrationTime = 0x0000089A
    
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
    
    case rawValue1 = 0x0000041A
    case rawValue2 = 0x0000041C
    case rawValue3 = 0x0000041E
    case rawValue4 = 0x00000420
    case rawValue5 = 0x00000422
    case rawValue6 = 0x00000424
    case rawValue7 = 0x00000426
    case rawValue8 = 0x00000428
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
    
    static func writeFourByteSerialFlashRegister(memoryAddress: FlashMemory, data: Data) -> Data {
        var data = Data([0x2F, UInt8(memoryAddress.rawValue), UInt8(memoryAddress.rawValue >> 8), UInt8(memoryAddress.rawValue >> 16), data[0], data[1], data[2], data[3]])
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
