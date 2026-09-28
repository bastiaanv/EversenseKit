extension Eversense365 {
    class SetBloodGlucosePointResponse {}

    class SetBloodGlucosePointPacket: BasePacket {
        typealias T = SetBloodGlucosePointResponse

        var responseType: UInt8 {
            PacketIds.WriteResponseId.rawValue
        }

        var responseId: UInt8? {
            WriteIds.Calibration.rawValue
        }

        let glucoseInMgDl: UInt16
        let timestamp: Date
        init(glucoseInMgDl: UInt16, timestamp: Date) {
            self.glucoseInMgDl = glucoseInMgDl
            self.timestamp = timestamp
        }

        func getRequestData() -> Data {
            var data = Data([PacketIds.WriteCommandId.rawValue, WriteIds.Calibration.rawValue])

            data.append(timestamp.toUnix2000())
            data.append(Date.now.toUnix2000())
            data.append(BinaryOperations.dataFrom16Bits(value: glucoseInMgDl))
            data.append(Data([1, 0, 0]))

            return data
        }

        /// Parse response:
        /// 43 0C -> CmdType & CmdId
        /// ?? -> Calibration ENUM
        func parseResponse(data _: Data) -> SetBloodGlucosePointResponse {
            SetBloodGlucosePointResponse()
        }
    }
}
