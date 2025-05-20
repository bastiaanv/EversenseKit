//
//  GetLastCalibrationDatePacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

struct GetLastCalibrationDateResponse {
    let date: DateComponents
}

class GetLastCalibrationDatePacket : BasePacket {
    typealias T = GetLastCalibrationDateResponse
    
    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.mostRecentCalibrationDate)
    }
    
    func parseResponse(data: Data) -> GetLastCalibrationDateResponse {
        return GetLastCalibrationDateResponse(
            date: BinaryOperations.toDateComponents(data: data, start: start)
        )
    }
}
