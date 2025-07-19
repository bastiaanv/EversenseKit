import SwiftUI

struct EversenseSettings: View {
    @ObservedObject var viewModel: EversenseSettingsViewModel

    var body: some View {
        Button(action: viewModel.sync) {
            Text("Sync")
        }

        Button(action: viewModel.deleteCgm) {
            Text("Delete CGM")
        }
    }
}
