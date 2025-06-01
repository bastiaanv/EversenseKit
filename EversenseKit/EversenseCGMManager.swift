//
//  EversenseCGMManager.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

import LoopKit
import HealthKit

public class EversenseCGMManager: CGMManager {
    private let logger = EversenseLogger(category: "CGMManager")
    private let bluetoothManager: BluetoothManager
    
    public var state: EversenseCGMState
    public var rawState: RawStateValue {
        self.state.rawValue
    }
    
    public var managedDataInterval: TimeInterval? {
        return .hours(3)
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
            device: self.device
        )
    }
    
    private var device: HKDevice {
        HKDevice(
            name: self.state.modelStr,
            manufacturer: "Senseonics",
            model: nil,
            hardwareVersion: nil,
            firmwareVersion: self.state.version,
            softwareVersion: self.state.extVersion,
            localIdentifier: nil,
            udiDeviceIdentifier: nil
        )
    }
    
    
    public weak var cgmManagerDelegate: CGMManagerDelegate? {
        get {
            return delegate.delegate
        }
        set {
            delegate.delegate = newValue
        }
    }

    public var delegateQueue: DispatchQueue! {
        get {
            return delegate.queue
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
        self.bluetoothManager = BluetoothManager()
        self.bluetoothManager.cgmManager = self
    }
    
    
    
    public var isOnboarded: Bool {
        false
    }
    
    public var debugDescription: String {
        let lines = [
            "## EverSense CGM:",
            self.state.debugDescription
        ]
        return lines.joined(separator: "\n")
    }
    
    public func acknowledgeAlert(alertIdentifier: LoopKit.Alert.AlertIdentifier, completion: @escaping ((any Error)?) -> Void) {
        completion(nil)
    }
    
    public func getSoundBaseURL() -> URL? {
        return nil
    }
    
    public func getSounds() -> [LoopKit.Alert.Sound] {
        return []
    }

}

extension EversenseCGMManager {
    public func fetchNewDataIfNeeded(_ completion: @escaping (LoopKit.CGMReadingResult) -> Void) {
        guard let cgmManagerDelegate = cgmManagerDelegate else {
            completion(.error(NSError(domain: "No cgmManagerDelegate", code: -1)))
            return
        }
        
        self.bluetoothManager.ensureConnected { error in
            if let internalError = error {
                completion(.error(internalError))
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
