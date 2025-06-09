enum ConnectFailure: Error {
    case failedToDiscoverServices
    case failedToDiscoverCharacteristics
    case unknown(error: Error)
}
