//
//  SearchViewModel.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/02.
//
import RxFlow
import RxRelay
import RxSwift

class SearchViewModel: ViewModelType, Stepper {
    
    // MARK: - Stepper
    var steps = RxRelay.PublishRelay<RxFlow.Step>()
    
    // MARK: - ViewModelType, Protocal
    typealias ViewModel = HomeViewModel
    private let disposeBag = DisposeBag()
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    func transform(req: Input) -> Output {
        
        return Output()
    }
    
}

