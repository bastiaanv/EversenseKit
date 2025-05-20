//
//  GetLowGlucoseAlarmRepeatIntervalDayTimeResponse.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 18/05/2025.
//


struct GetHighGlucoseAlarmRepeatIntervalDayTimeResponse {
    let value: UInt8
}

class GetHighGlucoseAlarmRepeatIntervalDayTimePacket : BasePacket {
    typealias T = GetHighGlucoseAlarmRepeatIntervalDayTimeResponse
    
    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.highGlucoseAlarmRepeatIntervalDayTime)
    }
    
    func parseResponse(data: Data) -> GetHighGlucoseAlarmRepeatIntervalDayTimeResponse {
        return GetHighGlucoseAlarmRepeatIntervalDayTimeResponse(
            value: data[start]
        )
    }
}
