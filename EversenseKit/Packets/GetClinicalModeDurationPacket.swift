//
//  GetClinicalModeDurationPacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 20/05/2025.
//

struct GetClinicalModeDurationResponse {
    let value: TimeInterval
}

class GetClinicalModeDurationPacket : BasePacket {
    typealias T = GetClinicalModeDurationResponse
    
    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.clinicalModeDuration)
    }
    
    func parseResponse(data: Data) -> GetClinicalModeDurationResponse {
        let value = UInt16(data[start]) | (UInt16(data[start + 1]) << 8)
        return GetClinicalModeDurationResponse(
            value: .minutes(Double(value))
        )
    }
}
