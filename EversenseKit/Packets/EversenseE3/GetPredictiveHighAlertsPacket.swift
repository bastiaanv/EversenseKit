extension EversenseE3 {
    class GetPredictiveHighAlertsResponse {
        let value: Bool

        init(value: Bool) {
            self.value = value
        }
    }

    class GetPredictiveHighAlertsPacket: BasePacket {
        typealias T = GetPredictiveHighAlertsResponse

        var responseType: UInt8 {
            PacketIds.readSingleByteSerialFlashRegisterResponseId.rawValue
        }

        var responseId: UInt8? {
            nil
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
}
