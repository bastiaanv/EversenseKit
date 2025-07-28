import LoopKitUI
import SwiftUI

struct TransmitterSettingsView: View {
    @ObservedObject var viewModel: TransmitterSettingsViewModel

    var body: some View {
        VStack {
            List {
                Toggle(isOn: $viewModel.isRateEnabled) {
                    Text(LocalizedString("Alarming enabled", comment: "transmitter settings rate alarming enabled"))
                }

                if viewModel.isRateEnabled {
                    Toggle(isOn: $viewModel.isRisingRateEnabled) {
                        Text(LocalizedString("Rising alarming enabled", comment: "transmitter settings rising alarming enabled"))
                    }

                    Toggle(isOn: $viewModel.isFallingRateEnabled) {
                        Text(LocalizedString(
                            "Falling alarming enabled",
                            comment: "transmitter settings falling alarming enabled"
                        ))
                    }
                }
            }

            Spacer()

            Button(action: {}) {
                if viewModel.loading {
                    ActivityIndicator(isAnimating: .constant(true), style: .medium)
                } else {
                    Text(LocalizedString("Continue", comment: "Text for continue button"))
                }
            }
            .buttonStyle(ActionButtonStyle())
            .padding([.bottom, .horizontal])
            .disabled(viewModel.loading)
        }
        .navigationBarTitle(LocalizedString("User options", comment: "Title for user options"))
    }
}
