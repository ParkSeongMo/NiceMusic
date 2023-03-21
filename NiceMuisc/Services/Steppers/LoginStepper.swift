//
//  LoginStepper.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/21.
//

import RxFlow
import RxRelay

final class LoginStepper: Stepper {
    
    static let shared = LoginStepper()
    
    var steps = PublishRelay<Step>()
    
    var initialStep: Step {
        return MainSteps.loginIsRequired
    }
}
