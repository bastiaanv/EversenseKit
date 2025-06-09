struct GetUnlinkedSensorIdResponse {
    let value: String?
}

class GetUnlinkedSensorIdPacket: BasePacket {
    typealias T = GetUnlinkedSensorIdResponse

    private let unlinkedSensorId: UInt32 = 4_294_967_295

    var response: PacketIds {
        PacketIds.readFourByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readFourByteSerialFlashRegister(memoryAddress: FlashMemory.unlinkedSensorId)
    }

    func parseResponse(data: Data) -> GetUnlinkedSensorIdResponse {
        let id = UInt32(data[start]) | (UInt32(data[start + 1]) << 8) | (UInt32(data[start + 2]) << 16)
        var value: String? = String(id)

        let checkValue = id | (UInt32(data[start + 3]) << 24)
        if checkValue == 0 || checkValue == unlinkedSensorId {
            value = nil
        }

        return GetUnlinkedSensorIdResponse(value: value)
    }
}
