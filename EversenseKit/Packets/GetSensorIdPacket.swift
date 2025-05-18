//
//  GetSensorIdPacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 18/05/2025.
//

struct GetSensorIdResponse {
    let value: String?
}

class GetSensorIdPacket : BasePacket {
    typealias T = GetSensorIdResponse
    
    private let unlinkedSensorId: UInt32 = 4294967295
    
    var response: PacketIds {
        PacketIds.readFourByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readFourByteSerialFlashRegisterResponseId(memoryAddress: FlashMemory.linkedSensorId)
    }
    
    func parseResponse(data: Data) -> GetSensorIdResponse {
        let id = UInt32(data[0]) | UInt32(data[1] << 8) | UInt32(data[2] << 16)
        var value: String? = String(id)
        
        let checkValue = id | UInt32(data[3] << 24)
        if checkValue == 0 || checkValue == unlinkedSensorId {
            value = nil
        }
        
        return GetSensorIdResponse(value: value)
    }
}
