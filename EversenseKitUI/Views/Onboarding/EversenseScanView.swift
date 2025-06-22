import LoopKitUI
import SwiftUI

struct Eversense365ScanView: View {
    @Environment(\.isPresented) var isPresented
    @Environment(\.dismissAction) private var dismiss

    @ObservedObject var viewModel: EversenseScanViewModel

    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 0) {
                Text(
                    !viewModel.isConnecting ?
                        LocalizedString("Scanning", comment: "Scanning text") :
                        LocalizedString("Connecting", comment: "Connecting text")
                )
                Spacer()
                ActivityIndicator(isAnimating: .constant(true), style: .medium)
            }

            Divider()
            content
        }
        .listStyle(InsetGroupedListStyle())
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarHidden(false)
        .navigationTitle(LocalizedString("Find your Eversense", comment: "Login header"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(LocalizedString("Cancel", comment: "Cancel button title"), action: {
                    self.dismiss()
                })
            }
        }
        .onChange(of: isPresented) { newValue in
            if !newValue {
                viewModel.stopScan()
            }
        }
    }

    @ViewBuilder private var content: some View {
        List {
            ForEach($viewModel.results) { $result in
                Button(action: { viewModel.connect($result.wrappedValue) }) {
                    HStack {
                        Text($result.name.wrappedValue)
                        Spacer()
                        if !$viewModel.isConnecting.wrappedValue {
                            NavigationLink.empty
                        } else if $result.name.wrappedValue == viewModel.connectingTo {
                            ActivityIndicator(isAnimating: .constant(true), style: .medium)
                        }
                    }
                    .padding(.horizontal)
                }
                .disabled($viewModel.isConnecting.wrappedValue)
                .buttonStyle(.plain)
            }
        }
        .listStyle(.plain)
    }
}
