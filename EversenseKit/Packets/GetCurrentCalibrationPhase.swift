//
//  GetCurrentCalibrationPhase.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 17/05/2025.
//

struct GetCurrentCalibrationPhaseResponse {
    let phase: CalibrationPhase
}

class GetCurrentCalibrationPhasePacket : BasePacket {
    typealias T = GetCurrentCalibrationPhaseResponse
    
    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.currentCalibrationPhase)
    }
    
    func parseResponse(data: Data) -> GetCurrentCalibrationPhaseResponse {
        return GetCurrentCalibrationPhaseResponse(
            phase: CalibrationPhase(rawValue: data[start]) ?? .UNKNOWN
        )
    }
}
