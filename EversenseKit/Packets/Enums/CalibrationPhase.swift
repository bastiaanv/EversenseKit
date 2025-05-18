//
//  CalibrationPhase.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 17/05/2025.
//

public enum CalibrationPhase: UInt8 {
    case UNKNOWN = 0
    case WARM_UP = 1
    case INITIALIZATION = 2
    case DAILY_CALIBRATION = 3
    case SUSPICIOUS = 4
    case DROPOUT = 5
    case DEBUG = 6
    case UNDERTERMINED = 7
}
