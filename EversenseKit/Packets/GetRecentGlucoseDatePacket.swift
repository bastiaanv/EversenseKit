struct GetRecentGlucoseDateResponse {
    let date: DateComponents
}

class GetRecentGlucoseDatePacket: BasePacket {
    typealias T = GetRecentGlucoseDateResponse

    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.mostRecentGlucoseDate)
    }

    func parseResponse(data: Data) -> GetRecentGlucoseDateResponse {
        GetRecentGlucoseDateResponse(
            date: BinaryOperations.toDateComponents(data: data, start: start)
        )
    }
}
