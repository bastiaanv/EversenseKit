import LoopKit

public struct EversenseCGMState: RawRepresentable, Equatable {
    public typealias RawValue = CGMManager.RawStateValue

    public init?(rawValue: RawValue) {
        alarms = []
        bleNameString = rawValue["bleNameString"] as? String ?? ""
        bleUUIDString = rawValue["bleUUIDString"] as? String
        isOnboarded = rawValue["isOnboarded"] as? Bool ?? false
        isSyncing = rawValue["isSyncing"] as? Bool ?? false
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
        oneCalibrationPhaseExists = rawValue["oneCalibrationPhaseExists"] as? Bool ?? false
        isOneCalibrationPhase = rawValue["isOneCalibrationPhase"] as? Bool ?? false
        calibrationCount = rawValue["calibrationCount"] as? UInt16 ?? 0
        lowGlucoseAlarmRepeatingDayTime = rawValue["lowGlucoseAlarmRepeatingDayTime"] as? UInt8 ?? 0
        highGlucoseAlarmRepeatingDayTime = rawValue["highGlucoseAlarmRepeatingDayTime"] as? UInt8 ?? 0
        lowGlucoseAlarmRepeatingNightTime = rawValue["lowGlucoseAlarmRepeatingNightTime"] as? UInt8 ?? 0
        highGlucoseAlarmRepeatingNightTime = rawValue["highGlucoseAlarmRepeatingNightTime"] as? UInt8 ?? 0
        isClinicalMode = rawValue["isClinicalMode"] as? Bool ?? false
        clinicalModeDuration = rawValue["clinicalModeDuration"] as? TimeInterval
        lowGlucoseTargetInMgDl = rawValue["lowGlucoseTargetInMgDl"] as? UInt16 ?? 0
        highGlucoseTargetInMgDl = rawValue["highGlucoseTargetInMgDl"] as? UInt16 ?? 0
        isGlucoseAlarmEnabled = rawValue["isGlucoseAlarmEnabled"] as? Bool ?? false
        lowGlucoseAlarmInMgDl = rawValue["lowGlucoseAlarmInMgDl"] as? UInt16 ?? 0
        highGlucoseAlarmInMgDl = rawValue["highGlucoseAlarmInMgDl"] as? UInt16 ?? 0
        isPredictionEnabled = rawValue["isPredictionEnabled"] as? Bool ?? false
        isPredictionLowEnabled = rawValue["isPredictionLowEnabled"] as? Bool ?? false
        isPredictionHighEnabled = rawValue["isPredictionHighEnabled"] as? Bool ?? false
        predictionRisingInterval = rawValue["predictionRisingInterval"] as? TimeInterval
        predictionFallingInterval = rawValue["predictionFallingInterval"] as? TimeInterval
        isRateEnabled = rawValue["isRateEnabled"] as? Bool ?? false
        isFallingRateEnabled = rawValue["isRateEnabled"] as? Bool ?? false
        isRisingRateEnabled = rawValue["isRisingRateEnabled"] as? Bool ?? false
        rateFallingThreshold = rawValue["rateFallingThreshold"] as? Double
        rateRisingThreshold = rawValue["rateRisingThreshold"] as? Double
        signalStrengthRaw = rawValue["signalStrengthRaw"] as? UInt16 ?? 0
        tempThresholdWarning = rawValue["tempThresholdWarning"] as? UInt8 ?? 68
        tempThresholdModeChange = rawValue["tempThresholdModeChange"] as? UInt8 ?? 52
        recentGlucoseInMgDl = rawValue["recentGlucoseInMgDl"] as? UInt16
        recentGlucoseDateTime = rawValue["recentGlucoseDateTime"] as? Date

        username = rawValue["username"] as? String
        password = rawValue["password"] as? String
        accessToken = rawValue["accessToken"] as? String
        accessTokenExpiration = rawValue["accessTokenExpiration"] as? Date
        fleetKey = rawValue["fleetKey"] as? String

        if let rawCalibrationPhase = rawValue["calibrationPhase"] as? CalibrationPhase.RawValue {
            calibrationPhase = CalibrationPhase(rawValue: rawCalibrationPhase) ?? .UNKNOWN
        } else {
            calibrationPhase = .UNKNOWN
        }

        if let rawMorningCalibration = rawValue["morningCalibrationTime"] as? Data {
            morningCalibrationTime = DateComponents(
                timeZone: GMTTimezone,
                hour: Int(rawMorningCalibration[0]),
                minute: Int(rawMorningCalibration[1]),
                second: 0
            )
        } else {
            morningCalibrationTime = DateComponents()
        }

        if let rawEveningCalibration = rawValue["eveningCalibrationTime"] as? Data {
            eveningCalibrationTime = DateComponents(
                timeZone: GMTTimezone,
                hour: Int(rawEveningCalibration[0]),
                minute: Int(rawEveningCalibration[1]),
                second: 0
            )
        } else {
            eveningCalibrationTime = DateComponents()
        }

        if let rawSignalStrength = rawValue["signalStrength"] as? SignalStrength.RawValue {
            signalStrength = SignalStrength(rawValue: rawSignalStrength) ?? .NoSignal
        } else {
            signalStrength = .NoSignal
        }

        if let rawBatteryPercentage = rawValue["batteryPercentage"] as? BatteryLevel.RawValue {
            batteryPercentage = BatteryLevel(rawValue: rawBatteryPercentage) ?? .Percentage0
        } else {
            batteryPercentage = .Percentage0
        }

        if let rawRecentGlucoseTrend = rawValue["recentGlucoseTrend"] as? GlucoseTrend.RawValue {
            recentGlucoseTrend = GlucoseTrend(rawValue: rawRecentGlucoseTrend) ?? .flat
        } else {
            recentGlucoseTrend = .flat
        }

        if let rawSecurity = rawValue["security"] as? SecurityType.RawValue {
            security = SecurityType(rawValue: rawSecurity) ?? .none
        } else {
            security = .none
        }
    }

    public var rawValue: RawValue {
        var value: [String: Any] = [:]

        value["bleNameString"] = bleNameString
        value["bleUUIDString"] = bleUUIDString
        value["isOnboarded"] = isOnboarded
        value["isSyncing"] = isSyncing
        value["model"] = model
        value["version"] = version
        value["extVersion"] = extVersion
        value["communicationProtocol"] = communicationProtocol
        value["sensorId"] = sensorId
        value["unLinkedSensorId"] = unLinkedSensorId
        value["mmaFeatures"] = mmaFeatures
        value["vibrateMode"] = vibrateMode
        value["batteryPercentage"] = batteryPercentage.rawValue
        value["signalStrength"] = signalStrength.rawValue
        value["signalStrengthRaw"] = signalStrengthRaw
        value["batteryVoltage"] = batteryVoltage
        value["algorithmFormatVersion"] = algorithmFormatVersion
        value["transmitterStart"] = transmitterStart
        value["dayStartTime"] = dayStartTime
        value["nightStartTime"] = nightStartTime
        value["warmingUpDuration"] = warmingUpDuration
        value["sensorSamplingInterval"] = sensorSamplingInterval
        value["delayBLEDisconnectionAlarm"] = delayBLEDisconnectionAlarm
        value["isDelayBLEDisconnectionAlarmSupported"] = isDelayBLEDisconnectionAlarmSupported
        value["morningCalibrationTime"] =
            Data([UInt8(morningCalibrationTime.hour ?? 0), UInt8(morningCalibrationTime.minute ?? 0)])
        value["eveningCalibrationTime"] =
            Data([UInt8(eveningCalibrationTime.hour ?? 0), UInt8(eveningCalibrationTime.minute ?? 0)])
        value["lastCalibration"] = lastCalibration
        value["calibrationMinThreshold"] = calibrationMinThreshold
        value["calibrationMaxThreshold"] = calibrationMaxThreshold
        value["phaseStart"] = phaseStart
        value["sensorInsertion"] = sensorInsertion
        value["oneCalibrationPhaseExists"] = oneCalibrationPhaseExists
        value["isOneCalibrationPhase"] = isOneCalibrationPhase
        value["calibrationCount"] = calibrationCount
        value["calibrationPhase"] = calibrationPhase.rawValue
        value["lowGlucoseAlarmRepeatingDayTime"] = lowGlucoseAlarmRepeatingDayTime
        value["highGlucoseAlarmRepeatingDayTime"] = highGlucoseAlarmRepeatingDayTime
        value["lowGlucoseAlarmRepeatingNightTime"] = lowGlucoseAlarmRepeatingNightTime
        value["highGlucoseAlarmRepeatingNightTime"] = highGlucoseAlarmRepeatingNightTime
        value["isClinicalMode"] = isClinicalMode
        value["clinicalModeDuration"] = clinicalModeDuration
        value["lowGlucoseTargetInMgDl"] = lowGlucoseTargetInMgDl
        value["highGlucoseTargetInMgDl"] = highGlucoseTargetInMgDl
        value["isGlucoseAlarmEnabled"] = isGlucoseAlarmEnabled
        value["lowGlucoseAlarmInMgDl"] = lowGlucoseAlarmInMgDl
        value["highGlucoseAlarmInMgDl"] = highGlucoseAlarmInMgDl
        value["isPredictionEnabled"] = isPredictionEnabled
        value["isPredictionLowEnabled"] = isPredictionLowEnabled
        value["isPredictionHighEnabled"] = isPredictionHighEnabled
        value["predictionRisingInterval"] = predictionRisingInterval
        value["predictionFallingInterval"] = predictionFallingInterval
        value["isRateEnabled"] = isRateEnabled
        value["isFallingRateEnabled"] = isFallingRateEnabled
        value["isRisingRateEnabled"] = isRisingRateEnabled
        value["rateFallingThreshold"] = rateFallingThreshold
        value["rateRisingThreshold"] = rateRisingThreshold
        value["tempThresholdWarning"] = tempThresholdWarning
        value["tempThresholdModeChange"] = tempThresholdModeChange
        value["recentGlucoseInMgDl"] = recentGlucoseInMgDl
        value["recentGlucoseDateTime"] = recentGlucoseDateTime
        value["recentGlucoseTrend"] = recentGlucoseTrend.rawValue
        value["security"] = security.rawValue
        value["username"] = username
        value["password"] = password
        value["accessToken"] = accessToken
        value["accessTokenExpiration"] = accessTokenExpiration
        value["fleetKey"] = fleetKey

        return value
    }

    public var bleUUIDString: String?
    public var bleNameString: String
    public var isOnboarded: Bool
    public var isSyncing: Bool
    public var model: String?
    public var version: String?
    public var extVersion: String?
    public var communicationProtocol: String?
    public var sensorId: String?
    public var unLinkedSensorId: String?

    public var mmaFeatures: UInt8
    public var batteryVoltage: Double
    public var batteryPercentage: BatteryLevel
    public var algorithmFormatVersion: UInt16
    public var vibrateMode: Bool?

    public var signalStrength: SignalStrength
    public var signalStrengthRaw: UInt16

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

    public var oneCalibrationPhaseExists: Bool
    public var isOneCalibrationPhase: Bool
    public var calibrationPhase: CalibrationPhase
    public var calibrationCount: UInt16
    public var calibrationMinThreshold: UInt16
    public var calibrationMaxThreshold: UInt16

    public var lowGlucoseAlarmRepeatingDayTime: UInt8
    public var highGlucoseAlarmRepeatingDayTime: UInt8
    public var lowGlucoseAlarmRepeatingNightTime: UInt8
    public var highGlucoseAlarmRepeatingNightTime: UInt8

    public var isClinicalMode: Bool
    public var clinicalModeDuration: TimeInterval?

    public var lowGlucoseTargetInMgDl: UInt16
    public var highGlucoseTargetInMgDl: UInt16
    public var isGlucoseAlarmEnabled: Bool
    public var lowGlucoseAlarmInMgDl: UInt16
    public var highGlucoseAlarmInMgDl: UInt16

    public var isPredictionEnabled: Bool
    public var isPredictionLowEnabled: Bool
    public var isPredictionHighEnabled: Bool
    public var predictionFallingInterval: TimeInterval?
    public var predictionRisingInterval: TimeInterval?

    public var isRateEnabled: Bool
    public var isFallingRateEnabled: Bool
    public var isRisingRateEnabled: Bool
    public var rateFallingThreshold: Double?
    public var rateRisingThreshold: Double?

    public var tempThresholdWarning: UInt8
    public var tempThresholdModeChange: UInt8

    public var recentGlucoseInMgDl: UInt16?
    public var recentGlucoseDateTime: Date?
    public var recentGlucoseTrend: GlucoseTrend

    // Eversense 365
    public var security: SecurityType = .none
    public var username: String?
    public var password: String?
    public var accessToken: String?
    public var accessTokenExpiration: Date?

    public var fleetKey: String?
    public var publicKeyV2: Data?
    public var privateKeyV2: Data?
    public var clientIdV2: Data?
    public var noneV2: Data?
    public var certificateV2: String?
    public var fleetKeyPublicKeyV2: Data?

    public var isUSXLorOUSXL2: Bool {
        !(mmaFeatures == 0 || mmaFeatures == 255 || mmaFeatures < 1)
    }

    public var is365: Bool {
        !(security == .none)
    }

    public var modelStr: String? {
        if is365 {
            return LocalizedString("Eversense 365 - 1 year", comment: "Eversense 365 (1year)")
        }

        return LocalizedString("Eversense E3", comment: "Eversense E3")
    }

    public var debugDescription: String {
        [
            "TODO"
        ].joined(separator: "\n")
    }
}
