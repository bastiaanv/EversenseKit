//
//  GetCommunicationProtocolVersionPacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 18/05/2025.
//

struct GetCommunicationProtocolVersionResponse {
    let version: String
}

class GetCommunicationProtocolVersionPacket : BasePacket {
    typealias T = GetCommunicationProtocolVersionResponse
    
    var response: PacketIds {
        PacketIds.readFourByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readFourByteSerialFlashRegister(memoryAddress: FlashMemory.communicationProtocolVersion)
    }
    
    func parseResponse(data: Data) -> GetCommunicationProtocolVersionResponse {
        let version = data[0..<4].compactMap { String(UnicodeScalar($0)) }.joined()
        return GetCommunicationProtocolVersionResponse(version: version)
    }
}
