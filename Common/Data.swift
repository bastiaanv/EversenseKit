//
//  Data.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 13/05/2025.
//

extension Data {
    func hexString() -> String {
        let format = "%02hhx"
        return self.map { String(format: format, $0) }.joined()
    }
}
