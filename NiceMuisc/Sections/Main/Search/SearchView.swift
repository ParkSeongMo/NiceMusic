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
        $0.placeholder = NSLocalizedString("search.inputSearchKeyword", comment: "")
        $0.font = .systemFont(ofSize: 15)
        $0.returnKeyType = .search
        $0.layer.cornerRadius = 10
        $0.leftPadding(5.0)
        $0.rightPadding(40.0)
        $0.delegate = self
    }
    
    private lazy var searchButton = UIButton().then {
        $0.titleLabel?.font = .systemFont(ofSize: 15)
        $0.setTitleColor(.white, for: .normal)
        $0.setTitleColor(.gray, for: .highlighted)
        $0.setTitle(NSLocalizedString("search.search", comment: ""), for: .normal)
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
    private let searchKeywordView = SearchKeywordView()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupLayout()
        bindRx()
        tapViewGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        subViews = [            
            searchTabView,
            searchKeywordView
        ]
    }
    
    private func setupLayout() {
        
        addSubviews(
            searchBarTextField,
            searchButton,
            deleteButton,
            searchTabView,
            searchKeywordView)
        
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
        
        searchKeywordView.snp.makeConstraints {
            $0.top.equalTo(searchBarTextField.snp.bottom).offset(20)
            $0.leading.equalTo(searchBarTextField.snp.leading)
            $0.trailing.equalTo(searchButton.snp.trailing)
            $0.height.equalTo(0)
        }
        
        searchTabView.isHidden = true
    }
    
    private func bindRx() {
                
        searchButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            let keyword = self.searchBarTextField.text ?? ""
            self.inputRelay.accept(SearchActionType.execute(keyword))
            self.inputRelay.accept(SearchActionType.saveKeyword(keyword))
        }
        .disposed(by: disposeBag)
        
        deleteButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            self.removeKeywordInputTextField()
            self.showSearchKeywordView(isHidden: false)
        }
        .disposed(by: disposeBag)
    }
    
    private func removeKeywordInputTextField() {
        searchBarTextField.text = ""
    }
    
    @discardableResult
    func setupDI<T>(generic: PublishRelay<T>) -> Self {
        
        if let generic = generic as? PublishRelay<SearchActionType> {
            inputRelay.compactMap { $0 as? SearchActionType }
                .bind(to: generic)
                .disposed(by: disposeBag)
            
            generic.subscribe { [weak self] action in
                guard let `self` = self else { return }
                switch action {
                case .executeRecently(let keyword):
                    self.searchBarTextField.text = keyword
                    self.showSearchKeywordView(isHidden: true)
                default:
                    return
                }
            }
            .disposed(by: disposeBag)
        }
        
        return self
    }
    
    @discardableResult
    func setupDI<T>(observable: Observable<(DetailType,[T])>) -> Self {
        if let observable = observable as? Observable<(DetailType, [CommonCardModel])> {
            searchTabView.setupDI(observable: observable)
            observable
                .subscribe(onNext: { [weak self] (type, items) in
                    guard let `self` = self else { return }
                    if items.count > 0 && self.searchTabView.isHidden {
                        self.searchTabView.isHidden = false
                    }
                })
                .disposed(by: disposeBag)            
        }
        return self
    }
    
    @discardableResult
    func setupDI<T>(observable: Observable<[T]>) -> Self {
        if let observable = observable as? Observable<[RecentSearchWord]> {
            observable.subscribe(onNext: { [weak self] element in
                guard let `self` = self else { return }
                self.changeTableViewHeight(count: element.count)
            })
            .disposed(by: disposeBag)
            searchKeywordView.setupDI(observable: observable)
        }
        return self
    }
    
    private func changeTableViewHeight(count: Int) {
        searchKeywordView.snp.updateConstraints {
            $0.height.equalTo(30*count)
        }
    }
    
    private func showSearchKeywordView(isHidden: Bool) {
        
        if !isHidden && searchKeywordView.isHidden {
            inputRelay.accept(SearchActionType.getKeyword)
        }
        searchKeywordView.isHidden = isHidden
    }
}

extension SearchView: UITextViewDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text else { return false }
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        let newLength = currentText.count + string.count - range.length
        showSearchKeywordView(isHidden: newLength > 0)
        if newLength > 40 {
            return false
        }
        return updatedText.count <= 40
    }
}

extension SearchView {
    func tapViewGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        endEditing(true)
    }
}
