import LoopKit

struct GetGlucoseDataResponse {
    let trend: GlucoseTrend?
}

class GetGlucoseDataPacket: BasePacket {
    typealias T = GetGlucoseDataResponse

    var response: PacketIds {
        PacketIds.readSensorGlucoseResponseId
    }

    func getRequestData() -> Data {
        var data = Data([8])
        let checksum = BinaryOperations.generateChecksumCRC16(data: data)
        data.append(BinaryOperations.dataFrom16Bits(value: checksum))

        return data
    }

    func parseResponse(data: Data) -> GetGlucoseDataResponse {
        // TODO: Need to extra more data???
        GetGlucoseDataResponse(
            trend: getTrend(value: data[start + 13])
        )
    }

    func getTrend(value: UInt8) -> GlucoseTrend? {
        switch value {
        case 0:
            return nil // STALE
        case 1:
            return .downDown
        case 2:
            return .down
        case 3:
            return .flat
        case 4:
            return .up
        case 5:
            return .upUp
        default:
            return nil // STALE
        }
    }
}
