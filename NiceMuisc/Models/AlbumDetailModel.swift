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
    let tags:Tags?
    let wiki:Desciption?
    //음원 목록
}

