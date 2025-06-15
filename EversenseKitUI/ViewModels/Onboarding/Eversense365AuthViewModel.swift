import LoopKit
import SwiftUI

class Eversense365AuthViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var error: String = ""
    @Published var isLoading: Bool = false

    private let nextStep: () -> Void
    private let cgmManager: EversenseCGMManager?
    init(_ cgmManager: EversenseCGMManager?, _ nextStep: @escaping () -> Void) {
        self.cgmManager = cgmManager
        self.nextStep = nextStep
    }

    func login() {
        isLoading = true
        Task {
            do {
                let response = try await AuthenticationApi.login(username: username, password: password)

                if let cgmManager = cgmManager {
                    cgmManager.state.username = username
                    cgmManager.state.password = password
                    cgmManager.state.accessToken = response.accessToken
                    cgmManager.state.accessTokenExpiration = Date.now.addingTimeInterval(.seconds(Double(response.expiresIn)))
                    cgmManager.notifyStateDidChange()
                }

                nextStep()
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    func openRegistrationUrl() {
        if let url = URL(string: "https://us.eversensedms.com/Account/Register") {
            UIApplication.shared.open(url)
        } else {
            error = "Could not open registration link..."
        }
    }

    func openForgotPasswordUrl() {
        if let url = URL(string: "https://us.eversensedms.com/Account/ForgotPassword") {
            UIApplication.shared.open(url)
        } else {
            error = "Could not open forgot password link..."
        }
    }
}
