extension EversenseE3 {
    class GetBatteryPercentageResponse {
        let value: BatteryLevel

        init(value: BatteryLevel) {
            self.value = value
        }
    }

    class GetBatteryPercentagePacket: BasePacket {
        typealias T = GetBatteryPercentageResponse

        var responseType: UInt8 {
            PacketIds.readSingleByteSerialFlashRegisterResponseId.rawValue
        }

        var responseId: UInt8? {
            nil
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
}
