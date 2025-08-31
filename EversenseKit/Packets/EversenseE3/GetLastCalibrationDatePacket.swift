extension EversenseE3 {
    class GetLastCalibrationDateResponse {
        let date: DateComponents

        init(date: DateComponents) {
            self.date = date
        }
    }

    class GetLastCalibrationDatePacket: BasePacket {
        typealias T = GetLastCalibrationDateResponse

        var response: PacketIds {
            PacketIds.readTwoByteSerialFlashRegisterResponseId
        }

        func getRequestData() -> Data {
            CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.mostRecentCalibrationDate)
        }

        func parseResponse(data: Data) -> GetLastCalibrationDateResponse {
            GetLastCalibrationDateResponse(
                date: BinaryOperations.toDateComponents(data: data, start: start)
            )
        }
    }
}
