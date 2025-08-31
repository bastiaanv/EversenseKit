extension EversenseE3 {
    class GetBatteryVoltageResponse {
        let value: Double

        init(value: Double) {
            self.value = value
        }
    }

    class GetBatteryVoltagePacket: BasePacket {
        typealias T = GetBatteryVoltageResponse

        var response: PacketIds {
            PacketIds.readTwoByteSerialFlashRegisterResponseId
        }

        func getRequestData() -> Data {
            CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.batteryVoltage)
        }

        func parseResponse(data: Data) -> GetBatteryVoltageResponse {
            GetBatteryVoltageResponse(value: Double(data[0] | (data[1] << 8)) * 0.006)
        }
    }
}
