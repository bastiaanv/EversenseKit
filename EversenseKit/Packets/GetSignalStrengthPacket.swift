//
//  GetSignalStrengthPacket.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

struct GetSignalStrengthResponse {
    let value: SignalStrength
}

class GetSignalStrengthPacket : BasePacket {
    typealias T = GetSignalStrengthResponse
    
    var response: PacketIds {
        PacketIds.readTwoByteSerialFlashRegisterResponseId
    }
    
    func getRequestData() -> Data {
        return CommandOperations.readTwoByteSerialFlashRegister(memoryAddress: FlashMemory.sensorFieldCurrent)
    }
    
    func parseResponse(data: Data) -> GetSignalStrengthResponse {
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
        
        return GetSignalStrengthResponse(value: signalStrength)
    }
}
