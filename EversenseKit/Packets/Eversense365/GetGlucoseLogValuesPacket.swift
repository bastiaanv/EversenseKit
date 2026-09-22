import LoopKit

extension Eversense365 {
    struct GlucoseHistoryItem {
        let valueInMgDl: UInt16
        let datetime: Date
        let trend: GlucoseTrend
        let raw: String
    }

    class GetGlucoseLogValuesResponse {
        let count: Int
        let glucoseHistory: [GlucoseHistoryItem]

        init(count: Int, glucoseHistory: [GlucoseHistoryItem]) {
            self.count = count
            self.glucoseHistory = glucoseHistory
        }
    }

    class GetGlucoseLogValuesPacket: BasePacket {
        typealias T = GetGlucoseLogValuesResponse

        var responseType: UInt8 {
            PacketIds.ReadLogsId.rawValue
        }

        var responseId: UInt8? {
            ReadIds.LogValue.rawValue
        }

        let from: UInt32
        let to: UInt32
        init(from: UInt32, to: UInt32) {
            self.from = from
            self.to = to
        }

        func getRequestData() -> Data {
            var data = Data([PacketIds.ReadCommandId.rawValue, ReadIds.LogValue.rawValue, LogTypes.Glucose.rawValue])
            data.append(BinaryOperations.dataFrom32Bits(value: from))
            data.append(BinaryOperations.dataFrom32Bits(value: to))
            return CryptoUtil.shared.encrypt(data: data)
        }

        func parseResponse(data: Data) -> GetGlucoseLogValuesResponse {
            guard data[6] == LogTypes.Glucose.rawValue else {
                logger.error("Invalid packet type received - expected: \(LogTypes.Glucose.rawValue), actual: \(data[6])")
                return GetGlucoseLogValuesResponse(count: 0, glucoseHistory: [])
            }

            let actualData = Data(data.subdata(in: 7 ..< data.count))
            let length: UInt32 = 193

            // Offset glucose value = sensorId + datetime + recordLength
            let offsetGlucose = Eversense365.sensorIdLength + 8 + 4

            // Offset trendDirection = offset Glucose + trend value
            let trendDirection = offsetGlucose + 2 + 4

            var history: [GlucoseHistoryItem] = []
            var i: UInt32 = 0
            while i + length <= actualData.count {
                let end = i + length
                let chunk = Data(actualData.subdata(in: Int(i) ..< Int(end)))

                let datetime = Date.fromUnix2000(data: chunk.subdata(in: 4 ..< 12))
                let glucose = UInt16(chunk[offsetGlucose]) + (UInt16(chunk[offsetGlucose + 1]) << 8)
                let trend = getTrend(value: chunk[trendDirection])

                i = end

                guard glucose < 0x01C2 else {
                    logger.warning("WARNING: glucose exceeds safety limits - value: \(glucose) mg/dl, datetime: \(datetime)")
                    continue
                }

                history.append(GlucoseHistoryItem(
                    valueInMgDl: glucose,
                    datetime: datetime,
                    trend: trend,
                    raw: "0x" + chunk.hexString().uppercased()
                ))
            }

            return GetGlucoseLogValuesResponse(
                count: history.count,
                glucoseHistory: history
            )
        }

        private func getTrend(value: UInt8) -> GlucoseTrend {
            switch value {
            case 0:
                return .flat // STALE
            case 1:
                return .downDown
            case 2:
                return .down
            case 4:
                return .flat
            case 8:
                return .up
            case 16:
                return .upUp
            case 32:
                return .downDownDown
            case 64:
                return .upUpUp
            default:
                return .flat // STALE
            }
        }
    }
}
