//
//  ListViewController.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/16.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit

final class ListViewController: UIViewController {
                
    typealias ActionType = ListActionType
    
    private let action = PublishRelay<ActionType>()
    
    private let viewModel: ListViewModel
        
    private lazy var subView = ListView()
    
    init(viewModel: ListViewModel) {
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
    
    private func setupLayout() {
        
        self.title = self.viewModel.index.title + " 목록"
        self.navigationController?.navigationBar.backgroundColor = .black
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        self.view.addSubview(subView)
        subView.snp.makeConstraints {
            $0.directionalEdges.equalToSuperview()
        }
    }
    
    private func bindViewModel() {
        
        let output = viewModel.transform(
            req: ListViewModel.Input(actionTrigger: action.asObservable()))
        
        subView
            .setupDI(generic: action)
            .setupDI(observable: output.response)
            .setupDI(loadChanger: output.loadChanger)
    }
}
