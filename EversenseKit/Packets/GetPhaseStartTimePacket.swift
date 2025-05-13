//
//  GetPhaseStartTimePacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

struct GetPhaseStartTimePacketResponse {
    let time: DateComponents
}

class GetPhaseStartTimePacket : BasePacket {
    typealias T = GetPhaseStartTimePacketResponse
    
    static var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.startTimeOfCalibrationPhaseAddress)
    }
    
    static func parseResponse(data: Data) -> GetPhaseStartTimePacketResponse {
        return GetPhaseStartTimePacketResponse(time: BinaryOperations.toTimeComponents(data: data))
    }
}
