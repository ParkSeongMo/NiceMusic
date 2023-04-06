//
//  SearchKeywordView.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/27.
//

import UIKit
import RxRelay
import RxSwift
import SnapKit
import Then


final class SearchKeywordView: DescendantView {
    
    private let disposeBag = DisposeBag()
    
    private lazy var tableView = UITableView().then {
        $0.separatorInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        $0.separatorInsetReference = .fromCellEdges
        $0.separatorStyle = .singleLine
        $0.separatorColor = .gray
        
        $0.rowHeight = 30
        $0.backgroundColor = .gray
        $0.contentInset = .zero
        $0.register(SearchKeywordCell.self, forCellReuseIdentifier: SearchKeywordCell.id)
        $0.layer.cornerRadius = 10
        $0.alwaysBounceVertical = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        bindRx()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.directionalEdges.equalToSuperview()
        }
    }
    
    private func bindRx() {     
        tableView.rx.modelSelected(RecentSearchWord.self)
            .map { $0.keyword }
            .bind { [weak self] keyword in
                guard let `self` = self else { return }
                self.delegate?.inputRelay.accept(SearchActionType.executeRecently(keyword))
                self.delegate?.inputRelay.accept(SearchActionType.saveKeyword(keyword))
            }
            .disposed(by: disposeBag)
    }
    
    @discardableResult
    func setupDI(observable: Observable<[RecentSearchWord]>) -> Self {
                
        observable.bind(to: tableView.rx.items) { [weak self] tableView, _, element in
            guard let `self` = self else { return UITableViewCell() }
            if let cell = tableView.dequeueReusableCell(withIdentifier: SearchKeywordCell.id) as? SearchKeywordCell {
                cell.prepare(
                    title: element.keyword,
                    date: element.date,
                    inputRelay: self.delegate?.inputRelay ?? PublishRelay<Any>())
                cell.selectionStyle = .none
                return cell
            }
            return UITableViewCell()
        }
        .disposed(by: disposeBag)
        
        return self
    }
}
