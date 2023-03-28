//
//  RecentlySearchManager.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/27.
//

import RxSwift

class RecentlySearchManager {
    
    static let shared = RecentlySearchManager()
    
    private let recentlySearchWordKey = "recently_search_word"
    private let MAX_COUNT = 10
       
    func getRecentSearchData() -> [RecentSearchWord] {
        var res = [RecentSearchWord]()
        let decoder = JSONDecoder()
        let datas = getOrgRecentSearchData()
        datas.forEach { data in
            if let decodedData = try? decoder.decode(RecentSearchWord.self, from: data) {
                res.append(decodedData)
            }
        }
        
        return res
    }
    
    func getOrgRecentSearchData() -> [Data] {
        return UserDefaults.standard.array(forKey: recentlySearchWordKey) as? [Data]  ?? []
    }
    
        
    func setRecentSearchData(_ data: RecentSearchWord) {
        
        var savedOrgData = getOrgRecentSearchData()
        savedOrgData = removeSameSearchData(wordData: data, savedData: savedOrgData)
                
                
        let encoder: JSONEncoder = JSONEncoder()
        if let encodedData = try? encoder.encode(data) {
            if savedOrgData.count >= MAX_COUNT {
                savedOrgData.removeLast()
            }
            savedOrgData.insert(encodedData, at: savedOrgData.startIndex)
        }
        
        UserDefaults.standard.set(savedOrgData, forKey: recentlySearchWordKey)
        Log.d("\(getRecentSearchData())")
    }
    
    private func removeSameSearchData(wordData: RecentSearchWord, savedData: [Data]) -> [Data] {
        
        var savedData = savedData
        let decoder = JSONDecoder()
        
        for index in 0...savedData.count-1 {
            if let decodedData = try? decoder.decode(RecentSearchWord.self, from: savedData[index]) {
                if wordData.keyword == decodedData.keyword {
                    savedData.remove(at: index)
                    break
                }
            }
        }
        
        return savedData
    }
}
