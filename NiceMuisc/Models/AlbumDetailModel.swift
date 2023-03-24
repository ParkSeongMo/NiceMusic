//
//  AlbumDetailModel.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/13.
//

import Foundation

struct AlbumDetailModel: Codable {
    let album:AlbumDetail?
}

struct AlbumDetail: Codable {
    let name:String?
    let artist:String?
    let image:[Image]?
//    let tags:Tags?
    let wiki:Desciption?
    let tracks:AlbumTrack?
    let playcount: String?
    let listeners: String?
}

struct AlbumTrack: Codable {
    let track:[AlbumTrackDetail]?
}

struct AlbumTrackDetail: Codable {
    let name:String?
    let artist:AlbumArtist?
    let duration:Int?
    var image:String?
}

struct AlbumArtist: Codable {
    let name:String?
}
