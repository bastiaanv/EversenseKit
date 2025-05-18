//
//  GetCompletedCalibrationsCountPacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 17/05/2025.
//

struct GetCompletedCalibrationsCountResponse {
    let value: UInt16
}

class GetCompletedCalibrationsCountPacket : BasePacket {
    typealias T = GetCompletedCalibrationsCountResponse
    
    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.calibrationsMadeInThisPhase)
    }
    
    func parseResponse(data: Data) -> GetCompletedCalibrationsCountResponse {
        return GetCompletedCalibrationsCountResponse(value: UInt16(data[0]) | UInt16(data[1] << 8))
    }
    
    
}
