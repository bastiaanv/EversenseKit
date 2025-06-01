//
//  Bundle.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 01/06/2025.
//


import Foundation

extension Bundle {
    var bundleDisplayName: String {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
    }
}
