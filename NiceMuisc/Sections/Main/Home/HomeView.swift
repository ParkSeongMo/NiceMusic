//
//  HomeView.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/02.
//

import RxCocoa
import RxRelay
import RxSwift
import SnapKit
import Then
import UIKit

// 홈화면에 표출되는 항목 순서
enum HomeIndex: Int {
    case none = -1
    case topArtist = 0      // Top 가수
    case topTrack = 1       // Top 음원
    case topLocalArtist = 2 // Top 국내 가수
    case topLocalTrack = 3  // Top 국내 음원
}

extension HomeIndex {
    var title: String {
        switch self {
        case .topArtist:
            return NSLocalizedString("home.title.topArtist", comment: "")
        case .topTrack:
            return NSLocalizedString("home.title.topTrack", comment: "")
        case .topLocalArtist:
            return NSLocalizedString("home.title.topLocalArtist", comment: "")
        case .topLocalTrack:
            return NSLocalizedString("home.title.topLocalTrack", comment: "")
        default:
            return "None"
        }
    }
}

extension HomeIndex {
    var detailType: DetailType {
        switch self {
        case .topArtist, .topLocalArtist:
            return .artist
        case .topTrack, .topLocalTrack:
            return .track
        default:
            return .none
        }
    }
}

final class HomeView: BaseSubView {
        
    typealias Model = HomeViewModel
    
    private let tableViewHeight = 270.0
                
    private let refreshControl = UIRefreshControl()
        
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.rowHeight = tableViewHeight
        $0.allowsSelection = false
        $0.backgroundColor = .black
        $0.separatorStyle = .none
        $0.bounces = true
        $0.showsVerticalScrollIndicator = true
        $0.contentInset = .zero
        $0.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.id)
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        tableView.refreshControl = getRefreshControl(#selector(refreshTable(refresh:)))
    }
    
    @objc func refreshTable(refresh: UIRefreshControl) {
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.inputRelay.accept(HomeActionType.refresh)
            refresh.endRefreshing()
        }
    }
    
    @discardableResult
    func setupDI<T>(generic: PublishRelay<T>) -> Self {
        
        if let generic = generic as? PublishRelay<HomeActionType> {
            inputRelay.compactMap { $0 as? HomeActionType }
                .bind(to: generic)
                .disposed(by: disposeBag)
        }
        
        return self
    }
    
    @discardableResult
    func setupDI<T>(observable: Observable<T>) -> Self {
        
        if let observable = observable as? Observable<[HomeCardModel]> {            
            observable.bind(to: tableView.rx.items(
                cellIdentifier: HomeTableViewCell.id,
                cellType: HomeTableViewCell.self)) {
                    index, item, cell in
                    cell.prepare(index: item.index, items: item.items)
                    cell.bindAction(reley: self.inputRelay)                
                }
                .disposed(by: disposeBag)
        }
              
        return self
    }
}
