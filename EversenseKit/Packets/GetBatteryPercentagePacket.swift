//
//  GetBatteryPercentagePacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

struct GetBatteryPercentagePacketResponse {
    let value: BatteryLevel
}

class GetBatteryPercentagePacket : BasePacket {
    typealias T = GetBatteryPercentagePacketResponse
    
    static var response: PacketIds {
        PacketIds.readSingleByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readSingleByteSerialFlashRegister(memoryAddress: FlashMemory.batteryPercentageAddress)
    }
    
    static func parseResponse(data: Data) -> GetBatteryPercentagePacketResponse {
        return GetBatteryPercentagePacketResponse(
            value: BatteryLevel(rawValue: data[0]) ?? .unknown
        )
    }
}
