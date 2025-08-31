import HealthKit
import LoopKit

protocol StateObserver: AnyObject {
    func stateDidUpdate(_ state: EversenseCGMState)
}

public class EversenseCGMManager: CGMManager {
    public static var pluginIdentifier: String = "EversenseKit"

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
        false
    }

    public var glucoseDisplay: (any LoopKit.GlucoseDisplayable)?

    public var cgmManagerStatus: LoopKit.CGMManagerStatus {
        LoopKit.CGMManagerStatus(
            hasValidSensorSession: false,
            lastCommunicationDate: nil,
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

    public let localizedTitle = "EverSense CGM: TODO"

    public required init?(rawState: RawStateValue) {
        guard let state = EversenseCGMState(rawValue: rawState) else {
            return nil
        }

        self.state = state
        bluetoothManager = BluetoothManager()
        bluetoothManager.cgmManager = self
    }

    public var isOnboarded: Bool {
        state.isOnboarded
    }

    public var debugDescription: String {
        let lines = [
            "## EverSense CGM:",
            state.debugDescription
        ]
        return lines.joined(separator: "\n")
    }

    func addStateObserver(state: StateObserver, queue: DispatchQueue) {
        stateObservers.insert(state, queue: queue)
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
}

extension EversenseCGMManager {
    public func fetchNewDataIfNeeded(_ completion: @escaping (CGMReadingResult) -> Void) {
        logger.debug("fetchNewDataIfNeeded called but we don't continue")
        completion(.noData)
    }

    /// Responsible for handling fetching Glucose data when ready
    func heartbeathOperation(force: Bool = false) {
        if !force, let recentTime = state.recentGlucoseDateTime, recentTime >= Date().addingTimeInterval(.minutes(-5)) {
            logger.debug("Skipping fetching new data as last fetch was less than 5 minutes ago - \(recentTime)")
            return
        }

        guard let cgmManagerDelegate = cgmManagerDelegate else {
            logger.error("No cgmManagerDelegate")
            return
        }

        bluetoothManager.ensureConnected { error in
            if let internalError = error {
                self.logger.error("Failed to connect to CGM: \(internalError.describe)")
                return
            }

            do {
                if !self.state.is365 {
                    let glucoseData: EversenseE3.GetGlucoseDataResponse = try await self.bluetoothManager
                        .write(EversenseE3.GetGlucoseDataPacket())
                    let recentGlucoseValue: EversenseE3.GetRecentGlucoseValueResponse = try await self.bluetoothManager
                        .write(EversenseE3.GetRecentGlucoseValuePacket())
                    let recentGlucoseDate: EversenseE3.GetRecentGlucoseDateResponse = try await self.bluetoothManager
                        .write(EversenseE3.GetRecentGlucoseDatePacket())
                    let recentGlucoseTime: EversenseE3.GetRecentGlucoseTimeResponse = try await self.bluetoothManager
                        .write(EversenseE3.GetRecentGlucoseTimePacket())

                    let dateTime = Date.fromComponents(
                        date: recentGlucoseDate.date,
                        time: recentGlucoseTime.time
                    )

                    self.state.recentGlucoseInMgDl = recentGlucoseValue.valueInMgDl
                    self.state.recentGlucoseDateTime = dateTime

                    cgmManagerDelegate.cgmManager(self, hasNew: .newData([
                        NewGlucoseSample(
                            cgmManager: self,
                            value: recentGlucoseValue.valueInMgDl,
                            trend: glucoseData.trend ?? .flat,
                            dateTime: dateTime
                        )
                    ]))

                    if let peripheralManager = self.bluetoothManager.peripheralManager {
                        await TransmitterStateSync.fullSyncE3(
                            peripheralManager: peripheralManager,
                            cgmManager: self
                        )
                    }
                } else {
                    self.logger.error("TODO: Implement 365 heartbeath operation")
                }

            } catch {
                self.logger.error("Failed to fetch recent Glucose: \(error.localizedDescription)")
            }
        }
    }

    func notifyStateDidChange() {
        stateObservers.forEach { observer in
            observer.stateDidUpdate(self.state)
        }

        guard let cgmManagerDelegate = cgmManagerDelegate else {
            logger.warning("Skip notifying delegate as no delegate set...")
            return
        }

        cgmManagerDelegate.cgmManagerDidUpdateState(self)
    }
}
