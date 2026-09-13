import Foundation

extension EversenseCGMManager {
    func enqueueForDMS(_ samples: [CGMReading]) {
        dmsQueue.sync {
            var queuedCount = 0
            updateState { state in
                let lastQueued = state.lastUploadedTimestamp ?? .distantPast
                var seen = Set(state.readingsToUpload.map(\.datetime))

                let newSamples = samples
                    .filter { sample in
                        guard sample.datetime > lastQueued, !seen.contains(sample.datetime) else {
                            return false
                        }
                        seen.insert(sample.datetime)
                        return true
                    }
                    .sorted { $0.datetime < $1.datetime }

                guard !newSamples.isEmpty else {
                    return
                }

                state.readingsToUpload.append(contentsOf: newSamples)
                queuedCount = newSamples.count
            }

            guard queuedCount > 0 else {
                return
            }

            logger.debug("Queued \(queuedCount) reading(s) for DMS, total: \(state.readingsToUpload.count)")
        }
    }

    /// Uploads the current value and, when a full batch is queued, the device history.
    /// The two calls are independent: a failing current-value upload must not block history.
    func uploadToDMS(currentGlucose: CGMReading) async {
        let shouldUpload: Bool = dmsQueue.sync {
            if isUploadingDMS {
                return false
            }
            isUploadingDMS = true
            return true
        }

        guard shouldUpload else {
            return
        }

        defer {
            dmsQueue.sync { isUploadingDMS = false }
        }

        await DMSUploadBackgroundTask.run {
            let currentResult = await DMSApi.uploadCurrentValues(cgmManager: self, reading: currentGlucose)
            if !currentResult.isSuccess {
                self.logger.warning("Failed to upload current reading: \(String(describing: currentResult))")
            }

            let (readings, batteryReadings, essentailLogs) = self.dmsQueue.sync {
                self.withState { ($0.readingsToUpload, $0.batteryReadingsToUpload, $0.essentailLogsToUpload) }
            }

            let uploadBatchSize = self.withState { $0.uploadBatchSize }

            if readings.count >= uploadBatchSize {
                handleDMSResult(name: "reading(s)", count: readings.count, result: await DMSApi.uploadDeviceEvents(
                    cgmManager: self,
                    sensorId: self.state.sensorId,
                    readings: readings,
                    calibrations: [],
                    alerts: self.state.activeAlarms.filter { $0.code.dmsCode != 255 }
                )) {
                    let uploadedMax = readings.map(\.datetime).max()
                    self.dmsQueue.sync {
                        self.updateState { state in
                            if let uploadedMax {
                                state.lastUploadedTimestamp = uploadedMax
                                // Remove only what was uploaded; readings queued while the request was in flight must be preserved.
                                state.readingsToUpload.removeAll { $0.datetime <= uploadedMax }
                            }
                        }
                    }
                }
            }

            if batteryReadings.count >= uploadBatchSize {
                handleDMSResult(name: "battery log(s)", count: batteryReadings.count, result: await DMSApi.uploadBatteryLogs(
                    cgmManager: self,
                    sensorId: self.state.sensorId,
                    batteryLogs: batteryReadings
                )) {
                    let uploadedMax = batteryReadings.map(\.datetime).max()
                    self.dmsQueue.sync {
                        self.updateState { state in
                            if let uploadedMax {
                                state.batteryReadingsToUpload.removeAll { $0.datetime <= uploadedMax }
                            }
                        }
                    }
                }
            }

            if essentailLogs.count >= uploadBatchSize {
                handleDMSResult(name: "essentail log(s)", count: essentailLogs.count, result: await DMSApi.uploadEssentailLogs(
                    cgmManager: self,
                    essentailLogs: essentailLogs
                )) {
                    let uploadedMax = essentailLogs.map(\.datetime).max()
                    self.dmsQueue.sync {
                        self.updateState { state in
                            if let uploadedMax {
                                state.essentailLogsToUpload.removeAll { $0.datetime <= uploadedMax }
                            }
                        }
                    }
                }
            }
        }
    }

    private func handleDMSResult(name: String, count: Int, result: DMSUploadResult, onSuccess: @escaping () -> Void) {
        switch result {
        case .success:
            onSuccess()
            logger.info("Uploaded \(count) \(name) to DMS")

        case let .rejected(reason):
            logger.warning("DMS rejected \(name), will retry: \(reason)")

        case let .networkError(reason):
            logger.warning("Failed to upload \(name), will retry: \(reason)")

        case let .other(reason):
            logger.error("Failed to upload \(name), will retry, other error: \(reason)")
        }
    }
}
