//
//  Track\TopListModel.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/13.
//

import Foundation

struct TrackTopListModel: Codable {
    let tracks:TrackList?
}

struct TrackList: Codable {
    let track:[TrackDetail]?
}
