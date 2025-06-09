struct GetHysteresisPercentageResponse {
    let value: UInt8
}

class GetHysteresisPercentagePacket: BasePacket {
    typealias T = GetHysteresisPercentageResponse

    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.hysteresisPercentage)
    }

    func parseResponse(data: Data) -> GetHysteresisPercentageResponse {
        GetHysteresisPercentageResponse(
            value: data[start]
        )
    }
}
