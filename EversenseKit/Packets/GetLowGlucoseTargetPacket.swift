struct GetLowGlucoseTargetResponse {
    let valueInMgDl: UInt16
}

class GetLowGlucoseTargetPacket: BasePacket {
    typealias T = GetLowGlucoseTargetResponse

    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.lowGlucoseTarget)
    }

    func parseResponse(data: Data) -> GetLowGlucoseTargetResponse {
        GetLowGlucoseTargetResponse(
            valueInMgDl: UInt16(data[start]) | (UInt16(data[start + 1]) << 8)
        )
    }
}
