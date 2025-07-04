class GetTransmitterOperationStartTimeResponse {
    let time: DateComponents

    init(time: DateComponents) {
        self.time = time
    }
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
