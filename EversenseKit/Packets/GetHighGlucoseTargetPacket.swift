struct GetHighGlucoseTargetResponse {
    let valueInMgDl: UInt16
}

class GetHighGlucoseTargetPacket: BasePacket {
    typealias T = GetHighGlucoseTargetResponse

    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.highGlucoseTarget)
    }

    func parseResponse(data: Data) -> GetHighGlucoseTargetResponse {
        GetHighGlucoseTargetResponse(
            valueInMgDl: UInt16(data[start]) | (UInt16(data[start + 1]) << 8)
        )
    }
}
