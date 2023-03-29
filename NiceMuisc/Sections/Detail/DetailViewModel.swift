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
    case logout
}

enum DetailAlertActionType {
    case api
    case logout
}

final class DetailViewModel: ViewModelType, Stepper {
      
     // MARK: - Stepper
    var steps = RxRelay.PublishRelay<RxFlow.Step>()
    
    // MARK: - Output properties
    private let resDataRelay = BehaviorRelay<DetailModel>(value: DetailModel())
    private let changerRelay = BehaviorRelay<LoadChangeAction>(value: .none)
    private let alertRelay = PublishRelay<AlertAction>()
    
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
        
        "buttonAction \(action)")
        switch action {
        case .none:
            return .empty()
        case .execute:
            self.requestDetailApi(type: self.detailType, artist: self.artist, name: self.name)
        case .logout:
            self.showLogoutAlert()
        }
        return .empty()
    }
    
    struct Input {
        let actionTrigger: Observable<DetailActionType>
    }
    
    struct Output {
        let response: Observable<DetailModel>
        let loadChanger: Observable<LoadChangeAction>
    }      
        
    private let disposeBag = DisposeBag()
    private let artist: String
    private let name: String
    let detailType: DetailType
    
    init(detailType: DetailType, artist: String?, name: String?) {
        self.detailType = detailType
        self.artist = artist ?? ""
        self.name = name ?? ""
    }
    
    func transform(req: Input) -> Output {
        
        req.actionTrigger.bind(to: buttonAction.inputs).disposed(by: disposeBag)
                
        subscribeServerRequestionAction(action: requestArtistDataAction)
        subscribeServerRequestionAction(action: requestAlbumDataAction)
        subscribeServerRequestionAction(action: requestTrackDataAction)
        
        subscribeAlert()
        
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
        
        action.errors.subscribe { code in
            self.changerRelay.accept(.loaderStop)
            self.showApiErrorAlert()
        }
        .disposed(by: disposeBag)
        
        action.elements
            .subscribe(onNext: { [weak self] element in
                guard let `self` = self else { return }
                self.changerRelay.accept(.loaderStop)
                self.resDataRelay.accept(DetailModel(detailType: self.detailType,
                                                     data: element))
            })
            .disposed(by: disposeBag)
    }
    
    private func subscribeAlert() {
        alertRelay.subscribe { [weak self] action in
            guard let `self` = self else { return }
            switch action {
            case .okBtnTap(let type):
                self.alertOkAction(type: type as? DetailAlertActionType)
            case .cancelBtnTap(let type):
                self.alertCancelAction(type: type as? DetailAlertActionType)
                return
            }
        }
        .disposed(by: disposeBag)
    }
    
    private func alertOkAction(type: DetailAlertActionType?) {
        switch type {
        case .api:
            requestDetailApi(type: detailType, artist: artist, name: name)
        case .logout:
            steps.accept(MainSteps.loginIsRequired)
        default:
            return
        }
    }
    
    private func alertCancelAction(type: DetailAlertActionType?) {
        switch type {
        case .api:
            steps.accept(MainSteps.rootViewController(animated: false))
        default:
            return
        }
    }
    
    private func showApiErrorAlert() {
        AlertDialogManager.shared.showApiErrorAndRetryAlertDialog(observable: alertRelay, actionType: DetailAlertActionType.api)
    }
    
    private func showLogoutAlert() {
        AlertDialogManager.shared.showAlertDialog(
            title: "로그아웃",
            message: "로그아웃 하시겠습니까?",
            observable: alertRelay,
            actionType: DetailAlertActionType.logout)
    }
}
