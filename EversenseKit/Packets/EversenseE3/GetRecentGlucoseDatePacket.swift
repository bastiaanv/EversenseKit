extension EversenseE3 {
    class GetRecentGlucoseDateResponse {
        let date: DateComponents

        init(date: DateComponents) {
            self.date = date
        }
    }

    class GetRecentGlucoseDatePacket: BasePacket {
        typealias T = GetRecentGlucoseDateResponse

        var response: PacketIds {
            PacketIds.readTwoByteSerialFlashRegisterResponseId
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
