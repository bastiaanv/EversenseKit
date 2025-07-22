import SwiftUI

class EversenseSettingsViewModel: ObservableObject {
    @Published var transmitterModel: String = ""
    @Published var transmitterName: String = ""

    @Published var showingDeleteConfirmation: Bool = false

    private let dateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter
    }()

    private let cgmManager: EversenseCGMManager?
    public let deleteCgm: () -> Void
    init(cgmManager: EversenseCGMManager?, deleteCgm: @escaping () -> Void) {
        self.cgmManager = cgmManager
        self.deleteCgm = deleteCgm

        guard let cgmManager = cgmManager else {
            return
        }

        updateState(state: cgmManager.state)
    }

    public var lastGlucoseTimestamp: String {
        dateFormatter.string(from: Date())
    }

    private func updateState(state: EversenseCGMState) {
        transmitterModel = state.modelStr ?? "UNKNOWN"
        transmitterName = state.bleNameString
    }
}
