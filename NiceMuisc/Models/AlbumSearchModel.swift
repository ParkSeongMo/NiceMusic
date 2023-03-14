//
//  AlbumSearchModel.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/13.
//

import Foundation

struct AlbumSearchModel: Codable {
    let results:AlbumSearch?
}

struct AlbumSearch: Codable {
    let albummatches:AlbumMatche?
}

struct AlbumMatche: Codable {
    let album:[AlbumDetail]?
}
