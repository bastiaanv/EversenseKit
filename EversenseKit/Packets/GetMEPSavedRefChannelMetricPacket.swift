//
//  GetMEPSavedRefChannelMetricPacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 18/05/2025.
//

struct GetMEPSavedRefChannelMetricResponse {
    let value: Float
}

class GetMEPSavedRefChannelMetricPacket : BasePacket {
    typealias T = GetMEPSavedRefChannelMetricResponse
    
    var response: PacketIds {
        PacketIds.readFourByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readFourByteSerialFlashRegister(memoryAddress: FlashMemory.mepSavedRefChannelMetric)
    }
    
    func parseResponse(data: Data) -> GetMEPSavedRefChannelMetricResponse {
        let bits = UInt32(data[0]) | UInt32(data[1] << 8) | UInt32(data[2] << 16) | UInt32(data[3] << 24)
        return GetMEPSavedRefChannelMetricResponse(value: Float(bitPattern: bits))
    }
}
