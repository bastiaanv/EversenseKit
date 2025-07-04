class GetHysteresisPredictivePercentageResponse {
    let value: UInt8

    init(value: UInt8) {
        self.value = value
    }
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
