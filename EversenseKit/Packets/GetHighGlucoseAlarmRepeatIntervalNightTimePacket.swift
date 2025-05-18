//
//  GetLowGlucoseAlarmRepeatIntervalNightTimeResponse.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 18/05/2025.
//


struct GetHighGlucoseAlarmRepeatIntervalNightTimeResponse {
    let value: UInt8
}

class GetHighGlucoseAlarmRepeatIntervalNightTimePacket : BasePacket {
    typealias T = GetHighGlucoseAlarmRepeatIntervalNightTimeResponse
    
    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.highGlucoseAlarmRepeatIntervalNightTime)
    }
    
    func parseResponse(data: Data) -> GetHighGlucoseAlarmRepeatIntervalNightTimeResponse {
        return GetHighGlucoseAlarmRepeatIntervalNightTimeResponse(value: data[0])
    }
}
