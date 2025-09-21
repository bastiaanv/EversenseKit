extension EversenseE3 {
    class SetRateRisingThresholdResponse {}

    class SetRateRisingThresholdPacket: BasePacket {
        typealias T = SetRateRisingThresholdResponse

        var responseType: UInt8 {
            PacketIds.writeSingleByteSerialFlashRegisterResponseId.rawValue
        }

        var responseId: UInt8? {
            nil
        }

        let value: UInt8
        init(value: UInt8) {
            self.value = value
        }

        func getRequestData() -> Data {
            CommandOperations.writeSingleByteSerialFlashRegister(
                memoryAddress: FlashMemory.rateRisingThreshold,
                data: Data([value])
            )
        }

        func parseResponse(data _: Data) -> SetRateRisingThresholdResponse {
            SetRateRisingThresholdResponse()
        }
    }
}
