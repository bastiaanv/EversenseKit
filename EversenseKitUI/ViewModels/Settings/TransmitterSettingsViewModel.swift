import SwiftUI

class TransmitterSettingsViewModel: ObservableObject {
    @Published var loading = false

    @Published var isRateEnabled = false
    @Published var isFallingRateEnabled = false
    @Published var isRisingRateEnabled = false
    @Published var rateFallingThreshold: Double = 0
    @Published var rateRisingThreshold: Double = 0

    private let cgmManager: EversenseCGMManager?
    init(cgmManager: EversenseCGMManager?) {
        self.cgmManager = cgmManager

        guard let cgmManager = cgmManager else {
            return
        }

        isRateEnabled = cgmManager.state.isRateEnabled
        isFallingRateEnabled = cgmManager.state.isFallingRateEnabled
        isRisingRateEnabled = cgmManager.state.isRisingRateEnabled

        if let value = cgmManager.state.rateFallingThreshold {
            rateFallingThreshold = value
        }

        if let value = cgmManager.state.rateRisingThreshold {
            rateRisingThreshold = value
        }
    }
}
