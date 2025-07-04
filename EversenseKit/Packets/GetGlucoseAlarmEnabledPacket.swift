class GetGlucoseAlarmEnabledResponse {
    let value: Bool

    init(value: Bool) {
        self.value = value
    }
}

class GetGlucoseAlarmEnabledPacket: BasePacket {
    typealias T = GetGlucoseAlarmEnabledResponse

    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.highGlucoseAlarmEnabled)
    }

    func parseResponse(data: Data) -> GetGlucoseAlarmEnabledResponse {
        GetGlucoseAlarmEnabledResponse(
            value: data[start] == 0x55
        )
    }
}
