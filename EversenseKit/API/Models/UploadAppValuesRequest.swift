struct UploadAppValuesRequest: Codable {
    let Active: Bool
    let AppOS: String
    let AppOSVersion: String
    let AppName: String
    let AppVersion: String
    let AppReserveField1: String // Timezone information
    let DeviceType: String
    let AutoSync: Int
}
