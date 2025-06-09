struct GetPredictiveFallingTimeIntervalResponse {
    let value: TimeInterval
}

class GetPredictiveFallingTimeIntervalPacket: BasePacket {
    typealias T = GetPredictiveFallingTimeIntervalResponse

    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.predictiveFallingTime)
    }

    func parseResponse(data: Data) -> GetPredictiveFallingTimeIntervalResponse {
        GetPredictiveFallingTimeIntervalResponse(
            value: .minutes(Double(data[start]))
        )
    }
}
