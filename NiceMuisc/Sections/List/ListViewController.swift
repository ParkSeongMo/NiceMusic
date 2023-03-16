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

class ListViewController: UIViewController {
                
    typealias ActionType = ListActionType
    
    private let disposeBag = DisposeBag()
    private let viewModel:ListViewModel
    private let index:HomeIndex
    private let action = PublishRelay<ActionType>()
    
    private lazy var listView = ListView()
    
    init(viewModel: ListViewModel, index: HomeIndex) {
        self.viewModel = viewModel
        self.index = index
        super.init(nibName: nil, bundle: nil)    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        bindViewModel()
        action.accept(.execute(index))
    }
    
    private func setupLayout() {
        
        self.title = index.title + " 목록"
        self.navigationController?.navigationBar.backgroundColor = .black
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        self.view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.directionalEdges.equalToSuperview()
        }
    }
    
    private func bindViewModel() {
        
        let output = viewModel.transform(
            req: ListViewModel.Input(actionTrigger: action.asObservable()))
        
        listView
            .setupDI(generic: action)
            .setupDI(observable: output.response)
    }
}
