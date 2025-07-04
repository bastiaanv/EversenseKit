class GetLowGlucoseAlarmRepeatIntervalDayTimeResponse {
    let value: UInt8

    init(value: UInt8) {
        self.value = value
    }
}

class GetLowGlucoseAlarmRepeatIntervalDayTimePacket: BasePacket {
    typealias T = GetLowGlucoseAlarmRepeatIntervalDayTimeResponse

    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.lowGlucoseAlarmRepeatIntervalDayTime)
    }

    func parseResponse(data: Data) -> GetLowGlucoseAlarmRepeatIntervalDayTimeResponse {
        GetLowGlucoseAlarmRepeatIntervalDayTimeResponse(
            value: data[start]
        )
    }
}
