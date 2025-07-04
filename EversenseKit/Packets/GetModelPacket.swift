class GetModelResponse {
    let model: String

    init(model: String) {
        self.model = model
    }
}

class GetModelPacket: BasePacket {
    typealias T = GetModelResponse

    var response: PacketIds {
        PacketIds.readFourByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readFourByteSerialFlashRegister(memoryAddress: FlashMemory.transmitterModelNumber)
    }

    func parseResponse(data: Data) -> GetModelResponse {
        GetModelResponse(
            model: "\(UInt32(data[start]) | (UInt32(data[start + 1]) << 8) | (UInt32(data[start + 2]) << 16) | (UInt32(data[start + 3]) << 24))"
        )
    }
}
