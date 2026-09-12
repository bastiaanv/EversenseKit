import LoopKit
import SwiftUI

class Eversense365AuthViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var error: String = ""
    @Published var isLoading: Bool = false
    @Published var apiZone: EversenseApiZone = .US

    let is365: Bool
    let nextStep: () -> Void
    private let cgmManager: EversenseCGMManager
    init(_ cgmManager: EversenseCGMManager, _ is365: Bool, _ nextStep: @escaping () -> Void) {
        self.cgmManager = cgmManager
        self.is365 = is365
        self.nextStep = nextStep
    }

    func login() {
        isLoading = true
        Task {
            do {
                cgmManager.state.apiZone = apiZone

                let response = try await AuthenticationApi.login(cgmManager: cgmManager, username: username, password: password)
                cgmManager.keychain.setEversenseCredentials(credentials: Credentials(username: username, password: password))
                cgmManager.state.accessToken = response.accessToken
                cgmManager.state.accessTokenExpiration = Date.now.addingTimeInterval(.seconds(Double(response.expiresIn)))
                cgmManager.notifyStateDidChange()

                await MainActor.run {
                    self.isLoading = false
                    self.nextStep()
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    func openRegistrationUrl() {
        if let url = URL(string: apiZone.registerUrl) {
            UIApplication.shared.open(url)
        } else {
            error = "Could not open registration link..."
        }
    }

    func openForgotPasswordUrl() {
        if let url = URL(string: apiZone.forgotPasswordUrl) {
            UIApplication.shared.open(url)
        } else {
            error = "Could not open forgot password link..."
        }
    }
}
