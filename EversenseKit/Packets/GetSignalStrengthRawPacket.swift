//
//  GetSignalStrengthRaw.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

struct GetSignalStrengthRawResponse {
    let value: SignalStrength
    let rawValue: UInt16
}

class GetSignalStrengthRawPacket : BasePacket {
    typealias T = GetSignalStrengthRawResponse
    
    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.sensorFieldCurrentRaw)
    }
    
    func parseResponse(data: Data) -> GetSignalStrengthRawResponse {
        let value = UInt16(data[0]) | UInt16(data[1] << 8)
        var signalStrength = SignalStrength.NoSignal
        if value >= SignalStrength.Excellent.threshold {
            signalStrength = SignalStrength.Excellent
        } else if value >= SignalStrength.Good.threshold {
            signalStrength = SignalStrength.Good
        } else if value >= SignalStrength.Low.threshold {
            signalStrength = SignalStrength.Low
        } else if value >= SignalStrength.VeryLow.threshold {
            signalStrength = SignalStrength.VeryLow
        } else if value >= SignalStrength.Poor.threshold {
            signalStrength = SignalStrength.Poor
        }
        
        return GetSignalStrengthRawResponse(value: signalStrength, rawValue: value)
    }
}
