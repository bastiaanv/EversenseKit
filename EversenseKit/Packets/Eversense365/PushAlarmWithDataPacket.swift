extension Eversense365 {
    class PushAlarmWithDataResponse {
        let alarm: ActiveAlarm
        let alarmRaw: UInt8
        let datetime: Date

        init(alarm: ActiveAlarm, alarmRaw: UInt8, datetime: Date) {
            self.alarm = alarm
            self.alarmRaw = alarmRaw
            self.datetime = datetime
        }
    }

    class PushAlarmWithDataPacket: BasePacket {
        typealias T = PushAlarmWithDataResponse

        var responseType: UInt8 {
            PacketIds.NotificationId.rawValue
        }

        var responseId: UInt8? {
            PushIds.AlarmWithData.rawValue
        }

        let currentGlucose: UInt16
        init(currentGlucose: UInt16) {
            self.currentGlucose = currentGlucose
        }

        func getRequestData() -> Data {
            // Unused
            Data()
        }

        /// Parsed message:
        /// 44 03 -> CmdType & CmdId
        /// 06 -> Alarm code
        /// 00 08 b2 e1 c4 00 00 00 -> Alarm datetime
        /// 03 00 00 00 00 03 00 00 00 00 00 00 00 00 00 00 -> Alarm data
        func parseResponse(data: Data) -> Eversense365.PushAlarmWithDataResponse {
            guard data.count >= 12 else {
                logger.warning("AlarmWithData notification too short - count: \(data.count)")
                return PushAlarmWithDataResponse(
                    alarm: ActiveAlarm(code: .unknown, datetime: Date.now, glucoseInMgDl: currentGlucose, flag: 0, priority: 0),
                    alarmRaw: 0,
                    datetime: Date.now
                )
            }

            return PushAlarmWithDataResponse(
                alarm: ActiveAlarm(
                    code: Alarm(rawValue: data[2]) ?? .unknown,
                    datetime: Date.now,
                    glucoseInMgDl: currentGlucose,
                    flag: 0,
                    priority: 0
                ),
                alarmRaw: data[2],
                datetime: Date.fromUnix2000(data: data.subdata(in: 4 ..< 12)),
            )
        }
    }
}
