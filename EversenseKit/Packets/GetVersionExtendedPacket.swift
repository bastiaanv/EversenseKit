//
//  GetVersionPacket 2.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

struct GetVersionExtendedResponse {
    let extVersion: String
}

class GetVersionExtendedPacket : BasePacket {
    typealias T = GetVersionExtendedResponse
    
    var response: PacketIds {
        PacketIds.readFourByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readFourByteSerialFlashRegister(memoryAddress: FlashMemory.transmitterSoftwareVersionExt)
    }
    
    func parseResponse(data: Data) -> GetVersionExtendedResponse {
        let extVersion = data[0..<4].compactMap { String(UnicodeScalar($0)) }.joined()
        return GetVersionExtendedResponse(extVersion: extVersion)
    }
}
