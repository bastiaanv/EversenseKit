//
//  FrameworkBundle.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 01/06/2025.
//


import Foundation

private class FrameworkBundle {
    static let main = Bundle(for: EversenseUIController.self)
}

func LocalizedString(_ key: String, tableName: String? = nil, value: String? = nil, comment: String) -> String {
    if let value = value {
        return NSLocalizedString(key, tableName: tableName, bundle: FrameworkBundle.main, value: value, comment: comment)
    } else {
        return NSLocalizedString(key, tableName: tableName, bundle: FrameworkBundle.main, comment: comment)
    }
}
