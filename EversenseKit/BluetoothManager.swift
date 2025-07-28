import CoreBluetooth

class BluetoothManager: NSObject {
    private let logger = EversenseLogger(category: "BluetoothManager")
    private let managerQueue = DispatchQueue(label: "com.bastiaanv.eversensekit.bluetoothManagerQueue", qos: .unspecified)
    public var cgmManager: EversenseCGMManager?
    private var manager: CBCentralManager?

    internal var peripheral: CBPeripheral?
    internal var peripheralManager: PeripheralManager?

    private var scanCompletion: ((ScanItem) -> Void)?
    private var connectCompletion: ((ConnectFailure?) -> Void)?

    override init() {
        super.init()

        managerQueue.sync {
            self.manager = CBCentralManager(delegate: self, queue: managerQueue)
        }
    }

    func ensureConnected(completionAsync: @escaping (ConnectFailure?) async -> Void) {
        let completion = { (_ result: ConnectFailure?) -> Void in
            Task {
                if let cgmManager = self.cgmManager {
                    cgmManager.state.connectionStatus = result == nil ? .connected : .idle
                    cgmManager.notifyStateDidChange()
                }

                await completionAsync(result)
            }
        }

        if let _ = peripheral, let _ = peripheralManager {
            completion(nil)
            return
        }

        if let cgmManager = self.cgmManager {
            cgmManager.state.connectionStatus = .connecting
            cgmManager.notifyStateDidChange()
        }

        if let peripheral = peripheral {
            connect(peripheral: peripheral) { error in
                if let error = error {
                    completion(error)
                    return
                }

                completion(nil)
            }
            return
        }

        guard let bleUUIDString = cgmManager?.state.bleUUIDString else {
            completion(.preconditionFailed(reason: "No ble uuid available"))
            return
        }

        scan { result in
            guard result.peripheral.identifier.uuidString == bleUUIDString else {
                return
            }

            self.peripheral = result.peripheral
            self.connect(peripheral: result.peripheral) { error in
                if let error = error {
                    completion(error)
                    return
                }

                completion(nil)
            }
        }
    }

    func write<T>(_ packet: any BasePacket) async throws -> T {
        guard let peripheralManager = peripheralManager else {
            throw NSError(domain: "Not connected", code: -1)
        }

        return try await peripheralManager.write(packet)
    }

    func scan(completion: @escaping (ScanItem) -> Void) {
        guard let manager = manager else {
            logger.error("No CBCentralManager available...")
            return
        }

        if manager.isScanning {
            manager.stopScan()
        }

        scanCompletion = completion
        manager.scanForPeripherals(withServices: [PeripheralManager.serviceUUID])

        logger.info("Started scanning!")
    }

    private func connect(peripheral: CBPeripheral, completion: @escaping (ConnectFailure?) -> Void) {
        logger.debug("Connecting to: \(peripheral.name ?? "Unknown")")
        guard let manager = manager else {
            logger.error("No CBCentralManager available...")
            return
        }

        // Cleanup scan operation
        if scanCompletion != nil {
            scanCompletion = nil
        }

        stopScan()

        connectCompletion = completion

        manager.connect(peripheral)
    }

    internal func stopScan() {
        guard let manager = manager else {
            logger.error("No CBCentralManager available...")
            return
        }

        if manager.isScanning {
            manager.stopScan()
        }
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        logger.debug("State update: \(central.state)")

        guard central.state == .poweredOn else {
            return
        }

        ensureConnected { error in
            if let error = error {
                self.logger.error("Failed to auto reconnect: \(error.describe)")
            }
        }
    }

    func centralManager(
        _: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi: NSNumber
    ) {
        guard let name = peripheral.name, let scanCompletion = self.scanCompletion else {
            return
        }

        logger.info("Device found! \(name), \(advertisementData)")
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

        cgmManager.state.bleNameString = peripheral.name ?? ""
        cgmManager.state.bleUUIDString = peripheral.identifier.uuidString
        cgmManager.notifyStateDidChange()

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
        if let cgmManager = cgmManager {
            cgmManager.state.connectionStatus = .idle
            cgmManager.notifyStateDidChange()
        }

        if let error = error {
            logger.error("Failure during disconnect: \(error.localizedDescription)")
        }

        // Reconnect
        ensureConnected { error in
            if let error = error {
                self.logger.error("Failed to reconnect: \(error.describe)")
            }

            self.logger.info("Reconnect succesfull!")
        }
    }

    func centralManager(_: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        logger.error("Failed to connect to \(peripheral.name ?? "unknown") - error \(error?.localizedDescription ?? "unknown")")
    }
}
