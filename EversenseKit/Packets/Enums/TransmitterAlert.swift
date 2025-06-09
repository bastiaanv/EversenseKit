enum TransmitterAlert: UInt8 {
    case criticalFaultAlarm = 0
    case sensorRetiredAlarm = 1
    case emptyBatteryAlarm = 2
    case sensorTemperatureAlarm = 3
    case sensorLowTemperatureAlarm = 4
    case readerTemperatureAlarm = 5
    case sensorAwolAlarm = 6
    case sensorErrorAlarm = 7
    case invalidSensorAlarm = 8
    case highAmbientLightAlarm = 9
    case reserved1 = 10
    case seriouslyLowAlarm = 12
    case seriouslyHighAlarm = 13
    case lowGlucoseAlarm = 14
    case highGlucoseAlarm = 15
    case lowGlucoseAlert = 16
    case highGlucoseAlert = 17
    case predictiveLowAlarm = 18
    case predictiveHighAlarm = 19
    case rateFallingAlarm = 20
    case rateRisingAlarm = 21
    case calibrationGracePeriodAlarm = 22
    case calibrationExpiredAlarm = 23
    case sensorRetiringSoon1Alarm = 24
    case sensorRetiringSoon2Alarm = 25
    case sensorRetiringSoon3Alarm = 26
    case sensorRetiringSoon4Alarm = 27
    case sensorRetiringSoon5Alarm = 28
    case sensorRetiringSoon6Alarm = 29
    case sensorPrematureReplacementAlarm = 30
    case veryLowBatteryAlarm = 31
    case lowBatteryAlarm = 32
    case invalidClockAlarm = 33
    case sensorStability = 34
    case transmitterDisconnected = 35
    case vibrationCurrentAlarm = 36
    case sensorAgedOutAlarm = 37
    case sensorOnHoldAlarm = 38
    case mepAlarm = 39
    case edrAlarm0 = 40
    case edrAlarm1 = 41
    case edrAlarm2 = 42
    case edrAlarm3 = 43
    case edrAlarm4 = 44
    case mspAlarm = 45
    case reserved2 = 46
    case transmitterEOL396 = 50
    case transmitterEOL366 = 51
    case batteryErrorAlarm = 52
    case sensorRetiringSoon7Alarm = 53
    case reserved3 = 54
    case transmitterEOL330 = 55
    case transmitterEOL395 = 56
    case oneCal = 57
    case twoCal = 58
    case transmitterReconnected = 60
    case appReserved1 = 63
    case systemTime = 64
    case appReserved2 = 65
    case incompatibleTx = 66
    case sensorFile = 67
    case sensorRelink = 68
    case newPasswordDetected = 69
    case batteryOptimization = 70
    case noAlarmActive = 71
    case numberOfMessages = 72

    var canBlindGlucose: Bool {
        switch self {
        case .highGlucoseAlarm,
             .highGlucoseAlert,
             .lowGlucoseAlarm,
             .lowGlucoseAlert,
             .predictiveHighAlarm,
             .predictiveLowAlarm,
             .rateFallingAlarm,
             .rateRisingAlarm:
            return true
        default:
            return false
        }
    }

    var title: String {
        switch self {
        case .criticalFaultAlarm:
            return "Critical Fault"
        case .sensorRetiredAlarm:
            return "Sensor Retired"
        case .emptyBatteryAlarm:
            return "Empty Battery"
        case .sensorTemperatureAlarm:
            return "Sensor High Temperature"
        case .sensorLowTemperatureAlarm:
            return "Sensor Low Temperature"
        case .readerTemperatureAlarm:
            return "Transmitter High Temperature"
        case .sensorAwolAlarm:
            return "No Sensor Detected"
        case .sensorErrorAlarm:
            return "Sensor Hardware Error"
        case .invalidSensorAlarm:
            return "Invalid Sensor"
        case .highAmbientLightAlarm:
            return "High Ambient Light"
        case .reserved1:
            return "Reserved 1"
        case .seriouslyLowAlarm:
            return "Seriously Low Glucose"
        case .seriouslyHighAlarm:
            return "Seriously High Glucose"
        case .lowGlucoseAlarm:
            return "Low Glucose"
        case .highGlucoseAlarm:
            return "High Glucose"
        case .lowGlucoseAlert:
            return "Low Glucose Alert"
        case .highGlucoseAlert:
            return "High Glucose Alert"
        case .predictiveLowAlarm:
            return "Predicted Low Glucose"
        case .predictiveHighAlarm:
            return "Predicted High Glucose"
        case .rateFallingAlarm:
            return "Rate Falling"
        case .rateRisingAlarm:
            return "Rate Rising"
        case .calibrationGracePeriodAlarm:
            return "Calibration Grace Period"
        case .calibrationExpiredAlarm:
            return "Calibration Expired"
        case .sensorRetiringSoon1Alarm:
            return "Sensor Retiring Soon 1"
        case .sensorRetiringSoon2Alarm:
            return "Sensor Retiring Soon 2"
        case .sensorRetiringSoon3Alarm:
            return "Sensor Retiring Soon 3"
        case .sensorRetiringSoon4Alarm:
            return "Sensor Retiring Soon 4"
        case .sensorRetiringSoon5Alarm:
            return "Sensor Retiring Soon 5"
        case .sensorRetiringSoon6Alarm:
            return "Sensor Retiring Soon 6"
        case .sensorPrematureReplacementAlarm:
            return "Sensor Premature Replacement"
        case .veryLowBatteryAlarm:
            return "Very Low Battery"
        case .lowBatteryAlarm:
            return "Low Battery"
        case .invalidClockAlarm:
            return "Invalid Clock"
        case .sensorStability:
            return "Sensor Instability"
        case .transmitterDisconnected:
            return "Transmitter Disconnected"
        case .vibrationCurrentAlarm:
            return "Vibration Motor"
        case .sensorAgedOutAlarm:
            return "Sensor Aged Out"
        case .sensorOnHoldAlarm:
            return "Sensor Suspend"
        case .mepAlarm:
            return "MEP Alarm"
        case .edrAlarm0:
            return "EDR Alarm 0"
        case .edrAlarm1:
            return "EDR Alarm 1"
        case .edrAlarm2:
            return "EDR Alarm 2"
        case .edrAlarm3:
            return "EDR Alarm 3"
        case .edrAlarm4:
            return "EDR Alarm 4"
        case .mspAlarm:
            return "MSP Alarm"
        case .reserved2:
            return "Reserved 2"
        case .transmitterEOL396:
            return "Transmitter EOL 396"
        case .transmitterEOL366:
            return "Transmitter EOL 366"
        case .batteryErrorAlarm:
            return "Battery Error"
        case .sensorRetiringSoon7Alarm:
            return "Sensor Retiring Soon 7"
        case .reserved3:
            return "Reserved 3"
        case .transmitterEOL330:
            return "Transmitter EOL 330"
        case .transmitterEOL395:
            return "Transmitter EOL 395"
        case .oneCal:
            return "1 Daily Calibration Phase"
        case .twoCal:
            return "2 Daily Calibrations Phase"
        case .transmitterReconnected:
            return "Transmitter Reconnected"
        case .appReserved1:
            return "App Reserved 1"
        case .systemTime:
            return "System Time"
        case .appReserved2:
            return "App Reserved 2"
        case .incompatibleTx:
            return "Incompatible Transmitter"
        case .sensorFile:
            return "Sensor File"
        case .sensorRelink:
            return "Sensor Re-link"
        case .newPasswordDetected:
            return "New Password Detected"
        case .batteryOptimization:
            return "App Performance"
        case .noAlarmActive:
            return "No Alarm Active"
        case .numberOfMessages:
            return "Number of Messages"
        }
    }
}
