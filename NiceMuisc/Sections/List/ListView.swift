//
//  ListView.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/16.
//

import RxCocoa
import RxSwift
import UIKit

class ListView: UIView, SubViewDI {
        
    private let disposeBag = DisposeBag()
    
    var inputRelay = PublishRelay<Any>()
    var outputRelay = PublishRelay<Any>()
        
    private let refreshControl = UIRefreshControl()
    private let action = PublishRelay<ListActionType>()
    private var fetchingMore = false
        
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        $0.separatorInsetReference = .fromCellEdges
        $0.separatorStyle = .singleLine
        $0.separatorColor = .gray
        
        $0.rowHeight = 70
        $0.backgroundColor = .black
        $0.bounces = true
        $0.showsVerticalScrollIndicator = true
        $0.contentInset = .zero
        $0.register(ListTableViewCell.self, forCellReuseIdentifier: ListTableViewCell.id)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        initRefresh()
        bindrx()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
        addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
        
    private func bindrx() {
                
        tableView.rx.modelSelected(CommonCardModel.self)
            .map { item in ListActionType.tapItemForDetail(item.title, item.subTitle) }
            .bind(to: inputRelay)
            .disposed(by: disposeBag)
        
        tableView.rx.contentOffset
            .subscribe({  [weak self] _ in
                guard let `self` = self else { return }
                if self.tableView.isNearBottomEdge() && !self.fetchingMore {
//                    print("contentOffset isNearBottomEdge \(self.fetchingMore)")
                    self.fetchingMore = true
                    self.inputRelay.accept(ListActionType.more)
                }
            }).disposed(by: disposeBag)
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
            self.inputRelay.accept(ListActionType.refresh)
            refresh.endRefreshing()
        }
    }
    
    @discardableResult
    func setupDI<T>(generic: PublishRelay<T>) -> Self {
                
        if let generic = generic as? PublishRelay<ListActionType> {
            inputRelay.compactMap { $0 as? ListActionType }
                .bind(to: generic)
                .disposed(by: disposeBag)
        }
        
        return self
    }
    
    @discardableResult
    func setupDI<T>(observable: Observable<T>) -> Self {
                  
        // check 타입 캐스팅
        observable
            .compactMap { $0 as? [CommonCardModel] }
            .do(onNext: { [weak self] element in
                guard let `self` = self else { return }
                self.fetchingMore = false
            })
            .bind(to: tableView.rx.items) { tableView, _, element in
                if let cell = tableView.dequeueReusableCell(withIdentifier: ListTableViewCell.id) as? ListTableViewCell {
                    cell.prepare(
                        title: element.title,
                        subTitle: element.subTitle,
                        imageUrl: element.image?.isEmpty == true ? "" : element.image?[2].text)
                    cell.selectionStyle = .none
                    return cell
                }
                return UITableViewCell()
            }
            .disposed(by: disposeBag)
              
        return self
    }
}
