extension Eversense365 {
    class GetLogRangeResponse {
        let rangeFrom: UInt32
        let rangeTo: UInt32

        init(rangeFrom: UInt32, rangeTo: UInt32) {
            self.rangeFrom = rangeFrom
            self.rangeTo = rangeTo
        }
    }

    class GetLogRangePacket: BasePacket {
        typealias T = GetLogRangeResponse

        var responseType: UInt8 {
            PacketIds.ReadResponseId.rawValue
        }

        var responseId: UInt8? {
            readId
        }

        private let readId: UInt8
        private let logType: LogTypes
        init(communicationVersion: Double, logType: LogTypes) {
            if communicationVersion >= 1.06 {
                readId = ReadIds.LogRange.rawValue
            } else {
                readId = ReadIds.LogRangeOld.rawValue
            }

            self.logType = logType
        }

        func getRequestData() -> Data {
            Data([PacketIds.ReadCommandId.rawValue, readId, logType.rawValue])
        }

        /// Parsed message:
        /// 42 38 -> CmdType & CmdId
        /// 06 -> Blood glucose
        /// 00 00 00 00 -> From range
        /// 00 00 00 00 -> To range
        func parseResponse(data: Data) -> GetLogRangeResponse {
            GetLogRangeResponse(
                rangeFrom: UInt32(data.subdata(in: 3 ..< 7).toUInt64()),
                rangeTo: UInt32(data.subdata(in: 7 ..< 11).toUInt64())
            )
        }
    }
}
