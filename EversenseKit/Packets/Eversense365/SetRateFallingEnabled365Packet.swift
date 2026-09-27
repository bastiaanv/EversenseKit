extension Eversense365 {
    class SetRateFallingEnabledResponse {}

    class SetRateFallingEnabledPacket: BasePacket {
        typealias T = SetRateFallingEnabledResponse

        var responseType: UInt8 {
            PacketIds.WriteResponseId.rawValue
        }

        var responseId: UInt8? {
            WriteIds.RateFallingEnabled.rawValue
        }

        let enabled: Bool
        init(enabled: Bool) {
            self.enabled = enabled
        }

        func getRequestData() -> Data {
            Data([PacketIds.WriteCommandId.rawValue, WriteIds.RateFallingEnabled.rawValue, enabled ? 1 : 0])
        }

        func parseResponse(data _: Data) -> SetRateFallingEnabledResponse {
            SetRateFallingEnabledResponse()
        }
    }
}
