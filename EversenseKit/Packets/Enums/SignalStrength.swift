//
//  SignalStrength.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

enum SignalStrength {
    case NoSignal
    case Poor
    case VeryLow
    case Low
    case Good
    case Excellent
    
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
}
