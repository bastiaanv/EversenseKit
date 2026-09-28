extension Eversense365 {
    class SetRateRisingThresholdResponse {}

    class SetRateRisingThresholdPacket: BasePacket {
        typealias T = SetRateRisingThresholdResponse

        var responseType: UInt8 {
            PacketIds.WriteResponseId.rawValue
        }

        var responseId: UInt8? {
            WriteIds.RateRisingThreshold.rawValue
        }

        let value: UInt8
        init(value: UInt8) {
            self.value = value
        }

        func getRequestData() -> Data {
            Data([PacketIds.WriteCommandId.rawValue, WriteIds.RateRisingThreshold.rawValue, value])
        }

        func parseResponse(data _: Data) -> SetRateRisingThresholdResponse {
            SetRateRisingThresholdResponse()
        }
    }
}
