class GetSensorIdResponse {
    let value: String?

    init(value: String?) {
        self.value = value
    }
}

class GetSensorIdPacket: BasePacket {
    typealias T = GetSensorIdResponse

    private let unlinkedSensorId: UInt32 = 4_294_967_295

    var response: PacketIds {
        PacketIds.readFourByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readFourByteSerialFlashRegister(memoryAddress: FlashMemory.linkedSensorId)
    }

    func parseResponse(data: Data) -> GetSensorIdResponse {
        let id = UInt32(data[start]) | (UInt32(data[start + 1]) << 8) | (UInt32(data[start + 2]) << 16)
        var value: String? = String(id)

        let checkValue = id | (UInt32(data[start + 3]) << 24)
        if checkValue == 0 || checkValue == unlinkedSensorId {
            value = nil
        }

        return GetSensorIdResponse(value: value)
    }
}
