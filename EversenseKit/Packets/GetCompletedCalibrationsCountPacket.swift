struct GetCompletedCalibrationsCountResponse {
    let value: UInt16
}

class GetCompletedCalibrationsCountPacket: BasePacket {
    typealias T = GetCompletedCalibrationsCountResponse

    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.calibrationsMadeInThisPhase)
    }

    func parseResponse(data: Data) -> GetCompletedCalibrationsCountResponse {
        GetCompletedCalibrationsCountResponse(
            value: UInt16(data[start]) | (UInt16(data[start + 1]) << 8)
        )
    }
}
