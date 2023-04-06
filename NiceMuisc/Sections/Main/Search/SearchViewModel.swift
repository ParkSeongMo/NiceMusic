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
    case executeRecently(String)
    case more(Int)
    case getKeyword
    case saveKeyword(String)
    case removeKeyword(String)
    case tapItemForDetail(Int, String?, String?)
}

class SearchViewModel: BaseListViewModelType, ViewModelType, Stepper {
    
    // MARK: - Output properties
    private let resDataRelay = BehaviorRelay<(DetailType, [CommonCardModel])>(value:(.none, [CommonCardModel]()))
    private let loaderRelay = BehaviorRelay<LoadChangeAction>(value: .none)
    private let keywordRelay = BehaviorRelay<[RecentSearchWord]>(value: [RecentSearchWord]())
    private let alertRelay = PublishRelay<AlertAction>()
    private let searchTabViewShowRelay = PublishRelay<Bool>()
    
    private var resData: [Int:[CommonCardModel]] = [:]
    private let defaultPageNum = 1
    private let limit = 20
    private var page: [Int:Int] = [:]
    private var keyword = ""
    private var isLoading = false
    private var searchIndex = DetailType.none.searchIndex
    
    private lazy var requestArtistDataAction = Action<String, ArtistSearchModel> { [weak self] artist in
        guard let `self` = self else { return Observable.empty()}
        return ServiceApi.Artist.search(
            artist: artist,
            page: self.page[DetailType.artist.searchIndex]!,
            limit: self.limit).asObservable()
    }
    
    private lazy var requestTrackDataAction = Action<String, TrackSearchModel> { [weak self] track in
        guard let `self` = self else { return Observable.empty() }
        return ServiceApi.Track.search(
            track: track,
            page: self.page[DetailType.track.searchIndex]!,
            limit: self.limit).asObservable()
    }
    
    private lazy var requestAblumDataAction = Action<String, AlbumSearchModel> { [weak self] album in
        guard let `self` = self else { return Observable.empty() }
        return ServiceApi.Album.search(
            album: album,
            page: self.page[DetailType.album.searchIndex]!,
            limit: self.limit).asObservable()
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
        case .execute(let keyword), .executeRecently(let keyword):
            if self.isLoading || keyword.isEmpty {
                return .empty()
            }
            self.keyword = keyword
            self.searchIndex = DetailType.none.searchIndex
            self.requestSearchApi(keyword: keyword)
            self.setRecentSearchData(keyword: keyword)
        case .more(let searchIndex):
            if self.isLoading {
                return .empty()
            }
            self.searchIndex = searchIndex
            self.requestSearchApi(keyword: self.keyword)
        case .getKeyword:
            self.getRecentlySearchWordsAction.execute()
        case .saveKeyword(let keyword):
            if keyword.isEmpty {
                return .empty()
            }
            self.setRecentSearchData(keyword: keyword)
        case .removeKeyword(let keyword):
            if self.isLoading || keyword.isEmpty {
                return .empty()
            }
            self.removeRecentlySearchWordsAction.execute(keyword)
        case .tapItemForDetail(let searchIndex, let title, let subTitle):
            self.detailIsRequired(searchIndex: searchIndex, title: title, subTitle: subTitle)
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
        
        subscribeServerRequestionAction(action: requestTrackDataAction)
        subscribeServerRequestionAction(action: requestArtistDataAction)
        subscribeServerRequestionAction(action: requestAblumDataAction)
        subscribeRecetlyWordAction()
        subscribeAlert()
        
        return Output(
            response: resDataRelay.asObservable(),
            loadChanger: loaderRelay.asObservable(),
            keyword: keywordRelay.asObservable(),
            searchTabViewShowRelay: searchTabViewShowRelay.asObservable())
    }
    
    private func requestSearchApi(keyword: String) {
        isLoading = true
        loaderRelay.accept(.loaderStart)
        
        switch self.searchIndex {
        case DetailType.track.searchIndex:
            page[searchIndex]! += 1
            requestTrackDataAction.execute(keyword)
        case DetailType.artist.searchIndex:
            page[searchIndex]! += 1
            requestArtistDataAction.execute(keyword)
        case DetailType.album.searchIndex:
            page[searchIndex]! += 1
            requestAblumDataAction.execute(keyword)
        default:
            page[DetailType.artist.searchIndex] = defaultPageNum
            page[DetailType.track.searchIndex] = defaultPageNum
            page[DetailType.album.searchIndex] = defaultPageNum
            resData[DetailType.artist.searchIndex] = []
            resData[DetailType.track.searchIndex] = []
            resData[DetailType.album.searchIndex] = []
            requestArtistDataAction.execute(keyword)
            requestTrackDataAction.execute(keyword)
            requestAblumDataAction.execute(keyword)
        }
    }
    
    private func subscribeServerRequestionAction<T>(action: Action<String, T>) {
        
        action.errors.subscribe { code in
            self.loaderRelay.accept(.loaderStop)
            if self.isLoading == true {
                self.isLoading = false
                self.showApiErrorAlert()
            }
        }
        .disposed(by: disposeBag)
        
        action.elements.subscribe(onNext: { [weak self] element in
            guard let `self` = self else { return }
            
            self.loaderRelay.accept(.loaderStop)
            self.isLoading = false
            
            switch element {
            case let data as TrackSearchModel:
                self.responseSearchData(type: .track, array: data.results?.trackmatches?.track)
            case let data as ArtistSearchModel:
                self.responseSearchData(type: .artist, array: data.results?.artistmatches?.artist)
            case let data as AlbumSearchModel:
                self.responseSearchData(type: .album, array: data.results?.albummatches?.album)
            default:
                return
            }
        }).disposed(by: disposeBag)
    }
    
    private func responseSearchData<T>(type: DetailType, array: [T]?) {
        
        resData[type.searchIndex]! += makeLimitedData(array: array)
        resDataRelay.accept((type, resData[type.searchIndex] ?? []))
        searchTabViewShowRelay.accept((array?.count ?? 0) < 1)
    }
            
    private func makeLimitedData<T>(array: [T]?) -> [CommonCardModel] {
        
        var responseData:[CommonCardModel] = []
        
        guard let array = array else { return responseData }
        
        for item in array {
            responseData.append(CommonCardModel(data: item))
        }
                
        return responseData
    }
    
    private func subscribeRecetlyWordAction() {
        Observable.merge(getRecentlySearchWordsAction.elements,
                         removeRecentlySearchWordsAction.elements)
        .subscribe {  [weak self] element in
            guard let `self` = self else { return }
            self.keywordRelay.accept(element)
        }
        .disposed(by: disposeBag)
    }
    
    func detailIsRequired(searchIndex: Int, title: String?, subTitle: String?) {
        super.parsingTitleToArtist(
            type: parsingSearchIndexToDetailType(searchIndex: searchIndex),
            title: title,
            subTitle: subTitle,
            task: MainSteps.detailIsRequired)
    }
    
    private func parsingSearchIndexToDetailType(searchIndex: Int) -> DetailType {
        switch searchIndex{
        case DetailType.track.searchIndex:
            return DetailType.track
        case DetailType.artist.searchIndex:
            return DetailType.artist
        case DetailType.album.searchIndex:
            return DetailType.album
        default:
            return DetailType.none
        }
    }
    
    private func getRecentSearchKeyword() {
        
        var keywords = [RecentSearchWord]()
        for i in 1...10 {
            keywords.append(RecentSearchWord(keyword: "keyword \(i)", date: Date()))
        }
        
        keywordRelay.accept(keywords)
    }
    
    private func setRecentSearchData(keyword: String) {
        let data = RecentSearchWord(keyword: keyword, date: Date())
        RecentlySearchManager.shared.setRecentSearchData(data)
    }
    
    private func subscribeAlert() {
        alertRelay.subscribe { [weak self] action in
            guard let `self` = self else { return }            
            switch action {
            case .okBtnTap:
                self.requestSearchApi(keyword: self.keyword)
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

