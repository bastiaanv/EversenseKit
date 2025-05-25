//
//  SetBatteryMonitorThresholdPacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 25/05/2025.
//

struct SetBatteryMonitorThresholdResponse {}

class SetBatteryMonitorThresholdPacket : BasePacket {
    typealias T = SetBatteryMonitorThresholdResponse
    
    private let tempThresholdWarning: UInt8
    private let tempThresholdModeChange: UInt8
    var response: PacketIds {
        PacketIds.testResponseId
    }
    
    init(tempThresholdWarning: UInt8, tempThresholdModeChange: UInt8) {
        self.tempThresholdWarning = tempThresholdWarning
        self.tempThresholdModeChange = tempThresholdModeChange
    }
    
    func getRequestData() -> Data {
        var data = Data([0x60, 0x2A, tempThresholdWarning, tempThresholdModeChange])
        let crc = BinaryOperations.dataFrom16Bits(value: BinaryOperations.generateChecksumCRC16(data: data))
        
        data.append(data)
        return data
    }
    
    func parseResponse(data: Data) -> SetBatteryMonitorThresholdResponse {
        return SetBatteryMonitorThresholdResponse()
    }
}
