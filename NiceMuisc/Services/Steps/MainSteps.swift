//
//  MainSteps.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/02.
//

import RxFlow

enum MainSteps: Step {
    case appStartIsRequired
    case mainTabBarIsRequired
    case homeIsRequired
    case searchIsRequired
    case listIsRequired(index: HomeIndex)
    case detailIsRequired(index: HomeIndex, title: String?, subTitle: String?)
}
