struct GetPredictiveAlertsResponse {
    let value: Bool
}

class GetPredictiveAlertsPacket: BasePacket {
    typealias T = GetPredictiveAlertsResponse

    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.predictiveAlert)
    }

    func parseResponse(data: Data) -> GetPredictiveAlertsResponse {
        GetPredictiveAlertsResponse(
            value: data[start] == 0x55
        )
    }
}
