extension Eversense365 {
    class SetPredictionLowThresholdResponse {}

    class SetPredictionLowThresholdPacket: BasePacket {
        typealias T = SetPredictionLowThresholdResponse

        var responseType: UInt8 {
            PacketIds.WriteResponseId.rawValue
        }

        var responseId: UInt8? {
            WriteIds.PredictionLowThreshold.rawValue
        }

        let value: UInt16
        init(value: UInt16) {
            self.value = value
        }

        func getRequestData() -> Data {
            var data = Data([PacketIds.WriteCommandId.rawValue, WriteIds.PredictionLowThreshold.rawValue])
            data.append(BinaryOperations.dataFrom16Bits(value: value))
            return data
        }

        func parseResponse(data _: Data) -> SetPredictionLowThresholdResponse {
            SetPredictionLowThresholdResponse()
        }
    }
}
