struct GetRateFallingThresholdResponse {
    let value: Double
}

class GetRateFallingThresholdPacket: BasePacket {
    typealias T = GetRateFallingThresholdResponse

    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.rateFallingThreshold)
    }

    func parseResponse(data: Data) -> GetRateFallingThresholdResponse {
        GetRateFallingThresholdResponse(
            value: Double(data[start]) / 10
        )
    }
}
