//
//  SearchKeywordCell.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/27.
//

import UIKit
import RxSwift
import RxRelay

final class SearchKeywordCell: UITableViewCell {
    
    static let id = "SearchKeywordCell"
    
    private let disposeBag = DisposeBag()
    
    private var inputRelay = PublishRelay<Any>()
    
    private lazy var titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 13)
        $0.textColor = .darkGray
    }
    
    private lazy var dateLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 13)
        $0.textColor = .darkGray
    }
    
    private lazy var deleteButton = UIButton().then {
        var image = UIImage(systemName: "xmark.circle",
                            withConfiguration:
                                UIImage.SymbolConfiguration(font: .systemFont(ofSize: 10)))
        $0.setBackgroundImage(image, for: .normal)
        $0.tintColor = .darkGray
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        bindRx()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
                
        contentView.addSubviews(titleLabel, dateLabel, deleteButton)
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalTo(dateLabel.snp.leading).offset(-5)
        }
        
        dateLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.width.equalTo(78)
            $0.trailing.equalTo(deleteButton.snp.leading).offset(-5)
        }
        
        deleteButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-10)
            $0.width.height.equalTo(25)
        }
    }
    
    private func bindRx() {
        deleteButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            Log.d("remove keyword")
            self.deleteKeyword()
        }.disposed(by: disposeBag)
    }
    
    private func deleteKeyword() {
        inputRelay.accept(SearchActionType.removeKeyword(titleLabel.text ?? ""))
    }
    
    func prepare(title: String?, date: Date, inputRelay: PublishRelay<Any>) {
        titleLabel.text = title
        dateLabel.text = date.kewordDate()
        self.inputRelay = inputRelay
    }
    
    
}
