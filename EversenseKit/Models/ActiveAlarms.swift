public struct ActiveAlarm: RawRepresentable, Equatable {
    let code: Alarm
    let datetime: Date
    let glucoseInMgDl: UInt16
    let flag: UInt8
    let priority: UInt8

    init(code: Alarm, datetime: Date, glucoseInMgDl: UInt16, flag: UInt8, priority: UInt8) {
        self.code = code
        self.datetime = datetime
        self.glucoseInMgDl = glucoseInMgDl
        self.flag = flag
        self.priority = priority
    }

    public typealias RawValue = [String: Any]
    public init?(rawValue: RawValue) {
        guard let codeRaw = rawValue["code"] as? Alarm.RawValue,
              let code = Alarm(rawValue: codeRaw),
              let datetime = rawValue["datetime"] as? Date,
              let glucoseInMgDl = rawValue["glucoseInMgDl"] as? UInt16,
              let flag = rawValue["flag"] as? UInt8,
              let priority = rawValue["priority"] as? UInt8
        else {
            return nil
        }

        self.code = code
        self.datetime = datetime
        self.glucoseInMgDl = glucoseInMgDl
        self.flag = flag
        self.priority = priority
    }

    public var rawValue: RawValue {
        var value: RawValue = [:]
        value["code"] = code.rawValue
        value["datetime"] = datetime
        value["glucoseInMgDl"] = glucoseInMgDl
        value["flag"] = flag
        value["priority"] = priority

        return value
    }
}
