extension EversenseE3 {
    class GetPredictiveRisingTimeIntervalResponse {
        let value: TimeInterval

        init(value: TimeInterval) {
            self.value = value
        }
    }

    class GetPredictiveRisingTimeIntervalPacket: BasePacket {
        typealias T = GetPredictiveRisingTimeIntervalResponse

        var responseType: UInt8 {
            PacketIds.readSingleByteSerialFlashRegisterResponseId.rawValue
        }

        var responseId: UInt8? {
            nil
        }

        func getRequestData() -> Data {
            CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.predictiveRisingTime)
        }

        func parseResponse(data: Data) -> GetPredictiveRisingTimeIntervalResponse {
            GetPredictiveRisingTimeIntervalResponse(
                value: .minutes(Double(data[start]))
            )
        }
    }
}
