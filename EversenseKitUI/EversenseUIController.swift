//
//  EversenseUIController.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 01/06/2025.
//

import LoopKitUI
import SwiftUICore

enum EversenseUIScreen {
    case onboardingStart
}

class EversenseUIController: UINavigationController, CGMManagerOnboarding, CompletionNotifying, UINavigationControllerDelegate {
    let logger = EversenseLogger(category: "EversenseUIController")
    
    var cgmManagerOnboardingDelegate: LoopKitUI.CGMManagerOnboardingDelegate?
    var completionDelegate: LoopKitUI.CompletionDelegate?
    var cgmManager: EversenseCGMManager?
    var displayGlucoseUnitObservable: DisplayGlucoseUnitObservable

    var colorPalette: LoopUIColorPalette
    var screenStack = [EversenseUIScreen]()

    init(cgmManager: EversenseCGMManager? = nil,
         colorPalette: LoopUIColorPalette,
         displayGlucoseUnitObservable: DisplayGlucoseUnitObservable,
         allowDebugFeatures: Bool)
    {
        self.cgmManager = cgmManager
        self.colorPalette = colorPalette
        self.displayGlucoseUnitObservable = displayGlucoseUnitObservable
        super.init(navigationBarClass: UINavigationBar.self, toolbarClass: UIToolbar.self)
    }

    required init?(coder aDecoder: NSCoder) {
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
        if cgmManager == nil {
            return .onboardingStart
        }
        
        return .onboardingStart
    }
    
    private func hostingController<Content: View>(rootView: Content) -> DismissibleHostingController {
        let rootView = rootView
            .environment(\.appName, Bundle.main.bundleDisplayName)
        return DismissibleHostingController(rootView: rootView, colorPalette: colorPalette)
    }
    
    private func viewControllerForScreen(_ screen: EversenseUIScreen) -> UIViewController {
        switch screen {
        case .onboardingStart:
            let view = EversenseOnboardingStart(
                nextAction: { type in
                    switch type {
                    case 0, 1:
                        // Eversense or Eversense XL
                        self.navigateTo(.onboardingStart)
                        return
                        
                    case 2:
                        // Eversense 365
                        self.navigateTo(.onboardingStart)
                        return
                    default:
                        self.logger.error("Invalid transmitter type received: \(type)")
                    }
                }
            )
            return hostingController(rootView: view)
        }
    }
    
    private func navigateTo(_ screen: EversenseUIScreen) {
        screenStack.append(screen)
        let viewController = viewControllerForScreen(screen)
        viewController.isModalInPresentation = false
        self.pushViewController(viewController, animated: true)
        viewController.view.layoutSubviews()
    }
}
