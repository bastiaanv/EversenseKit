struct GetDelayBLEDisconnectAlarmResponse {
    let value: TimeInterval
}

class GetDelayBLEDisconnectAlarmPacket: BasePacket {
    typealias T = GetDelayBLEDisconnectAlarmResponse

    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.delayBLEDisconnectAlarm)
    }

    func parseResponse(data: Data) -> GetDelayBLEDisconnectAlarmResponse {
        let value = UInt16(data[0]) | (UInt16(data[1]) << 8)
        return GetDelayBLEDisconnectAlarmResponse(
            value: .seconds(Double(value))
        )
    }
}
