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
        case .detailIsRequired(let type, let artist, let name):
            return coordinateToDetail(type: type, artist: artist, name: name)
        case .rootViewController(let animated):
            self.rootViewController.dismiss(animated: animated)
        default:
            return .none
        }
        return .none
    }
    
    private func coordinateToSearch() -> FlowContributors {
        let vm = SearchViewModel()
        let vc = SearchViewController(viewModel: vm)
        rootViewController.pushViewController(vc, animated: false)
        return .one(flowContributor: .contribute(withNextPresentable: vc, withNextStepper: vm))
    }
    
    private func coordinateToDetail(type: DetailType, artist: String?, name: String?) -> FlowContributors {
        let vm = DetailViewModel(detailType: type, artist: artist, name: name)
        let vc = DetailViewController(viewModel: vm)
        vc.hidesBottomBarWhenPushed = true
        rootViewController.pushViewController(vc, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: vc, withNextStepper: vm))
    }
}

