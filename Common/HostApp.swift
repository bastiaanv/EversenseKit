import Foundation

public enum HostApp {
    case trio
    case loop
    case iaps
    case unknown

    public static let current: HostApp = {
        guard let bundleId = Bundle.main.bundleIdentifier?.lowercased() else {
            return .unknown
        }
        if bundleId.contains("trio") || bundleId.contains("nightscout") {
            return .trio
        }
        if bundleId.contains("loopkit") {
            return .loop
        }
        if bundleId.contains("artpancreas") || bundleId.contains("FreeAPS") {
            return .iaps
        }
        return .unknown
    }()

    public var name: String {
        switch self {
        case .trio: return "Trio"
        case .loop: return "Loop"
        case .iaps: return "iAPS"
        case .unknown: return "Unknown iOS AID system"
        }
    }

    public var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
}
