//
//  ListView.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/16.
//

import RxCocoa
import RxSwift
import UIKit

class ListView: BaseSubView, BaseRefreshContrl {
                
    private let action = PublishRelay<ListActionType>()
        
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
        bindrx()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
        backgroundColor = .black
        
        addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        tableView.refreshControl = getRefreshControl(#selector(refreshTable(refresh:)))
        tableView.isHidden = true
    }
        
    private func bindrx() {
                
        tableView.rx.modelSelected(CommonCardModel.self)
            .map { item in ListActionType.tapItemForDetail(item.title, item.subTitle) }
            .bind(to: inputRelay)
            .disposed(by: disposeBag)
        
        tableView.rx.contentOffset
//            .throttle(.milliseconds(2000), scheduler: MainScheduler.instance)
            .subscribe({  [weak self] _ in
                guard let `self` = self else { return }
                if self.tableView.isNearBottomEdge() {
                    Log.d("loading")
                    self.inputRelay.accept(ListActionType.more)
                }
            }).disposed(by: disposeBag)
    }
        
    @objc func refreshTable(refresh: UIRefreshControl) {
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
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
    func setupDI<T>(observable: Observable<[T]>) -> Self {
        if let observable = observable as? Observable<[CommonCardModel]> {
            observable
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
        }
        
        return self
    }
    
    @discardableResult
    func setupDI<T>(observable: Observable<T>) -> Self {        
        if let observable = observable as? Observable<Bool> {
            observable
                .distinctUntilChanged()
                .subscribe { [weak self] isHidden in
                    guard let `self` = self else { return }
                    self.tableView.isHidden = isHidden
                }
                .disposed(by: disposeBag)
        }
        
        return self
    }
}
