//
//  SearchKeywordCell.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/27.
//

import UIKit

final class SearchKeywordCell: UITableViewCell {
    
    static let id = "SearchKeywordCell"
    
    private lazy var titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 13)
        $0.textColor = .darkGray
    }
    
    private lazy var dateLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 13)
        $0.textColor = .darkGray
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
                
        contentView.addSubviews(titleLabel, dateLabel)
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalTo(dateLabel.snp.leading).offset(5)
        }
        
        dateLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-10)
        }
    }
    
    func prepare(title: String?, date: Date) {
        titleLabel.text = title
        dateLabel.text = date.kewordDate()
    }
}
