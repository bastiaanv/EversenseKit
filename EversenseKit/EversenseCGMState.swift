import HealthKit
import LoopKit

public enum ConnectionStatus: UInt8 {
    case idle = 0
    case connecting = 1
    case connected = 2

    var title: String {
        switch self {
        case .idle:
            return String(localized: "Idle", comment: "connection status idle")
        case .connecting:
            return String(localized: "Connecting", comment: "connection status connecting")
        case .connected:
            return String(localized: "Operational", comment: "connection status connected")
        }
    }
}

public struct GlucoseDisplay: GlucoseDisplayable {
    public let isStateValid: Bool
    public let trendType: LoopKit.GlucoseTrend?
    public let trendRate: HKQuantity? = nil
    public let isLocal: Bool = true
    public let glucoseRangeCategory: LoopKit.GlucoseRangeCategory? = nil

    // TODO: Fix the placeholder glucoseRangeCategory & trendRate
    public init(state: EversenseCGMState) {
        if let lastSynced = state.lastSynced {
            isStateValid = abs(lastSynced.timeIntervalSinceNow) <= TimeInterval(minutes: 15)
        } else {
            isStateValid = false
        }

        trendType = state.recentGlucoseTrend
    }
}

public struct EversenseCGMState: RawRepresentable, Equatable {
    public typealias RawValue = CGMManager.RawStateValue

    public init(rawValue: RawValue) {
        bleNameString = rawValue["bleNameString"] as? String
        isOnboarded = rawValue["isOnboarded"] as? Bool ?? false
        isSyncing = rawValue["isSyncing"] as? Bool ?? false
        lastSynced = rawValue["lastSynced"] as? Date
        lastOnlineSync = rawValue["lastOnlineSync"] as? Date ?? lastSynced
        lastUploadedTimestamp = rawValue["lastUploadedTimestamp"] as? Date
            ?? rawValue["lastOnlineSync"] as? Date
            ?? lastSynced
        lastReadTimestamp = rawValue["lastReadTimestamp"] as? Date
            ?? rawValue["lastUploadedTimestamp"] as? Date
            ?? rawValue["lastOnlineSync"] as? Date
            ?? lastSynced
        version = rawValue["version"] as? String
        extVersion = rawValue["extVersion"] as? String
        transmitterId = rawValue["transmitterId"] as? String
        shouldUploadToEversenseDMS = rawValue["shouldUploadToEversenseDMS"] as? Bool ?? true
        uploadBatchSize = rawValue["uploadBatchSize"] as? Int ?? 12
        sensorId = rawValue["sensorId"] as? Data ?? Data()
        communicationProtocol = rawValue["communicationProtocol"] as? Double ?? 0
        hasReportedInsertionDate = rawValue["hasReportedInsertionDate"] as? Bool ?? false
        activatedAt = rawValue["activatedAt"] as? Date ?? Date.distantPast
        expiresAt = rawValue["expiresAt"] as? Date ?? Date.distantPast
        mmaFeatures = rawValue["mmaFeatures"] as? UInt8 ?? 0
        vibrateMode = rawValue["vibrateMode"] as? Bool
        lastCalibration = rawValue["lastCalibration"] as? Date
        nextCalibration = rawValue["nextCalibration"] as? Date
        calibrationCount = rawValue["calibrationCount"] as? UInt16 ?? 0
        isGlucoseHighAlarmEnabled = rawValue["isGlucoseHighAlarmEnabled"] as? Bool ?? false
        lowGlucoseAlarmInMgDl = rawValue["lowGlucoseAlarmInMgDl"] as? UInt16 ?? 40
        highGlucoseAlarmInMgDl = rawValue["highGlucoseAlarmInMgDl"] as? UInt16 ?? 200
        isPredictionLowEnabled = rawValue["isPredictionLowEnabled"] as? Bool ?? false
        isPredictionHighEnabled = rawValue["isPredictionHighEnabled"] as? Bool ?? false
        predictionRisingInterval = rawValue["predictionRisingInterval"] as? TimeInterval ?? .minutes(5)
        predictionFallingInterval = rawValue["predictionFallingInterval"] as? TimeInterval ?? .minutes(5)
        predictionRisingThreshold = rawValue["predictionRisingThreshold"] as? UInt16 ?? 180
        predictionFallingThreshold = rawValue["predictionFallingThreshold"] as? UInt16 ?? 70
        repeatLowTimeout = rawValue["repeatLowTimeout"] as? TimeInterval ?? .minutes(15)
        repeatHighTimeout = rawValue["repeatHighTimeout"] as? TimeInterval ?? .minutes(15)
        bleDisconnectTimeout = rawValue["bleDisconnectTimeout"] as? TimeInterval ?? .minutes(5)
        isFallingRateEnabled = rawValue["isRateEnabled"] as? Bool ?? false
        isRisingRateEnabled = rawValue["isRisingRateEnabled"] as? Bool ?? false
        rateFallingThreshold = rawValue["rateFallingThreshold"] as? Double ?? 0
        rateRisingThreshold = rawValue["rateRisingThreshold"] as? Double ?? 0
        signalStrengthRaw = rawValue["signalStrengthRaw"] as? UInt16 ?? 0
        recentGlucoseInMgDl = rawValue["recentGlucoseInMgDl"] as? UInt16
        recentGlucoseDateTime = rawValue["recentGlucoseDateTime"] as? Date
        batteryPercentage = rawValue["batteryPercentage"] as? Int ?? -1
        lastBatteryRecord = rawValue["lastBatteryRecord"] as? UInt32 ?? 0

        username = rawValue["username"] as? String
        password = rawValue["password"] as? String
        accessToken = rawValue["accessToken"] as? String
        accessTokenExpiration = rawValue["accessTokenExpiration"] as? Date
        publicKeyV2 = rawValue["publicKeyV2"] as? Data
        privateKeyV2 = rawValue["privateKeyV2"] as? Data
        clientIdV2 = rawValue["clientIdV2"] as? Data
        certificateV2 = rawValue["certificateV2"] as? String

        if let rawCalibrationMode = rawValue["calibrationMode"] as? CalibrationMode.RawValue {
            calibrationMode = CalibrationMode(rawValue: rawCalibrationMode) ?? .Default
        } else {
            calibrationMode = .Default
        }

        if let rawCalibrationPhase = rawValue["calibrationPhase"] as? CalibrationPhase.RawValue {
            calibrationPhase = CalibrationPhase(rawValue: rawCalibrationPhase) ?? .UNKNOWN
        } else {
            calibrationPhase = .UNKNOWN
        }

        if let rawSignalStrength = rawValue["signalStrength"] as? SignalStrength.RawValue {
            signalStrength = SignalStrength(rawValue: rawSignalStrength) ?? .NoSignal
        } else {
            signalStrength = .NoSignal
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

        if let rawCalibrationReadiness = rawValue["calibrationReadiness"] as? CalibrationReadiness.RawValue {
            calibrationReadiness = CalibrationReadiness(rawValue: rawCalibrationReadiness) ?? .Unknown
        } else {
            calibrationReadiness = .Unknown
        }

        if let rawApiZone = rawValue["apiZone"] as? EversenseApiZone.RawValue {
            apiZone = EversenseApiZone(rawValue: rawApiZone) ?? .US
        } else {
            // security none -> E3 -> EU
            // Every other security -> 365 -> US (only relevant while migrating this property)
            apiZone = security == .none ? .OutsideUS : .US
        }

        do {
            if let activeAlarmsData = rawValue["activeAlarms"] as? Data {
                activeAlarms = try JSONDecoder().decode([ActiveAlarm].self, from: activeAlarmsData)
            } else {
                activeAlarms = []
            }
        } catch {
            EversenseLogger(category: "EversenseCGMState").error("Failed to decode activeAlarms - \(error.localizedDescription)")
            activeAlarms = []
        }

        do {
            if let readingsToUploadData = rawValue["readingsToUpload"] as? Data {
                readingsToUpload = try JSONDecoder().decode([CGMReading].self, from: readingsToUploadData)
            } else {
                readingsToUpload = []
            }
        } catch {
            EversenseLogger(category: "EversenseCGMState")
                .error("Failed to decode readingsToUpload - \(error.localizedDescription)")
            readingsToUpload = []
        }

        do {
            if let batteryReadingsToUploadData = rawValue["batteryReadingsToUpload"] as? Data {
                batteryReadingsToUpload = try JSONDecoder().decode([BatteryReadings].self, from: batteryReadingsToUploadData)
            } else {
                batteryReadingsToUpload = []
            }
        } catch {
            EversenseLogger(category: "EversenseCGMState")
                .error("Failed to decode batteryReadingsToUpload - \(error.localizedDescription)")
            batteryReadingsToUpload = []
        }
    }

    public var rawValue: RawValue {
        var value: [String: Any] = [:]

        value["bleNameString"] = bleNameString
        value["isOnboarded"] = isOnboarded
        value["isSyncing"] = isSyncing
        value["lastSynced"] = lastSynced
        value["lastOnlineSync"] = lastOnlineSync
        value["lastReadTimestamp"] = lastReadTimestamp
        value["lastUploadedTimestamp"] = lastUploadedTimestamp
        value["shouldUploadToEversenseDMS"] = shouldUploadToEversenseDMS
        value["uploadBatchSize"] = uploadBatchSize
        value["version"] = version
        value["extVersion"] = extVersion
        value["transmitterId"] = transmitterId
        value["sensorId"] = sensorId
        value["communicationProtocol"] = communicationProtocol
        value["hasReportedInsertionDate"] = hasReportedInsertionDate
        value["activatedAt"] = activatedAt
        value["expiresAt"] = expiresAt
        value["mmaFeatures"] = mmaFeatures
        value["lastBatteryRecord"] = lastBatteryRecord
        value["vibrateMode"] = vibrateMode
        value["batteryPercentage"] = batteryPercentage
        value["signalStrength"] = signalStrength.rawValue
        value["signalStrengthRaw"] = signalStrengthRaw
        value["lastCalibration"] = lastCalibration
        value["nextCalibration"] = nextCalibration
        value["calibrationMode"] = calibrationMode.rawValue
        value["calibrationCount"] = calibrationCount
        value["calibrationPhase"] = calibrationPhase.rawValue
        value["calibrationReadiness"] = calibrationReadiness.rawValue
        value["isGlucoseHighAlarmEnabled"] = isGlucoseHighAlarmEnabled
        value["lowGlucoseAlarmInMgDl"] = lowGlucoseAlarmInMgDl
        value["highGlucoseAlarmInMgDl"] = highGlucoseAlarmInMgDl
        value["isPredictionLowEnabled"] = isPredictionLowEnabled
        value["isPredictionHighEnabled"] = isPredictionHighEnabled
        value["predictionRisingInterval"] = predictionRisingInterval
        value["predictionFallingInterval"] = predictionFallingInterval
        value["predictionFallingThreshold"] = predictionFallingThreshold
        value["predictionRisingThreshold"] = predictionRisingThreshold
        value["repeatLowTimeout"] = repeatLowTimeout
        value["repeatHighTimeout"] = repeatHighTimeout
        value["bleDisconnectTimeout"] = bleDisconnectTimeout
        value["isFallingRateEnabled"] = isFallingRateEnabled
        value["isRisingRateEnabled"] = isRisingRateEnabled
        value["rateFallingThreshold"] = rateFallingThreshold
        value["rateRisingThreshold"] = rateRisingThreshold
        value["recentGlucoseInMgDl"] = recentGlucoseInMgDl
        value["recentGlucoseDateTime"] = recentGlucoseDateTime
        value["recentGlucoseTrend"] = recentGlucoseTrend.rawValue
        value["security"] = security.rawValue
        value["apiZone"] = apiZone.rawValue
        value["username"] = username
        value["password"] = password
        value["accessToken"] = accessToken
        value["accessTokenExpiration"] = accessTokenExpiration
        value["publicKeyV2"] = publicKeyV2
        value["privateKeyV2"] = privateKeyV2
        value["clientIdV2"] = clientIdV2
        value["certificateV2"] = certificateV2

        do {
            value["activeAlarms"] = try JSONEncoder().encode(activeAlarms)
        } catch {
            EversenseLogger(category: "EversenseCGMState").error("Failed to encode activeAlarms - \(error.localizedDescription)")
        }

        do {
            value["readingsToUpload"] = try JSONEncoder().encode(readingsToUpload)
        } catch {
            EversenseLogger(category: "EversenseCGMState")
                .error("Failed to encode readingsToUpload - \(error.localizedDescription)")
        }

        do {
            value["batteryReadingsToUpload"] = try JSONEncoder().encode(batteryReadingsToUpload)
        } catch {
            EversenseLogger(category: "EversenseCGMState")
                .error("Failed to encode batteryReadingsToUpload - \(error.localizedDescription)")
        }

        return value
    }

    public var connectionStatus: ConnectionStatus = .idle
    public var bleNameString: String?
    public var isOnboarded: Bool
    public var isSyncing: Bool
    public var lastSynced: Date?
    public var version: String?
    public var extVersion: String?
    public var transmitterId: String?
    public var sensorId: Data
    public var communicationProtocol: Double
    public var hasReportedInsertionDate: Bool
    public var activatedAt: Date
    public var expiresAt: Date

    public var shouldUploadToEversenseDMS: Bool
    public var uploadBatchSize: Int
    public var lastOnlineSync: Date?
    public var lastReadTimestamp: Date?
    public var lastUploadedTimestamp: Date?

    public var mmaFeatures: UInt8
    public var batteryPercentage: Int
    public var vibrateMode: Bool?

    public var signalStrength: SignalStrength
    public var signalStrengthRaw: UInt16

    public var lastCalibration: Date?
    public var nextCalibration: Date?

    public var calibrationMode: CalibrationMode
    public var calibrationPhase: CalibrationPhase
    public var calibrationCount: UInt16
    public var calibrationReadiness: CalibrationReadiness

    public var isGlucoseHighAlarmEnabled: Bool
    public var lowGlucoseAlarmInMgDl: UInt16
    public var highGlucoseAlarmInMgDl: UInt16

    public var isPredictionLowEnabled: Bool
    public var isPredictionHighEnabled: Bool
    public var predictionFallingInterval: TimeInterval
    public var predictionRisingInterval: TimeInterval
    public var predictionFallingThreshold: UInt16
    public var predictionRisingThreshold: UInt16

    public var isFallingRateEnabled: Bool
    public var isRisingRateEnabled: Bool
    public var rateFallingThreshold: Double
    public var rateRisingThreshold: Double
    public var repeatLowTimeout: TimeInterval
    public var repeatHighTimeout: TimeInterval
    public var bleDisconnectTimeout: TimeInterval

    public var recentGlucoseInMgDl: UInt16?
    public var recentGlucoseDateTime: Date?
    public var recentGlucoseTrend: GlucoseTrend

    public var activeAlarms: [ActiveAlarm]
    public var readingsToUpload: [CGMReading]
    public var lastBatteryRecord: UInt32
    public var batteryReadingsToUpload: [BatteryReadings]

    // Eversense 365
    public var security: SecurityType = .none
    public var apiZone: EversenseApiZone
    public var username: String?
    public var password: String?
    public var accessToken: String?
    public var accessTokenExpiration: Date?

    public var publicKeyV2: Data?
    public var privateKeyV2: Data?
    public var clientIdV2: Data?
    public var certificateV2: String?

    public var is365: Bool {
        !(security == .none)
    }

    public var modelStr: String {
        is365 ?
            String(localized: "Eversense 365", comment: "Eversense 365 (1year)") :
            String(localized: "Eversense E3", comment: "Eversense E3")
    }

    public var debugDescription: String {
        [
            "## EverSense CGM:",
            "Current timezone: \(TimeZone.current.identifier)",
            "",
            "— Connection —",
            "connectionStatus: \(connectionStatus)",
            "bleNameString: \(bleNameString ?? "nil")",
            "isOnboarded: \(isOnboarded)",
            "isSyncing: \(isSyncing)",
            "lastSynced: \(lastSynced?.description ?? "nil")",
            "",
            "— Versions —",
            "version: \(version ?? "nil")",
            "extVersion: \(extVersion ?? "nil")",
            "communicationProtocol: \(communicationProtocol)",
            "",
            "— Lifecycle —",
            "activatedAt: \(activatedAt)",
            "expiresAt: \(expiresAt)",
            "",
            "— Device —",
            "mmaFeatures: \(mmaFeatures)",
            "batteryPercentage: \(batteryPercentage)",
            "vibrateMode: \(vibrateMode.map(String.init) ?? "nil")",
            "",
            "— Signal —",
            "signalStrength: \(signalStrength)",
            "signalStrengthRaw: \(signalStrengthRaw)",
            "",
            "— Calibration —",
            "lastCalibration: \(lastCalibration?.description ?? "nil")",
            "nextCalibration: \(nextCalibration?.description ?? "nil")",
            "calibrationMode: \(calibrationMode)",
            "calibrationPhase: \(calibrationPhase)",
            "calibrationCount: \(calibrationCount)",
            "calibrationReadiness: \(calibrationReadiness)",
            "",
            "— Alarms —",
            "isGlucoseHighAlarmEnabled: \(isGlucoseHighAlarmEnabled)",
            "lowGlucoseAlarmInMgDl: \(lowGlucoseAlarmInMgDl)",
            "highGlucoseAlarmInMgDl: \(highGlucoseAlarmInMgDl)",
            "",
            "— Prediction —",
            "isPredictionLowEnabled: \(isPredictionLowEnabled)",
            "isPredictionHighEnabled: \(isPredictionHighEnabled)",
            "predictionFallingInterval: \(predictionFallingInterval)",
            "predictionRisingInterval: \(predictionRisingInterval)",
            "predictionFallingThreshold: \(predictionFallingThreshold)",
            "predictionRisingThreshold: \(predictionRisingThreshold)",
            "",
            "— Rate —",
            "isFallingRateEnabled: \(isFallingRateEnabled)",
            "isRisingRateEnabled: \(isRisingRateEnabled)",
            "rateFallingThreshold: \(rateFallingThreshold)",
            "rateRisingThreshold: \(rateRisingThreshold)",
            "",
            "— Glucose —",
            "recentGlucoseInMgDl: \(recentGlucoseInMgDl.map(String.init) ?? "nil")",
            "recentGlucoseDateTime: \(recentGlucoseDateTime?.description ?? "nil")",
            "recentGlucoseTrend: \(recentGlucoseTrend)",
            "",
            "— Active Alarms —",
            "activeAlarms: \(activeAlarms)"
        ].joined(separator: "\n")
    }
}
