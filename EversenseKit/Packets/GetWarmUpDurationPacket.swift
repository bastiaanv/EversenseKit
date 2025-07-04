class GetWarmUpDurationResponse {
    let value: TimeInterval

    init(value: TimeInterval) {
        self.value = value
    }
}

class GetWarmUpDurationPacket: BasePacket {
    typealias T = GetWarmUpDurationResponse

    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.warmUpDuration)
    }

    func parseResponse(data: Data) -> GetWarmUpDurationResponse {
        let value = UInt16(data[start]) | (UInt16(data[start + 1]) << 8)
        return GetWarmUpDurationResponse(
            value: .hours(Double(value))
        )
    }
}
