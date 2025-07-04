class GetMorningCalibrationTimeResponse {
    let value: DateComponents

    init(value: DateComponents) {
        self.value = value
    }
}

class GetMorningCalibrationTimePacket: BasePacket {
    typealias T = GetMorningCalibrationTimeResponse

    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.morningCalibrationTime)
    }

    func parseResponse(data: Data) -> GetMorningCalibrationTimeResponse {
        let components = DateComponents(
            timeZone: GMTTimezone,
            hour: Int(data[start]),
            minute: Int(data[start + 1]),
            second: 0
        )
        return GetMorningCalibrationTimeResponse(value: components)
    }
}
