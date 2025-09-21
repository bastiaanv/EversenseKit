extension EversenseE3 {
    class GetCurrentCalibrationPhaseResponse {
        let phase: CalibrationPhase

        init(phase: CalibrationPhase) {
            self.phase = phase
        }
    }

    class GetCurrentCalibrationPhasePacket: BasePacket {
        typealias T = GetCurrentCalibrationPhaseResponse

        var responseType: UInt8 {
            PacketIds.readSingleByteSerialFlashRegisterResponseId.rawValue
        }

        var responseId: UInt8? {
            nil
        }

        func getRequestData() -> Data {
            CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.currentCalibrationPhase)
        }

        func parseResponse(data: Data) -> GetCurrentCalibrationPhaseResponse {
            GetCurrentCalibrationPhaseResponse(
                phase: CalibrationPhase(rawValue: data[start]) ?? .UNKNOWN
            )
        }
    }
}
