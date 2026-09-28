extension Eversense365 {
    class SetPredictionHighEnabledResponse {}

    class SetPredictionHighEnabledPacket: BasePacket {
        typealias T = SetPredictionHighEnabledResponse

        var responseType: UInt8 {
            PacketIds.WriteResponseId.rawValue
        }

        var responseId: UInt8? {
            WriteIds.PredictionHighEnabled.rawValue
        }

        let value: UInt8
        init(enabled: Bool) {
            value = enabled ? 1 : 0
        }

        func getRequestData() -> Data {
            Data([PacketIds.WriteCommandId.rawValue, WriteIds.PredictionHighEnabled.rawValue, value])
        }

        func parseResponse(data _: Data) -> SetPredictionHighEnabledResponse {
            SetPredictionHighEnabledResponse()
        }
    }
}
