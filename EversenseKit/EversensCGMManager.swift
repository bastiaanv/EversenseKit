//
//  EversensCGMManager.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

import LoopKit

public class EversensCGMManager: CGMManager {
    public var cgmManagerDelegate: (any LoopKit.CGMManagerDelegate)?
    
    public var providesBLEHeartbeat: Bool
    
    public var managedDataInterval: TimeInterval?
    
    public var shouldSyncToRemoteService: Bool
    
    public var glucoseDisplay: (any LoopKit.GlucoseDisplayable)?
    
    public var cgmManagerStatus: LoopKit.CGMManagerStatus
    
    public var delegateQueue: DispatchQueue!
    
    public func fetchNewDataIfNeeded(_ completion: @escaping (LoopKit.CGMReadingResult) -> Void) {
        <#code#>
    }
    
    public var managerIdentifier: String
    
    public var localizedTitle: String
    
    public required init?(rawState: RawStateValue) {
        <#code#>
    }
    
    public var rawState: RawStateValue
    
    public var isOnboarded: Bool {
        false
    }
    
    public var debugDescription: String
    
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
