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


enum HomeIndex: Int {
    case none = -1
    case topArtist = 0
    case topTrack = 1
    case topLocalArtist = 2
    case topLocalTrack = 3
}

final class HomeView: UIView, SubViewDI {
        
    typealias Model = HomeViewModel
    
    private let tableViewHeight = 270
    private let disposeBag = DisposeBag()
    
    var inputRelay = PublishRelay<Any>()
    var outputRelay = PublishRelay<Any>()
    
    var subViews: [DescendantView] = [] {
        willSet {
            newValue.forEach {
                $0.delegate = self
            }
            applySubviewTags()
        }
    }
        
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.allowsSelection = false
        $0.backgroundColor = .black
        $0.separatorStyle = .none
        $0.bounces = true
        $0.showsVerticalScrollIndicator = true
        $0.contentInset = .zero
        $0.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.id)
    }
        
    func applySubviewTags() {
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
        tableView.delegate = self
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
                    
        observable
            .compactMap { $0 as? [HomeCardModel] }
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
            .bind(to: tableView.rx.items) { tableView, _, element in
                if let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.id) as? HomeTableViewCell {
                    
//                    if !element.items.isEmpty {
//                        print("HomeView title \(element.items[0].title)")
//                    }
                    cell.prepare(name: self.getTitleText(index: element.index), items: element.items)
                    return cell
                }
                return UITableViewCell()
            }
            .disposed(by: disposeBag)
              
        return self
    }
    
    private func getTitleText(index: HomeIndex) -> String {
        
        switch index {
        case .topArtist:
            return "Top 뮤지션"
        case .topTrack:
            return "Top 음반"
        case .topLocalArtist:
            return "Top 국내 뮤지션"
        case .topLocalTrack:
            return "Top 국내 음반"
        default:
            return "None"
        }
    }
    
}

extension HomeView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(tableViewHeight)
  }    
}
