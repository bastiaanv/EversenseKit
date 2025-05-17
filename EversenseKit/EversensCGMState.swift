//
//  EversensCGMState.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 15/05/2025.
//

import LoopKit

public struct EversensCGMState: RawRepresentable, Equatable {
    public typealias RawValue = CGMManager.RawStateValue
    
    public init?(rawValue: RawValue) {
        model = rawValue["model"] as? String
        version = rawValue["version"] as? String
        extVersion = rawValue["extVersion"] as? String
        mmaFeatures = rawValue["mmaFeatures"] as? UInt8 ?? 0
        batteryVoltage = rawValue["batteryVoltage"] as? Double ?? 0
        dayStartTime = rawValue["dayStartTime"] as? Date ?? Date.defaultDayStartTime
        nightStartTime = rawValue["nightStartTime"] as? Date ?? Date.defaultNightStartTime
        lastCalibration = rawValue["lastCalibration"] as? Date
        phaseStart = rawValue["phaseStart"] as? Date
        hysteresisPercentage = rawValue["hysteresisPercentage"] as? UInt8 ?? 0
        hysteresisValueInMgDl = rawValue["hysteresisValueInMgDl"] as? UInt8 ?? 0
    }
    
    public var rawValue: RawValue {
        var value: [String: Any] = [:]
        
        value["model"] = model
        value["version"] = version
        value["extVersion"] = extVersion
        value["mmaFeatures"] = mmaFeatures
        value["batteryVoltage"] = batteryVoltage
        value["dayStartTime"] = dayStartTime
        value["nightStartTime"] = nightStartTime
        value["lastCalibration"] = lastCalibration
        value["phaseStart"] = phaseStart
        value["hysteresisPercentage"] = hysteresisPercentage
        value["hysteresisValueInMgDl"] = hysteresisValueInMgDl
        
        return value
    }
    
    public var model: String?
    public var version: String?
    public var extVersion: String?
    
    public var mmaFeatures: UInt8
    public var batteryVoltage: Double
    
    public var dayStartTime: Date
    public var nightStartTime: Date
    
    public var lastCalibration: Date?
    public var phaseStart: Date?
    
    public var hysteresisPercentage: UInt8
    public var hysteresisValueInMgDl: UInt8
}
