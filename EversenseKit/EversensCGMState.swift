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
        unLinkedSensorId = rawValue["unLinkedSensorId"] as? String
        mmaFeatures = rawValue["mmaFeatures"] as? UInt8 ?? 0
        vibrateMode = rawValue["vibrateMode"] as? Bool
        batteryVoltage = rawValue["batteryVoltage"] as? Double ?? 0
        algorithmFormatVersion = rawValue["algorithmFormatVersion"] as? UInt16 ?? 0
        dayStartTime = rawValue["dayStartTime"] as? Date ?? Date.defaultDayStartTime
        nightStartTime = rawValue["nightStartTime"] as? Date ?? Date.defaultNightStartTime
        warmingUpDuration = rawValue["warmingUpDuration"] as? TimeInterval ?? .hours(24)
        sensorSamplingInterval = rawValue["sensorSamplingInterval"] as? TimeInterval
        delayBLEDisconnectionAlarm = rawValue["delayBLEDisconnectionAlarm"] as? TimeInterval ?? .seconds(180)
        isDelayBLEDisconnectionAlarmSupported = rawValue["isDelayBLEDisconnectionAlarmSupported"] as? Bool ?? false
        transmitterStart = rawValue["transmitterStart"] as? Date
        lastCalibration = rawValue["lastCalibration"] as? Date
        calibrationMinThreshold = rawValue["calibrationMinThreshold"] as? UInt16 ?? 0
        calibrationMaxThreshold = rawValue["calibrationMaxThreshold"] as? UInt16 ?? 0
        phaseStart = rawValue["phaseStart"] as? Date
        sensorInsertion = rawValue["sensorInsertion"] as? Date
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
        isClinicalMode = rawValue["isClinicalMode"] as? Bool ?? false
        clinicalModeDuration = rawValue["clinicalModeDuration"] as? TimeInterval
        lowGlucoseTarget = rawValue["lowGlucoseTarget"] as? UInt16 ?? 0
        highGlucoseTarget = rawValue["highGlucoseTarget"] as? UInt16 ?? 0
        
        if let rawCalibrationPhase = rawValue["calibrationPhase"] as? CalibrationPhase.RawValue {
            calibrationPhase = CalibrationPhase(rawValue: rawCalibrationPhase) ?? .UNKNOWN
        } else {
            calibrationPhase = .UNKNOWN
        }
        
        if let rawMorningCalibration = rawValue["morningCalibrationTime"] as? Data {
            morningCalibrationTime = DateComponents(timeZone: GMTTimezone, hour: Int(rawMorningCalibration[0]), minute: Int(rawMorningCalibration[1]), second: 0)
        } else {
            morningCalibrationTime = DateComponents()
        }
        
        if let rawEveningCalibration = rawValue["eveningCalibrationTime"] as? Data {
            eveningCalibrationTime = DateComponents(timeZone: GMTTimezone, hour: Int(rawEveningCalibration[0]), minute: Int(rawEveningCalibration[1]), second: 0)
        } else {
            eveningCalibrationTime = DateComponents()
        }
    }
    
    public var rawValue: RawValue {
        var value: [String: Any] = [:]
        
        value["model"] = model
        value["version"] = version
        value["extVersion"] = extVersion
        value["communicationProtocol"] = communicationProtocol
        value["sensorId"] = sensorId
        value["unLinkedSensorId"] = unLinkedSensorId
        value["mmaFeatures"] = mmaFeatures
        value["vibrateMode"] = vibrateMode
        value["batteryVoltage"] = batteryVoltage
        value["algorithmFormatVersion"] = algorithmFormatVersion
        value["transmitterStart"] = transmitterStart
        value["dayStartTime"] = dayStartTime
        value["nightStartTime"] = nightStartTime
        value["warmingUpDuration"] = warmingUpDuration
        value["sensorSamplingInterval"] = sensorSamplingInterval
        value["delayBLEDisconnectionAlarm"] = delayBLEDisconnectionAlarm
        value["isDelayBLEDisconnectionAlarmSupported"] = isDelayBLEDisconnectionAlarmSupported
        value["morningCalibrationTime"] = Data([UInt8(morningCalibrationTime.hour ?? 0), UInt8(morningCalibrationTime.minute ?? 0)])
        value["eveningCalibrationTime"] = Data([UInt8(eveningCalibrationTime.hour ?? 0), UInt8(eveningCalibrationTime.minute ?? 0)])
        value["lastCalibration"] = lastCalibration
        value["calibrationMinThreshold"] = calibrationMinThreshold
        value["calibrationMaxThreshold"] = calibrationMaxThreshold
        value["phaseStart"] = phaseStart
        value["sensorInsertion"] = sensorInsertion
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
        value["isClinicalMode"] = isClinicalMode
        value["clinicalModeDuration"] = clinicalModeDuration
        value["lowGlucoseTarget"] = lowGlucoseTarget
        value["highGlucoseTarget"] = highGlucoseTarget
        
        return value
    }
    
    public var model: String?
    public var version: String?
    public var extVersion: String?
    public var communicationProtocol: String?
    public var sensorId: String?
    public var unLinkedSensorId: String?
    
    public var mmaFeatures: UInt8
    public var batteryVoltage: Double
    public var algorithmFormatVersion: UInt16
    public var vibrateMode: Bool?
    
    var alarms: [TransmitterAlert]
    
    public var dayStartTime: Date
    public var nightStartTime: Date
    public var warmingUpDuration: TimeInterval
    public var sensorSamplingInterval: TimeInterval?
    public var delayBLEDisconnectionAlarm: TimeInterval
    public var isDelayBLEDisconnectionAlarmSupported: Bool
    public var morningCalibrationTime: DateComponents
    public var eveningCalibrationTime: DateComponents
    
    public var transmitterStart: Date?
    public var lastCalibration: Date?
    public var phaseStart: Date?
    public var sensorInsertion: Date?
    
    public var hysteresisPercentage: UInt8
    public var hysteresisValueInMgDl: UInt8
    public var predictiveHysteresisPercentage: UInt8
    public var predictiveHysteresisValueInMgDl: UInt8
    
    public var isOneCalibrationPhase: Bool
    public var calibrationPhase: CalibrationPhase
    public var calibrationCount: UInt16
    public var calibrationMinThreshold: UInt16
    public var calibrationMaxThreshold: UInt16
    
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
    
    public var isClinicalMode: Bool
    public var clinicalModeDuration: TimeInterval?
    
    public var lowGlucoseTarget: UInt16
    public var highGlucoseTarget: UInt16
    
    public var isUSXLorOUSXL2: Bool {
        !(mmaFeatures == 0 || mmaFeatures == 255 || mmaFeatures < 1)
    }
}
