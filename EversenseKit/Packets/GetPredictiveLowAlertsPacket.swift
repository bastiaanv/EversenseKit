struct GetPredictiveLowAlertsResponse {
    let value: Bool
}

class GetPredictiveLowAlertsPacket: BasePacket {
    typealias T = GetPredictiveLowAlertsResponse

    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.predictiveLowAlert)
    }

    func parseResponse(data: Data) -> GetPredictiveLowAlertsResponse {
        GetPredictiveLowAlertsResponse(
            value: data[start] == 0x55
        )
    }
}
