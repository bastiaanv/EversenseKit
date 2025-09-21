extension EversenseE3 {
    class GetRateRisingThresholdResponse {
        let value: Double

        init(value: Double) {
            self.value = value
        }
    }

    class GetRateRisingThresholdPacket: BasePacket {
        typealias T = GetRateRisingThresholdResponse

        var responseType: UInt8 {
            PacketIds.readSingleByteSerialFlashRegisterResponseId.rawValue
        }

        var responseId: UInt8? {
            nil
        }

        func getRequestData() -> Data {
            CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.rateRisingThreshold)
        }

        func parseResponse(data: Data) -> GetRateRisingThresholdResponse {
            GetRateRisingThresholdResponse(
                value: Double(data[start]) / 10
            )
        }
    }
}
