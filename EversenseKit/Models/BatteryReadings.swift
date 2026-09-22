public struct BatteryReadings: RawRepresentable, Equatable {
    let value: Data
    let datetime: Date
    let recordId: UInt32

    init(value: Data, datetime: Date, recordId: UInt32) {
        self.value = value
        self.datetime = datetime
        self.recordId = recordId
    }

    public typealias RawValue = [String: Any]
    public init?(rawValue: RawValue) {
        guard let value = rawValue["value"] as? Data,
              let datetime = rawValue["datetime"] as? Date,
              let recordId = rawValue["recordId"] as? UInt32
        else {
            return nil
        }

        self.value = value
        self.datetime = datetime
        self.recordId = recordId
    }

    public var rawValue: RawValue {
        var value: RawValue = [:]
        value["value"] = value
        value["datetime"] = datetime
        value["recordId"] = recordId

        return value
    }
}
