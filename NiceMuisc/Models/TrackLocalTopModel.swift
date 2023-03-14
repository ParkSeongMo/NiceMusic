//
//  TrackLocalTopModel.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/14.
//

import Foundation

struct TrackLocalTopModel: Codable {
    let tracks:TrackList?
    
    static func makeNilModel(tracks: TrackList? = nil) -> Self {
        return TrackLocalTopModel(tracks: tracks)
    }
}
