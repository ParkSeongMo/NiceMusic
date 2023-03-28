//
//  HomeViewController.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/02.
//

import RxCocoa
import RxSwift
import SnapKit
import Then

final class HomeViewController: UIViewController {
    
    typealias ActionType = HomeActionType
    
    private let action = PublishRelay<ActionType>()
                
    private let viewModel: HomeViewModel
    
    private lazy var homeView = HomeView()
    
    private lazy var artistDetailApiButton = UIButton().then {
        $0.setTitle("artist Detail", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.backgroundColor = .gray
    }
        
    init(viewModel: HomeViewModel) {
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
        action.accept(.execute)
    }
        
    private func bindViewModel() {
        
        let output = viewModel.transform(
            req: HomeViewModel.Input(actionTrigger: action.asObservable()))
        
        homeView
            .setupDI(generic: action)
            .setupDI(observable: output.response)
            .setupDI(loadChanger: output.loadChanger)
    }
    
    private func setupLayout() {
        self.view.addSubview(homeView)
        homeView.snp.makeConstraints {
            $0.directionalEdges.equalToSuperview()
        }
    }
}
