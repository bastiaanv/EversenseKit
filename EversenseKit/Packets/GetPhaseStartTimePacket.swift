//
//  GetPhaseStartTimePacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

struct GetPhaseStartTimeResponse {
    let time: DateComponents
}

class GetPhaseStartTimePacket : BasePacket {
    typealias T = GetPhaseStartTimeResponse
    
    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.startTimeOfCalibrationPhase)
    }
    
    func parseResponse(data: Data) -> GetPhaseStartTimeResponse {
        return GetPhaseStartTimeResponse(time: BinaryOperations.toTimeComponents(data: data))
    }
}
