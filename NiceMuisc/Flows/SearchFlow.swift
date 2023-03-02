//
//  SearchFlow.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/02.
//

import RxFlow

final class SearchFlow: Flow {
    
    var root: RxFlow.Presentable {
        return self.rootViewController
    }
    
    private let rootViewController = UINavigationController()
    
    func navigate(to step: RxFlow.Step) -> RxFlow.FlowContributors {
        
        guard let step = step as? MainSteps else { return .none }
                
        switch step {
        case .searchIsRequired:
            return coordinateToSearch()
        default:
            return .none
        }
    }
    
    private func coordinateToSearch() -> FlowContributors {
        let vm = SearchViewModel()
        let vc = SearchViewController(viewModel: vm)
        self.rootViewController.pushViewController(vc, animated: false)
        return .one(flowContributor: .contribute(withNextPresentable: vc, withNextStepper: vm))
    }
}

