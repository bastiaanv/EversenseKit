extension EversenseE3 {
    class GetGlucoseAlertsAndStatusPacketResonse {
        let alarms: [ActiveAlarm]

        init(alarms: [ActiveAlarm]) {
            self.alarms = alarms
        }
    }

    class GetGlucoseAlertsAndStatusPacket: BasePacket {
        typealias T = GetGlucoseAlertsAndStatusPacketResonse

        private let STATUS_FLAG_COUNT = 13

        var responseType: UInt8 {
            PacketIds.readSensorGlucoseAlertsAndStatusResponseId.rawValue
        }

        var responseId: UInt8? {
            nil
        }

        let currentGlucose: UInt16
        init(currentGlucose: UInt16) {
            self.currentGlucose = currentGlucose
        }

        func getRequestData() -> Data {
            var data = Data([0x10])
            let checksum = BinaryOperations.generateChecksumCRC16(data: data)
            data.append(BinaryOperations.dataFrom16Bits(value: checksum))

            return data
        }

        func parseResponse(data: Data) -> GetGlucoseAlertsAndStatusPacketResonse {
            var content = data.subdata(in: start ..< data.count)
            if content.count < STATUS_FLAG_COUNT {
                content.append(Data(repeating: 0, count: STATUS_FLAG_COUNT - content.count))
            }

            if content.max() == 0 {
                return GetGlucoseAlertsAndStatusPacketResonse(alarms: [])
            }

            var alarms: [Alarm] = []

            if content[0] != 0, let mc = MessageCoder.messageCodeForGlucoseLevelAlarmFlags(content[0]) {
                alarms.append(mc)
            }
            if content[1] != 0, let mc = MessageCoder.messageCodeForGlucoseLevelAlertFlags(content[1]) {
                alarms.append(mc)
            }
            if content[2] != 0, let mc = MessageCoder.messageCodeForRateAlertFlags(content[2]) {
                alarms.append(mc)
            }
            if content[3] != 0, let mc = MessageCoder.messageCodeForPredictiveAlertFlags(content[3]) {
                alarms.append(mc)
            }
            if content[4] != 0, let mc = MessageCoder.messageCodeForSensorHardwareAndAlertFlags(content[4]) {
                alarms.append(mc)
            }
            if content[5] != 0, let mc = MessageCoder.messageCodeForSensorReadAlertFlags(content[5]) {
                alarms.append(mc)
            }
            if content[6] != 0, let mc = MessageCoder.messageCodeForSensorReplacementFlags(content[6]) {
                alarms.append(mc)
            }
            if content[7] != 0, let mc = MessageCoder.messageCodeForSensorCalibrationFlags(content[7]) {
                alarms.append(mc)
            }
            if content[8] != 0, let mc = MessageCoder.messageCodeForTransmitterStatusAlertFlags(content[8]) {
                alarms.append(mc)
            }
            if content[9] != 0, let mc = MessageCoder.messageCodeForTransmitterBatteryAlertFlags(content[9]) {
                alarms.append(mc)
            }
            if content[10] != 0, let mc = MessageCoder.messageCodeForTransmitterEOLAlertFlags(content[10]) {
                alarms.append(mc)
            }
            if content[11] != 0, let mc = MessageCoder.messageCodeForSensorReplacementFlags2(content[11]) {
                alarms.append(mc)
            }
            if content[12] != 0, let mc = MessageCoder.messageCodeForCalibrationSwitchFlags(content[12]) {
                alarms.append(mc)
            }

            return GetGlucoseAlertsAndStatusPacketResonse(
                alarms: alarms
                    .map { ActiveAlarm(code: $0, codeRaw: $0.rawValue, glucoseInMgDl: currentGlucose, flag: 0, priority: 0) }
            )
        }
    }
}
