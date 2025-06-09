struct GetMmaFeaturesResponse {
    let value: UInt8
}

class GetMmaFeaturesPacket: BasePacket {
    typealias T = GetMmaFeaturesResponse

    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.mmaFeatures)
    }

    func parseResponse(data: Data) -> GetMmaFeaturesResponse {
        GetMmaFeaturesResponse(
            value: data[start]
        )
    }
}
