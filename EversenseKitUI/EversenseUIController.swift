import LoopKitUI
import SwiftUI

enum EversenseUIScreen {
    case onboardingStart
    case onboardingAuth
    case onboardingScan

    case settings
    case transmitterInfo
    case transmitterSettings
    case placementGuide
    case calibration
    case calibrationHistory
    case alertHistory
    case dmsSettings
}

class EversenseUIController: UINavigationController, CGMManagerOnboarding, CompletionNotifying, UINavigationControllerDelegate {
    let logger = EversenseLogger(category: "EversenseUIController")

    var cgmManagerOnboardingDelegate: LoopKitUI.CGMManagerOnboardingDelegate?
    var completionDelegate: LoopKitUI.CompletionDelegate?
    var cgmManager: EversenseCGMManager
    var displayGlucosePreference: DisplayGlucosePreference

    var colorPalette: LoopUIColorPalette
    var screenStack = [EversenseUIScreen]()

    private var is365: Bool = true

    init(
        cgmManager: EversenseCGMManager? = nil,
        colorPalette: LoopUIColorPalette,
        displayGlucosePreference: DisplayGlucosePreference,
        allowDebugFeatures _: Bool
    )
    {
        if let cgmManager = cgmManager {
            self.cgmManager = cgmManager
        } else {
            self.cgmManager = EversenseCGMManager(rawState: [:])
        }
        self.colorPalette = colorPalette
        self.displayGlucosePreference = displayGlucosePreference
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
        cgmManager.state.isOnboarded ? .settings : .onboardingStart
    }

    private func hostingController<Content: View>(
        rootView: Content,
        title: String? = nil,
        largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode = .automatic
    ) -> DismissibleHostingController<some View> {
        let rootView = rootView
            .environment(\.appName, Bundle.main.bundleDisplayName)
            .environmentObject(displayGlucosePreference)

        let hostedView = DismissibleHostingController(content: rootView, colorPalette: colorPalette)
        hostedView.navigationItem.title = title
        hostedView.navigationItem.largeTitleDisplayMode = largeTitleDisplayMode

        return hostedView
    }

    private func viewControllerForScreen(_ screen: EversenseUIScreen) -> UIViewController {
        switch screen {
        case .onboardingStart:
            let view = EversenseOnboardingStart(nextAction: onboardingNextStep)
            return hostingController(
                rootView: view,
                title: String(localized: "Welcome!", comment: "Onboarding Header")
            )

        case .onboardingAuth:
            let viewModel = Eversense365AuthViewModel(cgmManager, is365, { self.navigateTo(.onboardingScan) })
            return hostingController(
                rootView: EversenseAuth(viewModel: viewModel),
                title: String(localized: "Eversense Account", comment: "Login header")
            )

        case .onboardingScan:
            let completion = {
                self.cgmManager.updateState {
                    $0.isOnboarded = true
                    $0.hasReportedInsertionDate = false
                }

                if let cgmManagerOnboardingDelegate = self.cgmManagerOnboardingDelegate {
                    DispatchQueue.main.async {
                        cgmManagerOnboardingDelegate.cgmManagerOnboarding(didOnboardCGMManager: self.cgmManager)
                        cgmManagerOnboardingDelegate.cgmManagerOnboarding(didCreateCGMManager: self.cgmManager)
                        self.completionDelegate?.completionNotifyingDidComplete(self)
                    }
                } else {
                    self.logger.warning("Not onboarded -> no onboardDelegate...")
                    DispatchQueue.main.async {
                        self.completionDelegate?.completionNotifyingDidComplete(self)
                    }
                }
            }

            let viewModel = EversenseScanViewModel(cgmManager, completion)
            return hostingController(
                rootView: EversenseScanView(viewModel: viewModel),
                title: String(localized: "Scanning", comment: "Scanning header")
            )

        case .settings:
            let deleteCgm = {
                self.cgmManager.delete {
                    DispatchQueue.main.async {
                        self.completionDelegate?.completionNotifyingDidComplete(self)
                    }
                }
            }

            let viewModel = EversenseSettingsViewModel(
                cgmManager: cgmManager,
                deleteCgm: deleteCgm,
                toTransmitterInfo: { self.navigateTo(.transmitterInfo) },
                toTransmitterSettings: { self.navigateTo(.transmitterSettings) },
                toDMSSettings: { self.navigateTo(.dmsSettings) },
                toPlacementGuide: { self.navigateTo(.placementGuide) },
                toCalibration: { self.navigateTo(.calibration) },
                toCalibrationHistory: { self.navigateTo(.calibrationHistory) },
                toAlertHistory: { self.navigateTo(.alertHistory) }
            )
            return hostingController(
                rootView: EversenseSettingsView(viewModel: viewModel),
                title: viewModel.transmitterModel
            )

        case .transmitterInfo:
            let viewModel = TransmitterInfoViewModel(cgmManager: cgmManager)
            return hostingController(
                rootView: TransmitterInfoView(viewModel: viewModel),
                title: String(localized: "Transmitter information", comment: "transmitter section")
            )

        case .transmitterSettings:
            let viewModel = TransmitterSettingsViewModel(cgmManager: cgmManager, unit: displayGlucosePreference.unit)
            return hostingController(
                rootView: TransmitterSettingsView(viewModel: viewModel),
                title: String(localized: "Transmitter settings", comment: "Title for user options")
            )

        case .placementGuide:
            if #available(iOS 16.0, *) {
                let viewModel = PlacementGuideViewModel(cgmManager: cgmManager)
                return hostingController(
                    rootView: PlacementGuideView(viewModel: viewModel),
                    title: String(localized: "Placement Guide", comment: "Title for placement guide")
                )
            } else {
                return hostingController(
                    rootView: PlacementGuideEmpty(),
                    title: String(localized: "Placement Guide", comment: "Title for placement guide")
                )
            }

        case .calibration:
            let viewModel = CalibrationViewModel(cgmManager: cgmManager, displayGlucosePreference.unit, goBack)
            return hostingController(
                rootView: CalibrationView(viewModel: viewModel),
                title: String(localized: "Calibration", comment: "Calibation header")
            )

        case .calibrationHistory:
            let viewModel = CalibrationHistoryViewModel(cgmManager: cgmManager, glucosePreference: displayGlucosePreference)
            return hostingController(
                rootView: CalibrationHistoryView(viewModel: viewModel),
                title: String(localized: "Calibration history", comment: "Calibation history header")
            )

        case .alertHistory:
            let viewModel = AlertHistoryViewModel(cgmManager: cgmManager)
            return hostingController(
                rootView: AlertHistoryView(viewModel: viewModel),
                title: String(localized: "Alert history", comment: "Alert history header")
            )

        case .dmsSettings:
            let inviteViewModel = InviteNowViewModel(cgmManager: cgmManager)
            let viewModel = DMSSettingsViewModel(cgmManager: cgmManager, inviteNowViewModel: inviteViewModel)
            return hostingController(
                rootView: DMSSettingsView(viewModel: viewModel),
                title: String(localized: "DMS Settings", comment: "DMS header")
            )
        }
    }

    private func navigateTo(_ screen: EversenseUIScreen) {
        screenStack.append(screen)
        let viewController = viewControllerForScreen(screen)
        viewController.isModalInPresentation = false
        pushViewController(viewController, animated: true)
        viewController.view.layoutSubviews()
    }

    private func goBack() {
        guard screenStack.count > 1 else {
            return
        }

        _ = screenStack.popLast()
        popViewController(animated: true)
    }

    private func onboardingNextStep(_ cgmType: Int) {
        #if targetEnvironment(simulator)
            cgmManager.updateState { state in
                state.isOnboarded = true
                state.bleNameString = cgmType == 1 ? "Eversense 365 DEMO" : "Eversense E3 DEMO"
                state.security = cgmType == 1 ? .v2 : .none
                state.recentGlucoseInMgDl = 140
                state.recentGlucoseDateTime = Date.now
                state.recentGlucoseTrend = .flat
                state.signalStrength = .Good
                state.signalStrengthRaw = 1350
                state.batteryPercentage = 75
                state.calibrationMode = .WeeklySingle
                state.calibrationPhase = .DAILY_CALIBRATION
                state.calibrationReadiness = .Ready
                state.activatedAt = Date.now
                state.lastCalibration = Date.now
                state.nextCalibration = Date.now.addingTimeInterval(.days(7))
                state.lastSynced = Date.now
                state.activeAlarms = [
                    ActiveAlarm(
                        code: .CalibrationNowAlarm,
                        codeRaw: Alarm.CalibrationNowAlarm.rawValue,
                        glucoseInMgDl: 0,
                        flag: 0,
                        priority: 0
                    ),
                    ActiveAlarm(
                        code: .PredictiveHighAlarm,
                        codeRaw: Alarm.CalibrationNowAlarm.rawValue,
                        glucoseInMgDl: 0,
                        flag: 0,
                        priority: 2
                    )
                ]
            }

            if let cgmManagerOnboardingDelegate = self.cgmManagerOnboardingDelegate {
                DispatchQueue.main.async {
                    cgmManagerOnboardingDelegate.cgmManagerOnboarding(didOnboardCGMManager: self.cgmManager)
                    cgmManagerOnboardingDelegate.cgmManagerOnboarding(didCreateCGMManager: self.cgmManager)
                    self.completionDelegate?.completionNotifyingDidComplete(self)
                }
            }
        #else
            is365 = cgmType == 1
            navigateTo(.onboardingAuth)
        #endif
    }
}
