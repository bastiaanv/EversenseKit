struct UploadAlgorihmLogRequest: Codable {
    let AlgoLogHexString: String
    let FWVersion: String
    let GlucoseDateTime: String
    let GlucoseValue: UInt16
    let Timestamp: String
    let RecordNumber: UInt32
    let SensorId: String
    let TransmitterId: String
}
