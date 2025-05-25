//
//  GetHighGlucoseTargetPacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 22/05/2025.
//

struct GetHighGlucoseTargetResponse {
    let valueInMgDl: UInt16
}

class GetHighGlucoseTargetPacket : BasePacket {
    typealias T = GetHighGlucoseTargetResponse
    
    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.highGlucoseTarget)
    }
    
    func parseResponse(data: Data) -> GetHighGlucoseTargetResponse {
        return GetHighGlucoseTargetResponse(
            valueInMgDl: UInt16(data[start]) | (UInt16(data[start+1]) << 8)
        )
    }
}
