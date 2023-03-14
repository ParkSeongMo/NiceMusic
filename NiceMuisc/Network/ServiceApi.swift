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
    
    static func search(artist: String) -> Single<ArtistSearchModel> {
        return ServiceApiClient.request(.artistSearch(artist: artist))
    }
    
    static func top() -> Single<ArtistTopModel> {
        return ServiceApiClient.request(.topArtistList)
    }
        
    static func topLocal() -> Single<ArtistLocalTopModel> {
        return ServiceApiClient.request(.topArtistListInLocal(country: "Korea, Republic of"))
    }
}

extension ServiceApi.Track {
    
    static func detail(artist: String, track: String) -> Single<TrackDetailModel> {
        return ServiceApiClient.request(.trackDetail(artist: artist, track: track))
    }
    
    static func search(track: String) -> Single<TrackSearchModel> {
        return ServiceApiClient.request(.trackSearch(track: track))
    }
    
    static func top() -> Single<TrackTopModel> {
        return ServiceApiClient.request(.topTrackList)
    }
    
    static func topLocal() -> Single<TrackLocalTopModel> {
        return ServiceApiClient.request(.topTrackListInLocal(country: "Korea, Republic of"))
    }
}

extension ServiceApi.Album {
    
    static func detail(artist: String, album: String) -> Single<AlbumDetailModel> {
        return ServiceApiClient.request(.albumDetail(artist: artist, album: album))
    }
    
    static func search(album: String) -> Single<AlbumSearchModel> {
        return ServiceApiClient.request(.albumSearch(album: album))
    }
}
