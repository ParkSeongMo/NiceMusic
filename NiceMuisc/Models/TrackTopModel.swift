//
//  Track\TopListModel.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/13.
//

import Foundation

struct TrackTopModel: Codable {
    let tracks:TrackList?
    
    static func makeNilModel(tracks: TrackList? = nil) -> Self {
        return TrackTopModel(tracks: tracks)
    }
}

struct TrackList: Codable {
    let track:[TrackDetail]?
}
