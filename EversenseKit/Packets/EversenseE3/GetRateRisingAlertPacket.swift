extension EversenseE3 {
    class GetRateRisingAlertResponse {
        let value: Bool

        init(value: Bool) {
            self.value = value
        }
    }

    class GetRateRisingAlertPacket: BasePacket {
        typealias T = GetRateRisingAlertResponse

        var responseType: UInt8 {
            PacketIds.readSingleByteSerialFlashRegisterResponseId.rawValue
        }

        var responseId: UInt8? {
            nil
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
}
