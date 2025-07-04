class GetEveningCalibrationTimeResponse {
    let value: DateComponents

    init(value: DateComponents) {
        self.value = value
    }
}

class GetEveningCalibrationTimePacket: BasePacket {
    typealias T = GetEveningCalibrationTimeResponse

    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.eveningCalibrationTime)
    }

    func parseResponse(data: Data) -> GetEveningCalibrationTimeResponse {
        let components = DateComponents(
            timeZone: GMTTimezone,
            hour: Int(data[start]),
            minute: Int(data[start + 1]),
            second: 0
        )
        return GetEveningCalibrationTimeResponse(value: components)
    }
}
