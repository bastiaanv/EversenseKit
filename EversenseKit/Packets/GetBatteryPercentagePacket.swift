//
//  GetBatteryPercentagePacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

struct GetBatteryPercentageResponse {
    let value: BatteryLevel
}

class GetBatteryPercentagePacket : BasePacket {
    typealias T = GetBatteryPercentageResponse
    
    var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.batteryPercentage)
    }
    
    func parseResponse(data: Data) -> GetBatteryPercentageResponse {
        return GetBatteryPercentageResponse(
            value: BatteryLevel(rawValue: data[start]) ?? .unknown
        )
    }
}
