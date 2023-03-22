//
//  DetailTrackView.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/22.
//

import UIKit
import RxSwift
import SnapKit
import Then

final class DetailTrackView: DescendantView {
    
    private let disposeBag = DisposeBag()
    
    private lazy var titleLabel = UILabel().then {
        $0.text = "음원 정보"
        $0.font = .boldSystemFont(ofSize: 18)
        $0.numberOfLines = 1
        $0.textColor = .white
    }
    
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
        addSubviews(titleLabel, tableView)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(10)
            $0.width.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(230)
        }
    }
    
    override func setupDI() {
        delegate?.outputRelay
            .compactMap { ($0 as? DetailModel)?.tracks }
            .bind(to: tableView.rx.items)  { tableView, _, element in
                if let cell = tableView.dequeueReusableCell(withIdentifier: ListTableViewCell.id) as? ListTableViewCell {                  
                    cell.prepare(
                        title: element.name,
                        subTitle: "\(element.duration ?? 0) sec",
                        imageUrl: element.image)
                    cell.selectionStyle = .none
                    return cell
                }
                return UITableViewCell()
            }
            .disposed(by: disposeBag)
    }
}
