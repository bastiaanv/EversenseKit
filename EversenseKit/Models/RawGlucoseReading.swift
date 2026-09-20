public struct RawGlucoseReading: RawRepresentable, Equatable {
    let datetime: Date
    let recordId: UInt32
    let algoLog: String

    init(datetime: Date, recordId: UInt32, algoLog: String) {
        self.datetime = datetime
        self.recordId = recordId
        self.algoLog = algoLog
    }

    public typealias RawValue = [String: Any]
    public init?(rawValue: RawValue) {
        guard let datetime = rawValue["datetime"] as? Date,
              let recordId = rawValue["recordId"] as? UInt32,
              let algoLog = rawValue["algoLog"] as? String
        else {
            return nil
        }

        self.datetime = datetime
        self.recordId = recordId
        self.algoLog = algoLog
    }

    public var rawValue: RawValue {
        var value: RawValue = [:]
        value["datetime"] = datetime
        value["recordId"] = recordId
        value["algoLog"] = algoLog

        return value
    }
}
