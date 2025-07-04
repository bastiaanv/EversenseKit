class GetCalibrationMinThresholdResponse {
    let value: UInt16

    init(value: UInt16) {
        self.value = value
    }
}

class GetCalibrationMinThresholdPacket: BasePacket {
    typealias T = GetCalibrationMinThresholdResponse

    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.minCalibrationThreshold)
    }

    func parseResponse(data: Data) -> GetCalibrationMinThresholdResponse {
        GetCalibrationMinThresholdResponse(
            value: UInt16(data[start]) | (UInt16(data[start + 1]) << 8)
        )
    }
}
