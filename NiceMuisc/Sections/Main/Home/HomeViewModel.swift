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
    case tapAllForList(HomeIndex)     // 전체 보기
    case tapItemForDetail(DetailType, String?, String?)   // 상세 보기
}

class HomeViewModel: BaseListViewModelType, ViewModelType, Stepper {
    
    // MARK: - ViewModelType, Protocal
    typealias ViewModel = HomeViewModel
    
    var apiResData: [HomeCardModel] = []
    
    // MARK: - Output properties
    private let homeDataRelay = BehaviorRelay<[HomeCardModel]>(value: [HomeCardModel()])
    private let changerRelay = BehaviorRelay<LoadChangeAction>(value: .none)
    private let alertRelay = PublishRelay<AlertAction>()
    private var isFinishHomeApi = false
    
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
        switch action {
        case .execute, .refresh:
            self.requestMainApi()
        case .tapAllForList(let index):
            self.steps.accept(MainSteps.listIsRequired(index: index))
        case .tapItemForDetail(let type, let title, let subTitle):
            self.moveToDetail(detailType: type, title: title, subTitle: subTitle)
        default:
            return .empty()
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
        subscribeAlert()
        
        return Output(response: homeDataRelay.asObservable(), loadChanger: changerRelay.asObservable())
    }
    
    func moveToDetail(detailType: DetailType, title: String?, subTitle: String?) {
        super.moveToDetail(
            type: detailType,
            title: title,
            subTitle: subTitle,
            task: MainSteps.detailIsRequired)
    }

    private func requestMainApi() {
        isFinishHomeApi = false
        changerRelay.accept(.loaderStart)
        
        apiResData.removeAll()
        requestTopTrackDataAction.execute()
        requestTopLocalTrackDataAction.execute()
        requestTopArtistDataAction.execute()
        requestTopLocalArtistDataAction.execute()
    }
    
    private func subscribeServerRequestionAction() {
              
        Observable.of(
            requestTopArtistDataAction.errors,
            requestTopTrackDataAction.errors,
            requestTopLocalArtistDataAction.errors,
            requestTopLocalTrackDataAction.errors)
        .merge()
        .take(while: { [weak self] _ in
            guard let `self` = self else { return true }
            return !self.isFinishHomeApi
        })
        .bind { [weak self] code in
            guard let `self` = self else { return }
            self.isFinishHomeApi = true
            self.changerRelay.accept(.loaderStop)
            self.showApiErrorAlert()
        }
        .disposed(by: disposeBag)
                
        Observable.zip(
            requestTopArtistDataAction.elements,
            requestTopTrackDataAction.elements,
            requestTopLocalArtistDataAction.elements,
            requestTopLocalTrackDataAction.elements)
        .subscribe(onNext: { [weak self] (topArtist, topTrack, topLocalArtist, topLocalTrack) in
            guard let `self` = self else { return }
            self.isFinishHomeApi = true
            self.appendHomeData(index: HomeIndex.topArtist, array: topArtist.artists?.artist ?? [ArtistDetail]())
            self.appendHomeData(index: HomeIndex.topTrack, array: topTrack.tracks?.track ?? [TrackDetail]())
            self.appendHomeData(index: HomeIndex.topLocalArtist, array: topLocalArtist.topartists?.artist ?? [ArtistDetail]())
            self.appendHomeData(index: HomeIndex.topLocalTrack, array: topLocalTrack.tracks?.track ?? [TrackDetail]())
            self.apiResData.sort { return $0.index.rawValue < $1.index.rawValue }
            self.homeDataRelay.accept(self.apiResData)
            self.changerRelay.accept(.loaderStop)
        })
        .disposed(by: disposeBag)
    }
    
    private func appendHomeData<T>(index: HomeIndex, array: [T]) {
        self.apiResData.append(
            HomeCardModel(index: index, items: array.map(CommonCardModel.init)))
    }
    
    private func subscribeAlert() {
        alertRelay.subscribe { [weak self] action in
            guard let `self` = self else { return }
            switch action{
            case .okBtnTap:
                self.requestMainApi()
            case .cancelBtnTap:
                return
            }
        }
        .disposed(by: disposeBag)
    }
    
    private func showApiErrorAlert() {
        AlertDialogManager.shared.showApiErrorAndRetryAlertDialog(observable: alertRelay)
    }
}
