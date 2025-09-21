extension EversenseE3 {
    class GetDelayBLEDisconnectAlarmResponse {
        let value: TimeInterval

        init(value: TimeInterval) {
            self.value = value
        }
    }

    class GetDelayBLEDisconnectAlarmPacket: BasePacket {
        typealias T = GetDelayBLEDisconnectAlarmResponse

        var responseType: UInt8 {
            PacketIds.readTwoByteSerialFlashRegisterResponseId.rawValue
        }

        var responseId: UInt8? {
            nil
        }

        func getRequestData() -> Data {
            CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.delayBLEDisconnectAlarm)
        }

        func parseResponse(data: Data) -> GetDelayBLEDisconnectAlarmResponse {
            let value = UInt16(data[0]) | (UInt16(data[1]) << 8)
            return GetDelayBLEDisconnectAlarmResponse(
                value: .seconds(Double(value))
            )
        }
    }
}
