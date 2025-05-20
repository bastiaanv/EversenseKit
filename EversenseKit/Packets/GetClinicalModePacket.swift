//
//  GetClinicalModePacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 20/05/2025.
//

struct GetClinicalModeResponse {
    let value: Bool
}

class GetClinicalModePacket : BasePacket {
    typealias T = GetClinicalModeResponse
    
    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.clinicalMode)
    }
    
    func parseResponse(data: Data) -> GetClinicalModeResponse {
        return GetClinicalModeResponse(
            value: data[start] == 0x55
        )
    }
}
