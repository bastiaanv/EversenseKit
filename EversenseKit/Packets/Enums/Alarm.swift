import LoopKit

enum AlarmType {
    case Critical
    case Warning
    case Info
}

public enum Alarm: UInt8, Codable {
    case CriticalFaultAlarm = 0
    case SensorRetiredAlarm = 1
    case EmptyBatteryAlarm = 2
    case SensorTemperatureAlarm = 3
    case SensorLowTemperatureAlarm = 4
    case ReaderTemperatureAlarm = 5
    case SensorAwolAlarm = 6
    case InvalidSensorAlarm = 8
    case CalibrationRequiredAlarm = 11
    case SeriouslyLowAlarm = 12
    case SeriouslyHighAlarm = 13
    case LowGlucoseAlarm = 14
    case HighGlucoseAlarm = 15
    case PredictiveLowAlarm = 18
    case PredictiveHighAlarm = 19
    case RateFallingAlarm = 20
    case RateRisingAlarm = 21
    case CalibrationGracePeriodAlarm = 22
    case CalibrationExpiredAlarm = 23
    case SensorRetiringSoon1Alarm = 24
    case SensorRetiringSoon3Alarm = 26
    case SensorRetiringSoon4Alarm = 27
    case SensorRetiringSoon5Alarm = 28
    case SensorRetiringSoon6Alarm = 29
    case SensorRetiringSoon7Alarm = 53
    case VeryLowBatteryAlarm = 31
    case InvalidClockAlarm = 33
    case SensorStability = 34
    case TransmitterDisconnected = 35
    case VibrationCurrentAlarm = 36
    case MSPAlarm = 45
    case CalibrationFailedAlert = 47
    case CalibrationSuspiciousAlert = 48
    case CalibrationNowAlarm = 49
    case TransmitterEOL396 = 50
    case TransmitterEOL366 = 51
    case BatteryErrorAlarm = 52
    case TransmitterEOL330 = 55
    case TransmitterEOL395 = 56
    case OneCal = 57
    case CalibrationSuspicious2Alert = 59
    case BatteryStatusAlarm = 60
    case SensorConnection = 62
    case EarlySensorRetirement = 64
    case GeneralGlucoseSuspended = 65
    case SensorGraceAlarm = 66
    case SensorSyncConfirmedAlarm = 67
    // Seen on the 365 each time the transmitter is put back on the arm (after charging or a patch change)
    case TransmitterReattached = 71
    // Custom error codes in Eversense app
//    case TxDockedAlert = 68
//    case TxUndockedAlert = 69
//    case TransmitterReconnected = 1001
//    case TransmitterKeepAliveNotReceived = 1002
//    case TransmitterGlucoseStale = 1003
//    case SystemTime = 1005
//    case IncompatibleTx = 1007
//    case SensorFile = 1008
//    case SensorRelink = 1009
//    case NewPasswordDetected = 1010
//    case BatteryOptimization = 1012
//    case WarmUpPhaseCompleteAlert = 1013
//    case ResetLogReport = 1014
//    case InValidTx = 1015
//    case RomeSensorLinkFail = 1016
//    case RomeSensorUnlinkable = 1017
//    case TxPairingError = 1018
//    case TxPairingErrorOnKeyInvalid = 1019
//    case TransmitterOrSensorConnectionLostDuringLinking = 1020
//    case PairingMetricsError = 1021
//    case SmfSyncFailed = 1022
//    case OtaUpgradeAvailable = 1023
//    case OtaUpgradeComplete = 1024
//    case OtaUpgradeError = 1025
//    case OtaAttemptRestart = 1026
//    case OtaUpgradeStatus = 1027
//    case PlannedMaintenanceAlert = 2001
//    case NoAlarmActive = 20000
//    case TransmitterKeepAliveNotReceived = 1002
//    case TransmitterGlucoseStale = 1003
//    case SystemTime = 1005
//    case IncompatibleTx = 1007
//    case SensorFile = 1008
//    case SensorRelink = 1009
//    case NewPasswordDetected = 1010
//    case BatteryOptimization = 1012
//    case WarmUpPhaseCompleteAlert = 1013
//    case ResetLogReport = 1014
//    case InValidTx = 1015
//    case RomeSensorLinkFail = 1016
//    case RomeSensorUnlinkable = 1017
//    case TxPairingError = 1018
//    case TxPairingErrorOnKeyInvalid = 1019
//    case TransmitterOrSensorConnectionLostDuringLinking = 1020
//    case PairingMetricsError = 1021
//    case SmfSyncFailed = 1022
//    case OtaUpgradeAvailable = 1023
//    case OtaUpgradeComplete = 1024
//    case OtaUpgradeError = 1025
//    case OtaAttemptRestart = 1026
//    case OtaUpgradeStatus = 1027
//    case PlannedMaintenanceAlert = 2001
//    case NoAlarmActive = 20000
    case TwoCal = 90
    case unknown = 255

    static let warningAlarms: [Alarm] = [.CalibrationNowAlarm, .CalibrationFailedAlert]
    static let criticalAlarms: [Alarm] = [
        .CalibrationRequiredAlarm,
        .CalibrationExpiredAlarm,
        .BatteryErrorAlarm,
        .ReaderTemperatureAlarm,
        .SensorTemperatureAlarm,
        .SensorLowTemperatureAlarm
    ]

    var alarm: Alert {
        let title = self.title
        let body = description ?? ""

        return Alert(
            identifier: Alert.Identifier(
                managerIdentifier: "EversenseKit",
                alertIdentifier: "com.bastiaanv.eversensekit.\(String(describing: self))"
            ),
            foregroundContent: Alert.Content(
                title: title,
                body: body,
                acknowledgeActionButtonLabel: String(localized: "OK", comment: "Acknowlegde alarm")
            ),
            backgroundContent: Alert.Content(
                title: title,
                body: body,
                acknowledgeActionButtonLabel: String(localized: "OK", comment: "Acknowlegde alarm")
            ),
            trigger: .immediate
        )
    }

    var type: AlarmType {
        switch self {
        case .BatteryStatusAlarm,
             .OneCal,
             .SensorRetiringSoon1Alarm,
             .SensorRetiringSoon3Alarm,
             .SensorRetiringSoon4Alarm,
             .SensorRetiringSoon5Alarm,
             .SensorRetiringSoon6Alarm,
             .SensorRetiringSoon7Alarm,
             .SensorSyncConfirmedAlarm,
             .TransmitterReattached,
             .TwoCal:
            return .Info

        case .CalibrationFailedAlert,
             .CalibrationSuspicious2Alert,
             .CalibrationSuspiciousAlert,
             .InvalidClockAlarm,
             .InvalidSensorAlarm,
             .PredictiveHighAlarm,
             .PredictiveLowAlarm,
             .RateFallingAlarm,
             .RateRisingAlarm,
             .TransmitterEOL330,
             .TransmitterEOL366,
             .TransmitterEOL395:
            return .Warning

        default:
            return .Critical
        }
    }

    var title: String {
        switch self {
        case .CriticalFaultAlarm:
            return String(localized: "Transmitter Error", comment: "title for CriticalFaultAlarm")
        case .SensorGraceAlarm,
             .SensorRetiredAlarm,
             .SensorRetiringSoon1Alarm,
             .SensorRetiringSoon3Alarm,
             .SensorRetiringSoon4Alarm,
             .SensorRetiringSoon5Alarm,
             .SensorRetiringSoon6Alarm,
             .SensorRetiringSoon7Alarm:
            return String(localized: "Sensor Replacement", comment: "title for SensorRetiredAlarm")
        case .EmptyBatteryAlarm:
            return String(localized: "Battery Empty", comment: "title for EmptyBatteryAlarm")
        case .SensorTemperatureAlarm:
            return String(localized: "High Sensor Temperature", comment: "title for SensorTemperatureAlarm")
        case .SensorLowTemperatureAlarm:
            return String(localized: "Low Sensor Temperature", comment: "title for SensorLowTemperatureAlarm")
        case .ReaderTemperatureAlarm:
            return String(localized: "High Transmitter Temperature", comment: "title for ReaderTemperatureAlarm")
        case .SensorAwolAlarm:
            return String(localized: "No Sensor Detected", comment: "title for SensorAwolAlarm")
        case .InvalidSensorAlarm:
            return String(localized: "New Sensor Detected", comment: "title for InvalidSensorAlarm")
        case .CalibrationRequiredAlarm:
            return String(localized: "Calibrate Now", comment: "title for CalibrationRequiredAlarm")
        case .SeriouslyLowAlarm:
            return String(localized: "Out of Range Low Glucose", comment: "title for SeriouslyLowAlarm")
        case .SeriouslyHighAlarm:
            return String(localized: "Out of Range High Glucose", comment: "title for SeriouslyHighAlarm")
        case .LowGlucoseAlarm:
            return String(localized: "Low Glucose", comment: "title for LowGlucoseAlarm")
        case .HighGlucoseAlarm:
            return String(localized: "High Glucose", comment: "title for HighGlucoseAlarm")
        case .PredictiveLowAlarm:
            return String(localized: "Predicted Low Glucose", comment: "title for PredictiveLowAlarm")
        case .PredictiveHighAlarm:
            return String(localized: "Predicted High Glucose", comment: "title for PredictiveHighAlarm")
        case .RateFallingAlarm:
            return String(localized: "Rate Falling", comment: "title for RateFallingAlarm")
        case .RateRisingAlarm:
            return String(localized: "Rate Rising", comment: "title for RateRisingAlarm")
        case .CalibrationGracePeriodAlarm:
            return String(localized: "Calibration Past Due", comment: "title for CalibrationGracePeriodAlarm")
        case .CalibrationExpiredAlarm:
            return String(localized: "Calibration Expired", comment: "title for CalibrationExpiredAlarm")
        case .VeryLowBatteryAlarm:
            return String(localized: "Low Battery", comment: "title for VeryLowBatteryAlarm")
        case .InvalidClockAlarm:
            return String(localized: "Invalid Transmitter Time", comment: "title for InvalidClockAlarm")
        case .TransmitterDisconnected:
            return String(localized: "Transmitter Disconnected", comment: "title for TransmitterDisconnected")
        case .VibrationCurrentAlarm:
            return String(localized: "Vibration Motor", comment: "title for VibrationCurrentAlarm")
        case .MSPAlarm:
            return String(localized: "Sensor Replacement", comment: "title for MSPAlarm")
        case .CalibrationFailedAlert:
            return String(localized: "Calibrate Again", comment: "title for CalibrationFailedAlert")
        case .CalibrationSuspiciousAlert:
            return String(localized: "New Calibration Needed", comment: "title for CalibrationSuspiciousAlert")
        case .CalibrationNowAlarm,
             .CalibrationSuspicious2Alert:
            return String(localized: "Calibrate Now", comment: "title for CalibrationNowAlarm")
        case .TransmitterEOL330,
             .TransmitterEOL366,
             .TransmitterEOL395,
             .TransmitterEOL396:
            return String(localized: "Transmitter Replacement", comment: "title for TransmitterEOL")
        case .BatteryErrorAlarm:
            return String(localized: "Battery Error", comment: "title for BatteryErrorAlarm")
        case .OneCal:
            return String(localized: "1 Weekly Calibration Phase", comment: "title for OneCal")
        case .TwoCal:
            return String(localized: "Daily dual calibration Phase", comment: "title for OneCal")
        case .BatteryStatusAlarm:
            return String(localized: "Battery Status", comment: "title for BatteryStatusAlarm")
        case .SensorConnection:
            return String(localized: "Sensor Connection", comment: "title for SensorConnection")
        case .EarlySensorRetirement:
            return String(localized: "Sensor Retirement Area", comment: "title for EarlySensorRetirement")
        case .GeneralGlucoseSuspended:
            return String(localized: "Glucose Suspend", comment: "title for GeneralGlucoseSuspended")
        case .SensorSyncConfirmedAlarm:
            return String(localized: "Sensor Sync Confirmed", comment: "title for SensorSyncConfirmedAlarm")
        case .TransmitterReattached:
            return String(localized: "Transmitter Reattached", comment: "title for TransmitterReattached")
        case .SensorStability:
            return String(localized: "Sensor Stability", comment: "title for unknown")
        case .unknown:
            return String(localized: "Unknown error", comment: "title for unknown")
        }
    }

    var description: String? {
        switch self {
        case .CriticalFaultAlarm:
            return String(
                localized:
                "Your transmitter has detected an error. Please contact Eversense Customer Support.",
                comment: "description for CriticalFaultAlarm"
            )
        case .EmptyBatteryAlarm:
            return String(
                localized:
                "Your transmitter's battery is empty. Please recharge transmitter now to resume sensor glucose display.",
                comment: "description for EmptyBatteryAlarm"
            )
        case .SensorTemperatureAlarm:
            return String(
                localized:
                "Your sensor's temperature is too high. Please go to a cooler place to resume receiving sensor glucose values. If the problem persists, contact Eversense Customer Support.",
                comment: "description for SensorTemperatureAlarm"
            )
        case .SensorLowTemperatureAlarm:
            return String(
                localized:
                "Your sensor's temperature is too low. Please go to a warmer place to resume receiving sensor glucose readings. If the problem persists, contact Eversense Customer Support.",
                comment: "description for SensorLowTemperatureAlarm"
            )
        case .ReaderTemperatureAlarm:
            return String(
                localized:
                "Your transmitter's temperature is too high. Go to a cooler area to resume receiving sensor glucose readings. If the problem persists, contact Eversense Customer Support.",
                comment: "description for ReaderTemperatureAlarm"
            )
        case .SensorAwolAlarm:
            return String(
                localized:
                "The connection between your sensor and transmitter is lost. No glucose data is available until the connection is restored.",
                comment: "description for SensorAwolAlarm"
            )
        case .InvalidSensorAlarm:
            return String(
                localized:
                "A new sensor has been detected. If you have a new sensor and/or transmitter, please link your sensor and transmitter.",
                comment: "description for InvalidSensorAlarm"
            )
        case .CalibrationRequiredAlarm,
             .CalibrationSuspicious2Alert:
            return String(
                localized:
                "Your calibration is due. Please perform a fingerstick blood glucose meter calibration now.",
                comment: "description for CalibrationRequiredAlarm"
            )
        case .SeriouslyLowAlarm:
            return String(
                localized:
                "Your sensor glucose value is too low. Please measure your glucose manually using your blood glucose meter.",
                comment: "description for SeriouslyLowAlarm"
            )
        case .SeriouslyHighAlarm:
            return String(
                localized:
                "Your sensor glucose value is too high. Please measure your glucose manually using your blood glucose meter.",
                comment: "description for SeriouslyHighAlarm"
            )
        case .CalibrationGracePeriodAlarm:
            return String(
                localized:
                "Your Transmitter is past due for Calibration. Sensor Glucose values will no longer be displayed.",
                comment: "description for CalibrationGracePeriodAlarm"
            )
        case .CalibrationExpiredAlarm:
            return String(
                localized:
                "A calibration has not been performed in 24 hours. Your system is now in re-initialization phase and you will have to perform 4 fingerstick calibration tests.",
                comment: "description for CalibrationExpiredAlarm"
            )
        case .InvalidClockAlarm:
            return String(
                localized:
                "Your transmitter has old or invalid date/time stamp.",
                comment: "description for InvalidClockAlarm"
            )
        case .VibrationCurrentAlarm:
            return String(
                localized:
                "Your transmitter has detected an issue with the vibration motor and can no longer provide vibe alerts. Please contact Eversense Customer Support for a replacement transmitter.",
                comment: "description for VibrationCurrentAlarm"
            )
        case .MSPAlarm:
            return String(
                localized:
                "Your sensor has passed day 365. Contact your health care provider to schedule a replacement.",
                comment: "description for MSPAlarm"
            )
        case .CalibrationFailedAlert:
            return String(
                localized:
                "Not enough data was collected after your calibration entry. Please enter a fingerstick blood glucose calibration now.",
                comment: "description for CalibrationFailedAlert"
            )
        case .CalibrationNowAlarm:
            return String(
                localized:
                "In 4 hours, your calibration will be past due and no glucose will be displayed. Please enter a fingerstick blood glucose calibration now.",
                comment: "description for CalibrationNowAlarm"
            )
        case .TransmitterEOL396:
            return String(
                localized:
                "Your transmitter is out of warranty and will no longer provide glucose values. Contact your distributor to order a new transmitter.",
                comment: "description for TransmitterEOL396"
            )
        case .TransmitterEOL330,
             .TransmitterEOL366,
             .TransmitterEOL395:
            return String(
                localized:
                "Your transmitter is out of warranty and will soon no longer provide glucose values. Contact your distributor to order a new transmitter.",
                comment: "description for TransmitterEOL"
            )
        case .BatteryErrorAlarm:
            return String(
                localized:
                "The system has detected a problem with your transmitter's battery. You can continue to use your system, but please contact Eversense Customer Support for a replacement transmitter.",
                comment: "description for BatteryErrorAlarm"
            )
        case .OneCal:
            return String(localized: "The system requires calibration once a week.", comment: "description for OneCal")
        case .BatteryStatusAlarm:
            return String(
                localized:
                "Your transmitter battery has approximately 24 hours of life remaining.",
                comment: "description for BatteryStatusAlarm"
            )
        case .SensorConnection:
            return String(
                localized:
                "The connection between your sensor and transmitter is not stable. Please position your transmitter for better signal strength.",
                comment: "description for SensorConnection"
            )
        case .GeneralGlucoseSuspended:
            return String(
                localized:
                "Use your BG meter to monitor your glucose. Contact Eversense Customer Support if the issue persists.",
                comment: "description for GeneralGlucoseSuspended"
            )
        case .SensorGraceAlarm:
            return String(
                localized:
                "Your sensor life has expired. Please contact your health care provider to schedule a replacement.",
                comment: "description for SensorGraceAlarm"
            )
        case .SensorSyncConfirmedAlarm:
            return String(
                localized:
                "Your transmitter has synced with your sensor.",
                comment: "description for SensorSyncConfirmedAlarm"
            )
        case .TransmitterReattached:
            return String(
                localized:
                "Your transmitter is back on and is reconnecting to your sensor. Glucose readings will resume in a few minutes.",
                comment: "description for TransmitterReattached"
            )
        default:
            return nil
        }
    }

    var dmsCode: UInt8 {
        switch self {
        case .LowGlucoseAlarm: return 0
        case .HighGlucoseAlarm: return 1
        // LOW_GLUCOSE_ALERT_ASSERTED -> return 2
        // HIGH_GLUCOSE_ALERT_ASSERTED -> return 3
        case .RateFallingAlarm: return 4
        case .RateRisingAlarm: return 5
        case .PredictiveLowAlarm: return 6
        case .PredictiveHighAlarm: return 7
        case .CalibrationNowAlarm: return 8
        case .CalibrationRequiredAlarm: return 9
        case .CalibrationGracePeriodAlarm: return 10
        case .CalibrationExpiredAlarm: return 11
        case .SeriouslyLowAlarm: return 12
        case .SeriouslyHighAlarm: return 13
        default: return 255
        }
    }
}
