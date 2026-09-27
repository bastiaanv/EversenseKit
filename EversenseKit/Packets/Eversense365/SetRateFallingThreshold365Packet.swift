extension Eversense365 {
    class SetRateFallingThresholdResponse {}

    class SetRateFallingThresholdPacket: BasePacket {
        typealias T = SetRateFallingThresholdResponse

        var responseType: UInt8 {
            PacketIds.WriteResponseId.rawValue
        }

        var responseId: UInt8? {
            WriteIds.RateFallingThreshold.rawValue
        }

        let value: UInt8
        init(value: UInt8) {
            self.value = value
        }

        func getRequestData() -> Data {
            Data([PacketIds.WriteCommandId.rawValue, WriteIds.RateFallingThreshold.rawValue, value])
        }

        func parseResponse(data _: Data) -> SetRateFallingThresholdResponse {
            SetRateFallingThresholdResponse()
        }
    }
}
