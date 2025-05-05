//
//  GetBatteryVoltagePacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

struct GetBatteryVoltagePacketResponse {
    let value: Double
}

class GetBatteryVoltagePacket : BasePacket {
    typealias T = GetBatteryVoltagePacketResponse
    
    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterCommandId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.batteryVoltageAddress)
    }
    
    func parseResponse(data: Data) -> GetBatteryVoltagePacketResponse {
        return GetBatteryVoltagePacketResponse(value: Double((data[0] | (data[1] << 8))) * 0.006)
    }
}
