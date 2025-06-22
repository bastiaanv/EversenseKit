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
        case let .failedToFetchFleetKey(reason: reason):
            return "Failed to fetch security keys: \(reason)"
        case let .preconditionFailed(reason: reason):
            return "Precondition failed: \(reason)"
        case let .unknown(reason: reason):
            return "Unknown error: \(reason)"
        }
    }
}
