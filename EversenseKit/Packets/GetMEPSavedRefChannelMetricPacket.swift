struct GetMEPSavedRefChannelMetricResponse {
    let value: Float
}

class GetMEPSavedRefChannelMetricPacket: BasePacket {
    typealias T = GetMEPSavedRefChannelMetricResponse

    var response: PacketIds {
        PacketIds.readFourByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readFourByteSerialFlashRegister(memoryAddress: FlashMemory.mepSavedRefChannelMetric)
    }

    func parseResponse(data: Data) -> GetMEPSavedRefChannelMetricResponse {
        let bits = UInt32(data[start]) | (UInt32(data[start + 1]) << 8) | (UInt32(data[start + 2]) << 16) |
            (UInt32(data[start + 3]) << 24)
        return GetMEPSavedRefChannelMetricResponse(value: Float(bitPattern: bits))
    }
}
