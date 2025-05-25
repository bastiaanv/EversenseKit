//
//  GetHighGlucoseTargetResponse.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 22/05/2025.
//


struct GetLowGlucoseTargetResponse {
    let valueInMgDl: UInt16
}

class GetLowGlucoseTargetPacket : BasePacket {
    typealias T = GetLowGlucoseTargetResponse
    
    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.lowGlucoseTarget)
    }
    
    func parseResponse(data: Data) -> GetLowGlucoseTargetResponse {
        return GetLowGlucoseTargetResponse(
            valueInMgDl: UInt16(data[start]) | (UInt16(data[start+1]) << 8)
        )
    }
}
