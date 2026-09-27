extension Eversense365 {
    class SetPredictionHighThresholdResponse {}

    class SetPredictionHighThresholdPacket: BasePacket {
        typealias T = SetPredictionHighThresholdResponse

        var responseType: UInt8 {
            PacketIds.WriteResponseId.rawValue
        }

        var responseId: UInt8? {
            WriteIds.PredictionHighThreshold.rawValue
        }

        let value: UInt16
        init(value: UInt16) {
            self.value = value
        }

        func getRequestData() -> Data {
            var data = Data([PacketIds.WriteCommandId.rawValue, WriteIds.PredictionHighThreshold.rawValue])
            data.append(BinaryOperations.dataFrom16Bits(value: value))
            return data
        }

        func parseResponse(data _: Data) -> SetPredictionHighThresholdResponse {
            SetPredictionHighThresholdResponse()
        }
    }
}
