public enum SignalStrength: UInt8 {
    case NoSignal = 0
    case Poor = 1
    case VeryLow = 2
    case Low = 3
    case Good = 4
    case Excellent = 5

    var rawThreshold: UInt16 {
        switch self {
        case .NoSignal:
            return 0
        case .Poor:
            return 350
        case .VeryLow:
            return 500
        case .Low:
            return 800
        case .Good:
            return 1300
        case .Excellent:
            return 1600
        }
    }

    var threshold: UInt16 {
        switch self {
        case .NoSignal:
            return 0
        case .Poor:
            return 350
        case .VeryLow:
            return 395
        case .Low:
            return 494
        case .Good:
            return 705
        case .Excellent:
            return 903
        }
    }

    var title: String {
        switch self {
        case .NoSignal:
            return LocalizedString("No signal", comment: "signalStrength no signal")
        case .Poor:
            return LocalizedString("Poor", comment: "signalStrength poor")
        case .VeryLow:
            return LocalizedString("Very low", comment: "signalStrength very low")
        case .Low:
            return LocalizedString("Low", comment: "signalStrength low")
        case .Good:
            return LocalizedString("Good", comment: "signalStrength good")
        case .Excellent:
            return LocalizedString("Excellent", comment: "signalStrength excellent")
        }
    }
}
