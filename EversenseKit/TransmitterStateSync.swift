enum TransmitterStateSync {
    static let fakeAppVersion = "8.0.1"

    static func fullSync(
        peripheralManager: PeripheralManager,
        cgmManager: EversenseCGMManager
    ) async {
        let logger = EversenseLogger(category: "TransmitterStateSync")

        do {
            cgmManager.state.isSyncing = true
            cgmManager.notifyStateDidChange()

            let currentDateTime: GetCurrentDateTimeResponse = try await peripheralManager.write(GetCurrentDateTimePacket())
            let timeDifference = currentDateTime.datetime.timeIntervalSince1970 - Date.nowWithTimezone().timeIntervalSince1970
            if abs(timeDifference) >= TimeInterval.minutes(2) {
                logger.info("Updating transmitter datetime -> difference \(timeDifference) sec")
                let _: SetCurrentDateTimeResponse = try await peripheralManager.write(SetCurrentDateTimePacket())
            }

            // Get MMA Features
            let mmaResponse: GetMmaFeaturesResponse = try await peripheralManager.write(GetMmaFeaturesPacket())
            cgmManager.state.mmaFeatures = mmaResponse.value

            // Get battery voltage
            let batteryResponse: GetBatteryVoltageResponse = try await peripheralManager.write(GetBatteryVoltagePacket())
            let batteryPercentage: GetBatteryPercentageResponse = try await peripheralManager
                .write(GetBatteryPercentagePacket())
            cgmManager.state.batteryPercentage = batteryPercentage.value
            cgmManager.state.batteryVoltage = batteryResponse.value

            // TODO: Write morningCalibrationTime
            // TODO: Write eveningCalibrationTime

            // Set day startTime
            let setDayStartTimePacket = SetDayStartTimePacket(dayStartTime: cgmManager.state.dayStartTime)
            let _: SetDayStartTimeResponse = try await peripheralManager.write(setDayStartTimePacket)

            // Set night startTime
            let setNightStartTimePacket = SetNightStartTimePacket(nightStartTime: cgmManager.state.nightStartTime)
            let _: SetNightStartTimeResponse = try await peripheralManager.write(setNightStartTimePacket)

            // Do Ping
            let _: PingResponse = try await peripheralManager.write(PingPacket())

            // Get Transmitter model
            let modelResponse: GetModelResponse = try await peripheralManager.write(GetModelPacket())
            cgmManager.state.model = modelResponse.model

            // Get Transmitter version & extended Version
            let versionResponse: GetVersionResponse = try await peripheralManager.write(GetVersionPacket())
            let versionExtendedResponse: GetVersionExtendedResponse = try await peripheralManager
                .write(GetVersionExtendedPacket())
            cgmManager.state.version = versionResponse.version
            cgmManager.state.extVersion = versionExtendedResponse.extVersion

            // Get phase start datetime
            let phaseStartDate: GetPhaseStartDateResponse = try await peripheralManager.write(GetPhaseStartDatePacket())
            let phaseStartTime: GetPhaseStartTimeResponse = try await peripheralManager.write(GetPhaseStartTimePacket())
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
                let isOneCalPhase: GetIsOneCalPhaseResponse = try await peripheralManager.write(GetIsOneCalPhasePacket())

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

            if cgmManager.state.is365 {
                // Get warming up duration - Only available on transmitter 365
                let warmingUpDuration: GetWarmUpDurationResponse = try await peripheralManager
                    .write(GetWarmUpDurationPacket())
                cgmManager.state.warmingUpDuration = warmingUpDuration.value
            }

            // Get algorithm format version
            let algorithmFormatVersion: GetAlgorithmParameterFormatVersionResponse = try await peripheralManager
                .write(GetAlgorithmParameterFormatVersionPacket())
            cgmManager.state.algorithmFormatVersion = algorithmFormatVersion.value

            // Get communication protocol version
            let communicationProtocol: GetCommunicationProtocolVersionResponse = try await peripheralManager
                .write(GetCommunicationProtocolVersionPacket())
            cgmManager.state.communicationProtocol = communicationProtocol.version

            // Get glucose alarm repeat interval - SKIPPING day/night start time, since we just wrote them
            let lowAlarmRepeatingDay: GetLowGlucoseAlarmRepeatIntervalDayTimeResponse = try await peripheralManager
                .write(GetLowGlucoseAlarmRepeatIntervalDayTimePacket())
            let highAlarmRepeatingDay: GetHighGlucoseAlarmRepeatIntervalDayTimeResponse = try await peripheralManager
                .write(GetHighGlucoseAlarmRepeatIntervalDayTimePacket())
            let lowAlarmRepeatingNight: GetLowGlucoseAlarmRepeatIntervalNightTimeResponse = try await peripheralManager
                .write(GetLowGlucoseAlarmRepeatIntervalNightTimePacket())
            let highAlarmRepeatingNight: GetHighGlucoseAlarmRepeatIntervalNightTimeResponse = try await peripheralManager
                .write(GetHighGlucoseAlarmRepeatIntervalNightTimePacket())
            cgmManager.state.lowGlucoseAlarmRepeatingDayTime = lowAlarmRepeatingDay.value
            cgmManager.state.highGlucoseAlarmRepeatingDayTime = highAlarmRepeatingDay.value
            cgmManager.state.lowGlucoseAlarmRepeatingNightTime = lowAlarmRepeatingNight.value
            cgmManager.state.highGlucoseAlarmRepeatingNightTime = highAlarmRepeatingNight.value

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

            let vibrateMode: GetVibrateModeResponse = try await peripheralManager.write(GetVibrateModePacket())
            cgmManager.state.vibrateMode = vibrateMode.value

            // Write the fake app version
            if let appVersion = SetAppVersionPacket.parseAppVersion(version: TransmitterStateSync.fakeAppVersion) {
                let _: SetAppVersionResponse = try await peripheralManager.write(SetAppVersionPacket(appVersion: appVersion))
            }

            // Get sampling interval
            let sensorSamplingInterval: GetSensorSamplingIntervalResponse = try await peripheralManager
                .write(GetSensorSamplingIntervalPacket())
            cgmManager.state.sensorSamplingInterval = sensorSamplingInterval.value

            // Get calibration times
            let morningCalibrationTime: GetMorningCalibrationTimeResponse = try await peripheralManager
                .write(GetMorningCalibrationTimePacket())
            let eveningCalibrationTime: GetEveningCalibrationTimeResponse = try await peripheralManager
                .write(GetEveningCalibrationTimePacket())
            cgmManager.state.morningCalibrationTime = morningCalibrationTime.value
            cgmManager.state.eveningCalibrationTime = eveningCalibrationTime.value

            // Get glucose alarms & status
            let glucoseAlarmsStatus: GetGlucoseAlertsAndStatusPacketResonse = try await peripheralManager
                .write(GetGlucoseAlertsAndStatusPacket())
            cgmManager.state.alarms = glucoseAlarmsStatus.alarms

            // Get calibration thresholds
            let minCalibration: GetCalibrationMinThresholdResponse = try await peripheralManager
                .write(GetCalibrationMinThresholdPacket())
            let maxCalibration: GetCalibrationMaxThresholdResponse = try await peripheralManager
                .write(GetCalibrationMaxThresholdPacket())
            cgmManager.state.calibrationMinThreshold = minCalibration.value
            cgmManager.state.calibrationMaxThreshold = maxCalibration.value

            // Get glucose alarm enabled & thresholds
            let isGlucoseAlarmEnabled: GetHighGlucoseAlarmEnabledResponse = try await peripheralManager
                .write(GetHighGlucoseAlarmEnabledPacket())
            let lowGlucoseAlarm: GetLowGlucoseAlarmResponse = try await peripheralManager.write(GetLowGlucoseAlarmPacket())
            let highGlucoseAlarm: GetHighGlucoseAlarmResponse = try await peripheralManager.write(GetHighGlucoseAlarmPacket())
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
            let isRateEnabled: GetRateAlertResponse = try await peripheralManager.write(GetRateAlertPacket())
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

        } catch {
            logger.error("Something went wrong during full sync: \(error)")
        }

        cgmManager.state.isSyncing = false
        cgmManager.notifyStateDidChange()
    }
}
