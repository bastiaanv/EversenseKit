//
//  GetVersionPacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

struct GetVersionResponse {
    let version: String
}

class GetVersionPacket : BasePacket {
    typealias T = GetVersionResponse
    
    var response: PacketIds {
        PacketIds.readFourByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readFourByteSerialFlashRegister(memoryAddress: FlashMemory.transmitterSoftwareVersion)
    }
    
    func parseResponse(data: Data) -> GetVersionResponse {
        let version = data[0..<4].compactMap { String(UnicodeScalar($0)) }.joined()
        return GetVersionResponse(version: version)
    }
}
