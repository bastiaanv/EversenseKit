extension EversenseE3 {
    class GetRateFallingThresholdResponse {
        let value: Double

        init(value: Double) {
            self.value = value
        }
    }

    class GetRateFallingThresholdPacket: BasePacket {
        typealias T = GetRateFallingThresholdResponse

        var responseType: UInt8 {
            PacketIds.readSingleByteSerialFlashRegisterResponseId.rawValue
        }

        var responseId: UInt8? {
            nil
        }

        func getRequestData() -> Data {
            CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.rateFallingThreshold)
        }

        func parseResponse(data: Data) -> GetRateFallingThresholdResponse {
            GetRateFallingThresholdResponse(
                value: Double(data[start]) / 10
            )
        }
    }
}
