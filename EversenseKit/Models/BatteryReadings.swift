public struct BatteryReadings: Codable, Equatable {
    let value: Data
    let datetime: Date
    let recordId: UInt32
}
