//
//  CommonCardModel.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/14.
//

import Foundation

final class CommonCardModel {
    
    let title:String?
    let subTitle:String?
    var image:[Image]?
    
    init() {
        self.title = ""
        self.subTitle = ""
        self.image = []
    }
    
    init(title: String?, subTitle: String?, image: [Image]?) {
        self.title = title
        self.subTitle = subTitle
        self.image = getDummyImage()
    }
    
    init(data:Any) {
        switch data {
        case let someData as ArtistDetail:
            title = someData.name
            subTitle = nil
//            image = someData.image
        case let someData as TrackDetail:
            title = someData.name
            subTitle = someData.artist?.name
//            image = someData.album?.image
        default:
            title = nil
            subTitle = nil
//            image = nil
        }
        image = getDummyImage()
    }
    
    private func getDummyImage() -> [Image] {
        return [Image(text: "https://lastfm.freetls.fastly.net/i/u/174s/bfb84f4aa2ac69a5ffa98c0406b8bf10.png", size: "large"),
                Image(text: "https://lastfm.freetls.fastly.net/i/u/174s/bfb84f4aa2ac69a5ffa98c0406b8bf10.png", size: "large"),
                Image(text: "https://lastfm.freetls.fastly.net/i/u/174s/bfb84f4aa2ac69a5ffa98c0406b8bf10.png", size: "large"),
                Image(text: "https://lastfm.freetls.fastly.net/i/u/174s/bfb84f4aa2ac69a5ffa98c0406b8bf10.png", size: "large"),
                Image(text: "https://lastfm.freetls.fastly.net/i/u/174s/bfb84f4aa2ac69a5ffa98c0406b8bf10.png", size: "large")]
    }
    
    static func makeNilModel(title: String? = nil,
                             subTitle: String? = nil,
                             image: [Image]? = nil) -> Self {
        return CommonCardModel(title: title,
                               subTitle: subTitle,
                               image: image) as! Self
    }
}
