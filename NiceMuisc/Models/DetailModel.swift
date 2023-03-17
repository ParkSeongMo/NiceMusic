//
//  DetailModel.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/17.
//

import Foundation


struct DetailModel {
    
    let image:String?
    let artistName:String?
    let name:String?    // track, album
    let tags:Tags?
    let tracks:[Track]?
    let desc: Desciption?
    
    let duration: String?
    let playcount: String?
    let listeners: String?
    
    init() {
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
    
    init(data:Any) {
        
        switch data {
        case let someData as ArtistDetail:
            self.image = "https://lastfm.freetls.fastly.net/i/u/174s/bfb84f4aa2ac69a5ffa98c0406b8bf10.png"//someData.image?[4].text
            self.name = ""
            self.artistName = someData.name
            self.tags = someData.tags
            self.tracks = []
            self.desc = someData.bio
            self.duration = ""
            self.playcount = ""
            self.listeners = ""
        case let someData as TrackDetail:
            self.image = "https://lastfm.freetls.fastly.net/i/u/174s/bfb84f4aa2ac69a5ffa98c0406b8bf10.png"//someData.image?[4].text
            self.name = someData.name
            self.artistName = someData.artist?.name
            self.tags = someData.toptags
            self.tracks = []
            self.desc = someData.wiki
            self.duration = someData.duration
            self.playcount = someData.playcount
            self.listeners = someData.listeners
        case let someData as AlbumDetail:
            self.image = "https://lastfm.freetls.fastly.net/i/u/174s/bfb84f4aa2ac69a5ffa98c0406b8bf10.png"//someData.image?[4].text
            self.name = someData.name
            self.artistName = someData.artist
            self.tags = someData.tags
            self.tracks = someData.tracks?.track
            self.desc = someData.wiki
            self.duration = ""
            self.playcount = ""
            self.listeners = ""
        default:
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
    }    
}
