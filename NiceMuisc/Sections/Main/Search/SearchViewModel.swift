//
//  SearchViewModel.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/02.
//

import Action
import RxFlow
import RxRelay
import RxSwift

enum SearchActionType {
    case none
    case execute(String)
    case more(String)
    case tapItemForDetail(DetailType, String?, String?)
}

class SearchViewModel: ViewModelType, Stepper {
    
    // MARK: - Stepper
    var steps = RxRelay.PublishRelay<RxFlow.Step>()
    
    // MARK: - ViewModelType, Protocal
    typealias ViewModel = HomeViewModel
    private let disposeBag = DisposeBag()
    
    private let resDataRelay = BehaviorRelay<(DetailType, [CommonCardModel])>(value:(.none, [CommonCardModel]()))
    private let LoaderRelay = BehaviorRelay<LoadChangeAction>(value: .none)
    
    private lazy var requestArtistDataAction = Action<String, ArtistSearchModel> { [weak self] artist in
        guard let `self` = self else { return Observable.empty()}
        return ServiceApi.Artist.search(artist: artist).asObservable()
    }
    
    private lazy var requestTrackDataAction = Action<String, TrackSearchModel> { [weak self] track in
        guard let `self` = self else { return Observable.empty() }
        return ServiceApi.Track.search(track: track).asObservable()
    }
    
    private lazy var requestAblumDataAction = Action<String, AlbumSearchModel> { [weak self] album in
        guard let `self` = self else { return Observable.empty() }
        return ServiceApi.Album.search(album: album).asObservable()
    }
    
    private lazy var action = Action<SearchActionType, Void> { [weak self] action in
        guard let `self` = self else { return .empty() }
        Log.d("action \(action)")
        switch action {
        case .execute(let keyword):
            self.resData[DetailType.artist.searchIndex] = [CommonCardModel]()
            self.resData[DetailType.track.searchIndex] = [CommonCardModel]()
            self.resData[DetailType.album.searchIndex] = [CommonCardModel]()
            self.requestSearchApi(keyword: keyword)
        default:
            return .empty()
        }
        
        return .empty()
    }
    
    struct Input {
        let actionTrigger: Observable<SearchActionType>
    }
    
    struct Output {
        let response: Observable<(DetailType, [CommonCardModel])>
        let loadChanger: Observable<LoadChangeAction>
    }
    
    func transform(req: Input) -> Output {
        
        req.actionTrigger.bind(to: action.inputs).disposed(by: disposeBag)
        
        subscribeServerRequestionAction()
        
        return Output(response: resDataRelay.asObservable(), loadChanger: LoaderRelay.asObservable())
    }
    
    private func requestSearchApi(keyword: String) {
        
        self.requestArtistDataAction.execute(keyword)
        self.requestTrackDataAction.execute(keyword)
        self.requestAblumDataAction.execute(keyword)
    }
    
    private var resData: [Int:[CommonCardModel]] = [:]
    
    private func subscribeServerRequestionAction() {
        let observable = Observable.zip(
            requestArtistDataAction.elements,
            requestTrackDataAction.elements,
            requestAblumDataAction.elements)
            .subscribe { [weak self] (artist, track, album) in
                guard let `self` = self else { return }
                
                self.responseSearchData(type: .track, array: track.results?.trackmatches?.track)
                self.responseSearchData(type: .artist, array: artist.results?.artistmatches?.artist)
                self.responseSearchData(type: .album, array: album.results?.albummatches?.album)
            }
        
        observable.disposed(by: disposeBag)
    }
    
    private func responseSearchData<T>(type:DetailType, array: [T]?) {
        
        self.resData[type.searchIndex] = self.makeLimitedData(
            orgData: self.resData[type.searchIndex],
            array: array)
        
        self.resDataRelay.accept((type, self.resData[type.searchIndex] ?? [CommonCardModel]()))
    }
        
    private func makeLimitedData<T>(orgData:[CommonCardModel]?, array: [T]?) -> [CommonCardModel] {
        
        var orgData = orgData ?? [CommonCardModel]()
        
        guard let array = array else { return orgData }
        
        for item in array {
            orgData.append(CommonCardModel(data: item))
        }
                
        return orgData
    }
}

