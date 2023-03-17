//
//  ArtistModel.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/13.
//

import Foundation

struct ArtistDetailModel: Codable {
    let artist:ArtistDetail?
}

struct ArtistDetail: Codable {
    let name:String?
    let image:[Image]?
    let tags:Tags?
    let bio:Desciption?
}

struct Image: Codable {
    let text:String?
    let size:String?
}

struct Tags: Codable {
    let tag:[Tag]?
    
    init() {
        self.tag = []
    }
}

struct Tag: Codable {
    let name:String?
    let url:String?
}

struct Desciption: Codable {
    let summary:String?
    let content:String?
    
    init() {
        self.summary = ""
        self.content = ""
    }
}
