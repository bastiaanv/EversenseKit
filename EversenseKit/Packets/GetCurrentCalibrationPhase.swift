class GetCurrentCalibrationPhaseResponse {
    let phase: CalibrationPhase

    init(phase: CalibrationPhase) {
        self.phase = phase
    }
}

class GetCurrentCalibrationPhasePacket: BasePacket {
    typealias T = GetCurrentCalibrationPhaseResponse

    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
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
