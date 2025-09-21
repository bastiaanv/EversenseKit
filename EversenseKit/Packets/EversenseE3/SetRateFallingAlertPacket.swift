extension EversenseE3 {
    class SetRateFallingAlertResponse {}

    class SetRateFallingAlertPacket: BasePacket {
        typealias T = SetRateFallingAlertResponse

        var responseType: UInt8 {
            PacketIds.writeSingleByteSerialFlashRegisterResponseId.rawValue
        }

        var responseId: UInt8? {
            nil
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
