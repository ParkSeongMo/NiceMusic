//
//  ListViewModel.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/16.
//

import Action
import RxFlow
import RxRelay
import RxSwift


enum ListActionType {
    // MARK: - Setting Part
    case none        // None Or Error
    case execute     // 조회API Execute
    case refresh     // 화면 갱신
    case more        // 더가져오기
    case tapItemForDetail(String?, String?)   // 상세 보기
}

final class ListViewModel: ViewModelType, Stepper {
   
    // MARK: - Stepper
    var steps = RxRelay.PublishRelay<RxFlow.Step>()
            
    // MARK: - Output properties
    private let resDataRelay = BehaviorRelay<[CommonCardModel]>(value: [CommonCardModel()])
    private let changerRelay = BehaviorRelay<LoadChangeAction>(value: .none)
    
    private let disposeBag = DisposeBag()
    private let defaultPageNum = 1
    private var page = 1
    private let limit = 20
    private var responseData:[CommonCardModel] = []
    var index = HomeIndex.none
    
    private lazy var requestTopTrackDataAction = Action<Void, TrackTopModel> { [weak self] in
        guard let `self` = self else { return Observable.empty() }
        return ServiceApi.Track.top(page: self.page, limit: self.limit).asObservable()
    }
    
    private lazy var requestTopLocalTrackDataAction = Action<Void, TrackLocalTopModel> { [weak self] in
        guard let `self` = self else { return Observable.empty() }
        return ServiceApi.Track.topLocal(page: self.page, limit: self.limit).asObservable()
    }
    
    private lazy var requestTopArtistDataAction = Action<Void, ArtistTopModel> { [weak self] in
        guard let `self` = self else { return Observable.empty() }
        return ServiceApi.Artist.top(page: self.page, limit: self.limit).asObservable()
    }
    
    private lazy var requestTopLocalArtistDataAction = Action<Void, ArtistLocalTopModel> { [weak self] in
        guard let `self` = self else { return Observable.empty() }
        return ServiceApi.Artist.topLocal(page: self.page, limit: self.limit).asObservable()
    }
        
    lazy var buttonAction = Action<ListActionType, Void> { [weak self] action in
        guard let `self` = self else { return .empty() }
        switch action {
        case .none:
            return .empty()
        case .execute, .refresh:
            self.page = self.defaultPageNum
            self.responseData.removeAll()
            self.requestListApi()
        case .more:
            self.page += 1
            self.requestListApi()
        case .tapItemForDetail(let artist, let name):
            Log.d("tap list artist:\(String(describing: artist)), name:\(String(describing: name))")
        }
        
        return .empty()
    }
        
    init(index: HomeIndex) {
        self.index = index
    }
    
    private func requestListApi() {
        self.changerRelay.accept(.loaderStart)
        switch index {
        case .topArtist:
            self.requestTopArtistDataAction.execute()
        case .topTrack:
            self.requestTopTrackDataAction.execute()
        case .topLocalArtist:
            self.requestTopLocalArtistDataAction.execute()
        case .topLocalTrack:
            self.requestTopLocalTrackDataAction.execute()
        default:
            return
        }
    }
    
    struct Input {
        let actionTrigger: Observable<ListActionType>
    }
    
    struct Output {
        let response: Observable<[CommonCardModel]>
        let loadChanger: Observable<LoadChangeAction>
    }
    
    func transform(req: Input) -> Output {
        
        req.actionTrigger.bind(to: buttonAction.inputs).disposed(by: disposeBag)
               
        subscribeServerRequestionAction(action: requestTopTrackDataAction)
        subscribeServerRequestionAction(action: requestTopLocalTrackDataAction)
        subscribeServerRequestionAction(action: requestTopArtistDataAction)
        subscribeServerRequestionAction(action: requestTopLocalArtistDataAction)
        
        return Output(response: resDataRelay.asObservable(), loadChanger: changerRelay.asObservable())
    }
    
    private func subscribeServerRequestionAction<T>(action:Action<Void, T>) {
                
        action.elements
            .subscribe(onNext: { [weak self] element in
                guard let `self` = self else { return }
                switch element {
                case let data as ArtistTopModel:
                    self.responseData.append(contentsOf: self.makeLimitedHomeData(array: data.artists?.artist))
                case let data as TrackTopModel:
                    self.responseData.append(contentsOf: self.makeLimitedHomeData(array: data.tracks?.track))
                case let data as ArtistLocalTopModel:
                    self.responseData.append(contentsOf: self.makeLimitedHomeData(array: data.topartists?.artist))
                case let data as TrackLocalTopModel:
                    self.responseData.append(contentsOf: self.makeLimitedHomeData(array: data.tracks?.track))
                default:
                    return
                }
                self.resDataRelay.accept(self.responseData)
                self.changerRelay.accept(.loaderStop)
            }, onError: { code in
                Log.d("RequestHomeData Error: \(code)")
                // TODO 에러 처리 필요
                self.changerRelay.accept(.loaderStop)
            }).disposed(by: disposeBag)
    }
    
    private func makeLimitedHomeData<T>(array: [T]?) -> [CommonCardModel] {
        
        var responseData:[CommonCardModel] = []
        
        guard let array = array else { return responseData }
        
        for item in array {
            responseData.append(CommonCardModel(data: item))
        }
                
        return responseData
    }
}
