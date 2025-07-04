class GetPredictiveRisingTimeIntervalResponse {
    let value: TimeInterval

    init(value: TimeInterval) {
        self.value = value
    }
}

class GetPredictiveRisingTimeIntervalPacket: BasePacket {
    typealias T = GetPredictiveRisingTimeIntervalResponse

    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.predictiveRisingTime)
    }

    func parseResponse(data: Data) -> GetPredictiveRisingTimeIntervalResponse {
        GetPredictiveRisingTimeIntervalResponse(
            value: .minutes(Double(data[start]))
        )
    }
}
