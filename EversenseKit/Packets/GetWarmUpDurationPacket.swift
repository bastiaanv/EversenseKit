//
//  GetWarmUpDuration.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 20/05/2025.
//

struct GetWarmUpDurationResponse {
    let value: TimeInterval
}

class GetWarmUpDurationPacket : BasePacket {
    typealias T = GetWarmUpDurationResponse
    
    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.warmUpDuration)
    }
    
    func parseResponse(data: Data) -> GetWarmUpDurationResponse {
        let value = UInt16(data[start]) | (UInt16(data[start+1]) << 8)
        return GetWarmUpDurationResponse(
            value: .hours(Double(value))
        )
    }
}
