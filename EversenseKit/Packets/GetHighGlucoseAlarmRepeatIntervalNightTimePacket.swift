class GetHighGlucoseAlarmRepeatIntervalNightTimeResponse {
    let value: UInt8

    init(value: UInt8) {
        self.value = value
    }
}

class GetHighGlucoseAlarmRepeatIntervalNightTimePacket: BasePacket {
    typealias T = GetHighGlucoseAlarmRepeatIntervalNightTimeResponse

    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.highGlucoseAlarmRepeatIntervalNightTime)
    }

    func parseResponse(data: Data) -> GetHighGlucoseAlarmRepeatIntervalNightTimeResponse {
        GetHighGlucoseAlarmRepeatIntervalNightTimeResponse(
            value: data[start]
        )
    }
}
