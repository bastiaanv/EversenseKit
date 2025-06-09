import LoopKitUI
import SwiftUI

struct EversenseOnboardingStart: View {
    @Environment(\.dismissAction) private var dismiss

    let nextAction: (Int) -> Void
    let allowedOptions = [0, 1, 2]

    @State var value: Int = 2 // Eversense 365 -> default
    private var currentValue: Binding<Int> {
        Binding(
            get: { value },
            set: { newValue in
                self.value = newValue
            }
        )
    }

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Spacer()

                ResizeablePicker(
                    selection: currentValue,
                    data: self.allowedOptions,
                    formatter: { formatter($0) }
                )

                Spacer()
            }
            .padding(.horizontal)

            Button(action: { nextAction(value) }) {
                Text(LocalizedString("Continue", comment: "Text for continue button"))
            }
            .buttonStyle(ActionButtonStyle())
            .padding([.bottom, .horizontal])
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarHidden(false)
        .navigationTitle(LocalizedString("Choose your Eversense transmitter", comment: "Onboarding Header"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(LocalizedString("Cancel", comment: "Cancel button title"), action: {
                    self.dismiss()
                })
            }
        }
    }

    private func formatter(_ index: Int) -> String {
        switch index {
        case 0:
            return LocalizedString("Eversense - 3 months", comment: "Eversense (3months)")
        case 1:
            return LocalizedString("Eversense XL - 6 months", comment: "Eversense XL (6months)")
        case 2:
            return LocalizedString("Eversense 365 - 1 year", comment: "Eversense 365 (1year)")
        default:
            return ""
        }
    }
}
