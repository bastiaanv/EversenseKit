struct GetHysteresisPredictiveValueResponse {
    let valueInMgDl: UInt8
}

class GetHysteresisPredictiveValuePacket: BasePacket {
    typealias T = GetHysteresisPredictiveValueResponse

    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.hysteresisPredictiveValue)
    }

    func parseResponse(data: Data) -> GetHysteresisPredictiveValueResponse {
        GetHysteresisPredictiveValueResponse(
            valueInMgDl: data[start]
        )
    }
}
