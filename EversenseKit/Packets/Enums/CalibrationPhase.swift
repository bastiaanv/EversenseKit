public enum CalibrationPhase: UInt8 {
    case WARM_UP = 1
    case INITIALIZATION = 3
    case DAILY_CALIBRATION = 2
    case SUSPICIOUS = 4
    case UNKNOWN = 5
    case DEBUG = 6
    case DROPOUT = 7

    func getTitle(isOneCal: Bool, oneCalExists: Bool) -> String {
        switch self {
        case .WARM_UP:
            return LocalizedString("Warming up", comment: "phase warming up")
        case .DAILY_CALIBRATION:
            if oneCalExists {
                if isOneCal {
                    return LocalizedString("Daily single calibration", comment: "phase daily calibration")
                } else {
                    return LocalizedString("Daily dual calibration", comment: "phase daily calibration")
                }
            }

            return LocalizedString("Daily calibration", comment: "phase daily calibration")
        case .INITIALIZATION:
            return LocalizedString("Initialization", comment: "phase init")
        case .SUSPICIOUS:
            return LocalizedString("Suspicious fingerstick", comment: "phase suspicious")
        case .DROPOUT:
            return LocalizedString("Dropout", comment: "phase dropout")
        case .DEBUG:
            return LocalizedString("Debug/test", comment: "phase debug")
        default:
            return LocalizedString("Unknown", comment: "phase unknown")
        }
    }
}
