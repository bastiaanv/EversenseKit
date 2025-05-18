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
        communicationProtocol = rawValue["communicationProtocol"] as? String
        sensorId = rawValue["sensorId"] as? String
        mmaFeatures = rawValue["mmaFeatures"] as? UInt8 ?? 0
        batteryVoltage = rawValue["batteryVoltage"] as? Double ?? 0
        algorithmFormatVersion = rawValue["algorithmFormatVersion"] as? UInt16 ?? 0
        dayStartTime = rawValue["dayStartTime"] as? Date ?? Date.defaultDayStartTime
        nightStartTime = rawValue["nightStartTime"] as? Date ?? Date.defaultNightStartTime
        transmitterStart = rawValue["transmitterStart"] as? Date
        lastCalibration = rawValue["lastCalibration"] as? Date
        phaseStart = rawValue["phaseStart"] as? Date
        hysteresisPercentage = rawValue["hysteresisPercentage"] as? UInt8 ?? 0
        hysteresisValueInMgDl = rawValue["hysteresisValueInMgDl"] as? UInt8 ?? 0
        isOneCalibrationPhase = rawValue["isOneCalibrationPhase"] as? Bool ?? false
        calibrationCount = rawValue["calibrationCount"] as? UInt16 ?? 0
        mepValue = rawValue["mepValue"] as? Float ?? 0
        mepRefChannelMetric = rawValue["mepRefChannelMetric"] as? Float ?? 0
        mepDriftMetric = rawValue["mepDriftMetric"] as? Float ?? 0
        mepLowRefMetric = rawValue["mepLowRefMetric"] as? Float ?? 0
        mepSpike = rawValue["mepSpike"] as? Float ?? 0
        eep24MSP = rawValue["eep24MSP"] as? Float ?? 0
        lowGlucoseAlarmRepeatingDayTime = rawValue["lowGlucoseAlarmRepeatingDayTime"] as? UInt8 ?? 0
        highGlucoseAlarmRepeatingDayTime = rawValue["highGlucoseAlarmRepeatingDayTime"] as? UInt8 ?? 0
        lowGlucoseAlarmRepeatingNightTime = rawValue["lowGlucoseAlarmRepeatingNightTime"] as? UInt8 ?? 0
        highGlucoseAlarmRepeatingNightTime = rawValue["highGlucoseAlarmRepeatingNightTime"] as? UInt8 ?? 0
        
        if let rawCalibrationPhase = rawValue["calibrationPhase"] as? CalibrationPhase.RawValue {
            calibrationPhase = CalibrationPhase(rawValue: rawCalibrationPhase) ?? .UNKNOWN
        } else {
            calibrationPhase = .UNKNOWN
        }
    }
    
    public var rawValue: RawValue {
        var value: [String: Any] = [:]
        
        value["model"] = model
        value["version"] = version
        value["extVersion"] = extVersion
        value["communicationProtocol"] = communicationProtocol
        value["sensorId"] = sensorId
        value["mmaFeatures"] = mmaFeatures
        value["batteryVoltage"] = batteryVoltage
        value["algorithmFormatVersion"] = algorithmFormatVersion
        value["transmitterStart"] = transmitterStart
        value["dayStartTime"] = dayStartTime
        value["nightStartTime"] = nightStartTime
        value["lastCalibration"] = lastCalibration
        value["phaseStart"] = phaseStart
        value["hysteresisPercentage"] = hysteresisPercentage
        value["hysteresisValueInMgDl"] = hysteresisValueInMgDl
        value["isOneCalibrationPhase"] = isOneCalibrationPhase
        value["calibrationCount"] = calibrationCount
        value["calibrationPhase"] = calibrationPhase.rawValue
        value["mepValue"] = mepValue
        value["mepRefChannelMetric"] = mepRefChannelMetric
        value["mepDriftMetric"] = mepDriftMetric
        value["mepLowRefMetric"] = mepLowRefMetric
        value["mepSpike"] = mepSpike
        value["eep24MSP"] = eep24MSP
        value["lowGlucoseAlarmRepeatingDayTime"] = lowGlucoseAlarmRepeatingDayTime
        value["highGlucoseAlarmRepeatingDayTime"] = highGlucoseAlarmRepeatingDayTime
        value["lowGlucoseAlarmRepeatingNightTime"] = lowGlucoseAlarmRepeatingNightTime
        value["highGlucoseAlarmRepeatingNightTime"] = highGlucoseAlarmRepeatingNightTime
        
        return value
    }
    
    public var model: String?
    public var version: String?
    public var extVersion: String?
    public var communicationProtocol: String?
    public var sensorId: String?
    
    public var mmaFeatures: UInt8
    public var batteryVoltage: Double
    public var algorithmFormatVersion: UInt16
    
    public var dayStartTime: Date
    public var nightStartTime: Date
    
    public var transmitterStart: Date?
    public var lastCalibration: Date?
    public var phaseStart: Date?
    
    public var hysteresisPercentage: UInt8
    public var hysteresisValueInMgDl: UInt8
    public var predictiveHysteresisPercentage: UInt8
    public var predictiveHysteresisValueInMgDl: UInt8
    
    public var isOneCalibrationPhase: Bool
    public var calibrationPhase: CalibrationPhase
    public var calibrationCount: UInt16
    
    public var mepValue: Float
    public var mepRefChannelMetric: Float
    public var mepDriftMetric: Float
    public var mepLowRefMetric: Float
    public var mepSpike: Float
    public var eep24MSP: Float
    
    public var lowGlucoseAlarmRepeatingDayTime: UInt8
    public var highGlucoseAlarmRepeatingDayTime: UInt8
    public var lowGlucoseAlarmRepeatingNightTime: UInt8
    public var highGlucoseAlarmRepeatingNightTime: UInt8
    
    public var isUSXLorOUSXL2: Bool {
        !(mmaFeatures == 0 || mmaFeatures == 255 || mmaFeatures < 1)
    }
}
