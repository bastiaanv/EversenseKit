enum MessageCoder {
    static func messageCodeForPredictiveAlertFlags(_ value: UInt8) -> TransmitterAlert? {
        switch value {
        case 1: return .predictiveLowAlarm
        case 4: return .predictiveHighAlarm
        default: return nil
        }
    }

    static func messageCodeForTransmitterStatusAlertFlags(_ value: UInt8) -> TransmitterAlert? {
        switch value {
        case 1: return .criticalFaultAlarm
        case 4: return .invalidSensorAlarm
        case 8: return .invalidClockAlarm
        case 32: return .vibrationCurrentAlarm
        case 64: return .sensorAgedOutAlarm
        case 128: return .sensorOnHoldAlarm
        default: return nil
        }
    }

    static func messageCodeForRateAlertFlags(_ value: UInt8) -> TransmitterAlert? {
        switch value {
        case 1: return .rateFallingAlarm
        case 2: return .rateRisingAlarm
        default: return nil
        }
    }

    static func messageCodeForTransmitterBatteryAlertFlags(_ value: UInt8) -> TransmitterAlert? {
        switch value {
        case 1: return .emptyBatteryAlarm
        case 2: return .veryLowBatteryAlarm
        case 4: return .lowBatteryAlarm
        case 8: return .batteryErrorAlarm
        default: return nil
        }
    }

    static func messageCodeForSensorReadAlertFlags(_ value: UInt8) -> TransmitterAlert? {
        switch value {
        case 1: return .seriouslyHighAlarm
        case 2: return .seriouslyLowAlarm
        case 4: return .highAmbientLightAlarm
        case 8: return .mepAlarm
        case 16: return .sensorTemperatureAlarm
        case 32: return .sensorLowTemperatureAlarm
        case 64: return .readerTemperatureAlarm
        case 128: return .mspAlarm
        default: return nil
        }
    }

    static func messageCodeForSensorReplacementFlags(_ value: UInt8) -> TransmitterAlert? {
        switch value {
        case 1: return .sensorRetiredAlarm
        case 2: return .sensorRetiringSoon1Alarm
        case 4: return .sensorRetiringSoon2Alarm
        case 8: return .sensorRetiringSoon3Alarm
        case 16: return .sensorRetiringSoon4Alarm
        case 32: return .sensorRetiringSoon5Alarm
        case 64: return .sensorRetiringSoon6Alarm
        case 128: return .sensorPrematureReplacementAlarm
        default: return nil
        }
    }

    static func messageCodeForSensorCalibrationFlags(_ value: UInt8) -> TransmitterAlert? {
        switch value {
        case 1: return .calibrationGracePeriodAlarm
        case 2: return .calibrationExpiredAlarm
        case 4: return .calibrationGracePeriodAlarm // "CalibrationRequiredAlarm" not in enum
        case 16: return .calibrationGracePeriodAlarm // "CalibrationFailedAlert" not in enum
        case 32: return .calibrationGracePeriodAlarm // "CalibrationSuspiciousAlert" not in enum
        case 64: return .calibrationGracePeriodAlarm // "CalibrationNowAlarm" not in enum
        case 128: return .calibrationGracePeriodAlarm // "CalibrationSuspicious2Alert" not in enum
        default: return nil
        }
    }

    static func messageCodeForSensorHardwareAndAlertFlags(_ value: UInt8) -> TransmitterAlert? {
        switch value {
        case 1: return .sensorErrorAlarm
        case 2: return .sensorAwolAlarm
        case 4: return .sensorStability
        case 8: return .edrAlarm0
        case 16: return .edrAlarm1
        case 32: return .edrAlarm2
        case 64: return .edrAlarm3
        case 128: return .edrAlarm4
        default: return nil
        }
    }

    static func messageCodeForTransmitterEOLAlertFlags(_ value: UInt8) -> TransmitterAlert? {
        switch value {
        case 1: return .transmitterEOL396
        case 2: return .transmitterEOL366
        case 4: return .transmitterEOL330
        case 8: return .transmitterEOL395
        default: return nil
        }
    }

    static func messageCodeForSensorReplacementFlags2(_ value: UInt8) -> TransmitterAlert? {
        switch value {
        case 1: return .sensorRetiringSoon7Alarm
        default: return nil
        }
    }

    static func messageCodeForCalibrationSwitchFlags(_ value: UInt8) -> TransmitterAlert? {
        switch value {
        case 1: return .oneCal
        case 2: return .twoCal
        default: return nil
        }
    }

    static func messageCodeForGlucoseLevelAlarmFlags(_ value: UInt8) -> TransmitterAlert? {
        switch value {
        case 1: return .lowGlucoseAlarm
        case 2: return .highGlucoseAlarm
        default: return nil
        }
    }

    static func messageCodeForGlucoseLevelAlertFlags(_ value: UInt8) -> TransmitterAlert? {
        switch value {
        case 1: return .lowGlucoseAlert
        case 2: return .highGlucoseAlert
        default: return nil
        }
    }
}
