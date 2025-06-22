enum ConnectFailure {
    case failedToDiscoverServices
    case failedToDiscoverCharacteristics
    case failedToFetchFleetKey(reason: String)
    case preconditionFailed(reason: String)
    case unknown(reason: String)
    
    var describe: String {
        switch self {
        case .failedToDiscoverServices:
            return "Failed to discover services"
        case .failedToDiscoverCharacteristics:
            return "Failed to discover characteristics"
        case .failedToFetchFleetKey(reason: let reason):
            return "Failed to fetch security keys: \(reason)"
        case .preconditionFailed(reason: let reason):
            return "Precondition failed: \(reason)"
        case .unknown(reason: let reason):
            return "Unknown error: \(reason)"
        }
    }
}
