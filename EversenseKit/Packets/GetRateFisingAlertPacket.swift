struct GetRateRisingAlertResponse {
    let value: Bool
}

class GetRateRisingAlertPacket: BasePacket {
    typealias T = GetRateRisingAlertResponse

    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.rateRisingAlert)
    }

    func parseResponse(data: Data) -> GetRateRisingAlertResponse {
        GetRateRisingAlertResponse(
            value: data[start] == 0x55
        )
    }
}
