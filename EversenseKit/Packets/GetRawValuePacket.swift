class GetRawValueResponse {
    let value: UInt16

    init(value: UInt16) {
        self.value = value
    }
}

class GetRawValuePacket: BasePacket {
    typealias T = GetRawValueResponse

    private let memory: FlashMemory
    init(memory: FlashMemory) {
        self.memory = memory
    }

    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: memory)
    }

    func parseResponse(data: Data) -> GetRawValueResponse {
        GetRawValueResponse(
            value: UInt16(data[start]) | (UInt16(data[start + 1]) << 8)
        )
    }
}
