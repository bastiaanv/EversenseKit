extension EversenseE3 {
    class GetPredictiveFallingTimeIntervalResponse {
        let value: TimeInterval

        init(value: TimeInterval) {
            self.value = value
        }
    }

    class GetPredictiveFallingTimeIntervalPacket: BasePacket {
        typealias T = GetPredictiveFallingTimeIntervalResponse

        var responseType: UInt8 {
            PacketIds.readSingleByteSerialFlashRegisterResponseId.rawValue
        }

        var responseId: UInt8? {
            nil
        }

        func getRequestData() -> Data {
            CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.predictiveFallingTime)
        }

        func parseResponse(data: Data) -> GetPredictiveFallingTimeIntervalResponse {
            GetPredictiveFallingTimeIntervalResponse(
                value: .minutes(Double(data[start]))
            )
        }
    }
}
