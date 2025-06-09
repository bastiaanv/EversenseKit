struct GetHighGlucoseAlarmResponse {
    let valueInMgDl: UInt16
}

class GetHighGlucoseAlarmPacket: BasePacket {
    typealias T = GetHighGlucoseAlarmResponse

    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.highGlucoseAlarmThreshold)
    }

    func parseResponse(data: Data) -> GetHighGlucoseAlarmResponse {
        GetHighGlucoseAlarmResponse(
            valueInMgDl: UInt16(data[start]) | (UInt16(data[start + 1]) << 8)
        )
    }
}
