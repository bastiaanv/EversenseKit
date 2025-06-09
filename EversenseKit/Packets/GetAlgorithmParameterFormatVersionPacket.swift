struct GetAlgorithmParameterFormatVersionResponse {
    let value: UInt16
}

class GetAlgorithmParameterFormatVersionPacket: BasePacket {
    typealias T = GetAlgorithmParameterFormatVersionResponse

    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.algorithmParameterFormatVersion)
    }

    func parseResponse(data: Data) -> GetAlgorithmParameterFormatVersionResponse {
        GetAlgorithmParameterFormatVersionResponse(
            value: UInt16(data[start]) | (UInt16(data[start + 1]) << 8)
        )
    }
}
