struct GetBatteryPercentageResponse {
    let value: BatteryLevel
}

class GetBatteryPercentagePacket: BasePacket {
    typealias T = GetBatteryPercentageResponse

    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }

    func getRequestData() -> Data {
        CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.batteryPercentage)
    }

    func parseResponse(data: Data) -> GetBatteryPercentageResponse {
        GetBatteryPercentageResponse(
            value: BatteryLevel(rawValue: data[start]) ?? .unknown
        )
    }
}
