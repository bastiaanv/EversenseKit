struct GetLastCalibrationTimeResponse {
    let time: DateComponents
}

class GetLastCalibrationTimePacket: BasePacket {
    typealias T = GetLastCalibrationTimeResponse

    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.mostRecentCalibrationTime)
    }

    func parseResponse(data: Data) -> GetLastCalibrationTimeResponse {
        GetLastCalibrationTimeResponse(
            time: BinaryOperations.toTimeComponents(data: data, start: start)
        )
    }
}
