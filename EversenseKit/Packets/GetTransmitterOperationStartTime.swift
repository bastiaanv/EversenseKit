struct GetTransmitterOperationStartTimeResponse {
    let time: DateComponents
}

class GetTransmitterOperationStartTime: BasePacket {
    typealias T = GetTransmitterOperationStartTimeResponse

    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.transmitterOperationStartTime)
    }

    func parseResponse(data: Data) -> GetTransmitterOperationStartTimeResponse {
        GetTransmitterOperationStartTimeResponse(
            time: BinaryOperations.toTimeComponents(data: data, start: start)
        )
    }
}
