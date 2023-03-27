//
//  ServiceApi.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/13.
//

import Foundation
import RxSwift

struct ServiceApi {
    struct Artist {}
    struct Track {}
    struct Album {}
}

extension ServiceApi.Artist {
    
    static func detail(artist: String) -> Single<ArtistDetailModel> {
        return ServiceApiClient.request(.artistDetail(artist: artist))
    }
    
    static func search(artist: String, page: Int, limit: Int) -> Single<ArtistSearchModel> {
        return ServiceApiClient.request(.artistSearch(artist: artist, page: page, limit: limit))
    }
    
    static func top(page: Int=1, limit: Int=10) -> Single<ArtistTopModel> {
        return ServiceApiClient.request(.topArtistList(page: page, limit: limit))
    }
        
    static func topLocal(page: Int=1, limit: Int=10) -> Single<ArtistLocalTopModel> {
        return ServiceApiClient.request(.topArtistListInLocal(page: page, limit: limit, country: "Korea, Republic of"))
    }
}

extension ServiceApi.Track {
    
    static func detail(artist: String, track: String) -> Single<TrackDetailModel> {
        return ServiceApiClient.request(.trackDetail(artist: artist, track: track))
    }
    
    static func search(track: String, page: Int, limit: Int) -> Single<TrackSearchModel> {
        return ServiceApiClient.request(.trackSearch(track: track, page: page, limit: limit))
    }
    
    static func top(page: Int=1, limit: Int=10) -> Single<TrackTopModel> {
        return ServiceApiClient.request(.topTrackList(page: page, limit: limit))
    }
    
    static func topLocal(page: Int=1, limit: Int=10) -> Single<TrackLocalTopModel> {
        return ServiceApiClient.request(.topTrackListInLocal(page: page, limit: limit, country: "Korea, Republic of"))
    }
}

extension ServiceApi.Album {
    
    static func detail(artist: String, album: String) -> Single<AlbumDetailModel> {
        return ServiceApiClient.request(.albumDetail(artist: artist, album: album))
    }
    
    static func search(album: String, page: Int, limit: Int) -> Single<AlbumSearchModel> {
        return ServiceApiClient.request(.albumSearch(album: album, page: page, limit: limit))
    }
}
