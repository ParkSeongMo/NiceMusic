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
    let listeners: String?
    let toptags: Tags?
    let wiki: Desciption?
    let image:[Image]?
    let album:AlbumDetail?    
}


