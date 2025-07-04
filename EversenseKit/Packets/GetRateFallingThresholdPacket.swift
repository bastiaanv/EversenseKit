class GetRateFallingThresholdResponse {
    let value: Double

    init(value: Double) {
        self.value = value
    }
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
