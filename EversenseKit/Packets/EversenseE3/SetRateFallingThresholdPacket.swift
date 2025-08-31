extension EversenseE3 {
    class SetRateFallingThresholdResponse {}

    class SetRateFallingThresholdPacket: BasePacket {
        typealias T = SetRateFallingThresholdResponse

        var response: PacketIds {
            PacketIds.writeSingleByteSerialFlashRegisterResponseId
        }

        let value: UInt8
        init(value: UInt8) {
            self.value = value
        }

        func getRequestData() -> Data {
            CommandOperations.writeSingleByteSerialFlashRegister(
                memoryAddress: FlashMemory.rateFallingThreshold,
                data: Data([value])
            )
        }

        func parseResponse(data _: Data) -> SetRateFallingThresholdResponse {
            SetRateFallingThresholdResponse()
        }
    }
}
