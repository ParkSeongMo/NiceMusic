//
//  HomeView.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/02.
//

import UIKit
import RxRelay
import RxSwift


enum HomeIndex {
    case none
    case topArtist
    case topTrack
    case topLocalArtist
    case topLocalTrack
}

final class HomeView: UIView, SubViewDI {
    
    typealias Model = HomeViewModel
    
    private let disposeBag = DisposeBag()
    
    var inputRelay = PublishRelay<Any>()
    var outputRelay = PublishRelay<Any>()
    
    var subViews: [DescendantView] = [] {
        willSet {
            newValue.forEach {
                $0.delegate = self
            }
            applySubviewTags()
        }
    }
    
    
    func applySubviewTags() {
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout() 
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        backgroundColor = .yellow
    }
    
    
    @discardableResult
    func setupDI<T>(generic: PublishRelay<T>) -> Self {
        
        if let generic = generic as? PublishRelay<HomeActionType> {
            inputRelay.compactMap { $0 as? HomeActionType }
                .bind(to: generic)
                .disposed(by: disposeBag)
        }
        
        return self
    }
    
    
    @discardableResult
    func setupDI<T>(observable: Observable<T>) -> Self {
        
        observable.subscribe(onNext: { [weak self] element in      
            guard let `self` = self else { return }
            let name = self.paringName(data: element)
            let someData = element as? (HomeIndex, [Any])
            print("response index: \(String(describing: someData?.0)), count: \(String(describing: someData?.1.count)), name: \(String(describing: name))")
            
        }).disposed(by: disposeBag)
        
        return self
    }
    
    private func paringName<T>(data: T) -> String? {
        switch data {
        case let someData as (HomeIndex, [ArtistDetail]):
            return someData.1[0].name
        case let someData as (HomeIndex, [TrackDetail]):
            return someData.1[0].name
            
        default:
            return "none"
        }
    }
    
//    private func paringName<T>(data: T) -> String? {
//        switch data {
//        case let someData as (Int, ArtistDetailModel):
//            return someData.1.artist?.name
//        case let someData as (Int, ArtistSearchModel):
//            return someData.1.results?.artistmatches?.artist?[0].name
//        case let someData as (Int, ArtistTopModel):
//            return someData.1.artists?.artist?[0].name
//        case let someData as (Int, ArtistLocalTopModel):
//            return someData.1.topartists?.artist?[0].name
//        case let someData as (Int, AlbumDetailModel):
//            return someData.1.album?.name
//        case let someData as (Int, AlbumSearchModel):
//            return someData.1.results?.albummatches?.album?[0].name
//        case let someData as (Int, TrackDetailModel):
//            return someData.1.track?.name
//        case let someData as (Int, TrackSearchModel):
//            return someData.1.results?.trackmatches?.track?[0].name
//        case let someData as (Int, TrackTopModel):
//            return someData.1.tracks?.track?[0].name
//        case let someData as (Int, TrackLocalTopModel):
//            return someData.1.tracks?.track?[0].name
//
//        default:
//            return "none"
//        }
//    }
    
}
