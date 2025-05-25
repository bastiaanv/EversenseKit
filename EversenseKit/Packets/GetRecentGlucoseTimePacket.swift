//
//  GetRecentGlucoseDateResponse.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 25/05/2025.
//


struct GetRecentGlucoseTimeResponse {
    let time: DateComponents
}

class GetRecentGlucoseTimePacket : BasePacket {
    typealias T = GetRecentGlucoseTimeResponse
    
    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.mostRecentGlucoseTime)
    }
    
    func parseResponse(data: Data) -> GetRecentGlucoseTimeResponse {
        return GetRecentGlucoseTimeResponse(
            time: BinaryOperations.toTimeComponents(data: data, start: start)
        )
    }
}
