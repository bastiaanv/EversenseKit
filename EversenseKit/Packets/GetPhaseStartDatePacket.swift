//
//  GetPhaseStartDatePacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

struct GetPhaseStartDateResponse {
    let date: DateComponents
}

class GetPhaseStartDatePacket : BasePacket {
    typealias T = GetPhaseStartDateResponse
    
    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.startDateOfCalibrationPhase)
    }
    
    func parseResponse(data: Data) -> GetPhaseStartDateResponse {
        return GetPhaseStartDateResponse(date: BinaryOperations.toDateComponents(data: data))
    }
}
