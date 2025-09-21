extension EversenseE3 {
    class GetRecentGlucoseTimeResponse {
        let time: DateComponents

        init(time: DateComponents) {
            self.time = time
        }
    }

    class GetRecentGlucoseTimePacket: BasePacket {
        typealias T = GetRecentGlucoseTimeResponse

        var responseType: UInt8 {
            PacketIds.readTwoByteSerialFlashRegisterResponseId.rawValue
        }

        var responseId: UInt8? {
            nil
        }

        func getRequestData() -> Data {
            CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.mostRecentGlucoseTime)
        }

        func parseResponse(data: Data) -> GetRecentGlucoseTimeResponse {
            GetRecentGlucoseTimeResponse(
                time: BinaryOperations.toTimeComponents(data: data, start: start)
            )
        }
    }
}
