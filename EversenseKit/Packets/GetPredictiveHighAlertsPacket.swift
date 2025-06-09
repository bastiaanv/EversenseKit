struct GetPredictiveHighAlertsResponse {
    let value: Bool
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
