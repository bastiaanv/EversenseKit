//
//  GetLastCalibrationDatePacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

struct GetLastCalibrationDatePacketResponse {
    let date: DateComponents
}

class GetLastCalibrationDatePacket : BasePacket {
    typealias T = GetLastCalibrationDatePacketResponse
    
    static var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.mostRecentCalibrationDateAddress)
    }
    
    static func parseResponse(data: Data) -> GetLastCalibrationDatePacketResponse {
        return GetLastCalibrationDatePacketResponse(
            date: BinaryOperations.toDateComponents(data: data)
        )
    }
}
