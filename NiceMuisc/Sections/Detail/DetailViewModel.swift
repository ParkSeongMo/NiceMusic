//
//  DetailViewModel.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/17.
//

import Action
import RxFlow
import RxRelay
import RxSwift

enum DetailActionType {
    case none
    case execute
}

enum DetailType {
    case none
    case artist
    case album
    case track
}

final class DetailViewModel: ViewModelType, Stepper {
      
     // MARK: - Stepper
    var steps = RxRelay.PublishRelay<RxFlow.Step>()
    
    // MARK: - Output properties
    private let resDataRelay = BehaviorRelay<DetailModel>(value: DetailModel())
    private let changerRelay = BehaviorRelay<LoadChangeAction>(value: .none)
    
    private lazy var requestArtistDataAction = Action<String, ArtistDetailModel> { [weak self] artist in
        guard let `self` = self else { return Observable.empty() }
        return ServiceApi.Artist.detail(artist: artist).asObservable()
    }
    
    private lazy var requestAlbumDataAction = Action<(String, String), AlbumDetailModel> { [weak self] artist, album in
        guard let `self` = self else { return Observable.empty() }
        return ServiceApi.Album.detail(artist: artist, album: album).asObservable()
    }
    
    private lazy var requestTrackDataAction = Action<(String, String), TrackDetailModel> { [weak self] artist, track in
        guard let `self` = self else { return Observable.empty() }
        return ServiceApi.Track.detail(artist: artist, track: track).asObservable()
    }
       
    private lazy var buttonAction = Action<DetailActionType, Void> { [weak self] action in
        guard let `self` = self else { return .empty() }
        
        switch action {
        case .none:
            return .empty()
        case .execute:
            self.requestDetailApi(type: self.detailType, artist: self.artist, name: self.name)
            return .empty()
        }
    }
    
    struct Input {
        let actionTrigger: Observable<DetailActionType>
    }
    
    struct Output {
        let response: Observable<DetailModel>
        let loadChanger: Observable<LoadChangeAction>
    }      
        
    private let disposeBag = DisposeBag()
    private let detailType: DetailType
    private let artist: String
    private let name: String
    
    init(detailType: DetailType, artist: String?, name: String?) {
        self.detailType = detailType
        if let artist = artist {
            self.artist = artist
        } else {
            self.artist = ""
        }
        if let name = name {
            self.name = name
        } else {
            self.name = ""
        }
    }
    
    func transform(req: Input) -> Output {
        
        req.actionTrigger.bind(to: buttonAction.inputs).disposed(by: disposeBag)
                
        subscribeServerRequestionAction(action: requestArtistDataAction)
        subscribeServerRequestionAction(action: requestAlbumDataAction)
        subscribeServerRequestionAction(action: requestTrackDataAction)
        
        return Output(response: resDataRelay.asObservable(), loadChanger: changerRelay.asObservable())
    }
    
    private func requestDetailApi(type: DetailType, artist: String, name: String) {
        changerRelay.accept(.loaderStart)
        
        switch type {
        case .artist:
            requestArtistDataAction.execute(artist)
        case .album:
            requestAlbumDataAction.execute((artist, name))
        case .track:
            requestTrackDataAction.execute((artist, name))
        case .none:
            return
        }
    }
    
    private func subscribeServerRequestionAction<T, E>(action: Action<T, E>) {
        
        action.elements
            .subscribe(onNext: { [weak self] element in
                guard let `self` = self else { return }
                
                self.changerRelay.accept(.loaderStop)
                
                switch element {
                case let data as ArtistDetailModel:
                    self.resDataRelay.accept(DetailModel(data: data))
                case let data as AlbumDetailModel:
                    self.resDataRelay.accept(DetailModel(data: data))
                case let data as TrackDetailModel:
                    self.resDataRelay.accept(DetailModel(data: data))
                default:
                    return
                }
            }, onError: { code in
                Log.d("RequestHomeData Error: \(code)")
                self.changerRelay.accept(.loaderStop)
                // TODO 에러 처리 필요
            })
            .disposed(by: disposeBag)
    }
}
