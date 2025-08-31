extension EversenseE3 {
    class GetRateRisingThresholdResponse {
        let value: Double

        init(value: Double) {
            self.value = value
        }
    }

    class GetRateRisingThresholdPacket: BasePacket {
        typealias T = GetRateRisingThresholdResponse

        var response: PacketIds {
            PacketIds.readSingleByteSerialFlashRegisterResponseId
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
