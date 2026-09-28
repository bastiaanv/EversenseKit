extension Eversense365 {
    class SetPredictionLowEnabledResponse {}

    class SetPredictionLowEnabledPacket: BasePacket {
        typealias T = SetPredictionLowEnabledResponse

        var responseType: UInt8 {
            PacketIds.WriteResponseId.rawValue
        }

        var responseId: UInt8? {
            WriteIds.PredictionLowEnabled.rawValue
        }

        let value: UInt8
        init(enabled: Bool) {
            value = enabled ? 1 : 0
        }

        func getRequestData() -> Data {
            Data([PacketIds.WriteCommandId.rawValue, WriteIds.PredictionLowEnabled.rawValue, value])
        }

        func parseResponse(data _: Data) -> SetPredictionLowEnabledResponse {
            SetPredictionLowEnabledResponse()
        }
    }
}
