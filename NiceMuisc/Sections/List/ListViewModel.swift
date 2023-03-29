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

final class ListViewModel: BaseListViewModelType, ViewModelType, Stepper {
            
    // MARK: - Output properties
    private let resDataRelay = BehaviorRelay<[CommonCardModel]>(value: [CommonCardModel()])
    private let loaderRelay = BehaviorRelay<LoadChangeAction>(value: .none)
    private let alertRelay = PublishRelay<AlertAction>()
    
    private var resData: [CommonCardModel] = []
    private let defaultPageNum = 1
    private let limit = 20
    private var page = 1
    private var isLoading = false
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
                
    private lazy var buttonAction = Action<ListActionType, Void> { [weak self] action in
        guard let `self` = self else { return .empty() }
        
        switch action {
        case .execute, .refresh:
            if self.isLoading {
                return .empty()
            }
            self.page = self.defaultPageNum
            self.resData.removeAll()
            self.requestListApi()
        case .more:
            if self.isLoading {
                return .empty()
            }
            self.page += 1
            self.requestListApi()
        case .tapItemForDetail(let title, let subTitle):
            self.detailIsRequired(title: title, subTitle: subTitle)
        default:
            return .empty()
        }
        
        return .empty()
    }

    init(index: HomeIndex) {
        self.index = index
    }
    
    private func requestListApi() {
        self.loaderRelay.accept(.loaderStart)
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
        
        subscribeServerRequestionAction()
        
        subscribeAlert()
        
        return Output(response: resDataRelay.asObservable(), loadChanger: loaderRelay.asObservable())
    }
    
    private func subscribeServerRequestionAction() {
        switch index {
        case .topArtist:
            subscribeServerRequestionAction(action: requestTopArtistDataAction)
        case .topTrack:
            subscribeServerRequestionAction(action: requestTopTrackDataAction)
        case .topLocalArtist:
            subscribeServerRequestionAction(action: requestTopLocalArtistDataAction)
        case .topLocalTrack:
            subscribeServerRequestionAction(action: requestTopLocalTrackDataAction)
        default:
            return            
        }
    }
    
    private func subscribeServerRequestionAction<T>(action:Action<Void, T>) {
        
        action.executing.bind { [weak self] element in
            guard let `self` = self else { return }
            self.isLoading = element
        }
        .disposed(by: disposeBag)
        
        action.errors.subscribe { code in
            self.loaderRelay.accept(.loaderStop)
            self.showApiErrorAlert()
        }
        .disposed(by: disposeBag)
        
        action.elements
            .subscribe(onNext: { [weak self] element in
                guard let `self` = self else { return }
                switch element {
                case let data as ArtistTopModel:
                    self.resData.append(contentsOf: self.makeLimitedData(array: data.artists?.artist))
                case let data as TrackTopModel:
                    self.resData.append(contentsOf: self.makeLimitedData(array: data.tracks?.track))
                case let data as ArtistLocalTopModel:
                    self.resData.append(contentsOf: self.makeLimitedData(array: data.topartists?.artist))
                case let data as TrackLocalTopModel:
                    self.resData.append(contentsOf: self.makeLimitedData(array: data.tracks?.track))
                default:
                    return
                }
                self.resDataRelay.accept(self.resData)
                self.loaderRelay.accept(.loaderStop)
            })
            .disposed(by: disposeBag)
    }
    
    private func makeLimitedData<T>(array: [T]?) -> [CommonCardModel] {
        
        var responseData:[CommonCardModel] = []
        
        guard let array = array else { return responseData }
        
        for item in array {
            responseData.append(CommonCardModel(data: item))
        }
                
        return responseData
    }
    
    func detailIsRequired(title: String?, subTitle: String?) {
        super.parsingTitleToArtist(type: index.detailType, title: title, subTitle: subTitle, task: MainSteps.detailIsRequired)
    }
    
    private func subscribeAlert() {
        alertRelay.subscribe { [weak self] action in
            guard let `self` = self else { return }
            switch action {
            case .okBtnTap:
                self.requestListApi()
            case .cancelBtnTap:
                // TODO 이전화면으로 되돌아가기
                return
            }
        }
        .disposed(by: disposeBag)
    }
    
    private func showApiErrorAlert() {
        AlertDialogManager.shared.showApiErrorAndRetryAlertDialog(observable: alertRelay)
    }
}
