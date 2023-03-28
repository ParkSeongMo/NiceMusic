//
//  KeywordModel.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/27.
//

import Foundation

struct RecentSearchWord: Codable {
    let keyword: String
    let date: Date
    
    init(keyword: String, date: Date) {
        self.keyword = keyword
        self.date = date
    }
}
