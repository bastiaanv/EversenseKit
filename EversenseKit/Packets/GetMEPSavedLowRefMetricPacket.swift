class GetMEPSavedLowRefMetricResponse {
    let value: Float

    init(value: Float) {
        self.value = value
    }
}

class GetMEPSavedLowRefMetricPacket: BasePacket {
    typealias T = GetMEPSavedLowRefMetricResponse

    var response: PacketIds {
        PacketIds.readFourByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readFourByteSerialFlashRegister(memoryAddress: FlashMemory.mepSavedLowRefMetric)
    }

    func parseResponse(data: Data) -> GetMEPSavedLowRefMetricResponse {
        let bits = UInt32(data[start]) | (UInt32(data[start + 1]) << 8) | (UInt32(data[start + 2]) << 16) |
            (UInt32(data[start + 3]) << 24)
        return GetMEPSavedLowRefMetricResponse(value: Float(bitPattern: bits))
    }
}
