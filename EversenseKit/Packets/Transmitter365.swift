import LoopKit

extension Eversense365 {
    static let fakeAppVersion = "8.0.4"
    static let logger = EversenseLogger(category: "TransmitterState365")
    static var sensorIdLength = 0x00

    static func readGlucoseData(
        cgmManager: EversenseCGMManager,
        peripheralManager: PeripheralManager,
        lastGlucoseTimestamp: Date
    ) -> (CGMReading, [CGMReading])? {
        do {
            logger.debug("sending GetRecentGlucosePacket...")
            guard let mostRecentGlucose = getRecentGlucose(peripheralManager: peripheralManager) else {
                return nil
            }

            logger.debug("sending GetGlucoseLogRangePacket...")
            let glucoseRange: GetLogRangeResponse = try peripheralManager
                .write(GetLogRangePacket(communicationVersion: cgmManager.state.communicationProtocol, logType: LogTypes.Glucose))

            let range = RangeCalculator.calculateGlucoseRange(
                rangeFrom: glucoseRange.rangeFrom,
                rangeTo: glucoseRange.rangeTo,
                lastGlucoseTimestamp: lastGlucoseTimestamp
            )

            let message =
                "GetLogValuePacket -  from: \(range.from), to: \(range.to), lastGlucoseTimestamp: \(lastGlucoseTimestamp)"
            logger.debug(message)

            let historyResponse: GetGlucoseLogValuesResponse = try peripheralManager
                .write(GetGlucoseLogValuesPacket(from: range.from, to: range.to), timeout: .seconds(15))

            let samples = historyResponse.glucoseHistory.filter { $0.datetime > lastGlucoseTimestamp }.map {
                CGMReading(
                    glucoseInMgDl: $0.valueInMgDl,
                    datetime: $0.datetime,
                    trend: $0.trend,
                    raw: $0.raw
                )
            }

            logger.info("[365] Glucose data read  - timestamp: \(Date.now), count: \(samples.count)")
            return (
                CGMReading(
                    glucoseInMgDl: mostRecentGlucose.glucoseInMgDl,
                    datetime: mostRecentGlucose.glucoseDatetime,
                    trend: mostRecentGlucose.trend,
                    raw: ""
                ),
                samples.sorted { $0.datetime < $1.datetime }
            )
        } catch {
            logger.error("[365] Something went wrong during readGlucoseData: \(error)")
            return nil
        }
    }

    private static func getRecentGlucose(peripheralManager: PeripheralManager) -> GetGlucoseDataResponse? {
        do {
            let response: GetGlucoseDataResponse = try peripheralManager.write(GetGlucoseDataPacket())
            guard response.glucoseInMgDl < 0x01C2 else {
                let message =
                    "Invalid Glucose data - value: \(response.glucoseInMgDl) mg/dl, timestamp: \(response.glucoseDatetime)"
                logger.warning(message)
                return nil
            }

            return response
        } catch {
            logger.error("Failed to fetch Glucose data - error: \(error.localizedDescription)")
            return nil
        }
    }

    static func fullSync(
        peripheralManager: PeripheralManager,
        cgmManager: EversenseCGMManager
    ) {
        do {
            cgmManager.state.isSyncing = true
            cgmManager.notifyStateDidChange()

            // Do Ping
            logger.debug("Sending PING")
            let _: PingResponse = try peripheralManager.write(PingPacket())

            // Get transmitter information
            logger.debug("Sending GetSensorInformationPacket")
            let sensorInformation: GetSensorInformationResponse = try peripheralManager
                .write(GetSensorInformationPacket())

            cgmManager.state.transmitterId = sensorInformation.serialNumber
            cgmManager.state.mmaFeatures = sensorInformation.mmaFeatures
            cgmManager.state.sensorId = sensorInformation.sensorId
            cgmManager.state.batteryPercentage = sensorInformation.batteryLevel
            cgmManager.state.version = sensorInformation.version
            cgmManager.state.extVersion = sensorInformation.extVersion
            cgmManager.state.communicationProtocol = sensorInformation.communicationProtocolVersion
            cgmManager.state.activatedAt = sensorInformation.insertionDate
            cgmManager.state.expiresAt = sensorInformation.insertionDate.addingTimeInterval(.days(365))
            sensorIdLength = sensorInformation.sensorIdLength

            let timeDifference = sensorInformation.transmitterDatetime.timeIntervalSince1970 - Date.nowWithTimezone()
                .timeIntervalSince1970
            if abs(timeDifference) >= TimeInterval.seconds(10) {
                logger.info("Updating transmitter datetime -> current date \(sensorInformation.transmitterDatetime)")
                let _: Eversense365.SetCurrentDateTimeResponse = try peripheralManager
                    .write(Eversense365.SetCurrentDateTimePacket())
            }

            // Fetch signal strength
            logger.debug("Sending GetSignalStrenghtPacket")
            let signalStrength: GetSignalStrenghtResponse = try peripheralManager.write(GetSignalStrenghtPacket())
            cgmManager.state.signalStrengthRaw = signalStrength.rawValue
            cgmManager.state.signalStrength = signalStrength.signalStrength

            logger.debug("Sending GetCalibrationInfoPacket")
            let calibrationInfo: GetCalibrationInfoResponse = try peripheralManager.write(GetCalibrationInfoPacket())
            cgmManager.state.calibrationCount = UInt16(calibrationInfo.countCalibrations)
            cgmManager.state.calibrationReadiness = calibrationInfo.calibrationReadiness
            cgmManager.state.calibrationMode = calibrationInfo.calibrationMode
            cgmManager.state.calibrationPhase = calibrationInfo.currentPhase
            cgmManager.state.lastCalibration = calibrationInfo.lastCalibration
            cgmManager.state.nextCalibration = calibrationInfo.nextCalibration

            logger.debug("Sending SetAppVersionPacket")
            let _: SetAppVersionResponse = try peripheralManager.write(SetAppVersionPacket(appVersion: fakeAppVersion))

            logger.debug("Sending GetPatientSettingsPacket")
            let patientSettings: GetPatientSettingsResponse = try peripheralManager.write(GetPatientSettingsPacket())
            cgmManager.state.vibrateMode = patientSettings.vibrateMode
            cgmManager.state.lowGlucoseAlarmInMgDl = patientSettings.lowGlucoseAlarmInMgDl
            cgmManager.state.isGlucoseHighAlarmEnabled = patientSettings.highGlucoseEnabled
            cgmManager.state.highGlucoseAlarmInMgDl = patientSettings.highGlucoseAlarmInMgDl
            cgmManager.state.isPredictionLowEnabled = patientSettings.predictionLowEnabled
            cgmManager.state.isPredictionHighEnabled = patientSettings.predictionHighEnabled
            cgmManager.state.predictionFallingInterval = patientSettings.predictionFallingInterval
            cgmManager.state.predictionRisingInterval = patientSettings.predictionRisingInterval
            cgmManager.state.predictionFallingThreshold = patientSettings.predictionFallingThreshold
            cgmManager.state.predictionRisingThreshold = patientSettings.predictionRisingThreshold
            cgmManager.state.isFallingRateEnabled = patientSettings.rateFallingEnabled
            cgmManager.state.isRisingRateEnabled = patientSettings.rateRisingEnabled
            cgmManager.state.rateFallingThreshold = patientSettings.rateFallingThreshold
            cgmManager.state.rateRisingThreshold = patientSettings.rateRisingThreshold
            cgmManager.state.bleDisconnectTimeout = patientSettings.disconnectTimeout
            cgmManager.state.repeatLowTimeout = patientSettings.repeatLowTimeout
            cgmManager.state.repeatHighTimeout = patientSettings.repeatHighTimeout

            logger.debug("Sending GetActiveAlarmsPacket")
            let alarmsRequest = GetActiveAlarmsPacket(currentGlucose: cgmManager.state.recentGlucoseInMgDl ?? 0)
            let activeAlarms: GetActiveAlarmsResponse = try peripheralManager.write(alarmsRequest)
            cgmManager.handleAlarm(alarms: activeAlarms.alarms)

            logger.debug("Reading battery logs")
            let batteryLogRange: GetLogRangeResponse = try peripheralManager
                .write(GetLogRangePacket(communicationVersion: cgmManager.state.communicationProtocol, logType: .Battery))

            if let range = RangeCalculator.calculateRange(
                lastRecord: cgmManager.state.lastBatteryRecord,
                rangeFrom: batteryLogRange.rangeFrom,
                rangeTo: batteryLogRange.rangeTo
            ) {
                let packet2: GetBatteryLogResponse = try peripheralManager
                    .write(GetBatteryLogPacket(from: range.from, to: range.to))

                cgmManager.state.lastBatteryRecord = range.to
                cgmManager.state.batteryReadingsToUpload.append(contentsOf: packet2.logs)
            }

            logger.info("[365] Sync completed - timestamp: \(Date.now)")

        } catch {
            logger.error("[365] Something went wrong during full sync: \(error)")
        }

        cgmManager.state.isSyncing = false
        cgmManager.state.lastSynced = Date.now
        cgmManager.notifyStateDidChange()
    }

    static func writeTransmitterSettings(
        peripheralManager: PeripheralManager,
        data: TransmitterSettings
    ) {
        do {
            logger.debug("Write vibration")
            let _: SetDoNotDisturbResponse = try peripheralManager.write(SetDoNotDisturbRequest(silenced: data.vibrationMode))

            logger.debug("Write glucose alerts")
            let _: SetHighGlucoseAlarmEnabledResponse = try peripheralManager
                .write(SetHighGlucoseAlarmEnabledPacket(enabled: data.glucoseHighEnabled))
            let _: SetHighGlucoseAlarmResponse = try peripheralManager
                .write(SetHighGlucoseAlarmPacket(value: data.glucoseHighInMgDl))
            let _: SetLowGlucoseAlarmResponse = try peripheralManager
                .write(SetLowGlucoseAlarmPacket(value: data.glucoseLowInMgDl))

            logger.debug("Write rate alerts")
            let _: SetRateRisingEnabledResponse = try peripheralManager
                .write(SetRateRisingEnabledPacket(enabled: data.rateRisingEnabled))
            let _: SetRateRisingThresholdResponse = try peripheralManager
                .write(SetRateRisingThresholdPacket(value: data.rateRisingThreshold))
            let _: SetRateFallingEnabledResponse = try peripheralManager
                .write(SetRateFallingEnabledPacket(enabled: data.rateFallingEnabled))
            let _: SetRateFallingThresholdResponse = try peripheralManager
                .write(SetRateFallingThresholdPacket(value: data.rateFallingThreshold))

            logger.debug("Write prediction alerts")
            let _: SetPredictionLowEnabledResponse = try peripheralManager
                .write(SetPredictionLowEnabledPacket(enabled: data.predictiveLowEnabled))
            let _: SetPredictionLowIntervalResponse = try peripheralManager
                .write(SetPredictionLowIntervalPacket(time: data.predictiveLowTime))
            let _: SetPredictionLowThresholdResponse = try peripheralManager
                .write(SetPredictionLowThresholdPacket(value: data.predictiveLowThreshold))
            let _: SetPredictionHighEnabledResponse = try peripheralManager
                .write(SetPredictionHighEnabledPacket(enabled: data.predictiveHighEnabled))
            let _: SetPredictionHighIntervalResponse = try peripheralManager
                .write(SetPredictionHighIntervalPacket(time: data.predictiveHighTime))
            let _: SetPredictionHighThresholdResponse = try peripheralManager
                .write(SetPredictionHighThresholdPacket(value: data.predictiveHighThreshold))

            logger.debug("Write timeouts")
            let _: SetBleDisconnectResponse = try peripheralManager.write(SetBleDisconnectPacket(interval: data.bleDisconnect))
            let _: SetRepeatLowGlucoseResponse = try peripheralManager
                .write(SetRepeatLowGlucosePacket(interval: data.repeatAlarmLow))
            let _: SetRepeatHighGlucoseResponse = try peripheralManager
                .write(SetRepeatHighGlucosePacket(interval: data.repeatAlarmHigh))

            logger.info("[365] Transmitter settings have been written - timestamp: \(Date.now)")
        } catch {
            logger.error("[365] Something went wrong setting transmitter settings: \(error)")
        }
    }

    static func updateSignalStrength(cgmManager: EversenseCGMManager) -> GetSignalStrenghtResponse? {
        do {
            logger.debug("sending GetSignalStrenghtResponse...")
            let signalStrength: GetSignalStrenghtResponse = try cgmManager.bluetoothManager.write(GetSignalStrenghtPacket())
            cgmManager.state.signalStrengthRaw = signalStrength.rawValue
            cgmManager.state.signalStrength = signalStrength.signalStrength

            return signalStrength
        } catch {
            logger.error("Failed to update signal strength - error: \(error)")
            return nil
        }
    }

    static func setDiagnosticMode(cgmManager: EversenseCGMManager, isEnabled: Bool) {
        do {
            logger.debug("sending \(isEnabled ? "enterDiagnosticModePhx2" : "exitDiagnosticModePhx2")...")
            let _: SetDiagnosticModeResponse = try cgmManager.bluetoothManager.write(SetDiagnosticModePacket(enabled: isEnabled))
        } catch {
            logger.error("Failed to set diagnostic mode: \(error)")
        }
    }

    static func calibrateSensors(cgmManager: EversenseCGMManager, glucoseInMgDl: UInt16, timestamp: Date) throws {
        do {
            logger.info("Sending SetBloodGlucosePointPacket - glucose: \(glucoseInMgDl)mg/dl, timestamp: \(timestamp)")

            let _: SetBloodGlucosePointResponse = try cgmManager.bluetoothManager
                .write(SetBloodGlucosePointPacket(glucoseInMgDl: glucoseInMgDl, timestamp: timestamp))

            logger.info("[365] Calibation has been send - timestamp: \(Date.now)")
        } catch {
            logger.error("[365] Something went wrong during calibration: \(error)")
            throw error
        }
    }

    static func handleError(data: Data) {
        // TODO: Emit error
        logger.warning("Received error from transmitter - data: \(data.hexString())")
    }
}
