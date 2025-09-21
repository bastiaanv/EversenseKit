extension EversenseE3 {
    class GetPhaseStartTimeResponse {
        let time: DateComponents

        init(time: DateComponents) {
            self.time = time
        }
    }

    class GetPhaseStartTimePacket: BasePacket {
        typealias T = GetPhaseStartTimeResponse

        var responseType: UInt8 {
            PacketIds.readTwoByteSerialFlashRegisterResponseId.rawValue
        }

        var responseId: UInt8? {
            nil
        }

        func getRequestData() -> Data {
            CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.startTimeOfCalibrationPhase)
        }

        func parseResponse(data: Data) -> GetPhaseStartTimeResponse {
            GetPhaseStartTimeResponse(
                time: BinaryOperations.toTimeComponents(data: data, start: start)
            )
        }
    }
}
