extension EversenseE3 {
    static let fakeAppVersion = "8.0.1"
    static let logger = EversenseLogger(category: "TransmitterStateE3")

    static func fullSync(
        peripheralManager: PeripheralManager,
        cgmManager: EversenseCGMManager
    ) async {
        do {
            cgmManager.state.isSyncing = true
            cgmManager.notifyStateDidChange()

            let currentDateTime: GetCurrentDateTimeResponse = try await peripheralManager
                .write(GetCurrentDateTimePacket())
            let timeDifference = currentDateTime.datetime.timeIntervalSince1970 - Date.nowWithTimezone().timeIntervalSince1970
            if abs(timeDifference) >= TimeInterval.minutes(2) {
                logger.info("Updating transmitter datetime -> current date \(currentDateTime.datetime)")
                let _: SetCurrentDateTimeResponse = try await peripheralManager
                    .write(SetCurrentDateTimePacket())
            }

            // Get MMA Features
            let mmaResponse: GetMmaFeaturesResponse = try await peripheralManager
                .write(GetMmaFeaturesPacket())
            cgmManager.state.mmaFeatures = mmaResponse.value

            // Get battery voltage
            let batteryPercentage: GetBatteryPercentageResponse = try await peripheralManager
                .write(GetBatteryPercentagePacket())
            cgmManager.state.batteryPercentage = batteryPercentage.value.percentage()

            // Set day startTime
            let _: SetDayStartTimeResponse = try await peripheralManager
                .write(SetDayStartTimePacket(dayStartTime: cgmManager.state.dayStartTime))

            // Set night startTime
            let _: SetNightStartTimeResponse = try await peripheralManager
                .write(SetNightStartTimePacket(nightStartTime: cgmManager.state.nightStartTime))

            // Do Ping
            let _: PingResponse = try await peripheralManager.write(PingPacket())

            // Get Transmitter version & extended Version
            let versionResponse: GetVersionResponse = try await peripheralManager
                .write(GetVersionPacket())
            let versionExtendedResponse: GetVersionExtendedResponse = try await peripheralManager
                .write(GetVersionExtendedPacket())
            cgmManager.state.version = versionResponse.version
            cgmManager.state.extVersion = versionExtendedResponse.extVersion

            // Get phase start datetime
            let phaseStartDate: GetPhaseStartDateResponse = try await peripheralManager
                .write(GetPhaseStartDatePacket())
            let phaseStartTime: GetPhaseStartTimeResponse = try await peripheralManager
                .write(GetPhaseStartTimePacket())
            cgmManager.state.phaseStart = Date.fromComponents(
                date: phaseStartDate.date,
                time: phaseStartTime.time
            )

            // Get last calibration datetime
            let lastCalibrationDate: GetLastCalibrationDateResponse = try await peripheralManager
                .write(GetLastCalibrationDatePacket())
            let lastCalibrationTime: GetLastCalibrationTimeResponse = try await peripheralManager
                .write(GetLastCalibrationTimePacket())
            cgmManager.state.lastCalibration = Date.fromComponents(
                date: lastCalibrationDate.date,
                time: lastCalibrationTime.time
            )

            // Get current calibration phase
            do {
                let isOneCalPhase: GetIsOneCalPhaseResponse = try await peripheralManager
                    .write(GetIsOneCalPhasePacket())

                cgmManager.state.oneCalibrationPhaseExists = true
                cgmManager.state.isOneCalibrationPhase = isOneCalPhase.value
            } catch {
                cgmManager.state.oneCalibrationPhaseExists = false
            }

            let calibrationCount: GetCompletedCalibrationsCountResponse = try await peripheralManager
                .write(GetCompletedCalibrationsCountPacket())
            let calibrationPhase: GetCurrentCalibrationPhaseResponse = try await peripheralManager
                .write(GetCurrentCalibrationPhasePacket())
            cgmManager.state.calibrationCount = calibrationCount.value
            cgmManager.state.calibrationPhase = calibrationPhase.phase

            // Get BLE disconnect alarm -> possible we get no reply, this feature might not be supported
            do {
                let bleDisconnectAlarm: GetDelayBLEDisconnectAlarmResponse = try await peripheralManager
                    .write(GetDelayBLEDisconnectAlarmPacket())
                cgmManager.state.isDelayBLEDisconnectionAlarmSupported = true
                cgmManager.state.delayBLEDisconnectionAlarm = bleDisconnectAlarm.value
            } catch {
                cgmManager.state.isDelayBLEDisconnectionAlarmSupported = false
                cgmManager.state.delayBLEDisconnectionAlarm = .seconds(180)
            }

            let vibrateMode: GetVibrateModeResponse = try await peripheralManager
                .write(GetVibrateModePacket())
            cgmManager.state.vibrateMode = vibrateMode.value

            // Write the fake app version
            if let appVersion = SetAppVersionPacket.parseAppVersion(version: fakeAppVersion) {
                let _: SetAppVersionResponse = try await peripheralManager
                    .write(SetAppVersionPacket(appVersion: appVersion))
            }

            // Get glucose alarms & status
            let glucoseAlarmsStatus: GetGlucoseAlertsAndStatusPacketResonse = try await peripheralManager
                .write(GetGlucoseAlertsAndStatusPacket())
            cgmManager.state.alarms = glucoseAlarmsStatus.alarms

            // Get glucose alarm enabled & thresholds
            let isGlucoseAlarmEnabled: GetHighGlucoseAlarmEnabledResponse = try await peripheralManager
                .write(GetHighGlucoseAlarmEnabledPacket())
            let lowGlucoseAlarm: GetLowGlucoseAlarmResponse = try await peripheralManager
                .write(GetLowGlucoseAlarmPacket())
            let highGlucoseAlarm: GetHighGlucoseAlarmResponse = try await peripheralManager
                .write(GetHighGlucoseAlarmPacket())
            cgmManager.state.isGlucoseHighAlarmEnabled = isGlucoseAlarmEnabled.value
            cgmManager.state.lowGlucoseAlarmInMgDl = lowGlucoseAlarm.valueInMgDl
            cgmManager.state.highGlucoseAlarmInMgDl = highGlucoseAlarm.valueInMgDl

            // Get predictive values
            let isPredictionEnabled: GetPredictiveAlertsResponse = try await peripheralManager
                .write(GetPredictiveAlertsPacket())
            let isPredictionLowEnabled: GetPredictiveLowAlertsResponse = try await peripheralManager
                .write(GetPredictiveLowAlertsPacket())
            let isPredictionHighEnabled: GetPredictiveHighAlertsResponse = try await peripheralManager
                .write(GetPredictiveHighAlertsPacket())
            let predictionFallingInterval: GetPredictiveFallingTimeIntervalResponse = try await peripheralManager
                .write(GetPredictiveFallingTimeIntervalPacket())
            let predictionRisingInterval: GetPredictiveRisingTimeIntervalResponse = try await peripheralManager
                .write(GetPredictiveRisingTimeIntervalPacket())
            cgmManager.state.isPredictionEnabled = isPredictionEnabled.value
            cgmManager.state.isPredictionLowEnabled = isPredictionLowEnabled.value
            cgmManager.state.isPredictionHighEnabled = isPredictionHighEnabled.value
            cgmManager.state.predictionFallingInterval = predictionFallingInterval.value
            cgmManager.state.predictionRisingInterval = predictionRisingInterval.value

            // Get rate values
            let isRateEnabled: GetRateAlertResponse = try await peripheralManager
                .write(GetRateAlertPacket())
            let isFallingRateEnabled: GetRateFallingAlertResponse = try await peripheralManager
                .write(GetRateFallingAlertPacket())
            let isRisingRateEnabled: GetRateRisingAlertResponse = try await peripheralManager
                .write(GetRateRisingAlertPacket())
            let rateFallingThreshold: GetRateFallingThresholdResponse = try await peripheralManager
                .write(GetRateFallingThresholdPacket())
            let rateRisingThreshold: GetRateRisingThresholdResponse = try await peripheralManager
                .write(GetRateRisingThresholdPacket())
            cgmManager.state.isRateEnabled = isRateEnabled.value
            cgmManager.state.isFallingRateEnabled = isFallingRateEnabled.value
            cgmManager.state.isRisingRateEnabled = isRisingRateEnabled.value
            cgmManager.state.rateFallingThreshold = rateFallingThreshold.value
            cgmManager.state.rateRisingThreshold = rateRisingThreshold.value

            // Get signal strength
            let rawSignalStrength: GetSignalStrengthRawResponse = try await peripheralManager
                .write(GetSignalStrengthRawPacket())
            cgmManager.state.signalStrength = rawSignalStrength.value
            cgmManager.state.signalStrengthRaw = rawSignalStrength.rawValue

            logger.info("[E3] Sync completed - timestamp: \(Date())")

        } catch {
            logger.error("[E3] Something went wrong during full sync: \(error)")
        }

        cgmManager.state.isSyncing = false
        cgmManager.notifyStateDidChange()
    }

    static func handleError(data: Data) {
        guard data.count >= 4 else {
            logger.error("Invalid error response length - length: \(data.count), data: \(data.hexString())")
            return
        }

        let code = (UInt16(data[3]) << 8) | UInt16(data[2])
        guard let error = CommandError(rawValue: code) else {
            logger.error("Received unknown error - code: \(code), data: \(data.hexString())")
            return
        }

        // TODO: Emit error
        logger.warning("Received error from transmitter - error: \(error), data: \(data.hexString())")
    }
}

extension Eversense365 {
    static let logger = EversenseLogger(category: "TransmitterState365")

    static func fullSync(
        peripheralManager: PeripheralManager,
        cgmManager: EversenseCGMManager
    ) async {
        do {
            cgmManager.state.isSyncing = true
            cgmManager.notifyStateDidChange()

            let sensorInformation: GetSensorInformationResponse = try await peripheralManager
                .write(GetSensorInformationPacket())

            cgmManager.state.mmaFeatures = sensorInformation.mmaFeatures
            cgmManager.state.batteryPercentage = sensorInformation.batteryLevel

            let timeDifference = sensorInformation.transmitterDatetime.timeIntervalSince1970 - Date.nowWithTimezone()
                .timeIntervalSince1970
            if abs(timeDifference) >= TimeInterval.minutes(2) {
                logger.info("Updating transmitter datetime -> current date \(sensorInformation.transmitterDatetime)")
                let _: Eversense365.SetCurrentDateTimeResponse = try await peripheralManager
                    .write(Eversense365.SetCurrentDateTimePacket())
            }

            let signalStrength: GetSignalStrenghtResponse = try await peripheralManager.write(GetSignalStrenghtPacket())
            cgmManager.state.signalStrengthRaw = signalStrength.rawValue
            cgmManager.state.signalStrength = signalStrength.signalStrength

            logger.info("[365] Sync completed - timestamp: \(Date())")

        } catch {
            logger.error("[365] Something went wrong during full sync: \(error)")
        }

        cgmManager.state.isSyncing = false
        cgmManager.notifyStateDidChange()
    }

    static func handleError(data: Data) {
        // TODO: Emit error
        logger.warning("Received error from transmitter - data: \(data.hexString())")
    }
}
