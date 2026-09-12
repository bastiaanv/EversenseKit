import LoopKit

enum DMSUploadResult: Equatable {
    case success
    /// The server understood the request but did not accept the data (HTTP error or business error).
    case rejected(String)
    /// The request never reached the server (no network, auth failure, invalid URL, ...).
    case networkError(String)
    /// The request could not be build or something else is preventing upload
    case other(String)

    var isSuccess: Bool {
        if case .success = self {
            return true
        }
        return false
    }
}

enum DMSApi {
    private static let logger = EversenseLogger(category: "DMSApi")

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "GMT")!
        return formatter
    }()

    static func uploadCurrentValues(cgmManager: EversenseCGMManager, reading: CGMReading) async -> DMSUploadResult {
        guard let url = URL(string: "\(cgmManager.state.apiZone.careUrl)api/care/PutCurrentValues") else {
            logger.error("Could not create URL...")
            return .other("Could not create URL")
        }

        guard let token = await getAccessToken(cgmManager: cgmManager) else {
            return .networkError("Not authenticated")
        }

        do {
            let message = UploadCurrentGlucoseRequest(
                CurrentGlucose: Int(reading.glucoseInMgDl),
                CGTime: dateFormatter.string(from: reading.datetime),
                GlucoseTrend: mapTrend(reading.trend),
                SignalStrength: Int(cgmManager.state.signalStrength.rawValue),
                BatteryStrength: cgmManager.state.batteryPercentage,
                IsTransmitterConnected: true
            )

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpBody = try JSONEncoder().encode(message)

            let (data, response) = try await URLSession.shared.data(for: request)
            logger
                .info(
                    "Server response PutCurrentValues: \((response as? HTTPURLResponse)?.statusCode ?? -1), data: \(String(data: data, encoding: .utf8) ?? "No data")"
                )

            let result = evaluate(data: data, response: response)
            if !result.isSuccess {
                logger.error("Got invalid response from PutCurrentValues")
            }
            return result
        } catch {
            logger.error("Failed to upload readings: \(error.localizedDescription)")
            return .networkError(error.localizedDescription)
        }
    }

    static func uploadDeviceEvents(
        cgmManager: EversenseCGMManager,
        sensorId: Data,
        readings: [CGMReading],
        calibrations: [CalibrationEvent],
        alerts: [ActiveAlarm]
    ) async -> DMSUploadResult {
        guard let url = URL(string: "\(cgmManager.state.apiZone.careUrl)api/care/PutDeviceEvents") else {
            logger.error("Could not create URL...")
            return .other("Could not create URL")
        }

        guard let transmitterId = cgmManager.state.transmitterId else {
            logger.error("transmitterId is nil")
            return .other("transmitterId is nil")
        }

        guard let token = await getAccessToken(cgmManager: cgmManager) else {
            return .networkError("Not authenticated")
        }

        do {
            let message = UploadDeviceEventRequest(
                deviceType: "SMSIMeter",
                deviceName: "Senseonics Transmitter",
                deviceID: transmitterId,
                offsetBytes: buildOffsetBytes(),
                sgBytes: buildSgBytes(readings: readings, sensorId: sensorId),
                mgBytes: buildEmptyMgBytes(calibrations: calibrations),
                patientBytes: buildEmptyPatientBytes(),
                alertBytes: buildAlertBytes(alerts: alerts, sensorId: sensorId),
                algorithmVersion: cgmManager.state.is365 ? "10" : "1"
            )

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpBody = try JSONEncoder().encode(message)

            let (data, response) = try await URLSession.shared.data(for: request)
            logger
                .info(
                    "Server response PutDeviceEvents: \((response as? HTTPURLResponse)?.statusCode ?? -1), data: \(String(data: data, encoding: .utf8) ?? "No data")"
                )
            let result = evaluate(data: data, response: response)
            if !result.isSuccess {
                logger.error("Got invalid response from PutDeviceEvents")
            }
            return result
        } catch {
            logger.error("Failed to upload readings: \(error.localizedDescription)")
            return .networkError(error.localizedDescription)
        }
    }

    static func uploadBatteryLogs(
        cgmManager: EversenseCGMManager,
        sensorId: Data,
        batteryLogs: [BatteryReadings]
    ) async -> DMSUploadResult {
        guard let url = URL(string: "\(cgmManager.state.apiZone.diagnosticUrl)PostBatteryLogs") else {
            logger.error("Could not create URL...")
            return .other("Could not create URL")
        }

        guard let transmitterId = cgmManager.state.transmitterId else {
            logger.error("transmitterId is nil")
            return .other("transmitterId is nil")
        }

        guard let version = cgmManager.state.version else {
            logger.error("version is nil")
            return .other("version is nil")
        }

        guard let token = await getAccessToken(cgmManager: cgmManager) else {
            return .networkError("Not authenticated")
        }

        do {
            let body = batteryLogs.map {
                UploadBatteryLogRequest(
                    MMATimestamp: dateFormatter.string(from: Date.now),
                    TransmitterId: transmitterId,
                    BatteryLogs: $0.value.base64EncodedString(),
                    RecordNumber: Int($0.recordId),
                    TxTimestamp: dateFormatter.string(from: $0.datetime),
                    SensorId: sensorId.base64EncodedString(),
                    FWVersion: version
                )
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpBody = try JSONEncoder().encode(body)

            let (data, response) = try await URLSession.shared.data(for: request)
            logger
                .info(
                    "Server response PostBatteryLogs: \((response as? HTTPURLResponse)?.statusCode ?? -1), data: \(String(data: data, encoding: .utf8) ?? "No data")"
                )
            let result = evaluate(data: data, response: response)
            if !result.isSuccess {
                logger.error("Got invalid response from PostBatteryLogs")
            }
            return result
        } catch {
            logger.error("Failed to upload battery logs: \(error.localizedDescription)")
            return .networkError(error.localizedDescription)
        }
    }

    /// Classifies a DMS response. Only an HTTP 2xx without an explicit failure flag is accepted;
    /// anything else keeps the caller's pending batch intact so it can be retried.
    private static func evaluate(data: Data, response: URLResponse) -> DMSUploadResult {
        guard let http = response as? HTTPURLResponse else {
            return .networkError("Invalid response type")
        }

        let body = String(data: data, encoding: .utf8) ?? "No data"
        guard (200 ..< 300).contains(http.statusCode) else {
            return .rejected("HTTP \(http.statusCode): \(body)")
        }

        if let businessError = businessError(in: data) {
            return .rejected("\(businessError): \(body)")
        }

        return .success
    }

    /// Conservative business-error detection: only flags an explicit `success == false`
    /// so an unknown response schema can never cause an endless retry loop.
    private static func businessError(in data: Data) -> String? {
        guard !data.isEmpty,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return nil
        }

        for key in ["Success", "success", "IsSuccess", "isSuccess", "Succeeded", "succeeded"] {
            if let value = json[key] as? Bool, value == false {
                return "Server reported \(key)=false"
            }
        }

        return nil
    }

    public static func updateFollowers(cgmManager: EversenseCGMManager) async -> [NowFollowerUI] {
        guard let token = await getAccessToken(cgmManager: cgmManager) else {
            return []
        }

        do {
            guard let urlFollowers = URL(string: "\(cgmManager.state.apiZone.careUrl)api/care/GetMyFollowerPatientList") else {
                logger.error("Could not create follower URL...")
                return []
            }

            guard let urlPending = URL(string: "\(cgmManager.state.apiZone.careUrl)api/care/GetMyPendingFollowerPatientList")
            else {
                logger.error("Could not create URL...")
                return []
            }

            var requestFollower = URLRequest(url: urlFollowers)
            requestFollower.httpMethod = "GET"
            requestFollower.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            let (dataFollower, responseFollower) = try await URLSession.shared.data(for: requestFollower)
            guard let responseFollower = responseFollower as? HTTPURLResponse, responseFollower.statusCode < 400 else {
                let message =
                    "Got invalid response from GetMyFollowerPatientList: \((responseFollower as? HTTPURLResponse)?.statusCode ?? -1) \(String(data: dataFollower, encoding: .utf8) ?? "No data")"

                logger.error(message)
                return []
            }

            var requestPending = URLRequest(url: urlPending)
            requestPending.httpMethod = "GET"
            requestPending.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            let (dataPending, responsePending) = try await URLSession.shared.data(for: requestPending)
            guard let responsePending = responsePending as? HTTPURLResponse, responsePending.statusCode < 400 else {
                let message =
                    "Got invalid response from GetMyFollowerPatientList: \((responsePending as? HTTPURLResponse)?.statusCode ?? -1) \(String(data: dataPending, encoding: .utf8) ?? "No data")"

                logger.error(message)
                return []
            }

            let followers = (try JSONDecoder().decode([NowFollower].self, from: dataFollower)).map {
                NowFollowerUI(
                    FollowerEmail: $0.FollowerEmail,
                    ReferenceName: $0.ReferenceName,
                    isPending: false
                )
            }
            let pending = (try JSONDecoder().decode([NowFollower].self, from: dataPending)).map {
                NowFollowerUI(
                    FollowerEmail: $0.FollowerEmail,
                    ReferenceName: $0.ReferenceName,
                    isPending: true
                )
            }

            return followers + pending
        } catch {
            logger.error("Failed to get patient followers: \(error.localizedDescription)")
            return []
        }
    }

    public static func inviteFollower(cgmManager: EversenseCGMManager, fullName: String, email: String) async {
        guard let token = await getAccessToken(cgmManager: cgmManager) else {
            return
        }

        guard let url =
            URL(
                string: "\(cgmManager.state.apiZone.careUrl)api/care/PutVerificationCode_V2?SenderEmail=\(email)&ReferenceName=\(fullName)&LangCode=en"
            )
        else {
            logger.error("Could not create URL...")
            return
        }

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode < 400 else {
                let message =
                    "Got invalid response from PutVerificationCode_V2: \((response as? HTTPURLResponse)?.statusCode ?? -1) \(String(data: data, encoding: .utf8) ?? "No data")"

                logger.error(message)
                return
            }

        } catch {
            logger.error("Failed to invite follower: \(error.localizedDescription)")
        }
    }

    public static func removeFollower(cgmManager: EversenseCGMManager, email: String) async {
        guard let token = await getAccessToken(cgmManager: cgmManager) else {
            return
        }

        guard let url = URL(string: "\(cgmManager.state.apiZone.careUrl)api/care/UpdateStatus?FollowerEmail=\(email)&Status=2")
        else {
            logger.error("Could not create URL...")
            return
        }

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode < 400 else {
                let message =
                    "Got invalid response from UpdateStatus: \((response as? HTTPURLResponse)?.statusCode ?? -1) \(String(data: data, encoding: .utf8) ?? "No data")"

                logger.error(message)
                return
            }

        } catch {
            logger.error("Failed to update followers: \(error.localizedDescription)")
        }
    }

    private static func getAccessToken(cgmManager: EversenseCGMManager) async -> String? {
        let accessToken = cgmManager.state.accessToken
        let expiration = cgmManager.state.accessTokenExpiration

        if let accessToken, let expiration, expiration.timeIntervalSinceNow > 0 {
            return accessToken
        }

        guard let credentials = cgmManager.keychain.getEversenseCredentials() else {
            logger.error("User not logged in...")
            return nil
        }

        do {
            let response = try await AuthenticationApi.login(
                cgmManager: cgmManager,
                username: credentials.username,
                password: credentials.password
            )
            cgmManager.state.accessToken = response.accessToken
            cgmManager.state.accessTokenExpiration = Date.now.addingTimeInterval(.seconds(Double(response.expiresIn)))
            cgmManager.notifyStateDidChange()

            return response.accessToken
        } catch {
            logger.error("Failed to re-authenticate: \(error.localizedDescription)")
            return nil
        }
    }

    private static func mapTrend(_ trend: GlucoseTrend?) -> Int {
        guard let trend else {
            return 0
        }

        // STALE=0, FALLING_FAST=1, FALLING=2, FLAT=3, RISING=4, RISING_FAST=5
        switch trend {
        case .downDown,
             .downDownDown:
            return 1
        case .down:
            return 2
        case .flat:
            return 3
        case .up:
            return 4
        case .upUp,
             .upUpUp:
            return 5
        }
    }

    private static func buildOffsetBytes() -> String {
        let tzOffsetSec = TimeZone.current.secondsFromGMT()
        return Int64(tzOffsetSec)
            .toData(length: 4)
            .base64EncodedString()
    }

    private static func buildEmptyPatientBytes() -> String {
        // Header: 9E 01 00 + count(2 bytes LE)  → 0 events
        let data = Data([0x9E, 0x01, 0x00, 0x00, 0x00])
        return data.base64EncodedString()
    }

    private static func buildEmptyMgBytes(calibrations: [CalibrationEvent]) -> String {
        // Header: 98 01 00 + count(2 bytes LE) + 00
        var data = Data([0x98, 0x01, 0x00])
        data.append(Int64(calibrations.count).toData(length: 2))
        data.append(0x00)

        let zeroInt16 = Int64(0).toData(length: 2)
        for (idx, r) in calibrations.enumerated() {
            data.append(Int64(idx + 1).toData(length: 2)) // record number (1-based)
            data.append(calcDateBytes(date: r.datetime)) // date
            data.append(calcTimeBytes(date: r.datetime)) // time
            data.append(Int64(r.glucoseInMgDl).toData(length: 2)) // glucose
            data.append(zeroInt16) // Padding
            data.append(Data([1, 0, 0, 0])) // Custom field
        }

        return data.base64EncodedString()
    }

    private static func buildAlertBytes(alerts: [ActiveAlarm], sensorId: Data) -> String {
        // Header: 93 01 00 + count(2 bytes LE) + sensorIdBytes + 00
        var data = Data([0x93, 0x01, 0x00])
        data.append(Int64(alerts.count).toData(length: 2))
        data.append(sensorId)
        data.append(0x00)

        let zeroInt16 = Int64(0).toData(length: 2)
        for (idx, r) in alerts.enumerated() {
            data.append(Int64(idx + 1).toData(length: 2)) // record number (1-based)
            data.append(calcDateBytes(date: r.datetime)) // date
            data.append(calcTimeBytes(date: r.datetime)) // time
            data.append(Data([r.code.dmsCode]))
            data.append(Int64(r.glucoseInMgDl).toData(length: 2)) // glucose
            data.append(zeroInt16) // Padding
            data.append(zeroInt16) // Padding
        }

        return data.base64EncodedString()
    }

    private static func buildSgBytes(readings: [CGMReading], sensorId: Data) -> String {
        // Header: 8C 00 01 00 00 + count (3 bytes LE)
        var data = Data([0x8C, 0x00, 0x01, 0x00, 0x00])
        data.append(Int64(readings.count).toData(length: 3))

        let zeroInt16 = Int64(0).toData(length: 2)
        for (idx, r) in readings.enumerated() {
            data.append(Int64(idx + 1).toData(length: 3)) // record number (1-based)
            data.append(calcDateBytes(date: r.datetime)) // date
            data.append(calcTimeBytes(date: r.datetime)) // time
            data.append(Int64(r.glucoseInMgDl).toData(length: 2)) // glucose
            data.append(0x00) // padding
            data.append(sensorId) // sensor ID

            // RAW_DATA_INDEX 1, 2, 3, 7, 8 (no raw ADC data available)
            for _ in 0 ..< 5 {
                data.append(zeroInt16)
            }

            // Accel values (2 bytes)
            data.append(zeroInt16)

            // AccelTemp (1 byte)
            data.append(0x00)

            // RAW_DATA_INDEX 4, 5, 6
            for _ in 0 ..< 3 {
                data.append(zeroInt16)
            }
        }

        return data.base64EncodedString()
    }

    private static func calcDateBytes(date: Date) -> Data {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "GMT")!
        let year = cal.component(.year, from: date)
        let month = cal.component(.month, from: date) // 1-12
        let day = cal.component(.day, from: date)
        var b1 = (year - 2000) << 1
        if month > 7 { b1 += 1 }
        let b0 = ((month & 7) << 5) | day
        return Data([UInt8(truncatingIfNeeded: b0), UInt8(truncatingIfNeeded: b1)])
    }

    private static func calcTimeBytes(date: Date) -> Data {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "GMT")!
        let hour = cal.component(.hour, from: date)
        let minute = cal.component(.minute, from: date)
        let second = cal.component(.second, from: date)
        let b0 = ((minute & 7) << 5) | (second / 2)
        let b1 = (hour << 3) | ((minute & 56) >> 3)
        return Data([UInt8(truncatingIfNeeded: b0), UInt8(truncatingIfNeeded: b1)])
    }
}
