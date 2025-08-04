class SetRateRisingThresholdResponse {}

class SetRateRisingThresholdPacket: BasePacket {
    typealias T = SetRateRisingThresholdResponse

    var response: PacketIds {
        PacketIds.writeSingleByteSerialFlashRegisterResponseId
    }

    let value: UInt8
    init(value: UInt8) {
        self.value = value
    }

    func getRequestData() -> Data {
        CommandOperations.writeSingleByteSerialFlashRegister(memoryAddress: FlashMemory.rateRisingThreshold, data: Data([value]))
    }

    func parseResponse(data _: Data) -> SetRateRisingThresholdResponse {
        SetRateRisingThresholdResponse()
    }
}
