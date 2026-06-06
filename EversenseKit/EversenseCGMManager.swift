import HealthKit
import LoopKit

protocol StateObserver: AnyObject {
    func stateDidUpdate(_ state: EversenseCGMState)
}

public class EversenseCGMManager: CGMManager {
    // Pluggable conformance: must be an instance property.
    public let pluginIdentifier: String = "EversenseKit"

    // DeviceManager conformance.
    public var inSignalLoss: Bool {
        guard let lastSynced = state.lastSynced else { return true }
        return Date().timeIntervalSince(lastSynced) > .minutes(15)
    }

    public var isInoperable: Bool {
        // EversenseKit reports connection/sensor state via state.connectionStatus;
        // we treat anything other than .connected as not-inoperable but stale.
        false
    }

    private let logger = EversenseLogger(category: "CGMManager")
    internal let bluetoothManager: BluetoothManager

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

    private let delegate = WeakSynchronizedDelegate<CGMManagerDelegate>()
    private let stateObservers = WeakSynchronizedSet<StateObserver>()

    public let managerIdentifier: String = "EversenseCGMManager"

    public var localizedTitle: String {
        state.modelStr
    }

    public required init?(rawState: RawStateValue) {
        guard let state = EversenseCGMState(rawValue: rawState) else {
            return nil
        }

        self.state = state
        bluetoothManager = BluetoothManager()
        bluetoothManager.cgmManager = self
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

    public func acknowledgeAlert(alertIdentifier _: LoopKit.Alert.AlertIdentifier) async throws {
        // No-op: EversenseKit doesn't surface its own LoopKit alerts.
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

            let result = self.getGlucoseAndSync(peripheralManager, lastGlucoseTimestamp)
            guard let (currentGlucose, samples) = result else {
                return
            }

            self.state.recentGlucoseInMgDl = currentGlucose.glucoseInMgDl
            self.state.recentGlucoseDateTime = currentGlucose.datetime
            self.state.recentGlucoseTrend = currentGlucose.trend ?? .flat
            self.notifyStateDidChange()

            self.delegate.notify { delegate in
                guard let delegate else {
                    return
                }

                var newData = samples
                    .filter { $0.datetime > lastGlucoseTimestamp }
                    .map {
                        NewGlucoseSample(
                            cgmManager: self,
                            value: $0.glucoseInMgDl,
                            trend: $0.trend,
                            dateTime: $0.datetime
                        ) }

                newData.append(NewGlucoseSample(
                    cgmManager: self,
                    value: currentGlucose.glucoseInMgDl,
                    trend: currentGlucose.trend,
                    dateTime: currentGlucose.datetime
                ))

                delegate.cgmManager(self, hasNew: .newData(newData))
            }

            if self.state.shouldUploadToEversenseDMS {
                Task {
                    guard await DMSApi.uploadCurrentValues(cgmManager: self, reading: currentGlucose)
                    else {
                        self.logger.warning("Failed to upload current reading")
                        return
                    }

                    self.state.readingsToUpload += samples
                    if self.state.readingsToUpload.count < self.state.uploadBatchSize {
                        self.logger.debug("Nothing to upload...")
                        return
                    }

                    guard await DMSApi.uploadDeviceEvents(
                        cgmManager: self,
                        sensorId: self.state.sensorId,
                        readings: self.state.readingsToUpload,
                        calibrations: [],
                        alerts: self.state.activeAlarms.filter { $0.code.dmsCode != 255 }
                    ) else {
                        self.logger.warning("Failed to upload device events")
                        return
                    }

                    self.state.lastOnlineSync = self.state.readingsToUpload.map(\.datetime).max()
                    self.state.readingsToUpload = []
                    self.notifyStateDidChange()
                }
            }

            completion?()
        }
    }

    private func getGlucoseAndSync(
        _ peripheralManager: PeripheralManager,
        _ lastGlucoseTimestamp: Date
    ) -> (CGMReading, [CGMReading])? {
        if !state.is365 {
            guard let (currentGlucose, samples) = EversenseE3.readGlucoseData(
                peripheralManager: peripheralManager,
                cgmManager: self,
                lastGlucoseTimestamp: state.lastOnlineSync ?? lastGlucoseTimestamp
            ) else {
                return nil
            }

            EversenseE3.fullSync(peripheralManager: peripheralManager, cgmManager: self)
            return (currentGlucose, samples)
        } else {
            guard let (currentGlucose, samples) = Eversense365.readGlucoseData(
                cgmManager: self,
                peripheralManager: peripheralManager,
                lastGlucoseTimestamp: state.lastOnlineSync ?? lastGlucoseTimestamp
            ) else {
                return nil
            }

            Eversense365.fullSync(peripheralManager: peripheralManager, cgmManager: self)
            return (currentGlucose, samples)
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
