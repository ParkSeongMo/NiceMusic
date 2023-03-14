//
//  TrackDetailModel.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/13.
//

import Foundation

struct TrackDetailModel: Codable {
    let track: TrackDetail?
}

struct TrackDetail: Codable {
    let name: String?
    let artist: ArtistDetail?
    let duration: String?
    let playcount: String?
    let toptags: Tags?
    let wiki: Desciption?
    
    static func makeNilModel(name: String? = nil,
                             artist: ArtistDetail? = nil,
                             duration: String? = nil,
                             playcount: String? = nil,
                             toptags: Tags? = nil,
                             wiki: Desciption? = nil) -> Self {
        return TrackDetail(name: name,
                           artist: artist,
                           duration: duration,
                           playcount: playcount,
                           toptags: toptags,
                           wiki: wiki)
    }
}


