struct GetLowGlucoseAlarmResponse {
    let valueInMgDl: UInt16
}

class GetLowGlucoseAlarmPacket: BasePacket {
    typealias T = GetLowGlucoseAlarmResponse

    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.lowGlucoseAlarmThreshold)
    }

    func parseResponse(data: Data) -> GetLowGlucoseAlarmResponse {
        GetLowGlucoseAlarmResponse(
            valueInMgDl: UInt16(data[start]) | (UInt16(data[start + 1]) << 8)
        )
    }
}
