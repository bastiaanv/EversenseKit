extension EversenseE3 {
    class GetGlucoseAlertsAndStatusPacketResonse {
        let alarms: [TransmitterAlert]

        init(alarms: [TransmitterAlert]) {
            self.alarms = alarms
        }
    }

    class GetGlucoseAlertsAndStatusPacket: BasePacket {
        typealias T = GetGlucoseAlertsAndStatusPacketResonse

        private let STATUS_FLAG_COUNT = 13

        var response: PacketIds {
            PacketIds.readSensorGlucoseAlertsAndStatusResponseId
        }

        func getRequestData() -> Data {
            var data = Data([0x10])
            let checksum = BinaryOperations.generateChecksumCRC16(data: data)
            data.append(BinaryOperations.dataFrom16Bits(value: checksum))

            return data
        }

        func parseResponse(data: Data) -> GetGlucoseAlertsAndStatusPacketResonse {
            var content = data.subdata(in: start + 1 ..< data.count - start - 2)
            if content.count < STATUS_FLAG_COUNT {
                let prefix = Data(repeating: 0, count: STATUS_FLAG_COUNT - content.count)
                content = prefix + content
            }

            if content.max() == 0 {
                return GetGlucoseAlertsAndStatusPacketResonse(alarms: [])
            }

            var alarms: [TransmitterAlert] = []

            if content[0] != 0, let mc = MessageCoder.messageCodeForGlucoseLevelAlarmFlags(content[0]), mc.canBlindGlucose {
                alarms.append(mc)
            }
            if content[1] != 0, let mc = MessageCoder.messageCodeForGlucoseLevelAlertFlags(content[1]), mc.canBlindGlucose {
                alarms.append(mc)
            }
            if content[2] != 0, let mc = MessageCoder.messageCodeForRateAlertFlags(content[2]), mc.canBlindGlucose {
                alarms.append(mc)
            }
            if content[3] != 0, let mc = MessageCoder.messageCodeForPredictiveAlertFlags(content[3]), mc.canBlindGlucose {
                alarms.append(mc)
            }
            if content[4] != 0, let mc = MessageCoder.messageCodeForSensorHardwareAndAlertFlags(content[4]), mc.canBlindGlucose {
                alarms.append(mc)
            }
            if content[5] != 0, let mc = MessageCoder.messageCodeForSensorReadAlertFlags(content[5]), mc.canBlindGlucose {
                alarms.append(mc)
            }
            if content[6] != 0, let mc = MessageCoder.messageCodeForSensorReplacementFlags(content[6]), mc.canBlindGlucose {
                alarms.append(mc)
            }
            if content[7] != 0, let mc = MessageCoder.messageCodeForSensorCalibrationFlags(content[7]), mc.canBlindGlucose {
                alarms.append(mc)
            }
            if content[8] != 0, let mc = MessageCoder.messageCodeForTransmitterStatusAlertFlags(content[8]), mc.canBlindGlucose {
                alarms.append(mc)
            }
            if content[9] != 0, let mc = MessageCoder.messageCodeForTransmitterBatteryAlertFlags(content[9]), mc.canBlindGlucose {
                alarms.append(mc)
            }
            if content[10] != 0, let mc = MessageCoder.messageCodeForTransmitterEOLAlertFlags(content[10]), mc.canBlindGlucose {
                alarms.append(mc)
            }
            if content[11] != 0, let mc = MessageCoder.messageCodeForSensorReplacementFlags2(content[11]), mc.canBlindGlucose {
                alarms.append(mc)
            }
            if content[12] != 0, let mc = MessageCoder.messageCodeForCalibrationSwitchFlags(content[12]), mc.canBlindGlucose {
                alarms.append(mc)
            }

            if let lastAlarm = alarms.last, lastAlarm.rawValue > TransmitterAlert.sensorRetiredAlarm.rawValue {
                if let mc = MessageCoder.messageCodeForTransmitterEOLAlertFlags(content[11]), mc == .transmitterEOL396 {
                    alarms.append(.transmitterEOL396)
                }

                if let mc = MessageCoder.messageCodeForSensorReadAlertFlags(content[6]), mc == .mspAlarm {
                    alarms.append(.mspAlarm)
                }

                if let mc = MessageCoder.messageCodeForSensorReadAlertFlags(content[6]), mc == .mepAlarm {
                    alarms.append(.mepAlarm)
                }

                if let mc = MessageCoder.messageCodeForSensorReplacementFlags(content[7]),
                   mc == .sensorPrematureReplacementAlarm
                {
                    alarms.append(.sensorPrematureReplacementAlarm)
                }
            }

            return GetGlucoseAlertsAndStatusPacketResonse(alarms: alarms)
        }
    }
}
