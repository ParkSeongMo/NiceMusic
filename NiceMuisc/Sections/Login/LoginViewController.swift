//
//  MainViewController.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/21.
//

import UIKit
import RxRelay

final class LoginViewController: UIViewController {
            
    typealias ActionType = LoginActionType
    
    private let action = PublishRelay<ActionType>()
    
    private let viewModel: LoginViewModel
    
    private lazy var subView = LoginView()
    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        bindViewModel()
    }
    
    private func setupLayout() {
             
        self.view.addSubview(subView)
        subView.snp.makeConstraints {
            $0.directionalEdges.equalToSuperview()
        }
    }
    
    private func bindViewModel() {
        
        let output = viewModel.transform(
            req: LoginViewModel.Input(actionTrigger: action.asObservable()))

        subView.setupDI(generic: action)
    }    
}
