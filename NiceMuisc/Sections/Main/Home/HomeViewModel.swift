//
//  HomeViewModel.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/02.
//

import Action
import RxFlow
import RxRelay
import RxSwift

enum HomeActionType {
    // MARK: - Setting Part
    case none     // None Or Error
    case execute  // 홈조회API Execute
    case refresh  // 홈화면 갱신
    case tapAllforList(HomeIndex)     // 전체 보기
    case tapItemForDetail(DetailType, String?, String?)   // 상세 보기
}

class HomeViewModel: ViewModelType, Stepper {
    
    // MARK: - Stepper
    var steps = RxRelay.PublishRelay<RxFlow.Step>()
    
    // MARK: - ViewModelType, Protocal
    typealias ViewModel = HomeViewModel
    private let disposeBag = DisposeBag()
    
    private var homeData: [HomeCardModel] = []
    
    // MARK: - Output properties
    private let homeDataRelay = BehaviorRelay<[HomeCardModel]>(value: [HomeCardModel()])
    private let changerRelay = BehaviorRelay<LoadChangeAction>(value: .none)
    
    private lazy var requestTopTrackDataAction = Action<Void, TrackTopModel> { [weak self] in
        guard let `self` = self else { return Observable.empty() }
        return ServiceApi.Track.top().asObservable()
    }
    
    private lazy var requestTopLocalTrackDataAction = Action<Void, TrackLocalTopModel> { [weak self] in
        guard let `self` = self else { return Observable.empty() }
        return ServiceApi.Track.topLocal().asObservable()
    }
    
    private lazy var requestTopArtistDataAction = Action<Void, ArtistTopModel> { [weak self] in
        guard let `self` = self else { return Observable.empty() }
        return ServiceApi.Artist.top().asObservable()
    }
    
    private lazy var requestTopLocalArtistDataAction = Action<Void, ArtistLocalTopModel> { [weak self] in
        guard let `self` = self else { return Observable.empty() }
        return ServiceApi.Artist.topLocal().asObservable()
    }
    
    private lazy var buttonAction = Action<HomeActionType, Void> { [weak self] action in
        guard let `self` = self else { return .empty() }
        
        Log.d("buttonAction:\(action)")
        switch action {
        case .none:
            return .empty()
        case .execute, .refresh:
            self.requestMainApi()
        case .tapAllforList(let index):
            self.steps.accept(MainSteps.listIsRequired(index: index))
        case .tapItemForDetail(let type, let artist, let name):
            self.steps.accept(MainSteps.detailIsRequired(type: type, artist: artist, name: name))
        }
        
        return .empty()
    }
    
    struct Input {
        let actionTrigger: Observable<HomeActionType>
    }
    
    struct Output {
        let response: Observable<[HomeCardModel]>
        let loadChanger: Observable<LoadChangeAction>
    }
    
    func transform(req: Input) -> Output {
                
        req.actionTrigger.bind(to: buttonAction.inputs).disposed(by: disposeBag)
                                
        subscribeServerRequestionAction()
        
        return Output(response: homeDataRelay.asObservable(), loadChanger: changerRelay.asObservable())
    }
    
    private func requestMainApi() {
        self.changerRelay.accept(.loaderStart)
        
        self.homeData.removeAll()
        self.requestTopTrackDataAction.execute()
        self.requestTopLocalTrackDataAction.execute()
        self.requestTopArtistDataAction.execute()
        self.requestTopLocalArtistDataAction.execute()
    }
    
    private func subscribeServerRequestionAction() {
                       
        let observable = Observable.zip(
            requestTopArtistDataAction.elements,
            requestTopTrackDataAction.elements,
            requestTopLocalArtistDataAction.elements,
            requestTopLocalTrackDataAction.elements)
            .subscribe {  [weak self] (topArtist, topTrack, topLocalArtist, topLocalTrack) in
                guard let `self` = self else { return }
                self.appendHomeData(index: HomeIndex.topArtist, array: topArtist.artists?.artist)
                self.appendHomeData(index: HomeIndex.topTrack, array: topTrack.tracks?.track)
                self.appendHomeData(index: HomeIndex.topLocalArtist, array: topLocalArtist.topartists?.artist)
                self.appendHomeData(index: HomeIndex.topLocalTrack, array: topLocalTrack.tracks?.track)
                self.homeData.sort { return $0.index.rawValue < $1.index.rawValue }
                self.homeDataRelay.accept(self.homeData)
                self.changerRelay.accept(.loaderStop)
            }
            
        observable.disposed(by: disposeBag)
    }
    
    private func appendHomeData<T>(index: HomeIndex, array: [T]?) {
        
        var cardModels:[CommonCardModel] = []
        
        guard let array = array else {
            self.homeData.append(HomeCardModel(index: index, items: []))
            return
        }
                
        array.forEach { item in
            cardModels.append(CommonCardModel(data: item))
        }
        
        self.homeData.append(HomeCardModel(index: index, items: cardModels))
    }
}
