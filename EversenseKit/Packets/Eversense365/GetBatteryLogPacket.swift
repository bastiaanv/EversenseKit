extension Eversense365 {
    struct GetBatteryLogResponse {
        let count: Int
        let logs: [BatteryReadings]
    }

    class GetBatteryLogPacket: BasePacket {
        typealias T = GetBatteryLogResponse

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
            var data = Data([PacketIds.ReadCommandId.rawValue, ReadIds.LogValue.rawValue, LogTypes.Battery.rawValue])
            data.append(BinaryOperations.dataFrom32Bits(value: from))
            data.append(BinaryOperations.dataFrom32Bits(value: to))
            return CryptoUtil.shared.encrypt(data: data)
        }

        func parseResponse(data: Data) -> GetBatteryLogResponse {
            guard data[6] == LogTypes.Battery.rawValue else {
                logger.error("Invalid packet type received - expected: \(LogTypes.Battery.rawValue), actual: \(data[6])")
                return GetBatteryLogResponse(count: 0, logs: [])
            }

            let actualData = Data(data.subdata(in: 7 ..< data.count))
            let length: UInt32 = 37

            var logs: [BatteryReadings] = []
            var i: UInt32 = 0
            while i + length <= actualData.count {
                let end = i + length
                let chunk = Data(actualData.subdata(in: Int(i) ..< Int(end)))

                let record = UInt32(chunk.subdata(in: 0 ..< 4).toUInt64())
                let datetime = Date.fromUnix2000(data: chunk.subdata(in: 4 ..< 12))

                i = end

                logs.append(BatteryReadings(
                    value: chunk,
                    datetime: datetime,
                    recordId: record
                ))
            }

            return GetBatteryLogResponse(
                count: logs.count,
                logs: logs
            )
        }
    }
}
