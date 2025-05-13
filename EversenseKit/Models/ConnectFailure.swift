//
//  ConnectFailure.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 13/05/2025.
//

enum ConnectFailure: Error {
    case failedToDiscoverServices
    case failedToDiscoverCharacteristics
    case unknown(error: Error)
}
