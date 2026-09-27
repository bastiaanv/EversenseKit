extension Eversense365 {
    struct CalibrationHistoryItem {
        public let datetime: Date
        public let glucoseInMgDl: UInt16
        public let flag: CalibrationFlag
    }

    class GetCalibrationLogResponse {
        public let count: Int
        public let calibrationHistory: [CalibrationHistoryItem]

        init(count: Int, calibrationHistory: [CalibrationHistoryItem]) {
            self.count = count
            self.calibrationHistory = calibrationHistory
        }
    }

    class GetCalibrationLogPacket: BasePacket {
        typealias T = GetCalibrationLogResponse

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
            var data = Data([PacketIds.ReadCommandId.rawValue, ReadIds.LogValue.rawValue, LogTypes.Calibrations.rawValue])
            data.append(BinaryOperations.dataFrom32Bits(value: from))
            data.append(BinaryOperations.dataFrom32Bits(value: to))
            return data
        }

        func parseResponse(data: Data) -> GetCalibrationLogResponse {
            guard data[6] == LogTypes.Calibrations.rawValue else {
                logger.error("Invalid packet type received - expected: \(LogTypes.Glucose.rawValue), actual: \(data[6])")
                return GetCalibrationLogResponse(count: 0, calibrationHistory: [])
            }

            let actualData = Data(data.subdata(in: 7 ..< data.count))
            let length: UInt32 = 56

            // Offset glucose value = recordLength + datetime + FsStartEndFlag + ProcessingDateTime + SampleDateTime + MmaFSDateTime + DecisionDateTime
            let offsetGlucose = 4 + 8 + 2 + 8 + 8 + 8 + 8

            // Offset CalibrationFlag = offsetGlucose + MeterIdentifier
            let offsetCalibrationFlag = offsetGlucose + 2

            var history: [CalibrationHistoryItem] = []
            var i: UInt32 = 0
            while i + length < actualData.count {
                let end = i + length
                let chunk = Data(actualData.subdata(in: Int(i) ..< Int(end)))

                let datetime = Date.fromUnix2000(data: chunk.subdata(in: 4 ..< 12))
                let glucose = UInt16(chunk[offsetGlucose]) + (UInt16(chunk[offsetGlucose + 1]) << 8)
                let flag = CalibrationFlag(rawValue: chunk[offsetCalibrationFlag]) ?? .UNKNOWN_FAILURE

                i = end
                history.append(CalibrationHistoryItem(
                    datetime: datetime,
                    glucoseInMgDl: glucose,
                    flag: flag
                ))
            }

            return GetCalibrationLogResponse(
                count: history.count,
                calibrationHistory: history
            )
        }
    }
}
