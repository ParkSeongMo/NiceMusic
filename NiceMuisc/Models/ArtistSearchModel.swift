//
//  ArtistSearhModel.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/13.
//

import Foundation

struct ArtistSearchModel: Codable {
    let results:ArtistSearch?
}

struct ArtistSearch: Codable {
    let artistmatches:ArtistMatche?
}

struct ArtistMatche: Codable {
    let artist:[ArtistDetail]?
}
