struct GetEEP24MSPResponse {
    let value: Float
}

class GetEEP24MSPPacket: BasePacket {
    typealias T = GetEEP24MSPResponse

    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.eep24MSP)
    }

    func parseResponse(data: Data) -> GetEEP24MSPResponse {
        GetEEP24MSPResponse(
            value: 1.0 - Float(data[start + 1]) / 255.0
        )
    }
}
