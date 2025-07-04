class GetTransmitterOperationStartDateResponse {
    let date: DateComponents

    init(date: DateComponents) {
        self.date = date
    }
}

class GetTransmitterOperationStartDate: BasePacket {
    typealias T = GetTransmitterOperationStartDateResponse

    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.transmitterOperationStartDate)
    }

    func parseResponse(data: Data) -> GetTransmitterOperationStartDateResponse {
        GetTransmitterOperationStartDateResponse(
            date: BinaryOperations.toDateComponents(data: data, start: start)
        )
    }
}
