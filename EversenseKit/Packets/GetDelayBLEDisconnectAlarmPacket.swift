//
//  GetDelayBLEDisconnectAlarmPacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 22/05/2025.
//

struct GetDelayBLEDisconnectAlarmResponse {
    let value: TimeInterval
}

class GetDelayBLEDisconnectAlarmPacket : BasePacket {
    typealias T = GetDelayBLEDisconnectAlarmResponse
    
    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.delayBLEDisconnectAlarm)
    }
    
    func parseResponse(data: Data) -> GetDelayBLEDisconnectAlarmResponse {
        let value = UInt16(data[0]) | (UInt16(data[1]) << 8)
        return GetDelayBLEDisconnectAlarmResponse(
            value: .seconds(Double(value))
        )
    }
}
