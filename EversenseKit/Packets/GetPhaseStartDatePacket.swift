//
//  GetPhaseStartDatePacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

struct GetPhaseStartDatePacketResponse {
    let date: DateComponents
}

class GetPhaseStartDatePacket : BasePacket {
    typealias T = GetPhaseStartDatePacketResponse
    
    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.startDateOfCalibrationPhaseAddress)
    }
    
    func parseResponse(data: Data) -> GetPhaseStartDatePacketResponse {
        return GetPhaseStartDatePacketResponse(date: BinaryOperations.toDateComponents(data: data))
    }
}
