//
//  LoginFlow.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/21.
//

import RxFlow

final class LoginFlow: Flow {
    
    var root: RxFlow.Presentable {
        return self.rootViewController
    }
    
    private let rootViewController = UINavigationController()
    
    init() {
        
    }
    
    func navigate(to step: RxFlow.Step) -> RxFlow.FlowContributors {
        guard let step = step as? MainSteps else { return .none }
        
        Log.d("navigate \(step)")
        switch step {
        case .loginIsRequired:
            return coordinateToLogin()
        case .loginIsComplete:
            return .end(forwardToParentFlowWithStep: MainSteps.mainTabBarIsRequired)
        default:
            return .none
        }
    }
    
    private func coordinateToLogin() -> FlowContributors {
        let vm = LoginViewModel()
        let vc = LoginViewController(viewModel: vm)
        self.rootViewController.pushViewController(vc, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: vc, withNextStepper: vm))
    }
}
