//
//  SearchView.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/23.
//

import UIKit
import RxSwift
import RxRelay

final class SearchView: BaseSubView, UITextFieldDelegate {
    
    var responseRelay = PublishRelay<(DetailType, [CommonCardModel])>()
    
    var subViews: [DescendantView] = [] {
        willSet {
            newValue.forEach {
                $0.delegate = self
            }
        }
    }
    
    private lazy var searchBarTextField = UITextField().then {
        $0.backgroundColor = .white
        $0.placeholder = "검색어를 입력하세요"
        $0.font = .systemFont(ofSize: 15)
        $0.returnKeyType = .search
//        $0.addDoneButtonOnKeyboard(title: "닫기")
        $0.layer.cornerRadius = 10
        $0.leftPadding(5.0)
        $0.rightPadding(40.0)
        $0.delegate = self
    }
    
    private lazy var searchButton = UIButton().then {
        $0.titleLabel?.font = .systemFont(ofSize: 15)
        $0.setTitleColor(.white, for: .normal)
        $0.setTitleColor(.gray, for: .highlighted)
        $0.setTitle("검색", for: .normal)
        $0.layer.borderWidth = 2
        $0.layer.borderColor = UIColor.white.cgColor
        $0.layer.cornerRadius = 10
    }
    
    private lazy var deleteButton = UIButton().then {
        var image =  UIImage(
            systemName: "xmark.circle",
            withConfiguration:
                UIImage.SymbolConfiguration(font: .systemFont(ofSize: 15.0)))
        $0.setBackgroundImage(image, for: .normal)
        $0.tintColor = .darkGray
    }
    
    private let searchTabView = SearchTabView()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupLayout()
        bindRx()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        subViews = [            
            searchTabView
        ]
    }
    
    private func setupLayout() {
        
        addSubviews(
            searchBarTextField,
            searchButton,
            deleteButton,
            searchTabView)
        
        searchButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(100)
            $0.trailing.equalToSuperview().offset(-15)
            $0.height.equalTo(40)
            $0.width.equalTo(50)
        }
        
        searchBarTextField.snp.makeConstraints {
            $0.centerY.equalTo(searchButton.snp.centerY)
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalTo(searchButton.snp.leading).offset(-10)
            $0.height.equalTo(40)
        }
        
        deleteButton.snp.makeConstraints {
            $0.centerY.equalTo(searchBarTextField.snp.centerY)
            $0.trailing.equalTo(searchBarTextField.snp.trailing).offset(-5)
            $0.width.height.equalTo(35)
        }
        
        searchTabView.snp.makeConstraints {
            $0.top.equalTo(searchBarTextField.snp.bottom).offset(20)
            $0.leading.equalTo(searchBarTextField.snp.leading)
            $0.trailing.equalTo(searchButton.snp.trailing)
            $0.bottom.equalToSuperview()
        }
    }
    
    private func bindRx() {
                
        deleteButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            self.searchBarTextField.text = ""
        }
        .disposed(by: disposeBag)
    }
    
    @discardableResult
    func setupDI<T>(generic: PublishRelay<T>) -> Self {
        
        if let generic = generic as? PublishRelay<SearchActionType> {
            inputRelay.compactMap { $0 as? SearchActionType }
                .bind(to: generic)
                .disposed(by: disposeBag)
        }
        
        return self
    }
    
    @discardableResult
    func setupDI<T>(observable: Observable<(DetailType,[T])>) -> Self {
        
        if let observable = observable as? Observable<(DetailType, [CommonCardModel])> {
            observable.subscribe { (detailType, items) in
//                self.responseRelay.accept((detailType, items))
            }
            .disposed(by: disposeBag)
        }
        
        searchTabView.setupDI(observable: observable)
        return self
    }
}

extension SearchView: UITextViewDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text else { return false }
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        let newLength = currentText.count + string.count - range.length
        if newLength > 40 {
            return false
        }
        return updatedText.count <= 40
    }
}
