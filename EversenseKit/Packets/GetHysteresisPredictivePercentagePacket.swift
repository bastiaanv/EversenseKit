struct GetHysteresisPredictivePercentageResponse {
    let value: UInt8
}

class GetHysteresisPredictivePercentagePacket: BasePacket {
    typealias T = GetHysteresisPredictivePercentageResponse

    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.hysteresisPredictivePercentage)
    }

    func parseResponse(data: Data) -> GetHysteresisPredictivePercentageResponse {
        GetHysteresisPredictivePercentageResponse(
            value: data[start]
        )
    }
}
