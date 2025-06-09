import CoreBluetooth

class BluetoothManager: NSObject {
    private let logger = EversenseLogger(category: "BluetoothManager")
    private let managerQueue = DispatchQueue(label: "com.bastiaanv.eversensekit.bluetoothManagerQueue", qos: .unspecified)
    public var cgmManager: EversenseCGMManager?
    private var manager: CBCentralManager?

    private var peripheral: CBPeripheral?
    private var peripheralManager: PeripheralManager?

    private var scanCompletion: ((ScanItem) -> Void)?
    private var connectCompletion: ((ConnectFailure?) -> Void)?

    override init() {
        super.init()

        managerQueue.sync {
            self.manager = CBCentralManager(delegate: self, queue: managerQueue)
        }
    }

    func ensureConnected(completion: @escaping (NSError?) -> Void) {
        if let _ = peripheral, let _ = peripheralManager {
            completion(nil)
        }

        if let peripheral = peripheral {
            connect(peripheral: peripheral) { error in
                if let error = error {
                    completion(NSError(domain: error.localizedDescription, code: -1))
                    return
                }

                completion(nil)
            }
        }

        guard let bleUUIDString = cgmManager?.state.bleUUIDString else {
            completion(NSError(domain: "No ble uuid available", code: -1))
            return
        }

        scan { result in
            guard result.peripheral.identifier.uuidString == bleUUIDString else {
                return
            }

            self.connect(peripheral: result.peripheral) { error in
                if let error = error {
                    completion(NSError(domain: error.localizedDescription, code: -1))
                    return
                }

                completion(nil)
            }
        }
    }

    private func scan(completion: @escaping (ScanItem) -> Void) {
        guard let manager = manager else {
            logger.error("No CBCentralManager available...")
            return
        }

        if manager.isScanning {
            manager.stopScan()
        }

        scanCompletion = completion
        manager.scanForPeripherals(withServices: nil)
    }

    private func connect(peripheral: CBPeripheral, completion: @escaping (ConnectFailure?) -> Void) {
        guard let manager = manager else {
            logger.error("No CBCentralManager available...")
            return
        }

        // Cleanup scan operation
        if scanCompletion != nil {
            scanCompletion = nil

            if manager.isScanning {
                manager.stopScan()
            }
        }

        connectCompletion = completion
        manager.connect(peripheral)
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_: CBCentralManager) {}

    func centralManager(
        _: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData _: [String: Any],
        rssi: NSNumber
    ) {
        guard let name = peripheral.name, let scanCompletion = self.scanCompletion else {
            return
        }

        // TODO: Add uuid check (parseUUIDs java method)

        scanCompletion(.init(name: name, rssi: rssi.intValue, peripheral: peripheral))
    }

    func centralManager(_: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard let connectCompletion = self.connectCompletion else {
            logger.error("No connectCompletion available")
            return
        }

        guard let cgmManager = self.cgmManager else {
            logger.error("No cgmManager available")
            return
        }

        self.peripheral = peripheral
        peripheralManager = PeripheralManager(
            peripheral: peripheral,
            cgmManager: cgmManager,
            connectCompletion: connectCompletion
        )

        logger.debug("Connected to transmitter -> Start discovering services...")
        peripheral.discoverServices(nil)
    }

    func centralManager(_: CBCentralManager, didDisconnectPeripheral _: CBPeripheral, error: Error?) {
        if let error = error {
            logger.error("Failure during disconnect: \(error.localizedDescription)")
        }

        // Reconnect
        ensureConnected { error in
            if let error = error {
                self.logger.error("Failed to reconnect: \(error.localizedDescription)")
            }

            self.logger.info("Reconnect succesfull!")
        }
    }

    func centralManager(_: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        logger.error("Failed to connect to \(peripheral.name ?? "unknown") - error \(error?.localizedDescription ?? "unknown")")
    }
}
