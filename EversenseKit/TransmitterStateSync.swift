enum TransmitterStateSync {
    static let fakeAppVersion = "8.0.1"

    static func fullSyncE3(
        peripheralManager: PeripheralManager,
        cgmManager: EversenseCGMManager
    ) async {
        let logger = EversenseLogger(category: "TransmitterStateSync")

        do {
            cgmManager.state.isSyncing = true
            cgmManager.notifyStateDidChange()

            let currentDateTime: EversenseE3.GetCurrentDateTimeResponse = try await peripheralManager
                .write(EversenseE3.GetCurrentDateTimePacket())
            let timeDifference = currentDateTime.datetime.timeIntervalSince1970 - Date.nowWithTimezone().timeIntervalSince1970
            if abs(timeDifference) >= TimeInterval.minutes(2) {
                logger.info("Updating transmitter datetime -> difference \(timeDifference) sec")
                let _: EversenseE3.SetCurrentDateTimeResponse = try await peripheralManager
                    .write(EversenseE3.SetCurrentDateTimePacket())
            }

            // Get MMA Features
            let mmaResponse: EversenseE3.GetMmaFeaturesResponse = try await peripheralManager
                .write(EversenseE3.GetMmaFeaturesPacket())
            cgmManager.state.mmaFeatures = mmaResponse.value

            // Get battery voltage
            let batteryResponse: EversenseE3.GetBatteryVoltageResponse = try await peripheralManager
                .write(EversenseE3.GetBatteryVoltagePacket())
            let batteryPercentage: EversenseE3.GetBatteryPercentageResponse = try await peripheralManager
                .write(EversenseE3.GetBatteryPercentagePacket())
            cgmManager.state.batteryPercentage = batteryPercentage.value
            cgmManager.state.batteryVoltage = batteryResponse.value

            // Set day startTime
            let _: EversenseE3.SetDayStartTimeResponse = try await peripheralManager
                .write(EversenseE3.SetDayStartTimePacket(dayStartTime: cgmManager.state.dayStartTime))

            // Set night startTime
            let _: EversenseE3.SetNightStartTimeResponse = try await peripheralManager
                .write(EversenseE3.SetNightStartTimePacket(nightStartTime: cgmManager.state.nightStartTime))

            // Do Ping
            let _: EversenseE3.PingResponse = try await peripheralManager.write(EversenseE3.PingPacket())

            // Get Transmitter version & extended Version
            let versionResponse: EversenseE3.GetVersionResponse = try await peripheralManager
                .write(EversenseE3.GetVersionPacket())
            let versionExtendedResponse: EversenseE3.GetVersionExtendedResponse = try await peripheralManager
                .write(EversenseE3.GetVersionExtendedPacket())
            cgmManager.state.version = versionResponse.version
            cgmManager.state.extVersion = versionExtendedResponse.extVersion

            // Get phase start datetime
            let phaseStartDate: EversenseE3.GetPhaseStartDateResponse = try await peripheralManager
                .write(EversenseE3.GetPhaseStartDatePacket())
            let phaseStartTime: EversenseE3.GetPhaseStartTimeResponse = try await peripheralManager
                .write(EversenseE3.GetPhaseStartTimePacket())
            cgmManager.state.phaseStart = Date.fromComponents(
                date: phaseStartDate.date,
                time: phaseStartTime.time
            )

            // Get last calibration datetime
            let lastCalibrationDate: EversenseE3.GetLastCalibrationDateResponse = try await peripheralManager
                .write(EversenseE3.GetLastCalibrationDatePacket())
            let lastCalibrationTime: EversenseE3.GetLastCalibrationTimeResponse = try await peripheralManager
                .write(EversenseE3.GetLastCalibrationTimePacket())
            cgmManager.state.lastCalibration = Date.fromComponents(
                date: lastCalibrationDate.date,
                time: lastCalibrationTime.time
            )

            // Get current calibration phase
            do {
                let isOneCalPhase: EversenseE3.GetIsOneCalPhaseResponse = try await peripheralManager
                    .write(EversenseE3.GetIsOneCalPhasePacket())

                cgmManager.state.oneCalibrationPhaseExists = true
                cgmManager.state.isOneCalibrationPhase = isOneCalPhase.value
            } catch {
                cgmManager.state.oneCalibrationPhaseExists = false
            }

            let calibrationCount: EversenseE3.GetCompletedCalibrationsCountResponse = try await peripheralManager
                .write(EversenseE3.GetCompletedCalibrationsCountPacket())
            let calibrationPhase: EversenseE3.GetCurrentCalibrationPhaseResponse = try await peripheralManager
                .write(EversenseE3.GetCurrentCalibrationPhasePacket())
            cgmManager.state.calibrationCount = calibrationCount.value
            cgmManager.state.calibrationPhase = calibrationPhase.phase

            // Get BLE disconnect alarm -> possible we get no reply, this feature might not be supported
            do {
                let bleDisconnectAlarm: EversenseE3.GetDelayBLEDisconnectAlarmResponse = try await peripheralManager
                    .write(EversenseE3.GetDelayBLEDisconnectAlarmPacket())
                cgmManager.state.isDelayBLEDisconnectionAlarmSupported = true
                cgmManager.state.delayBLEDisconnectionAlarm = bleDisconnectAlarm.value
            } catch {
                cgmManager.state.isDelayBLEDisconnectionAlarmSupported = false
                cgmManager.state.delayBLEDisconnectionAlarm = .seconds(180)
            }

            let vibrateMode: EversenseE3.GetVibrateModeResponse = try await peripheralManager
                .write(EversenseE3.GetVibrateModePacket())
            cgmManager.state.vibrateMode = vibrateMode.value

            // Write the fake app version
            if let appVersion = EversenseE3.SetAppVersionPacket.parseAppVersion(version: TransmitterStateSync.fakeAppVersion) {
                let _: EversenseE3.SetAppVersionResponse = try await peripheralManager
                    .write(EversenseE3.SetAppVersionPacket(appVersion: appVersion))
            }

            // Get glucose alarms & status
            let glucoseAlarmsStatus: EversenseE3.GetGlucoseAlertsAndStatusPacketResonse = try await peripheralManager
                .write(EversenseE3.GetGlucoseAlertsAndStatusPacket())
            cgmManager.state.alarms = glucoseAlarmsStatus.alarms

            // Get glucose alarm enabled & thresholds
            let isGlucoseAlarmEnabled: EversenseE3.GetHighGlucoseAlarmEnabledResponse = try await peripheralManager
                .write(EversenseE3.GetHighGlucoseAlarmEnabledPacket())
            let lowGlucoseAlarm: EversenseE3.GetLowGlucoseAlarmResponse = try await peripheralManager
                .write(EversenseE3.GetLowGlucoseAlarmPacket())
            let highGlucoseAlarm: EversenseE3.GetHighGlucoseAlarmResponse = try await peripheralManager
                .write(EversenseE3.GetHighGlucoseAlarmPacket())
            cgmManager.state.isGlucoseHighAlarmEnabled = isGlucoseAlarmEnabled.value
            cgmManager.state.lowGlucoseAlarmInMgDl = lowGlucoseAlarm.valueInMgDl
            cgmManager.state.highGlucoseAlarmInMgDl = highGlucoseAlarm.valueInMgDl

            // Get predictive values
            let isPredictionEnabled: EversenseE3.GetPredictiveAlertsResponse = try await peripheralManager
                .write(EversenseE3.GetPredictiveAlertsPacket())
            let isPredictionLowEnabled: EversenseE3.GetPredictiveLowAlertsResponse = try await peripheralManager
                .write(EversenseE3.GetPredictiveLowAlertsPacket())
            let isPredictionHighEnabled: EversenseE3.GetPredictiveHighAlertsResponse = try await peripheralManager
                .write(EversenseE3.GetPredictiveHighAlertsPacket())
            let predictionFallingInterval: EversenseE3.GetPredictiveFallingTimeIntervalResponse = try await peripheralManager
                .write(EversenseE3.GetPredictiveFallingTimeIntervalPacket())
            let predictionRisingInterval: EversenseE3.GetPredictiveRisingTimeIntervalResponse = try await peripheralManager
                .write(EversenseE3.GetPredictiveRisingTimeIntervalPacket())
            cgmManager.state.isPredictionEnabled = isPredictionEnabled.value
            cgmManager.state.isPredictionLowEnabled = isPredictionLowEnabled.value
            cgmManager.state.isPredictionHighEnabled = isPredictionHighEnabled.value
            cgmManager.state.predictionFallingInterval = predictionFallingInterval.value
            cgmManager.state.predictionRisingInterval = predictionRisingInterval.value

            // Get rate values
            let isRateEnabled: EversenseE3.GetRateAlertResponse = try await peripheralManager
                .write(EversenseE3.GetRateAlertPacket())
            let isFallingRateEnabled: EversenseE3.GetRateFallingAlertResponse = try await peripheralManager
                .write(EversenseE3.GetRateFallingAlertPacket())
            let isRisingRateEnabled: EversenseE3.GetRateRisingAlertResponse = try await peripheralManager
                .write(EversenseE3.GetRateRisingAlertPacket())
            let rateFallingThreshold: EversenseE3.GetRateFallingThresholdResponse = try await peripheralManager
                .write(EversenseE3.GetRateFallingThresholdPacket())
            let rateRisingThreshold: EversenseE3.GetRateRisingThresholdResponse = try await peripheralManager
                .write(EversenseE3.GetRateRisingThresholdPacket())
            cgmManager.state.isRateEnabled = isRateEnabled.value
            cgmManager.state.isFallingRateEnabled = isFallingRateEnabled.value
            cgmManager.state.isRisingRateEnabled = isRisingRateEnabled.value
            cgmManager.state.rateFallingThreshold = rateFallingThreshold.value
            cgmManager.state.rateRisingThreshold = rateRisingThreshold.value

            // Get signal strength
            let rawSignalStrength: EversenseE3.GetSignalStrengthRawResponse = try await peripheralManager
                .write(EversenseE3.GetSignalStrengthRawPacket())
            cgmManager.state.signalStrength = rawSignalStrength.value
            cgmManager.state.signalStrengthRaw = rawSignalStrength.rawValue

        } catch {
            logger.error("[E3] Something went wrong during full sync: \(error)")
        }

        cgmManager.state.isSyncing = false
        cgmManager.notifyStateDidChange()
    }

    static func fullSync365(
        peripheralManager: PeripheralManager,
        cgmManager: EversenseCGMManager
    ) async {
        let logger = EversenseLogger(category: "TransmitterStateSync")

        do {
            cgmManager.state.isSyncing = true
            cgmManager.notifyStateDidChange()

            let _: Eversense365.GetSensorInformationResponse = try await peripheralManager
                .write(Eversense365.GetSensorInformationPacket())

        } catch {
            logger.error("[365] Something went wrong during full sync: \(error)")
        }

        cgmManager.state.isSyncing = false
        cgmManager.notifyStateDidChange()
    }
}
