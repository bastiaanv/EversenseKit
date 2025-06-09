struct GetAccelerometerValuesResponse {
    let value: UInt16
}

class GetAccelerometerValuesPacket: BasePacket {
    typealias T = GetAccelerometerValuesResponse

    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.accelerometerValues)
    }

    func parseResponse(data: Data) -> GetAccelerometerValuesResponse {
        GetAccelerometerValuesResponse(
            value: UInt16(data[start]) | (UInt16(data[start + 1]) << 8)
        )
    }
}
