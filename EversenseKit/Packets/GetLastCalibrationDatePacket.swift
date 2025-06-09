struct GetLastCalibrationDateResponse {
    let date: DateComponents
}

class GetLastCalibrationDatePacket: BasePacket {
    typealias T = GetLastCalibrationDateResponse

    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.mostRecentCalibrationDate)
    }

    func parseResponse(data: Data) -> GetLastCalibrationDateResponse {
        GetLastCalibrationDateResponse(
            date: BinaryOperations.toDateComponents(data: data, start: start)
        )
    }
}
