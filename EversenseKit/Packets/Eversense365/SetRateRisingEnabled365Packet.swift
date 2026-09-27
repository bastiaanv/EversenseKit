extension Eversense365 {
    class SetRateRisingEnabledResponse {}

    class SetRateRisingEnabledPacket: BasePacket {
        typealias T = SetRateRisingEnabledResponse

        var responseType: UInt8 {
            PacketIds.WriteResponseId.rawValue
        }

        var responseId: UInt8? {
            WriteIds.RateRisingEnabled.rawValue
        }

        let enabled: Bool
        init(enabled: Bool) {
            self.enabled = enabled
        }

        func getRequestData() -> Data {
            Data([PacketIds.WriteCommandId.rawValue, WriteIds.RateRisingEnabled.rawValue, enabled ? 1 : 0])
        }

        func parseResponse(data _: Data) -> SetRateRisingEnabledResponse {
            SetRateRisingEnabledResponse()
        }
    }
}
