extension EversenseE3 {
    class GetRateAlertResponse {
        let value: Bool

        init(value: Bool) {
            self.value = value
        }
    }

    class GetRateAlertPacket: BasePacket {
        typealias T = GetRateAlertResponse

        var responseType: UInt8 {
            PacketIds.readSingleByteSerialFlashRegisterResponseId.rawValue
        }

        var responseId: UInt8? {
            nil
        }

        func getRequestData() -> Data {
            CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.rateAlert)
        }

        func parseResponse(data: Data) -> GetRateAlertResponse {
            GetRateAlertResponse(
                value: data[start] == 0x55
            )
        }
    }
}
