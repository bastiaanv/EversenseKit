extension EversenseE3 {
    class SetRateRisingAlertResponse {}

    class SetRateRisingAlertPacket: BasePacket {
        typealias T = SetRateRisingAlertResponse

        var responseType: UInt8 {
            PacketIds.writeSingleByteSerialFlashRegisterResponseId.rawValue
        }

        var responseId: UInt8? {
            nil
        }

        let value: UInt8
        init(enabled: Bool) {
            value = enabled ? 0x55 : 0x00
        }

        func getRequestData() -> Data {
            CommandOperations.writeSingleByteSerialFlashRegister(memoryAddress: FlashMemory.rateRisingAlert, data: Data([value]))
        }

        func parseResponse(data _: Data) -> SetRateRisingAlertResponse {
            SetRateRisingAlertResponse()
        }
    }
}
