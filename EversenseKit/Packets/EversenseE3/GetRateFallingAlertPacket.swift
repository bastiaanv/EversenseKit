extension EversenseE3 {
    class GetRateFallingAlertResponse {
        let value: Bool

        init(value: Bool) {
            self.value = value
        }
    }

    class GetRateFallingAlertPacket: BasePacket {
        typealias T = GetRateFallingAlertResponse

        var response: PacketIds {
            PacketIds.readSingleByteSerialFlashRegisterResponseId
        }

        func getRequestData() -> Data {
            CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.rateFallingAlert)
        }

        func parseResponse(data: Data) -> GetRateFallingAlertResponse {
            GetRateFallingAlertResponse(
                value: data[start] == 0x55
            )
        }
    }
}
