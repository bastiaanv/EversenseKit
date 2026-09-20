import LoopKit

public struct CGMReading: RawRepresentable, Equatable {
    let glucoseInMgDl: UInt16
    let datetime: Date
    let trend: GlucoseTrend?
    let raw: String

    init(glucoseInMgDl: UInt16, datetime: Date, trend: GlucoseTrend?, raw: String) {
        self.glucoseInMgDl = glucoseInMgDl
        self.datetime = datetime
        self.trend = trend
        self.raw = raw
    }

    public typealias RawValue = [String: Any]
    public init?(rawValue: RawValue) {
        guard let glucoseInMgDl = rawValue["glucoseInMgDl"] as? UInt16,
              let datetime = rawValue["datetime"] as? Date,
              let raw = rawValue["raw"] as? String
        else {
            return nil
        }

        self.glucoseInMgDl = glucoseInMgDl
        self.datetime = datetime
        self.raw = raw

        if let trendRaw = rawValue["trend"] as? GlucoseTrend.RawValue,
           let trend = GlucoseTrend(rawValue: trendRaw)
        {
            self.trend = trend
        } else {
            trend = nil
        }
    }

    public var rawValue: RawValue {
        var value: RawValue = [:]
        value["glucoseInMgDl"] = glucoseInMgDl
        value["datetime"] = datetime
        value["trend"] = trend?.rawValue
        value["raw"] = raw

        return value
    }
}

public struct CalibrationEvent {
    let glucoseInMgDl: UInt16
    let datetime: Date
}
