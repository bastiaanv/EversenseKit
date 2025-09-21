extension EversenseE3 {
    class SetHighGlucoseAlarmEnabledResponse {}

    class SetHighGlucoseAlarmEnabledPacket: BasePacket {
        typealias T = SetHighGlucoseAlarmEnabledResponse

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
            CommandOperations.writeSingleByteSerialFlashRegister(
                memoryAddress: FlashMemory.highGlucoseAlarmEnabled,
                data: Data([value])
            )
        }

        func parseResponse(data _: Data) -> SetHighGlucoseAlarmEnabledResponse {
            SetHighGlucoseAlarmEnabledResponse()
        }
    }
}
