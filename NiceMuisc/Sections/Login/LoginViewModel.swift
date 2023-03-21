//
//  MainViewModel.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/21.
//

import Action
import RxFlow
import RxRelay
import RxSwift

enum LoginActionType {
    case tapForHome
}

final class LoginViewModel: ViewModelType, Stepper {
  
    var steps = RxRelay.PublishRelay<RxFlow.Step>()
    
    private let disposeBag = DisposeBag()
    
    private lazy var buttonAction = Action<LoginActionType, Void> { [weak self] action in
        guard let `self` = self else { return .empty() }
        Log.d("buttonAction \(action)")
        switch action {
        case .tapForHome:
            self.steps.accept(MainSteps.loginIsComplete)
            return .empty()
        }
    }
    
    struct Input {
        let actionTrigger: Observable<LoginActionType>
    }
    
    struct Output {
    }
    
    func transform(req: Input) -> Output {
        req.actionTrigger.bind(to: buttonAction.inputs).disposed(by: disposeBag)
        return Output()
    }
    
}
