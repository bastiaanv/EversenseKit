class SetHighGlucoseAlarmEnabledResponse {}

class SetHighGlucoseAlarmEnabledPacket: BasePacket {
    typealias T = SetHighGlucoseAlarmEnabledResponse

    var response: PacketIds {
        PacketIds.writeSingleByteSerialFlashRegisterResponseId
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
