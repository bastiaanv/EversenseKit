class GetHysteresisPredictiveValueResponse {
    let valueInMgDl: UInt8

    init(valueInMgDl: UInt8) {
        self.valueInMgDl = valueInMgDl
    }
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
