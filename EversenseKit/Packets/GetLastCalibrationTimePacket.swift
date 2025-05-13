//
//  GetLastCalibrationTimePacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

struct GetLastCalibrationTimePacketResponse {
    let time: DateComponents
}

class GetLastCalibrationTimePacket : BasePacket {
    typealias T = GetLastCalibrationTimePacketResponse
    
    static var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.mostRecentCalibrationTimeAddress)
    }
    
    static func parseResponse(data: Data) -> GetLastCalibrationTimePacketResponse {
        return GetLastCalibrationTimePacketResponse(time: BinaryOperations.toTimeComponents(data: data))
    }
}
