//
//  MainTabBarController.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/02.
//


import UIKit

class MainTabBarController: UITabBarController {
    
    let HEIGHT_TAB_BAR:CGFloat = 100

    override func viewDidLoad() {
        super.viewDidLoad()
        print("MainTabBarController viewDidLoad()")
        setupLayout()
    }
    
    private func setupLayout() {
    
        self.view.backgroundColor = .systemBackground
    }
    
    override func viewDidLayoutSubviews() {
        print("MainTabBarController viewDidLoad()")
        super.viewDidLayoutSubviews()
        var tabFrame = self.tabBar.frame
        tabFrame.size.height = HEIGHT_TAB_BAR
        tabFrame.origin.y = self.view.frame.size.height - HEIGHT_TAB_BAR
        self.tabBar.frame = tabFrame
    }
}
