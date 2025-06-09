import CoreBluetooth

struct ScanItem {
    let name: String
    let rssi: Int
    let peripheral: CBPeripheral
}
