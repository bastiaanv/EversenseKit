struct UploadEssentailLogRequest: Codable {
    let EssentialLog: String
    let TransmitterId: String
    let Timestamp: String
    let CurrentGlucoseDateTime: String
    let CurrentGlucoseValue: Int
    let SensorId: String
    let FWVersion: String
}
