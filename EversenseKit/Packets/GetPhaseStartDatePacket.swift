class GetPhaseStartDateResponse {
    let date: DateComponents

    init(date: DateComponents) {
        self.date = date
    }
}

class GetPhaseStartDatePacket: BasePacket {
    typealias T = GetPhaseStartDateResponse

    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.startDateOfCalibrationPhase)
    }

    func parseResponse(data: Data) -> GetPhaseStartDateResponse {
        GetPhaseStartDateResponse(
            date: BinaryOperations.toDateComponents(data: data, start: start)
        )
    }
}
