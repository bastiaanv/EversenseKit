class GetCalibrationMaxThresholdResponse {
    let value: UInt16

    init(value: UInt16) {
        self.value = value
    }
}

class GetCalibrationMaxThresholdPacket: BasePacket {
    typealias T = GetCalibrationMaxThresholdResponse

    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.maxCalibrationThreshold)
    }

    func parseResponse(data: Data) -> GetCalibrationMaxThresholdResponse {
        GetCalibrationMaxThresholdResponse(
            value: UInt16(data[start]) | (UInt16(data[start + 1]) << 8)
        )
    }
}
