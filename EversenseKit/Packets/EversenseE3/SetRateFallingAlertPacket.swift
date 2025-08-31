extension EversenseE3 {
    class SetRateFallingAlertResponse {}

    class SetRateFallingAlertPacket: BasePacket {
        typealias T = SetRateFallingAlertResponse

        var response: PacketIds {
            PacketIds.writeSingleByteSerialFlashRegisterResponseId
        }

        let value: UInt8
        init(enabled: Bool) {
            value = enabled ? 0x55 : 0x00
        }

        func getRequestData() -> Data {
            CommandOperations.writeSingleByteSerialFlashRegister(memoryAddress: FlashMemory.rateFallingAlert, data: Data([value]))
        }

        func parseResponse(data _: Data) -> SetRateFallingAlertResponse {
            SetRateFallingAlertResponse()
        }
    }
}
