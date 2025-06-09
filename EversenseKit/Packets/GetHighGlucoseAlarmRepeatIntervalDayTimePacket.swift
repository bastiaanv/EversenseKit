struct GetHighGlucoseAlarmRepeatIntervalDayTimeResponse {
    let value: UInt8
}

class GetHighGlucoseAlarmRepeatIntervalDayTimePacket: BasePacket {
    typealias T = GetHighGlucoseAlarmRepeatIntervalDayTimeResponse

    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.highGlucoseAlarmRepeatIntervalDayTime)
    }

    func parseResponse(data: Data) -> GetHighGlucoseAlarmRepeatIntervalDayTimeResponse {
        GetHighGlucoseAlarmRepeatIntervalDayTimeResponse(
            value: data[start]
        )
    }
}
