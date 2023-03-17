//
//  TrackSearchModel.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/13.
//

import Foundation

struct TrackSearchModel: Codable {
    let results:TrackSearch?
}

struct TrackSearch: Codable {
    let trackmatches:TrackMatche?
}

struct TrackMatche: Codable {
    let track:[Track]?
}

struct Track: Codable {
    let name:String?
    let artist:String?
    let duration:String?
    let image:[Image]?
}
