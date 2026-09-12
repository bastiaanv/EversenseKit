import HealthKit
import LoopKit
import UIKit

protocol StateObserver: AnyObject {
    func stateDidUpdate(_ state: EversenseCGMState)
}

public class EversenseCGMManager: CGMManager {
    public static var pluginIdentifier: String = "EversenseKit"

    let logger = EversenseLogger(category: "CGMManager")
    internal let bluetoothManager: BluetoothManager
    internal let keychain = KeychainManager()

    public var state: EversenseCGMState
    public var rawState: RawStateValue {
        state.rawValue
    }

    public var managedDataInterval: TimeInterval? {
        .hours(3)
    }

    public var providesBLEHeartbeat: Bool {
        true
    }

    public var shouldSyncToRemoteService: Bool {
        true
    }

    public var glucoseDisplay: (any LoopKit.GlucoseDisplayable)? {
        GlucoseDisplay(state: state)
    }

    public var cgmManagerStatus: LoopKit.CGMManagerStatus {
        LoopKit.CGMManagerStatus(
            hasValidSensorSession: state.isOnboarded && state.recentGlucoseDateTime != nil,
            lastCommunicationDate: state.lastSynced,
            device: device
        )
    }

    internal var device: HKDevice {
        HKDevice(
            name: state.modelStr,
            manufacturer: "Senseonics",
            model: nil,
            hardwareVersion: nil,
            firmwareVersion: state.version,
            softwareVersion: state.extVersion,
            localIdentifier: nil,
            udiDeviceIdentifier: nil
        )
    }

    public weak var cgmManagerDelegate: CGMManagerDelegate? {
        get {
            delegate.delegate
        }
        set {
            delegate.delegate = newValue
        }
    }

    public var delegateQueue: DispatchQueue! {
        get {
            delegate.queue
        }
        set {
            delegate.queue = newValue
        }
    }

    let delegate = WeakSynchronizedDelegate<CGMManagerDelegate>()
    private let stateObservers = WeakSynchronizedSet<StateObserver>()
    let dmsQueue = DispatchQueue(label: "com.bastiaanv.eversensekit.dmsQueue")
    var isUploadingDMS = false

    public let managerIdentifier: String = "EversenseCGMManager"

    public var localizedTitle: String {
        state.modelStr
    }

    public required init(rawState: RawStateValue) {
        state = EversenseCGMState(rawValue: rawState)
        bluetoothManager = BluetoothManager()
        bluetoothManager.cgmManager = self
        EversenseLogger.cgmManager = self

        // Migrate username/password
        if let username = state.username, let password = state.password {
            keychain.setEversenseCredentials(credentials: Credentials(username: username, password: password))
            state.username = nil
            state.password = nil
            notifyStateDidChange()
        }
    }

    func cleanup() {
        logger.info("Cleaning up CGMManager")
        state.bleNameString = nil

        bluetoothManager.stopScan()
        bluetoothManager.disconnect()
    }

    public var isOnboarded: Bool {
        state.isOnboarded
    }

    public var debugDescription: String {
        state.debugDescription
    }

    func addStateObserver(state: StateObserver, queue: DispatchQueue) {
        stateObservers.insert(state, queue: queue)
    }

    func removeStateObserver(state: StateObserver) {
        stateObservers.removeElement(state)
    }

    public func acknowledgeAlert(alertIdentifier _: LoopKit.Alert.AlertIdentifier, completion: @escaping ((any Error)?) -> Void) {
        completion(nil)
    }

    public func getSoundBaseURL() -> URL? {
        nil
    }

    public func getSounds() -> [LoopKit.Alert.Sound] {
        []
    }

    public func delete(completion: @escaping () -> Void) {
        cleanup()
        notifyDelegateOfDeletion(completion: completion)
    }
}

extension EversenseCGMManager {
    public func fetchNewDataIfNeeded(_ completion: @escaping (CGMReadingResult) -> Void) {
        completion(.noData)
        heartbeathOperation {}
    }

    /// Responsible for handling fetching Glucose data when ready
    func heartbeathOperation(force: Bool = false, completion: (() -> Void)? = nil) {
        let lastGlucoseTimestamp = max(
            state.recentGlucoseDateTime ?? Date.distantPast,
            Date.now.addingTimeInterval(.hours(-4))
        )

        if !force, Date.now.timeIntervalSince(lastGlucoseTimestamp) < .minutes(4.5) {
            logger.warning("Skipping sync, glucose is still fresh - \(Date.now.timeIntervalSince(lastGlucoseTimestamp))s")
            completion?()
            return
        }

        bluetoothManager.ensureConnected { error in
            if let internalError = error {
                self.logger.error("Failed to connect to CGM: \(internalError.describe)")
                completion?()
                return
            }

            guard let peripheralManager = self.bluetoothManager.peripheralManager else {
                self.logger.error("No peripheralManager")
                completion?()
                return
            }

            guard let samples = self.getGlucoseAndSync(peripheralManager, lastGlucoseTimestamp),
                  let currentGlucose = samples.last
            else {
                return
            }

            self.state.recentGlucoseInMgDl = currentGlucose.glucoseInMgDl
            self.state.recentGlucoseDateTime = currentGlucose.datetime
            self.state.recentGlucoseTrend = currentGlucose.trend ?? .flat
            self.state.lastReadTimestamp = max(
                currentGlucose.datetime,
                samples.map(\.datetime).max() ?? currentGlucose.datetime
            )
            self.notifyStateDidChange()

            self.delegate.notify { delegate in
                guard let delegate else {
                    return
                }

                let newData = samples.map {
                    NewGlucoseSample(
                        cgmManager: self,
                        value: $0.glucoseInMgDl,
                        trend: $0.trend,
                        dateTime: $0.datetime
                    )
                }

                delegate.cgmManager(self, hasNew: .newData(newData))

                if !self.state.hasReportedInsertionDate {
                    let insertionEvent = PersistedCgmEvent(
                        date: self.state.activatedAt,
                        type: .sensorStart,
                        deviceIdentifier: self.state.sensorId.hexString(),
                        expectedLifetime: self.state.is365 ? .days(365) : .days(180),
                        warmupPeriod: .hours(24)
                    )
                    delegate.cgmManager(self, hasNew: [insertionEvent])

                    self.state.hasReportedInsertionDate = true
                    self.notifyStateDidChange()
                }
            }

            if self.state.shouldUploadToEversenseDMS {
                // Queue the freshly-read history before any network work, so a failed or
                // suspended upload can never discard data that was successfully read.
                self.enqueueForDMS(samples)

                Task {
                    await self.uploadToDMS(currentGlucose: currentGlucose)
                }
            }

            completion?()
        }
    }

    func handleAlarm(alarms: [ActiveAlarm]) {
        let newAlarms = findNewAlarms(current: state.activeAlarms, updated: alarms)
        if !newAlarms.isEmpty {
            delegate.notify { delegate in
                guard let delegate else {
                    return
                }

                newAlarms.forEach {
                    delegate.issueAlert($0.code.alarm)
                }
            }
        }

        state.activeAlarms = alarms.filter { $0.code != .unknown }
    }

    private func findNewAlarms(current: [ActiveAlarm], updated: [ActiveAlarm]) -> [ActiveAlarm] {
        let currentCodes = Set(current.filter { $0.code != .unknown }.map(\.codeRaw))
        return updated.filter { !currentCodes.contains($0.codeRaw) && $0.code != .unknown }
    }

    private func getGlucoseAndSync(
        _ peripheralManager: PeripheralManager,
        _ lastGlucoseTimestamp: Date
    ) -> [CGMReading]? {
        // `lastReadTimestamp` is the BLE read cursor and advances on every successful read.
        // Fall back to the old single cursor / delegate timestamp for migration.
        let readFrom = state.lastReadTimestamp
            ?? state.lastUploadedTimestamp
            ?? state.lastOnlineSync
            ?? lastGlucoseTimestamp

        if !state.is365 {
            guard let samples = EversenseE3.readGlucoseData(
                peripheralManager: peripheralManager,
                cgmManager: self,
                lastGlucoseTimestamp: readFrom
            ) else {
                return nil
            }

            EversenseE3.fullSync(peripheralManager: peripheralManager, cgmManager: self)
            return samples
        } else {
            guard let samples = Eversense365.readGlucoseData(
                cgmManager: self,
                peripheralManager: peripheralManager,
                lastGlucoseTimestamp: readFrom
            ) else {
                return nil
            }

            if state.shouldUploadToEversenseDMS {
                state.essentailLogsToUpload.append(contentsOf: samples)
            }

            Eversense365.fullSync(peripheralManager: peripheralManager, cgmManager: self)
            return samples
        }
    }

    func notifyStateDidChange() {
        stateObservers.forEach { observer in
            observer.stateDidUpdate(self.state)
        }

        delegate.notify { cgmManagerDelegate in
            guard let cgmManagerDelegate = cgmManagerDelegate else {
                self.logger.warning("Skip notifying delegate as no delegate set...")
                return
            }

            cgmManagerDelegate.cgmManagerDidUpdateState(self)
        }
    }
}

struct Credentials: Codable {
    let username: String
    let password: String
}

extension KeychainManager {
    private static let ServiceKey = "com.bastiaanv.Eversensekit"

    func getEversenseCredentials() -> Credentials? {
        do {
            let credentials = try getGenericPasswordForServiceAsData(Self.ServiceKey)
            return try JSONDecoder().decode(Credentials.self, from: credentials)
        } catch {
            print("Failed to fetch credentials: \(error)")
            return nil
        }
    }

    func setEversenseCredentials(credentials: Credentials?) {
        do {
            try deleteGenericPassword(forService: Self.ServiceKey)
            guard let session = credentials else {
                return
            }

            let sessionData = try JSONEncoder().encode(session)
            try replaceGenericPassword(sessionData, forService: Self.ServiceKey)
        } catch {
            return
        }
    }
}
