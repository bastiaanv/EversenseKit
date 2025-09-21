extension EversenseE3 {
    class GetPredictiveAlertsResponse {
        let value: Bool

        init(value: Bool) {
            self.value = value
        }
    }

    class GetPredictiveAlertsPacket: BasePacket {
        typealias T = GetPredictiveAlertsResponse

        var responseType: UInt8 {
            PacketIds.readSingleByteSerialFlashRegisterResponseId.rawValue
        }

        var responseId: UInt8? {
            nil
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
}
