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
    @Published var error: String = ""
    
    private var actualResults: [ScanItem] = []
    
    private let cgmManager: EversenseCGMManager?
    private let nextStep: () -> Void
    init(_ cgmManager: EversenseCGMManager?, _ nextStep: @escaping () -> Void) {
        self.cgmManager = cgmManager
        self.nextStep = nextStep
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
            self.actualResults.append(item)
        }
    }
    
    func stopScan() {
        guard let cgmManager = cgmManager else {
            return
        }
        
        cgmManager.bluetoothManager.stopScan()
    }
    
    func connect(_ item: ScanResultItem) {
        guard let scanItem = self.actualResults.first(where: { $0.peripheral.identifier.uuidString == item.bleIdentifier }), let cgmManager = self.cgmManager else {
            return
        }
        
        connectingTo = scanItem.name
        cgmManager.bluetoothManager.peripheral = scanItem.peripheral
        
        cgmManager.bluetoothManager.ensureConnected { error in
            if let error = error {
                DispatchQueue.main.async {
                    self.error = error.describe
                    return
                }
                return
            }
            
            self.nextStep()
        }
    }
}
