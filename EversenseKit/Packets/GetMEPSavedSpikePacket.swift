struct GetMEPSavedSpikeResponse {
    let value: Float
}

class GetMEPSavedSpikePacket: BasePacket {
    typealias T = GetMEPSavedSpikeResponse

    var response: PacketIds {
        PacketIds.readFourByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readFourByteSerialFlashRegister(memoryAddress: FlashMemory.mepSavedSpike)
    }

    func parseResponse(data: Data) -> GetMEPSavedSpikeResponse {
        let bits = UInt32(data[start]) | (UInt32(data[start + 1]) << 8) | (UInt32(data[start + 2]) << 16) |
            (UInt32(data[start + 3]) << 24)
        return GetMEPSavedSpikeResponse(value: Float(bitPattern: bits))
    }
}
