import HealthKit
import LoopKit

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

    private var device: HKDevice {
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
        false
    }

    public var debugDescription: String {
        let lines = [
            "## EverSense CGM:",
            state.debugDescription
        ]
        return lines.joined(separator: "\n")
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
    public func fetchNewDataIfNeeded(_ completion: @escaping (LoopKit.CGMReadingResult) -> Void) {
        guard let cgmManagerDelegate = cgmManagerDelegate else {
            completion(.error(NSError(domain: "No cgmManagerDelegate", code: -1)))
            return
        }

        bluetoothManager.ensureConnected { error in
            if let internalError = error {
                completion(.error(NSError(domain: internalError.describe, code: -1)))
                return
            }

            let startDate = cgmManagerDelegate.startDateToFilterNewData(for: self)
        }
    }

    private func scheduleGlucoseExtrator() {
        Task {
            do {
                try await Task.sleep(for: .seconds(300))
                // TODO:
            } catch {
                self.logger.error("Catched error during glucose extractor: \(error)")
            }

            self.scheduleGlucoseExtrator()
        }
    }

    func notifyStateDidChange() {
        // TODO: Implement
    }
}
