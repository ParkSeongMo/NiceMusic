//
//  HomeFlow.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/02.
//

import RxFlow

final class HomeFlow: Flow {
    
    var root: RxFlow.Presentable {
        return self.rootViewController
    }
    
    private let rootViewController = UINavigationController()
    
    func navigate(to step: RxFlow.Step) -> RxFlow.FlowContributors {
        
        guard let step = step as? MainSteps else { return .none }
                
        switch step {
        case .homeIsRequired:
            return coordinateToHome()
        case .listIsRequired(let index):
            return coordinateToList(index: index)
        default:
            return .none
        }
    }
    
    private func coordinateToHome() -> FlowContributors {
        let vm = HomeViewModel()
        let vc = HomeViewController(viewModel: vm)
        self.rootViewController.pushViewController(vc, animated: false)
        return .one(flowContributor: .contribute(withNextPresentable: vc, withNextStepper: vm))
    }
    
    private func coordinateToList(index: HomeIndex) -> FlowContributors {
        let vm = ListViewModel()
        let vc = ListViewController(viewModel: vm, index: index)
        vc.hidesBottomBarWhenPushed = true
        self.rootViewController.pushViewController(vc, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: vc, withNextStepper: vm))
    }
}
