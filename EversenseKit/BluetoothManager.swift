//
//  BluetoothManager.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 05/05/2025.
//

import CoreBluetooth

class BluetoothManager : NSObject {
    private let logger = EversenseLogger(category: "BluetoothManager")
    private let managerQueue = DispatchQueue(label: "com.bastiaanv.eversensekit.bluetoothManagerQueue", qos: .unspecified)
    public let cgmManager: EversenseCGMManager
    private var manager: CBCentralManager?
    
    private var peripheral: CBPeripheral?
    private var peripheralManager: PeripheralManager?
    
    private var scanCompletion: ((ScanItem) -> Void)?
    private var connectCompletion: ((Result<Void, ConnectFailure>) -> Void)?
    
    init(cgmManager: EversenseCGMManager) {
        self.cgmManager = cgmManager
        managerQueue.sync {
            self.manager = CBCentralManager(delegate: self, queue: managerQueue)
        }
    }
    
    func scan(completion: @escaping (ScanItem) -> Void) {
        guard let manager = manager else {
            self.logger.error("No CBCentralManager available...")
            return
        }
        
        if manager.isScanning {
            manager.stopScan()
        }
        
        self.scanCompletion = completion
        manager.scanForPeripherals(withServices: nil)
    }
    
    func connect(peripheral: CBPeripheral, completion: @escaping (Result<Void, ConnectFailure>) -> Void) {
        guard let manager = manager else {
            self.logger.error("No CBCentralManager available...")
            return
        }
        
        // Cleanup scan operation
        if scanCompletion != nil {
            scanCompletion = nil
            
            if manager.isScanning {
                manager.stopScan()
            }
        }
        
        self.connectCompletion = completion
        manager.connect(peripheral)
    }
}

extension BluetoothManager : CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) { }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi: NSNumber
    ) {
        guard let name = peripheral.name, let scanCompletion = self.scanCompletion else {
            return
        }
        
        // TODO: Add uuid check (parseUUIDs java method)
        
        scanCompletion(.init(name: name, rssi: rssi.intValue, peripheral: peripheral))
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard let connectCompletion = self.connectCompletion else {
            self.logger.error("No connectCompletion available")
            return
        }
        
        self.peripheral = peripheral
        self.peripheralManager = PeripheralManager(peripheral: peripheral, cgmManager: cgmManager, connectCompletion: connectCompletion)
        
        self.logger.debug("Connected to transmitter -> Start discovering services...")
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            self.logger.error("Failure during disconnect: \(error.localizedDescription)")
        }
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        self.logger.error("Failed to connect to \(peripheral.name ?? "unknown") - error \(error?.localizedDescription ?? "unknown")")
    }
}
