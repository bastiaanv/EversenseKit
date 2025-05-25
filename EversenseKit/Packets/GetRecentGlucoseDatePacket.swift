//
//  GetRecentGlucoseDatePacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 25/05/2025.
//

struct GetRecentGlucoseDateResponse {
    let date: DateComponents
}

class GetRecentGlucoseDatePacket : BasePacket {
    typealias T = GetRecentGlucoseDateResponse
    
    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.mostRecentGlucoseDate)
    }
    
    func parseResponse(data: Data) -> GetRecentGlucoseDateResponse {
        return GetRecentGlucoseDateResponse(
            date: BinaryOperations.toDateComponents(data: data, start: start)
        )
    }
}
