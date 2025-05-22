//
//  TransmitterStateSync.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 20/05/2025.
//

class TransmitterStateSync {
    static let fakeAppVersion = "8.0.1"
    
    static func fullSync(peripheralManager: PeripheralManager, cgmManager: EversensCGMManager) {
        let logger = EversenseLogger(category: "TransmitterStateSync")
        
        Task {
            do {
                // Get MMA Features
                let mmaResponse: GetMmaFeaturesResponse = try await peripheralManager.write(GetMmaFeaturesPacket())
                cgmManager.state.mmaFeatures = mmaResponse.value
                
                // Get battery voltage
                let batteryResponse: GetBatteryVoltageResponse = try await peripheralManager.write(GetBatteryVoltagePacket())
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
                let versionExtendedResponse: GetVersionExtendedResponse = try await peripheralManager.write(GetVersionExtendedPacket())
                cgmManager.state.version = versionResponse.version
                cgmManager.state.extVersion = versionExtendedResponse.extVersion
                
                // Get phase start datetime
                let phaseStartDate: GetPhaseStartDateResponse = try await peripheralManager.write(GetPhaseStartDatePacket())
                let phaseStartTime: GetPhaseStartTimeResponse = try await peripheralManager.write(GetPhaseStartTimePacket())
                cgmManager.state.lastCalibration = Date.fromComponents(
                    date: phaseStartDate.date,
                    time: phaseStartTime.time
                )
                
                // Get last calibration datetime
                let lastCalibrationDate: GetLastCalibrationDateResponse = try await peripheralManager.write(GetLastCalibrationDatePacket())
                let lastCalibrationTime: GetLastCalibrationTimeResponse = try await peripheralManager.write(GetLastCalibrationTimePacket())
                cgmManager.state.lastCalibration = Date.fromComponents(
                    date: lastCalibrationDate.date,
                    time: lastCalibrationTime.time
                )
                
                // Get current calibration phase
                let isOneCalPhase: GetIsOneCalPhaseResponse = try await peripheralManager.write(GetIsOneCalPhasePacket())
                let calibrationCount: GetCompletedCalibrationsCountResponse = try await peripheralManager.write(GetCompletedCalibrationsCountPacket())
                let calibrationPhase: GetCurrentCalibrationPhaseResponse = try await peripheralManager.write(GetCurrentCalibrationPhasePacket())
                cgmManager.state.isOneCalibrationPhase = isOneCalPhase.value
                cgmManager.state.calibrationCount = calibrationCount.value
                cgmManager.state.calibrationPhase = calibrationPhase.phase
                
                if peripheralManager.isTransmitter365 {
                    // Get warming up duration - Only available on transmitter 365
                    let warmingUpDuration: GetWarmUpDurationResponse = try await peripheralManager.write(GetWarmUpDurationPacket())
                    cgmManager.state.warmingUpDuration = warmingUpDuration.value
                }
                
                // Get hysteresis
                let hysteresisPercentage: GetHysteresisPercentageResponse = try await peripheralManager.write(GetHysteresisPercentagePacket())
                let hysteresisValue: GetHysteresisValueResponse = try await peripheralManager.write(GetHysteresisValuePacket())
                cgmManager.state.hysteresisPercentage = hysteresisPercentage.value
                cgmManager.state.hysteresisValueInMgDl = hysteresisValue.valueInMgDl
                
                // Get predictive hysteresis
                let predictiveHysteresisPercentage: GetHysteresisPredictivePercentageResponse = try await peripheralManager.write(GetHysteresisPredictivePercentagePacket())
                let predictiveHysteresisValue: GetHysteresisPredictiveValueResponse = try await peripheralManager.write(GetHysteresisPredictiveValuePacket())
                cgmManager.state.predictiveHysteresisPercentage = predictiveHysteresisPercentage.value
                cgmManager.state.predictiveHysteresisValueInMgDl = predictiveHysteresisValue.valueInMgDl
                
                // Get algorithm format version
                let algorithmFormatVersion: GetAlgorithmParameterFormatVersionResponse = try await peripheralManager.write(GetAlgorithmParameterFormatVersionPacket())
                cgmManager.state.algorithmFormatVersion = algorithmFormatVersion.value
                
                // Get transmitter starting moment
                if cgmManager.state.isUSXLorOUSXL2 {
                    let transmitterStartDate: GetTransmitterOperationStartDateResponse = try await peripheralManager.write(GetTransmitterOperationStartDate())
                    let transmitterStartTime: GetTransmitterOperationStartTimeResponse = try await peripheralManager.write(GetTransmitterOperationStartTime())
                    cgmManager.state.transmitterStart = Date.fromComponents(
                        date: transmitterStartDate.date,
                        time: transmitterStartTime.time
                    )
                }
                
                // Get communication protocol version
                let communicationProtocol: GetCommunicationProtocolVersionResponse = try await peripheralManager.write(GetCommunicationProtocolVersionPacket())
                cgmManager.state.communicationProtocol = communicationProtocol.version
                
                // Get MEPMSP information
                let mepValue: GetMEPSavedValueResponse = try await peripheralManager.write(GetMEPSavedValuePacket())
                let mepRefChannelMetric: GetMEPSavedRefChannelMetricResponse = try await peripheralManager.write(GetMEPSavedRefChannelMetricPacket())
                let mepDriftMetric: GetMEPSavedDriftMetricResponse = try await peripheralManager.write(GetMEPSavedDriftMetricPacket())
                let mepLowRefMetric: GetMEPSavedLowRefMetricResponse = try await peripheralManager.write(GetMEPSavedLowRefMetricPacket())
                let mepSpike: GetMEPSavedSpikeResponse = try await peripheralManager.write(GetMEPSavedSpikePacket())
                let eep24MSP: GetEEP24MSPResponse = try await peripheralManager.write(GetEEP24MSPPacket())
                cgmManager.state.mepValue = mepValue.value
                cgmManager.state.mepRefChannelMetric = mepRefChannelMetric.value
                cgmManager.state.mepDriftMetric = mepDriftMetric.value
                cgmManager.state.mepLowRefMetric = mepLowRefMetric.value
                cgmManager.state.mepSpike = mepSpike.value
                cgmManager.state.eep24MSP = eep24MSP.value
                
                // Get glucose alarm repeat interval - SKIPPING day/night start time, since we just wrote them
                let lowAlarmRepeatingDay: GetLowGlucoseAlarmRepeatIntervalDayTimeResponse = try await peripheralManager.write(GetLowGlucoseAlarmRepeatIntervalDayTimePacket())
                let highAlarmRepeatingDay: GetHighGlucoseAlarmRepeatIntervalDayTimeResponse = try await peripheralManager.write(GetHighGlucoseAlarmRepeatIntervalDayTimePacket())
                let lowAlarmRepeatingNight: GetLowGlucoseAlarmRepeatIntervalNightTimeResponse = try await peripheralManager.write(GetLowGlucoseAlarmRepeatIntervalNightTimePacket())
                let highAlarmRepeatingNight: GetHighGlucoseAlarmRepeatIntervalNightTimeResponse = try await peripheralManager.write(GetHighGlucoseAlarmRepeatIntervalNightTimePacket())
                cgmManager.state.lowGlucoseAlarmRepeatingDayTime = lowAlarmRepeatingDay.value
                cgmManager.state.highGlucoseAlarmRepeatingDayTime = highAlarmRepeatingDay.value
                cgmManager.state.lowGlucoseAlarmRepeatingNightTime = lowAlarmRepeatingNight.value
                cgmManager.state.highGlucoseAlarmRepeatingNightTime = highAlarmRepeatingNight.value
                
                // Get sensorId
                let senorId: GetSensorIdResponse = try await peripheralManager.write(GetSensorIdPacket())
                cgmManager.state.sensorId = senorId.value
                
                // Get sensor insertion datetime
                let insertionDate: GetSensorInsertionDateResponse = try await peripheralManager.write(GetSensorInsertionDatePacket())
                let insertionTime: GetSensorInsertionTimeResponse = try await peripheralManager.write(GetSensorInsertionTimePacket())
                cgmManager.state.sensorInsertion = Date.fromComponents(
                    date: insertionDate.date,
                    time: insertionTime.time
                )
                
                // Get clinical mode
                let isClinicalMode: GetClinicalModeResponse = try await peripheralManager.write(GetClinicalModePacket())
                cgmManager.state.isClinicalMode = isClinicalMode.value
                
                if isClinicalMode.value {
                    // Get clinical mode duration (if activated)
                    let clinicalModeDuration: GetClinicalModeDurationResponse = try await peripheralManager.write(GetClinicalModeDurationPacket())
                    cgmManager.state.clinicalModeDuration = clinicalModeDuration.value
                }
                
                // Get BLE disconnect alarm -> possible we get no reply, this feature might not be supported
                do {
                    let bleDisconnectAlarm: GetDelayBLEDisconnectAlarmResponse = try await peripheralManager.write(GetDelayBLEDisconnectAlarmPacket())
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
                let sensorSamplingInterval: GetSensorSamplingIntervalResponse = try await peripheralManager.write(GetSensorSamplingIntervalPacket())
                cgmManager.state.sensorSamplingInterval = sensorSamplingInterval.value
                
                // Get calibration times
                let morningCalibrationTime: GetMorningCalibrationTimeResponse = try await peripheralManager.write(GetMorningCalibrationTimePacket())
                let eveningCalibrationTime: GetEveningCalibrationTimeResponse = try await peripheralManager.write(GetEveningCalibrationTimePacket())
                cgmManager.state.morningCalibrationTime = morningCalibrationTime.value
                cgmManager.state.eveningCalibrationTime = eveningCalibrationTime.value
                
                // Get glucose alarms & status
                let glucoseAlarmsStatus: GetGlucoseAlertsAndStatusPacketResonse = try await peripheralManager.write(GetGlucoseAlertsAndStatusPacket())
                cgmManager.state.alarms = glucoseAlarmsStatus.alarms
                
                // Get calibration thresholds
                let minCalibration: GetCalibrationMinThresholdResponse = try await peripheralManager.write(GetCalibrationMinThresholdPacket())
                let maxCalibration: GetCalibrationMaxThresholdResponse = try await peripheralManager.write(GetCalibrationMaxThresholdPacket())
                cgmManager.state.calibrationMinThreshold = minCalibration.value
                cgmManager.state.calibrationMaxThreshold = maxCalibration.value
                
                // Get glucose targets
                let lowGlucoseTarget: GetLowGlucoseTargetResponse = try await peripheralManager.write(GetLowGlucoseTargetPacket())
                let highGlucoseTarget: GetHighGlucoseTargetResponse = try await peripheralManager.write(GetHighGlucoseTargetPacket())
                cgmManager.state.lowGlucoseTarget = lowGlucoseTarget.value
                cgmManager.state.highGlucoseTarget = highGlucoseTarget.value
            } catch {
                logger.error("Something went wrong during full sync: \(error)")
            }
        }
    }
}
