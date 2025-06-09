struct GetLowGlucoseAlarmRepeatIntervalNightTimeResponse {
    let value: UInt8
}

class GetLowGlucoseAlarmRepeatIntervalNightTimePacket: BasePacket {
    typealias T = GetLowGlucoseAlarmRepeatIntervalNightTimeResponse

    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.lowGlucoseAlarmRepeatIntervalNightTime)
    }

    func parseResponse(data: Data) -> GetLowGlucoseAlarmRepeatIntervalNightTimeResponse {
        GetLowGlucoseAlarmRepeatIntervalNightTimeResponse(
            value: data[start]
        )
    }
}
