extension Eversense365 {
    class SetPredictionHighIntervalResponse {}

    class SetPredictionHighIntervalPacket: BasePacket {
        typealias T = SetPredictionHighIntervalResponse

        var responseType: UInt8 {
            PacketIds.WriteResponseId.rawValue
        }

        var responseId: UInt8? {
            WriteIds.PredictionHighTime.rawValue
        }

        let value: UInt8
        init(time: TimeInterval) {
            value = UInt8(time.minutes)
        }

        func getRequestData() -> Data {
            Data([PacketIds.WriteCommandId.rawValue, WriteIds.PredictionHighTime.rawValue, value])
        }

        func parseResponse(data _: Data) -> SetPredictionHighIntervalResponse {
            SetPredictionHighIntervalResponse()
        }
    }
}
