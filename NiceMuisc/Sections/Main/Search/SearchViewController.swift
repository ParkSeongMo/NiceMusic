//
//  SearchViewController.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/02.
//

import RxCocoa
import SnapKit
import UIKit

class SearchViewController: UIViewController {
    
    typealias ActionType = SearchActionType
    
    private let action = PublishRelay<ActionType>()
    
    private let viewModel:SearchViewModel
    
    private let subView = SearchView()
    
    init(viewModel: SearchViewModel) {
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
        
        action.accept(.getKeyword)
    }
    
    private func setupLayout() {
        self.view.backgroundColor = .black
        
        self.view.addSubviews(subView)
        subView.snp.makeConstraints {
            $0.directionalEdges.equalToSuperview()
        }
    }
        
    private func bindViewModel() {
        let output = viewModel.transform(req: SearchViewModel.Input(actionTrigger: action.asObservable()))
        
        subView.setupDI(generic: action)
            .setupDI(observable: output.response)
            .setupDI(observable: output.keyword)
            .setupDI(loadChanger: output.loadChanger)
    }
}
