struct UploadBatteryLogRequest: Codable {
    let MMATimestamp: String
    let TransmitterId: String
    let BatteryLogs: String
    let RecordNumber: Int
    let TxTimestamp: String
    let SensorId: String
    let FWVersion: String
}
