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
    case topArtist = 0      // Top 뮤지션
    case topTrack = 1       // Top 음원
    case topLocalArtist = 2 // Top 국내 뮤지션
    case topLocalTrack = 3  // Top 국내 음원
}

extension HomeIndex {
    var title: String {
        switch self {
        case .topArtist:
            return "Top 뮤지션"
        case .topTrack:
            return "Top 음원"
        case .topLocalArtist:
            return "Top 국내 뮤지션"
        case .topLocalTrack:
            return "Top 국내 음원"
        default:
            return "None"
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
        initRefresh()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
        addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func initRefresh() {
                
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]
        refreshControl.attributedTitle = NSAttributedString(string: "당겨서 새로고침", attributes: attributes)
        refreshControl.addTarget(self, action: #selector(refreshTable(refresh:)), for: .valueChanged)
        refreshControl.tintColor = .white
        
        tableView.refreshControl = refreshControl
    }
    
    @objc func refreshTable(refresh: UIRefreshControl) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
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
            observable
//                .compactMap { $0 as? [HomeCardModel] }
    //                .do(onNext: { [weak self] element in
    //                    guard let `self` = self else { return }
    ////                    let name = self.paringName(data: element)
    //                    print("response name: ")
    //                })
    //            .bind(to: tableView.rx.items(cellIdentifier: HomeTableViewCell.id, cellType: HomeTableViewCell.self)) {
    //                (index: Int, element:HomeCardModel, cell:HomeTableViewCell) in
    //                cell.prepare(name: self.getTitleText(index: element.index), items: element.items)
    //                print("setupDI bind index:\(element.index), count:\(element.items.count)")
    //            }
                .bind(to: tableView.rx.items) { [weak self] tableView, _, element in
                    guard let `self` = self else { return UITableViewCell() }
                    if let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.id) as? HomeTableViewCell {
                        cell.prepare(index: element.index, items: element.items)
                        cell.bindAction(reley: self.inputRelay)
                        return cell
                    }
                    return UITableViewCell()
                }
                .disposed(by: disposeBag)
        }
              
        return self
    }
}
