class GetSensorSamplingIntervalResponse {
    let value: TimeInterval

    init(value: TimeInterval) {
        self.value = value
    }
}

class GetSensorSamplingIntervalPacket: BasePacket {
    typealias T = GetSensorSamplingIntervalResponse

    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.sensorGlucoseSamplingInterval)
    }

    func parseResponse(data: Data) -> GetSensorSamplingIntervalResponse {
        let value = UInt16(data[start]) | (UInt16(data[start + 1]) << 8)
        return GetSensorSamplingIntervalResponse(
            value: .seconds(Double(value))
        )
    }
}
