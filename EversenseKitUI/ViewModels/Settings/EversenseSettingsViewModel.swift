import SwiftUI

class EversenseSettingsViewModel: ObservableObject {
    private let cgmManager: EversenseCGMManager?
    public let deleteCgm: () -> Void
    init(cgmManager: EversenseCGMManager?, deleteCgm: @escaping () -> Void) {
        self.cgmManager = cgmManager
        self.deleteCgm = deleteCgm
    }

    // TEMP
    public func sync() {
        guard let cgmManager = cgmManager else { return }

        cgmManager.heartbeathOperation()
    }
}
