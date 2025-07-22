import LoopKitUI
import SwiftUICore

enum EversenseUIScreen {
    case onboardingStart
    case onboardingAuth
    case onboardingScan

    case settings
}

class EversenseUIController: UINavigationController, CGMManagerOnboarding, CompletionNotifying, UINavigationControllerDelegate {
    let logger = EversenseLogger(category: "EversenseUIController")

    var cgmManagerOnboardingDelegate: LoopKitUI.CGMManagerOnboardingDelegate?
    var completionDelegate: LoopKitUI.CompletionDelegate?
    var cgmManager: EversenseCGMManager?

    var colorPalette: LoopUIColorPalette
    var screenStack = [EversenseUIScreen]()

    init(
        cgmManager: EversenseCGMManager? = nil,
        colorPalette: LoopUIColorPalette,
        allowDebugFeatures _: Bool
    )
    {
        if let cgmManager = cgmManager {
            self.cgmManager = cgmManager
        } else {
            self.cgmManager = EversenseCGMManager(rawState: [:])
        }
        self.colorPalette = colorPalette
        super.init(navigationBarClass: UINavigationBar.self, toolbarClass: UIToolbar.self)
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self

        navigationBar.prefersLargeTitles = true // Ensure nav bar text is displayed correctly

        if screenStack.isEmpty {
            let screen = getInitialScreen()
            let viewController = viewControllerForScreen(screen)

            screenStack = [screen]
            viewController.isModalInPresentation = false
            setViewControllers([viewController], animated: false)
        }
    }

    private func getInitialScreen() -> EversenseUIScreen {
        guard let cgmManager = cgmManager else {
            return .onboardingStart
        }

        return cgmManager.state.isOnboarded ? .settings : .onboardingStart
    }

    private func hostingController<Content: View>(rootView: Content) -> DismissibleHostingController<some View> {
        let rootView = rootView
            .environment(\.appName, Bundle.main.bundleDisplayName)
        return DismissibleHostingController(content: rootView, colorPalette: colorPalette)
    }

    private func viewControllerForScreen(_ screen: EversenseUIScreen) -> UIViewController {
        switch screen {
        case .onboardingStart:
            let view = EversenseOnboardingStart(
                nextAction: { type in
                    switch type {
                    case 0:
                        // Eversense or Eversense XL
                        self.navigateTo(.onboardingScan)
                        return

                    case 1:
                        // Eversense 365
                        self.navigateTo(.onboardingAuth)
                        return
                    default:
                        self.logger.error("Invalid transmitter type received: \(type)")
                    }
                }
            )
            return hostingController(rootView: view)

        case .onboardingAuth:
            let viewModel = Eversense365AuthViewModel(cgmManager, { self.navigateTo(.onboardingScan) })
            return hostingController(rootView: Eversense365Auth(viewModel: viewModel))

        case .onboardingScan:
            let completion = {
                if let cgmManager = self.cgmManager {
                    cgmManager.state.isOnboarded = true
                    cgmManager.notifyStateDidChange()

                    if let cgmManagerOnboardingDelegate = self.cgmManagerOnboardingDelegate {
                        cgmManagerOnboardingDelegate.cgmManagerOnboarding(didCreateCGMManager: cgmManager)
                    } else {
                        self.logger.warning("Not onboarded -> no onboardDelegate...")
                    }
                }
            }

            if let cgmManager = self.cgmManager, let cgmManagerOnboardingDelegate = self.cgmManagerOnboardingDelegate {
                cgmManagerOnboardingDelegate.cgmManagerOnboarding(didOnboardCGMManager: cgmManager)
            }

            let viewModel = EversenseScanViewModel(cgmManager, completion)
            return hostingController(rootView: Eversense365ScanView(viewModel: viewModel))

        case .settings:
            let deleteCgm = {
                guard let cgmManager = self.cgmManager, let cgmManagerDelegate = cgmManager.cgmManagerDelegate else {
                    return
                }

                cgmManagerDelegate.cgmManagerWantsDeletion(cgmManager)
                self.completionDelegate?.completionNotifyingDidComplete(self)
            }
            let viewModel = EversenseSettingsViewModel(cgmManager: cgmManager, deleteCgm: deleteCgm)
            return hostingController(rootView: EversenseSettings(viewModel: viewModel))
        }
    }

    private func navigateTo(_ screen: EversenseUIScreen) {
        screenStack.append(screen)
        let viewController = viewControllerForScreen(screen)
        viewController.isModalInPresentation = false
        pushViewController(viewController, animated: true)
        viewController.view.layoutSubviews()
    }
}
