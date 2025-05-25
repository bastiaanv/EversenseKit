//
//  GetRecentGlucoseValue.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 25/05/2025.
//

struct GetRecentGlucoseValueResponse {
    let valueInMgDl: UInt16
}

class GetRecentGlucoseValuePacket : BasePacket {
    typealias T = GetRecentGlucoseValueResponse
    
    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.mostRecentGlucoseValue)
    }
    
    func parseResponse(data: Data) -> GetRecentGlucoseValueResponse {
        return GetRecentGlucoseValueResponse(
            valueInMgDl: UInt16(data[start]) | (UInt16(data[start + 1]) << 8)
        )
    }
}
