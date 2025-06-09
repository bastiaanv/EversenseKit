struct GetBatteryVoltageResponse {
    let value: Double
}

class GetBatteryVoltagePacket: BasePacket {
    typealias T = GetBatteryVoltageResponse

    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterCommandId
    }

    func getRequestData() -> Data {
        CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.batteryVoltage)
    }

    func parseResponse(data: Data) -> GetBatteryVoltageResponse {
        GetBatteryVoltageResponse(value: Double(data[0] | (data[1] << 8)) * 0.006)
    }
}
