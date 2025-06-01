//
//  SetNightStartTimePacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 17/05/2025.
//

struct SetNightStartTimeResponse {}

class SetNightStartTimePacket: BasePacket {
    typealias T = SetNightStartTimeResponse
    
    private let nightStartTime: Date
    init(nightStartTime: Date) {
        self.nightStartTime = nightStartTime
    }
    
    var response: PacketIds {
        PacketIds.writeTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        let hour = UInt8(Calendar.current.component(.hour, from: nightStartTime))
        let minute = UInt8(Calendar.current.component(.minute, from: nightStartTime))
        
        return CommandOperations.writeTwoByteSerialFlashRegister(
            memoryAddress: FlashMemory.nightStartTime,
            data: Data([hour, minute])
        )
    }
    
    func parseResponse(data: Data) -> SetNightStartTimeResponse {
        return SetNightStartTimeResponse()
    }
    
    
}
