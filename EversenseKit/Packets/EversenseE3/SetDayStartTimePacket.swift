extension EversenseE3 {
    class SetDayStartTimeResponse {}

    class SetDayStartTimePacket: BasePacket {
        typealias T = SetDayStartTimeResponse

        private let dayStartTime: Date
        init(dayStartTime: Date) {
            self.dayStartTime = dayStartTime
        }

        var responseType: UInt8 {
            PacketIds.writeTwoByteSerialFlashRegisterResponseId.rawValue
        }

        var responseId: UInt8? {
            nil
        }

        func getRequestData() -> Data {
            let hour = UInt8(Calendar.current.component(.hour, from: dayStartTime))
            let minute = UInt8(Calendar.current.component(.minute, from: dayStartTime))

            return CommandOperations.writeTwoByteSerialFlashRegister(
                memoryAddress: FlashMemory.dayStartTime,
                data: Data([hour, minute])
            )
        }

        func parseResponse(data _: Data) -> SetDayStartTimeResponse {
            SetDayStartTimeResponse()
        }
    }
}
