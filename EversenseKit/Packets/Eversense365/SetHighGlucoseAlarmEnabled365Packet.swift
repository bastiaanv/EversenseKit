extension Eversense365 {
    class SetHighGlucoseAlarmEnabledResponse {}

    class SetHighGlucoseAlarmEnabledPacket: BasePacket {
        typealias T = SetHighGlucoseAlarmEnabledResponse

        var responseType: UInt8 {
            PacketIds.WriteResponseId.rawValue
        }

        var responseId: UInt8? {
            WriteIds.HighGlucoseAlarmEnable.rawValue
        }

        let enabled: Bool
        init(enabled: Bool) {
            self.enabled = enabled
        }

        func getRequestData() -> Data {
            Data([PacketIds.WriteCommandId.rawValue, WriteIds.HighGlucoseAlarmEnable.rawValue, enabled ? 1 : 0])
        }

        func parseResponse(data _: Data) -> SetHighGlucoseAlarmEnabledResponse {
            SetHighGlucoseAlarmEnabledResponse()
        }
    }
}
