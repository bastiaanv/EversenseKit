//
//  GetLastCalibrationTimePacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

struct GetLastCalibrationTimeResponse {
    let time: DateComponents
}

class GetLastCalibrationTimePacket : BasePacket {
    typealias T = GetLastCalibrationTimeResponse
    
    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.mostRecentCalibrationTime)
    }
    
    func parseResponse(data: Data) -> GetLastCalibrationTimeResponse {
        return GetLastCalibrationTimeResponse(
            time: BinaryOperations.toTimeComponents(data: data, start: start)
        )
    }
}
