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
            return coordinateToMain()
            
        default:
            return .none
        }
    }
    
    private func coordinateToMain() -> FlowContributors {
        
        let mainFlow = MainFlow()
        let stepper = MainStepper()
        
        Flows.use(mainFlow, when: .created) {
            [unowned self] root in
            rootWindow.rootViewController = root
        }
        
        return .one(flowContributor: .contribute(withNextPresentable: mainFlow, withNextStepper: stepper))
    }
}

