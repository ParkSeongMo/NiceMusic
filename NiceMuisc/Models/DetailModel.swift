//
//  DetailModel.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/17.
//

import Foundation


struct DetailModel {
    
    let detailType: DetailType?
    
    let image:String?
    let artistName:String?
    let name:String?    // track, album
    let tags:Tags?
    var tracks:[AlbumTrackDetail]?
    let desc: Desciption?
    
    let duration: String?
    let playcount: String?
    let listeners: String?
    
    init() {
        self.detailType = DetailType.none
        self.image = ""
        self.artistName = ""
        self.name = ""
        self.tags = Tags()
        self.tracks = []
        self.desc = Desciption()
        self.duration = ""
        self.playcount = ""
        self.listeners = ""
    }
    
    init(detailType: DetailType, data:Any) {
        self.detailType = detailType
        
        switch data {
        case let someData as ArtistDetailModel:
            self.image = "https://lastfm.freetls.fastly.net/i/u/174s/bfb84f4aa2ac69a5ffa98c0406b8bf10.png"//someData.image?[4].text
            self.name = nil
            self.artistName = someData.artist?.name
            self.tags = someData.artist?.tags
            self.tracks = []
            self.desc = someData.artist?.bio
            self.duration = nil
            self.playcount = nil
            self.listeners = nil
        case let someData as TrackDetailModel:
            self.image = "https://lastfm.freetls.fastly.net/i/u/174s/bfb84f4aa2ac69a5ffa98c0406b8bf10.png"//someData.image?[4].text
            self.name = someData.track?.name
            self.artistName = someData.track?.artist?.name
            self.tags = someData.track?.toptags
            self.tracks = []
            self.desc = someData.track?.wiki
            self.duration = someData.track?.duration
            self.playcount = someData.track?.playcount
            self.listeners = someData.track?.listeners
        case let someData as AlbumDetailModel:
            self.image = "https://lastfm.freetls.fastly.net/i/u/174s/bfb84f4aa2ac69a5ffa98c0406b8bf10.png"//someData.image?[4].text
            self.name = someData.album?.name
            self.artistName = someData.album?.artist
            self.tags = someData.album?.tags
            self.desc = someData.album?.wiki
            self.duration = nil
            self.playcount = someData.album?.playcount
            self.listeners = someData.album?.listeners
            
            var tracks:[AlbumTrackDetail] = []
            for item in someData.album?.tracks?.track ?? [] {
                var newItem = item
                newItem.image = "https://lastfm.freetls.fastly.net/i/u/174s/bfb84f4aa2ac69a5ffa98c0406b8bf10.png"//someData.image?[4].text
                tracks.append(newItem)
            }
            
            self.tracks = tracks
        default:
            self.image = nil
            self.artistName = nil
            self.name = nil
            self.tags = Tags()
            self.tracks = []
            self.desc = Desciption()
            self.duration = nil
            self.playcount = nil
            self.listeners = nil
        }
    }    
}
