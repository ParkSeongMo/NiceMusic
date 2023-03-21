//
//  AppFlow.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/02.
//

import RxFlow

final class AppFlow: Flow {
        
    private let rootWindow: UIWindow
    
    var root: Presentable {
        return self.rootWindow
    }
    
    init(with rootwindow: UIWindow) {
        self.rootWindow = rootwindow
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? MainSteps else { return .none }
        
        switch step {
        case .appStartIsRequired:
            return coordinateToLogin()
        case .mainTabBarIsRequired:
            return coordinateToHome()
        default:
            return .none
        }
    }
    
    private func coordinateToLogin() -> FlowContributors {
        
        let flow = LoginFlow()
        let stepper = LoginStepper.shared
        
        Flows.use(flow, when: .created) {
            [unowned self] root in
            rootWindow.rootViewController = root
        }
        
        return .one(flowContributor: .contribute(withNextPresentable: flow, withNextStepper: stepper))
    }
    
    private func coordinateToHome() -> FlowContributors {
        
        let flow = MainFlow()
        let stepper = MainStepper.shared
        
        Flows.use(flow, when: .created) {
            [unowned self] root in
            rootWindow.rootViewController = root
        }
        
        return .one(flowContributor: .contribute(withNextPresentable: flow, withNextStepper: stepper))
    }
}

