//
//  GetBatteryVoltagePacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

struct GetBatteryVoltageResponse {
    let value: Double
}

class GetBatteryVoltagePacket : BasePacket {
    typealias T = GetBatteryVoltageResponse
    
    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterCommandId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.batteryVoltage)
    }
    
    func parseResponse(data: Data) -> GetBatteryVoltageResponse {
        return GetBatteryVoltageResponse(value: Double((data[0] | ((data[1]) << 8))) * 0.006)
    }
}
