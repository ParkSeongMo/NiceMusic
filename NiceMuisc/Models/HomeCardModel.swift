//
//  HomeCardModel.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/15.
//

import Foundation


final class HomeCardModel {
    
    let index: HomeIndex
    let items: [CommonCardModel]
    
    init() {
        self.index = .none
        self.items = []
    }
    
    init(index: HomeIndex, items: [CommonCardModel]) {
        self.index = index
        self.items = items
    }
}
