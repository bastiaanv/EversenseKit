extension EversenseE3 {
    class GetRecentGlucoseDateResponse {
        let date: DateComponents

        init(date: DateComponents) {
            self.date = date
        }
    }

    class GetRecentGlucoseDatePacket: BasePacket {
        typealias T = GetRecentGlucoseDateResponse

        var responseType: UInt8 {
            PacketIds.readTwoByteSerialFlashRegisterResponseId.rawValue
        }

        var responseId: UInt8? {
            nil
        }

        func getRequestData() -> Data {
            CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.mostRecentGlucoseDate)
        }

        func parseResponse(data: Data) -> GetRecentGlucoseDateResponse {
            GetRecentGlucoseDateResponse(
                date: BinaryOperations.toDateComponents(data: data, start: start)
            )
        }
    }
}
