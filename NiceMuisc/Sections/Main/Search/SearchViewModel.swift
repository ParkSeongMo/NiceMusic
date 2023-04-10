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
    case more(DetailType)
    case getKeyword
    case removeKeyword(String)
    case tapItemForDetail(DetailType, String?, String?)
}

class SearchViewModel: BaseListViewModelType, ViewModelType, Stepper {
    
    // MARK: - Output properties
    private let reqApiDefaultPageNum = 1
    private let reqApiLimitedCount = 20
    
    private let resDataRelay = BehaviorRelay<(DetailType, [CommonCardModel])>(value:(.none, [CommonCardModel]()))
    private let loaderRelay = BehaviorRelay<LoadChangeAction>(value: .none)
    private let keywordRelay = BehaviorRelay<[RecentSearchWord]>(value: [RecentSearchWord]())
    private let alertRelay = PublishRelay<AlertAction>()
    private let searchTabViewShowRelay = PublishRelay<Bool>()
    
    private var searchType = DetailType.none // 음원, 가수, 앨범
    private var apiResData = [DetailType.track: [CommonCardModel](),
                              DetailType.artist: [CommonCardModel](),
                              DetailType.album: [CommonCardModel]()] // 타입별 서버 응답 데이터
    private var apiReqPages = [DetailType.track: 0,
                               DetailType.artist: 0,
                               DetailType.album: 0] // 타입별 서버 요청 페이지
    private var searchKeyword = ""
    private var isFinishSearchApi = true
    
    private lazy var requestArtistDataAction = Action<String, ArtistSearchModel> { [weak self] artist in
        guard let `self` = self else { return Observable.empty()}
        return ServiceApi.Artist.search(
            artist: artist,
            page: self.apiReqPages[DetailType.artist]!,
            limit: self.reqApiLimitedCount).asObservable()
    }
    
    private lazy var requestTrackDataAction = Action<String, TrackSearchModel> { [weak self] track in
        guard let `self` = self else { return Observable.empty() }
        return ServiceApi.Track.search(
            track: track,
            page: self.apiReqPages[DetailType.track]!,
            limit: self.reqApiLimitedCount).asObservable()
    }
    
    private lazy var requestAblumDataAction = Action<String, AlbumSearchModel> { [weak self] album in
        guard let `self` = self else { return Observable.empty() }
        return ServiceApi.Album.search(
            album: album,
            page: self.apiReqPages[DetailType.album]!,
            limit: self.reqApiLimitedCount).asObservable()
    }
    
    private lazy var getRecentlySearchWordsAction = Action<Void, [RecentSearchWord]> { [weak self] _ in
        return Observable.just(RecentlySearchManager.shared.getRecentSearchData())
    }
    
    private lazy var removeRecentlySearchWordsAction = Action<String, [RecentSearchWord]> { [weak self] keyword in
        return Observable.just(RecentlySearchManager.shared.removeSameSearchData(keyword: keyword))
    }
    
    private lazy var action = Action<SearchActionType, Void> { [weak self] action in
        guard let `self` = self else { return .empty() }
        switch action {
        case .execute(let keyword):
            if !self.isFinishSearchApi || keyword.isEmpty {
                return .empty()
            }
            self.searchKeyword = keyword
            self.searchType = DetailType.none
            self.initApiReqPages()
            self.initApiResData()
            self.requestSearchApi(keyword: keyword)
            self.saveRecentSearchKeyword(keyword: keyword)
        case .more(let searchType):
            if !self.isFinishSearchApi {
                return .empty()
            }
            self.searchType = searchType
            self.apiReqPages[searchType]! += 1
            self.requestSearchApi(keyword: self.searchKeyword)
        case .getKeyword:
            self.getRecentlySearchWordsAction.execute()
        case .removeKeyword(let keyword):
            if keyword.isEmpty {
                return .empty()
            }
            self.removeRecentlySearchWordsAction.execute(keyword)
        case .tapItemForDetail(let searchType, let title, let subTitle):
            self.moveToDetail(detailType: searchType, title: title, subTitle: subTitle)
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
        let keyword: Observable<[RecentSearchWord]>
        let searchTabViewShowRelay: Observable<Bool>
    }
    
    func transform(req: Input) -> Output {
        
        req.actionTrigger.bind(to: action.inputs).disposed(by: disposeBag)
        
        subscribeServerRequestionAction()
        subscribeRecetlyWordAction()
        subscribeAlert()
        
        return Output(
            response: resDataRelay.asObservable(),
            loadChanger: loaderRelay.asObservable(),
            keyword: keywordRelay.asObservable(),
            searchTabViewShowRelay: searchTabViewShowRelay.asObservable())
    }
    
    private func requestSearchApi(keyword: String) {
        isFinishSearchApi = false
        loaderRelay.accept(.loaderStart)
        
        switch self.searchType {
        case DetailType.track:
            requestTrackDataAction.execute(keyword)
        case DetailType.artist:
            requestArtistDataAction.execute(keyword)
        case DetailType.album:
            requestAblumDataAction.execute(keyword)
        default:
            requestArtistDataAction.execute(keyword)
            requestTrackDataAction.execute(keyword)
            requestAblumDataAction.execute(keyword)
            return
        }
    }
    
    private func subscribeServerRequestionAction() {
        
        // 에러
        Observable.of(requestArtistDataAction.errors,
                      requestTrackDataAction.errors,
                      requestAblumDataAction.errors)
        .merge()
        .take (while:{ [weak self] _ in
            guard let `self` = self else { return true }
            return !self.isFinishSearchApi
        })
        .bind { [weak self] code in
            guard let `self` = self else { return }
            self.isFinishSearchApi = true
            self.loaderRelay.accept(.loaderStop)
            self.showApiErrorAlert()
        }
        .disposed(by: disposeBag)
        
        // 성공
        Observable.zip(requestArtistDataAction.elements,
                       requestTrackDataAction.elements,
                       requestAblumDataAction.elements)
        .subscribe(onNext: { [weak self] (artist, track, album) in
            guard let `self` = self else { return }
            self.isFinishSearchApi = true
            self.loaderRelay.accept(.loaderStop)
            self.searchTabViewShowRelay.accept(false)
            self.responseSearchData(type: .track, array: track.results?.trackmatches?.track)
            self.responseSearchData(type: .artist, array: artist.results?.artistmatches?.artist)
            self.responseSearchData(type: .album, array: album.results?.albummatches?.album)
        })
        .disposed(by: disposeBag)
    }
    
    private func responseSearchData<T>(type: DetailType, array: [T]?) {
        apiResData[type]! += convertResDataToCommonCardModel(array: array)
        resDataRelay.accept((type, apiResData[type] ?? []))
    }
    
    private func convertResDataToCommonCardModel<T>(array: [T]?) -> [CommonCardModel] {
        
        var responseData:[CommonCardModel] = []
        
        guard let array = array else { return responseData }
        
        for item in array {
            responseData.append(CommonCardModel(data: item))
        }
        
        return responseData
    }
    
    func moveToDetail(detailType: DetailType, title: String?, subTitle: String?) {
        super.moveToDetail(
            type: detailType,
            title: title,
            subTitle: subTitle,
            task: MainSteps.detailIsRequired)
    }
    
    private func subscribeRecetlyWordAction() {
        Observable.merge(getRecentlySearchWordsAction.elements,
                         removeRecentlySearchWordsAction.elements)
        .subscribe { [weak self] element in
            guard let `self` = self else { return }
            self.keywordRelay.accept(element)
        }
        .disposed(by: disposeBag)
    }
    
    private func saveRecentSearchKeyword(keyword: String) {
        let data = RecentSearchWord(keyword: keyword, date: Date())
        RecentlySearchManager.shared.setRecentSearchData(data)
    }
    
    private func subscribeAlert() {
        alertRelay.subscribe { [weak self] action in
            guard let `self` = self else { return }
            switch action {
            case .okBtnTap:
                self.requestSearchApi(keyword: self.searchKeyword)
            case .cancelBtnTap:
                return
            }
        }
        .disposed(by: disposeBag)
    }
    
    private func showApiErrorAlert() {
        AlertDialogManager.shared.showApiErrorAndRetryAlertDialog(observable: alertRelay)
    }
    
    private func initApiReqPages() {
        apiReqPages = [DetailType.track: reqApiDefaultPageNum,
                       DetailType.artist: reqApiDefaultPageNum,
                       DetailType.album: reqApiDefaultPageNum]
    }
    
    private func initApiResData() {
        apiResData = [DetailType.track: [],
                      DetailType.artist: [],
                      DetailType.album: []]
    }
}

