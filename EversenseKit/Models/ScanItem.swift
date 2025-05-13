//
//  ScanItem.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 13/05/2025.
//

import CoreBluetooth

struct ScanItem {
    let name: String
    let rssi: Int
    let peripheral: CBPeripheral
}
