//
//  EversenseCGMManager+UI.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 01/06/2025.
//

import LoopKit
import LoopKitUI

extension EversenseCGMManager: CGMManagerUI {
    public static func setupViewController(bluetoothProvider: any LoopKit.BluetoothProvider, displayGlucoseUnitObservable: LoopKitUI.DisplayGlucoseUnitObservable, colorPalette: LoopKitUI.LoopUIColorPalette, allowDebugFeatures: Bool) -> LoopKitUI.SetupUIResult<any LoopKitUI.CGMManagerViewController, any LoopKitUI.CGMManagerUI> {
        
        let vc = EversenseUIController(colorPalette: colorPalette, displayGlucoseUnitObservable: displayGlucoseUnitObservable, allowDebugFeatures: allowDebugFeatures)
        return .userInteractionRequired(vc)
    }
    
    public func settingsViewController(bluetoothProvider: any LoopKit.BluetoothProvider, displayGlucoseUnitObservable: LoopKitUI.DisplayGlucoseUnitObservable, colorPalette: LoopKitUI.LoopUIColorPalette, allowDebugFeatures: Bool) -> any LoopKitUI.CGMManagerViewController {
        
        return EversenseUIController(cgmManager: self, colorPalette: colorPalette, displayGlucoseUnitObservable: displayGlucoseUnitObservable, allowDebugFeatures: allowDebugFeatures)
    }
    
    public static var onboardingImage: UIImage? {
        return nil
    }
    
    public var smallImage: UIImage? {
        return nil
    }
    
    public var cgmStatusHighlight: (any LoopKit.DeviceStatusHighlight)? {
        return nil
    }
    
    public var cgmLifecycleProgress: (any LoopKit.DeviceLifecycleProgress)? {
        return nil
    }
    
    public var cgmStatusBadge: (any LoopKitUI.DeviceStatusBadge)? {
        return nil
    }
    
    
}
