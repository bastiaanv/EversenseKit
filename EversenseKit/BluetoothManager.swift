import CoreBluetooth

class BluetoothManager: NSObject {
    private let logger = EversenseLogger(category: "BluetoothManager")
    private let managerQueue = DispatchQueue(label: "com.bastiaanv.eversensekit.bluetoothManagerQueue", qos: .unspecified)
    public var cgmManager: EversenseCGMManager?
    private var manager: CBCentralManager?

    internal var peripheral: CBPeripheral?
    internal var peripheralManager: PeripheralManager?

    private var scanCompletion: ((ScanItem?, ScanError?) -> Void)?
    private var connectCompletion: ((ConnectFailure?) -> Void)?

    override init() {
        super.init()

        managerQueue.sync {
            self.manager = CBCentralManager(delegate: self, queue: managerQueue)
        }
    }

    func ensureConnected(completionAsync: @escaping (ConnectFailure?) -> Void) {
        let completion = { (_ result: ConnectFailure?) -> Void in
            if let cgmManager = self.cgmManager {
                cgmManager.updateState { $0.connectionStatus = result == nil ? .connected : .idle }
            }

            self.stopScan()
            self.scanCompletion = nil
            self.connectCompletion = nil
            completionAsync(result)
        }

        guard let cgmManager = cgmManager else {
            completion(.preconditionFailed(reason: "No cgm manager..."))
            return
        }

        if let _ = peripheral, let _ = peripheralManager {
            cgmManager.updateState { $0.connectionStatus = .connected }

            logger.debug("Already connected!")

            completion(nil)
            return
        }

        cgmManager.updateState { $0.connectionStatus = .connecting }

        if let peripheral = peripheral {
            logger.debug("Reconnecting to device...")
            connect(peripheral: peripheral) { error in
                if let error = error {
                    completion(error)
                    return
                }

                completion(nil)
            }
            return
        }

        guard let bleName = cgmManager.state.bleNameString else {
            completion(.preconditionFailed(reason: "No ble uuid available"))
            return
        }

        logger.debug("Scanning for device...")
        scan { result, error in
            guard error == nil, let result = result, result.peripheral.name == bleName else {
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

    func write<T>(_ packet: any BasePacket, timeout: TimeInterval = .seconds(5)) throws -> T {
        guard let peripheralManager = peripheralManager else {
            throw NSError(domain: "Not connected", code: -1)
        }

        return try peripheralManager.write(packet, timeout: timeout)
    }

    func scan(completion: @escaping (ScanItem?, ScanError?) -> Void) {
        guard let manager = manager else {
            logger.error("No CBCentralManager available...")
            completion(nil, .noCbCentralManager)
            return
        }

        stopScan()

        scanCompletion = completion
        manager.scanForPeripherals(withServices: [CBUUID.serviceUUID])

        logger.info("Started scanning!")
    }

    private func connect(peripheral: CBPeripheral, completion: @escaping (ConnectFailure?) -> Void) {
        logger.debug("Connecting to: \(peripheral.name ?? "Unknown")")
        guard let manager = manager else {
            completion(.unknown(reason: "No CBCentralManager available"))
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
            logger.info("Stop scanning...")
            manager.stopScan()
        }
    }

    func disconnect() {
        guard let peripheral = peripheral, let manager = manager else {
            logger.warning("No peripheral or manager available to complete disconnect action...")
            return
        }

        manager.cancelPeripheralConnection(peripheral)

        self.peripheral = nil
        peripheralManager = nil
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        logger.debug("State update: \(central.state)")

        if central.state == .resetting {
            peripheral = nil
            peripheralManager = nil
            return
        }

        if central.state == .poweredOn {
            ensureConnected { error in
                if let error = error {
                    self.logger.error("Failed to auto reconnect: \(error.describe)")
                }
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
        scanCompletion(ScanItem(name: name, rssi: rssi.intValue, peripheral: peripheral), nil)
    }

    func centralManager(_: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard let connectCompletion = self.connectCompletion else {
            logger.error("No connectCompletion available")
            return
        }

        guard let cgmManager = self.cgmManager else {
            logger.error("No cgmManager available")
            connectCompletion(.unknown(reason: "No cgmManager available"))
            return
        }

        cgmManager.updateState { $0.bleNameString = peripheral.name }

        self.peripheral = peripheral
        peripheralManager = PeripheralManager(
            peripheral: peripheral,
            cgmManager: cgmManager,
            connectCompletion: connectCompletion
        )

        logger.debug("Connected to transmitter -> Start discovering services...")
        peripheral.discoverServices([CBUUID.serviceUUID])
    }

    func centralManager(_: CBCentralManager, didDisconnectPeripheral _: CBPeripheral, error: Error?) {
        if let error = error {
            logger.error("Failure during disconnect: \(error.localizedDescription)")
        }

        peripheralManager?.cleanup()
        peripheralManager = nil

        guard let cgmManager = cgmManager else {
            return
        }

        cgmManager.updateState { $0.connectionStatus = .idle }

        if !cgmManager.isOnboarded {
            return
        }

        // Reconnect
        ensureConnected { error in
            if let error = error {
                self.logger.error("Failed to reconnect: \(error.describe)")
                return
            }

            self.logger.info("Reconnect succesfull!")
        }
    }

    func centralManager(_: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        logger.error("Failed to connect to \(peripheral.name ?? "unknown") - error \(error?.localizedDescription ?? "unknown")")

        if error != nil {
            logger.debug("Clearing old reference to Transmitter...")
        }

        self.peripheral = nil
        peripheralManager?.cleanup()
        peripheralManager = nil

        ensureConnected { error in
            if let error = error {
                self.logger.error("Failed to reconnect: \(error.describe)")
                return
            }

            self.logger.info("Reconnect succesfull!")
        }
    }
}
