//
//  DetailViewController.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/17.
//


import RxCocoa
import RxSwift
import SnapKit

final class DetailViewController: BaseViewController {
                
    typealias ActionType = DetailActionType
    
    private let action = PublishRelay<ActionType>()
    
    private let viewModel: DetailViewModel
    
    private let detailType: DetailType
    private lazy var subView = DetailView()
    
    init(viewModel: DetailViewModel, detailType: DetailType) {
        self.viewModel = viewModel
        self.detailType = detailType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subView.detailType = detailType
        
        setupLayout()
        bindViewModel()
        action.accept(.execute)
    }
    
    private func setupLayout() {
        
        self.view.backgroundColor = .black
//        self.title = index.title + " 목록"
//        self.navigationController?.navigationBar.backgroundColor = .black
//        self.navigationController?.navigationBar.tintColor = .white
//        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        self.view.addSubview(subView)
        subView.snp.makeConstraints {
            $0.directionalEdges.equalToSuperview()
        }
    }
    
    private func bindViewModel() {
        
        let output = viewModel.transform(
            req: DetailViewModel.Input(actionTrigger: action.asObservable()))

        subView
            .setupDI(observable: output.response)

        setupLoadChager(observable: output.loadChanger)
    }
}
