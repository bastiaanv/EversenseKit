struct GetSensorInsertionDateResponse {
    let date: DateComponents
}

class GetSensorInsertionDatePacket: BasePacket {
    typealias T = GetSensorInsertionDateResponse

    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.sensorInsertionDate)
    }

    func parseResponse(data: Data) -> GetSensorInsertionDateResponse {
        GetSensorInsertionDateResponse(
            date: BinaryOperations.toDateComponents(data: data, start: start)
        )
    }
}
