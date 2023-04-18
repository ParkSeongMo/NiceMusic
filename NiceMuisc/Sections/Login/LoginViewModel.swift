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
    case inputId(String)
    case inputPwd(String)
}

enum LoginValidType {
    case idValid
    case pwdValid
    case enableLoginBtn
}

final class LoginViewModel: ViewModelType, Stepper {
    
    var steps = RxRelay.PublishRelay<RxFlow.Step>()
    
    private let minPwdLength = 5
    private let disposeBag = DisposeBag()
    private let inputValidRelay = BehaviorRelay<(LoginValidType, Bool)>(value: (LoginValidType.enableLoginBtn, false))
    private var idValid = false
    private var pwdValid = false
    
    private lazy var buttonAction = Action<LoginActionType, Void> { [weak self] action in
        guard let `self` = self else { return .empty() }
        switch action {
        case .tapForHome:
            self.steps.accept(MainSteps.loginIsComplete)
            break
        case .inputId(let id):
            self.checkIdValidation(id: id)
            break
        case .inputPwd(let pwd):
            self.checkPwdValidation(pwd: pwd)
            break
        }
        
        return .empty()
    }
    
    struct Input {
        let actionTrigger: Observable<LoginActionType>
    }
    
    struct Output {
        let idValid: Observable<(LoginValidType, Bool)>
    }
    
    func transform(req: Input) -> Output {
        req.actionTrigger.bind(to: buttonAction.inputs).disposed(by: disposeBag)
        return Output(idValid: inputValidRelay.asObservable())
    }
    
    private func checkIdValidation(id: String) {
        idValid = id.count > 0 && id.contains("@")
        inputValidRelay.accept((LoginValidType.idValid, idValid))
        inputValidRelay.accept((LoginValidType.enableLoginBtn, idValid&&pwdValid))
    }
    
    private func checkPwdValidation(pwd: String) {
        pwdValid = pwd.count > minPwdLength
        inputValidRelay.accept((LoginValidType.pwdValid, pwdValid))
        inputValidRelay.accept((LoginValidType.enableLoginBtn, idValid&&pwdValid))
    }
}
