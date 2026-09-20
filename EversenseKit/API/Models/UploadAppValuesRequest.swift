struct UploadAppValuesRequest: Codable {
    let Active: Bool
    let AppOS: String
    let AppOSVersion: String
    let AppVersion: String
    let AppReserveField1: String // Used to let DMS knwo which app you are using
    let DeviceType: String
    let AutoSync: Int
}
