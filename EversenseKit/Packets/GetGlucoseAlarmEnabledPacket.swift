//
//  GetGlucoseAlarmEnabledPacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 25/05/2025.
//

struct GetGlucoseAlarmEnabledResponse {
    let value: Bool
}

class GetGlucoseAlarmEnabledPacket : BasePacket {
    typealias T = GetGlucoseAlarmEnabledResponse
    
    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.highGlucoseAlarmEnabled)
    }
    
    func parseResponse(data: Data) -> GetGlucoseAlarmEnabledResponse {
        return GetGlucoseAlarmEnabledResponse(
            value: data[start] == 0x55
        )
    }
}
