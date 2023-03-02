//
//  ViewModelType.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/02.
//

import Foundation

protocol ViewModel {
    
}

protocol ViewModelType: ViewModel {
    associatedtype Input
    associatedtype Output
    
    @discardableResult
    func transform(req: Input) -> Output
}
