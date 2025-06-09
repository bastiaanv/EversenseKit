struct GetSensorInsertionTimeResponse {
    let time: DateComponents
}

class GetSensorInsertionTimePacket: BasePacket {
    typealias T = GetSensorInsertionTimeResponse

    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.sensorInsertionTime)
    }

    func parseResponse(data: Data) -> GetSensorInsertionTimeResponse {
        GetSensorInsertionTimeResponse(
            time: BinaryOperations.toTimeComponents(data: data, start: start)
        )
    }
}
