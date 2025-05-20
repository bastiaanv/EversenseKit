//
//  GetAlgorithmParameterFormatVersionPacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 18/05/2025.
//

struct GetAlgorithmParameterFormatVersionResponse {
    let value: UInt16
}

class GetAlgorithmParameterFormatVersionPacket : BasePacket {
    typealias T = GetAlgorithmParameterFormatVersionResponse
    
    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.algorithmParameterFormatVersion)
    }
    
    func parseResponse(data: Data) -> GetAlgorithmParameterFormatVersionResponse {
        return GetAlgorithmParameterFormatVersionResponse(
            value: UInt16(data[start]) | (UInt16(data[start+1]) << 8)
        )
    }
}
