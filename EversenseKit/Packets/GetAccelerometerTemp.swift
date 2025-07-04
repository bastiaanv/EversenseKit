class GetAccelerometerTempResponse {
    let value: UInt16

    init(value: UInt16) {
        self.value = value
    }
}

class GetAccelerometerTempPacket: BasePacket {
    typealias T = GetAccelerometerTempResponse

    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.accelerometerTemp)
    }

    func parseResponse(data: Data) -> GetAccelerometerTempResponse {
        GetAccelerometerTempResponse(
            value: UInt16(data[start]) | (UInt16(data[start + 1]) << 8)
        )
    }
}
