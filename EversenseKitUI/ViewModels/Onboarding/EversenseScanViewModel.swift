import LoopKit
import SwiftUI

struct ScanResultItem: Identifiable {
    let id = UUID()
    var name: String
    let bleIdentifier: String
}

class EversenseScanViewModel: ObservableObject {
    @Published var results: [ScanResultItem] = []
    @Published var isConnecting: Bool = false
    @Published var connectingTo: String = ""
    
    private var cgmManager: EversenseCGMManager?
    init(_ cgmManager: EversenseCGMManager?) {
        self.cgmManager = cgmManager
    }
    
    func start() {
        guard let cgmManager = cgmManager else {
            return
        }
        
        cgmManager.bluetoothManager.scan { item in
            guard !self.results.contains(where: { $0.bleIdentifier == item.peripheral.identifier.uuidString }) else {
                return
            }
            
            self.results.append(ScanResultItem(
                name: item.name,
                bleIdentifier: item.peripheral.identifier.uuidString
            ))
        }
    }
    
    func stopScan() {
        guard let cgmManager = cgmManager else {
            return
        }
        
        cgmManager.bluetoothManager.stopScan()
    }
    
    func connect(_ item: ScanResultItem) {
        guard let scanItem = self.results.first(where: { $0.bleIdentifier == item.bleIdentifier }) else {
            return
        }
        
        connectingTo = item.name
    }
}
