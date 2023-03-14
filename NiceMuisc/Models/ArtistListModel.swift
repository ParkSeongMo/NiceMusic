//
//  ArtistListModel.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/13.
//

import Foundation

struct ArtistListModel: Codable {
    let artists:ArtistList?
}

struct ArtistList: Codable {
    let artist:[ArtistDetail]?
}
