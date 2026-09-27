extension Eversense365 {
    struct AlertHistoryItem {
        public let datetime: Date
        public let code: Alarm
    }

    class GetAlertLogResponse {
        public let count: Int
        public let alertHistory: [AlertHistoryItem]

        init(count: Int, alertHistory: [AlertHistoryItem]) {
            self.count = count
            self.alertHistory = alertHistory
        }
    }

    class GetAlertLogPacket: BasePacket {
        typealias T = GetAlertLogResponse

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
            var data = Data([PacketIds.ReadCommandId.rawValue, ReadIds.LogValue.rawValue, LogTypes.Alerts.rawValue])
            data.append(BinaryOperations.dataFrom32Bits(value: from))
            data.append(BinaryOperations.dataFrom32Bits(value: to))
            return data
        }

        func parseResponse(data: Data) -> GetAlertLogResponse {
            guard data[6] == LogTypes.Alerts.rawValue else {
                logger.error("Invalid packet type received - expected: \(LogTypes.Glucose.rawValue), actual: \(data[6])")
                return GetAlertLogResponse(count: 0, alertHistory: [])
            }

            let actualData = Data(data.subdata(in: 7 ..< data.count))
            let length: UInt32 = 60

            var history: [AlertHistoryItem] = []
            var i: UInt32 = 0
            while i + length < actualData.count {
                let end = i + length
                let chunk = Data(actualData.subdata(in: Int(i) ..< Int(end)))

                let datetime = Date.fromUnix2000(data: chunk.subdata(in: 4 ..< 12))
                let code = chunk[12]

                i = end
                history.append(AlertHistoryItem(
                    datetime: datetime,
                    code: Alarm(rawValue: code) ?? .unknown
                ))
            }

            return GetAlertLogResponse(
                count: history.count,
                alertHistory: history
            )
        }
    }
}
