//
//  GetGlucoseAlertsAndStatusPacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

struct GetGlucoseAlertsAndStatusPacketResonse {}

class GetGlucoseAlertsAndStatusPacket : BasePacket {
    typealias T = GetGlucoseAlertsAndStatusPacketResonse
    
    var response: PacketIds {
        PacketIds.readSensorGlucoseAlertsAndStatusResponseId
    }
    
    func getRequestData() -> Data {
        var data = Data([0x10])
        let checksum = BinaryOperations.generateChecksumCRC16(data: data)
        data.append(BinaryOperations.dataFrom16Bits(value: checksum))
        
        return data
    }
    
    func parseResponse(data: Data) -> GetGlucoseAlertsAndStatusPacketResonse {
        // TODO: 
        return GetGlucoseAlertsAndStatusPacketResonse()
    }
}
