extension Eversense365 {
    class GetActiveAlarmsResponse {
        let count: UInt8
        let alarms: [ActiveAlarm]

        init(count: UInt8, alarms: [ActiveAlarm]) {
            self.count = count
            self.alarms = alarms
        }
    }

    class GetActiveAlarmsPacket: BasePacket {
        typealias T = GetActiveAlarmsResponse

        var responseType: UInt8 {
            PacketIds.ReadResponseId.rawValue
        }

        var responseId: UInt8? {
            ReadIds.ActiveAlerts.rawValue
        }

        let currentGlucose: UInt16
        init(currentGlucose: UInt16) {
            self.currentGlucose = currentGlucose
        }

        func getRequestData() -> Data {
            let data = Data([PacketIds.ReadCommandId.rawValue, ReadIds.ActiveAlerts.rawValue])
            return CryptoUtil.shared.encrypt(data: data)
        }

        /// Parsed message:
        /// 42 22 -> CmdType & CmdId
        /// 03 -> Active alarm count
        /// 06 07 0b -> Alarm 1: SensorAwolAlarm
        /// 43 03 36 -> Alarm 2: SmfSyncFailed
        /// 45 00 38 -> Alarm 3: OtaUpgradeComplete
        ///
        /// 42 22 -> CmdType & CmdId
        /// 03 -> Active alarm count
        /// 0b 00 16 -> Alarm 1: LowGlucoseAlarm
        /// 17 04 19 -> Alarm 2: SensorRetiringSoon6Alarm
        /// 04 07 09 -> Alarm 3: SensorLowTemperatureAlarm
        func parseResponse(data: Data) -> GetActiveAlarmsResponse {
            let count = data[Offset.NoOfAlerts]
            var alarms: [ActiveAlarm] = []

            for i in 0 ..< Int(count) {
                let offsetStart = i * 3 + 3
                guard data.count >= offsetStart + 2 else {
                    let message =
                        "Missing data for alarms - data: \(data.hexString()), count: \(count), offsetStart: \(offsetStart)"
                    logger.warning(message)
                    break
                }

                alarms.append(ActiveAlarm(
                    code: Alarm(rawValue: data[offsetStart]) ?? .unknown,
                    datetime: Date.now,
                    glucoseInMgDl: currentGlucose,
                    flag: data[offsetStart + 1],
                    priority: data[offsetStart + 2],
                ))
            }

            alarms.sort(by: { $0.priority < $1.priority })
            return GetActiveAlarmsResponse(
                count: count,
                alarms: alarms
            )
        }

        enum Offset {
            static let NoOfAlerts = 2

            // Offset within the chunk
            static let Code = 0
            static let Flag = 1
            static let Priority = 2
        }
    }
}
