//
//  Date+.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/27.
//

import Foundation

extension TimeZone {
    static let korea = TimeZone(identifier: "Asia/Seoul")!
}

extension Locale {
    static let korea = Locale(identifier: "ko_KR")
}

private let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeZone = NSTimeZone.system
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.calendar = Calendar(identifier: .gregorian)
    return formatter
}()

extension Date {
    
    func kewordDate() -> String {
        formatter.dateFormat = "MM-dd HH:mm"
        return formatter.string(from: self)
    }
}
