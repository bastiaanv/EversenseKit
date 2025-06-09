struct GetHysteresisValueResponse {
    let valueInMgDl: UInt8
}

class GetHysteresisValuePacket: BasePacket {
    typealias T = GetHysteresisValueResponse

    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.hysteresisValue)
    }

    func parseResponse(data: Data) -> GetHysteresisValueResponse {
        GetHysteresisValueResponse(
            valueInMgDl: data[start]
        )
    }
}
