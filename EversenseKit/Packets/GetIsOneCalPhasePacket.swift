//
//  GetIsOneCalPhasePacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 17/05/2025.
//

struct GetIsOneCalPhaseResponse {
    let value: Bool
}

class GetIsOneCalPhasePacket : BasePacket {
    typealias T = GetIsOneCalPhaseResponse
    
    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.isOneCalPhase)
    }
    
    func parseResponse(data: Data) -> GetIsOneCalPhaseResponse {
        return GetIsOneCalPhaseResponse(value: data[0] == 1)
    }
}
