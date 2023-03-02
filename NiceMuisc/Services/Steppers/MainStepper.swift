//
//  MainStepper.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/02.
//

import RxFlow
import RxRelay

final class MainStepper: Stepper {
    
    var steps = PublishRelay<Step>()
    
    var initialStep: Step {
        return MainSteps.mainTabBarIsRequired
    }
}

