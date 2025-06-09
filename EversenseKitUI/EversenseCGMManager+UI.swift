import LoopKit
import LoopKitUI

extension EversenseCGMManager: CGMManagerUI {
    public static func setupViewController(
        bluetoothProvider _: BluetoothProvider,
        displayGlucosePreference _: DisplayGlucosePreference,
        colorPalette: LoopUIColorPalette,
        allowDebugFeatures: Bool,
        prefersToSkipUserInteraction _: Bool = false
    ) -> SetupUIResult<CGMManagerViewController, CGMManagerUI> {
        let vc = EversenseUIController(colorPalette: colorPalette, allowDebugFeatures: allowDebugFeatures)
        return .userInteractionRequired(vc)
    }

    public func settingsViewController(
        bluetoothProvider _: BluetoothProvider,
        displayGlucosePreference _: DisplayGlucosePreference,
        colorPalette: LoopUIColorPalette,
        allowDebugFeatures: Bool
    ) -> CGMManagerViewController {
        EversenseUIController(cgmManager: self, colorPalette: colorPalette, allowDebugFeatures: allowDebugFeatures)
    }

    public static var onboardingImage: UIImage? {
        nil
    }

    public var smallImage: UIImage? {
        nil
    }

    public var cgmStatusHighlight: (any LoopKit.DeviceStatusHighlight)? {
        nil
    }

    public var cgmLifecycleProgress: (any LoopKit.DeviceLifecycleProgress)? {
        nil
    }

    public var cgmStatusBadge: (any LoopKitUI.DeviceStatusBadge)? {
        nil
    }
}
