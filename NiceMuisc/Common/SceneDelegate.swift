//
//  SceneDelegate.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/02.
//

import RxFlow
import RxSwift
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    private let appCoordinator: FlowCoordinator = .init()
    
    private let disposeBag: DisposeBag = .init()


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let scene = (scene as? UIWindowScene) else { return }
        
        coordinatorLogStart()
        coordinateToAppFlow(with: scene)
    }
    
    private func coordinateToAppFlow(with windowScene: UIWindowScene) {
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        let appFlow = AppFlow(with: window)
        let appStepper = AppStepper()
        
        appCoordinator.coordinate(flow: appFlow, with: appStepper)
        
        window.makeKeyAndVisible()
    }
    
    private func coordinatorLogStart() {
        appCoordinator.rx.willNavigate
            .subscribe(onNext: { flow, step in
                let currentFlow = "\(flow)".split(separator: ".").last ?? "no flow"
                print("➡️ will navigate to flow = \(currentFlow) and step = \(step)")
            })
            .disposed(by: disposeBag)
    }
}

