//
//  MainFlow.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/02.
//


import RxFlow

final class MainFlow: Flow {
    
    
    private var tabBarTitle: [String] {
        ["Home", "Search"]
    }
    
    private var tabBarImageN: [UIImage] {
        return [#imageLiteral(resourceName: "cm_btn_gnb_home_n"),  #imageLiteral(resourceName: "cm_btn_gnb_search_n")]
    }
    
    private var tabBarImageP: [UIImage] {
        return [#imageLiteral(resourceName: "cm_btn_gnb_home_p"),  #imageLiteral(resourceName: "cm_btn_gnb_search_p")]
    }

    private var tabBarImageF: [UIImage] {
        return [#imageLiteral(resourceName: "cm_btn_gnb_home_f"),  #imageLiteral(resourceName: "cm_btn_gnb_search_f")]
    }
    
    var root: Presentable {
        return rootViewController
    }
    
    private lazy var rootViewController: UITabBarController = {
        let viewController = UITabBarController()
        viewController.view.backgroundColor = .systemBackground
        return viewController
    }()
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? MainSteps else { return .none }
        
        print("navigate \(step)")
        switch step {
        case .mainTabBarIsRequired:
            return coordinateToMainTabBar()
        default:
            return .none
        }
    }
    
    private func coordinateToMainTabBar() -> FlowContributors {
        
        let homeFlow = HomeFlow()
        let searchFlow = SearchFlow()
        
        let homeStepper = HomeStepper()
        let searchStepper = SearchStepper()
        
        Flows.use(homeFlow, searchFlow, when: .created) {
            [unowned self] (root1: UINavigationController, root2: UINavigationController) in
            
            rootViewController.tabBar.backgroundColor = .white
            
            root1.tabBarItem = makeTabBarItem(index: 0)
            root2.tabBarItem = makeTabBarItem(index: 1)
                                    
            self.rootViewController.setViewControllers([root1, root2], animated: false)
        }
        
        return .multiple(flowContributors: [
                .contribute(withNextPresentable: homeFlow, withNextStepper: homeStepper),
                .contribute(withNextPresentable: searchFlow, withNextStepper: searchStepper)
        ])
    }
    
    private func makeTabBarItem(index: Int) -> UITabBarItem {
        return .init(
            title: tabBarTitle[index],
            image: tabBarImageN[index],
            selectedImage: tabBarImageF[index])
    }
}
