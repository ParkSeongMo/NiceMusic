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
    case tapList(HomeIndex)     // 전체 보기
    case tapDetail(HomeIndex)   // 상세 보기
}

class HomeViewModel: ViewModelType, Stepper {
    
    private let maxHomeItemCount = 10
    
    // MARK: - Stepper
    var steps = RxRelay.PublishRelay<RxFlow.Step>()
    
    // MARK: - ViewModelType, Protocal
    typealias ViewModel = HomeViewModel
    private let disposeBag = DisposeBag()
    
    private var homeData: [HomeCardModel] = []
    
    // MARK: - Output properties
    private let homeDataRelay = BehaviorRelay<[HomeCardModel]>(value: [HomeCardModel()])
    
    lazy var requestTopTrackDataAction = Action<Void, TrackTopModel> { [weak self] in
        guard let `self` = self else { return Observable.empty() }
        return ServiceApi.Track.top().asObservable()
    }
    
    lazy var requestTopLocalTrackDataAction = Action<Void, TrackLocalTopModel> { [weak self] in
        guard let `self` = self else { return Observable.empty() }
        return ServiceApi.Track.topLocal().asObservable()
    }
    
    lazy var requestTopArtistDataAction = Action<Void, ArtistTopModel> { [weak self] in
        guard let `self` = self else { return Observable.empty() }
        return ServiceApi.Artist.top().asObservable()
    }
    
    lazy var requestTopLocalArtistDataAction = Action<Void, ArtistLocalTopModel> { [weak self] in
        guard let `self` = self else { return Observable.empty() }
        return ServiceApi.Artist.topLocal().asObservable()
    }
    
    lazy var buttonAction = Action<HomeActionType, Void> { [weak self] in
        guard let `self` = self else { return .empty() }
        
        switch $0 {
        case .none:
            return .empty()
        case .execute:
            self.homeData.removeAll()
            self.requestTopTrackDataAction.execute()
            self.requestTopLocalTrackDataAction.execute()
            self.requestTopArtistDataAction.execute()
            self.requestTopLocalArtistDataAction.execute()
        case .refresh:
            return .empty()
        case .tapList(let index):
            Log.d("tap list index:\(index)")
            // TODO Go to List
        case .tapDetail(let index):
            Log.d("tap list index:\(index)")
            // TODO Go to Detail
        }
        
        return .empty()
    }
    
    struct Input {
        let actionTrigger: Observable<HomeActionType>
    }
    
    struct Output {
        let response: Observable<[HomeCardModel]>
    }
    
    func transform(req: Input) -> Output {
        
        req.actionTrigger.bind(to: buttonAction.inputs).disposed(by: disposeBag)
                
        subscribeServerRequestionAction(action: requestTopTrackDataAction)
        subscribeServerRequestionAction(action: requestTopLocalTrackDataAction)
        subscribeServerRequestionAction(action: requestTopArtistDataAction)
        subscribeServerRequestionAction(action: requestTopLocalArtistDataAction)
                
        return Output(response: homeDataRelay.asObservable())
    }
    
    private func subscribeServerRequestionAction<T>(action:Action<Void, T>) {
        
        action.elements
            .subscribe(onNext: { [weak self] element in
                guard let `self` = self else { return }
                                
                switch element {
                case let data as ArtistTopModel:
                    self.homeData.append(HomeCardModel(index: HomeIndex.topArtist, items: self.makeLimitedHomeData(array: data.artists?.artist)))
                case let data as TrackTopModel:
                    self.homeData.append(HomeCardModel(index: HomeIndex.topTrack, items: self.makeLimitedHomeData(array: data.tracks?.track)))
                case let data as ArtistLocalTopModel:
                    self.homeData.append(HomeCardModel(index: HomeIndex.topLocalArtist, items: self.makeLimitedHomeData(array: data.topartists?.artist)))
                case let data as TrackLocalTopModel:
                    self.homeData.append(HomeCardModel(index: HomeIndex.topLocalTrack, items: self.makeLimitedHomeData(array: data.tracks?.track)))
                default:
                    return
                }
    
                if self.homeData.count >= 4 {
                    self.homeData.sort { return $0.index.rawValue < $1.index.rawValue }
                    self.homeDataRelay.accept(self.homeData)
                }
            }, onError: { code in
                Log.d("RequestHomeData Error: \(code)")
                // TODO 에러 처리 필요
            }).disposed(by: disposeBag)
    }
       
    private func makeLimitedHomeData<T>(array: [T]?) -> [CommonCardModel] {
        
        var responseData:[CommonCardModel] = []
        
        guard let array = array else { return responseData }
        
        for item in array {
            responseData.append(CommonCardModel(data: item))
            if responseData.count >= maxHomeItemCount {
                break
            }
        }
                
        return responseData
    }    
}
