extension Eversense365 {
    class SetPredictionLowIntervalResponse {}

    class SetPredictionLowIntervalPacket: BasePacket {
        typealias T = SetPredictionLowIntervalResponse

        var responseType: UInt8 {
            PacketIds.WriteResponseId.rawValue
        }

        var responseId: UInt8? {
            WriteIds.PredictionLowTime.rawValue
        }

        let value: UInt8
        init(time: TimeInterval) {
            value = UInt8(time.minutes)
        }

        func getRequestData() -> Data {
            Data([PacketIds.WriteCommandId.rawValue, WriteIds.PredictionLowTime.rawValue, value])
        }

        func parseResponse(data _: Data) -> SetPredictionLowIntervalResponse {
            SetPredictionLowIntervalResponse()
        }
    }
}
