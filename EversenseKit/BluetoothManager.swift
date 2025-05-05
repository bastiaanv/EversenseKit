//
//  BluetoothManager.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

import CoreBluetooth

class BluetoothManager : NSObject {
    private let managerQueue = DispatchQueue(label: "com.bastiaanv.eversensekit.bluetoothManagerQueue", qos: .unspecified)
    private var manager: CBCentralManager?
    
    override init() {
        managerQueue.sync {
            self.manager = CBCentralManager(delegate: self, queue: managerQueue)
        }
    }
}

extension BluetoothManager : CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
    }
}
