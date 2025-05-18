//
//  SetDayStartTimePacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 17/05/2025.
//

struct SetDayStartTimeResponse {}

class SetDayStartTimePacket : BasePacket {
    typealias T = SetDayStartTimeResponse
    
    private let dayStartTime: Date
    init(dayStartTime: Date) {
        self.dayStartTime = dayStartTime
    }
    
    var response: PacketIds {
        PacketIds.writeTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        let hour = UInt8(Calendar.current.component(.hour, from: dayStartTime))
        let minute = UInt8(Calendar.current.component(.minute, from: dayStartTime))
        
        return CommandOperations.writeTwoByteSerialFlashRegister(
            memoryAddress: FlashMemory.dayStartTimeAddress,
            data: Data([hour, minute])
        )
    }
    
    func parseResponse(data: Data) -> SetDayStartTimeResponse {
        return SetDayStartTimeResponse()
    }
}
