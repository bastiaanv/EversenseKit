class GetPredictiveHighAlertsResponse {
    let value: Bool

    init(value: Bool) {
        self.value = value
    }
}

class GetPredictiveHighAlertsPacket: BasePacket {
    typealias T = GetPredictiveHighAlertsResponse

    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.predictiveHighAlert)
    }

    func parseResponse(data: Data) -> GetPredictiveHighAlertsResponse {
        GetPredictiveHighAlertsResponse(
            value: data[start] == 0x55
        )
    }
}
