import LoopKitUI
import SwiftUI

struct Eversense365Auth: View {
    @Environment(\.dismissAction) private var dismiss

    @ObservedObject var viewModel: Eversense365AuthViewModel

    var body: some View {
        VStack {
            List {
                Section {
                    TextField(LocalizedString("Email address", comment: "Label for email address"), text: $viewModel.username)
                        .textContentType(.emailAddress)
                    SecureField(LocalizedString("Password", comment: "Label for password"), text: $viewModel.password)
                        .textContentType(.password)
                } footer: {
                    Text(LocalizedString(
                        "If your Eversense 365 is already active, please make sure to use the same account",
                        comment: "login footer same account"
                    ))
                }

                Button(LocalizedString("Forgot password", comment: "Label for forgot password")) {
                    viewModel.openForgotPasswordUrl()
                }
            }

            Spacer()

            if !viewModel.error.isEmpty {
                Text(viewModel.error)
                    .foregroundStyle(.red)
            }

            Button(action: viewModel.openRegistrationUrl) {
                Text(LocalizedString("Create account", comment: "Create account"))
            }
            .buttonStyle(ActionButtonStyle(.secondary))
            .disabled(viewModel.isLoading)
            .padding(.horizontal)

            Button(action: viewModel.login) {
                Text(LocalizedString("Login", comment: "Continue"))
            }
            .disabled(viewModel.username.isEmpty || viewModel.password.isEmpty || viewModel.isLoading)
            .buttonStyle(ActionButtonStyle())
            .padding([.bottom, .horizontal])
        }
        .listStyle(InsetGroupedListStyle())
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarHidden(false)
        .navigationTitle(LocalizedString("Eversense Account", comment: "Login header"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(LocalizedString("Cancel", comment: "Cancel button title"), action: {
                    self.dismiss()
                })
            }
        }
    }
}
