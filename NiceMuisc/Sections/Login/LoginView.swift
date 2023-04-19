//
//  MainView.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/21.
//

import UIKit
import RxRelay
import RxSwift
import Then

final class LoginView: BaseSubView {
    
    private lazy var idTextField = UITextField().then {
        $0.textColor = .black
        $0.backgroundColor = .white
        $0.placeholder = NSLocalizedString("login.id", comment: "")
        $0.font = .systemFont(ofSize: 15)
        $0.returnKeyType = .search
        $0.layer.cornerRadius = 10
        $0.leftPadding(5.0)
        $0.rightPadding(40.0)
        $0.delegate = self
    }
    
    private lazy var passwdTextField = UITextField().then {
        $0.textColor = .black
        $0.isSecureTextEntry = true
        $0.backgroundColor = .white
        $0.placeholder = NSLocalizedString("login.passwd", comment: "")
        $0.font = .systemFont(ofSize: 15)
        $0.returnKeyType = .search
        $0.layer.cornerRadius = 10
        $0.leftPadding(5.0)
        $0.rightPadding(40.0)
        $0.delegate = self
    }
    
    private lazy var homeButton = UIButton().then {
        $0.isEnabled = false
        $0.backgroundColor = .black
        $0.titleLabel?.font = .systemFont(ofSize: 20)
        $0.setTitleColor(.white, for: .normal)
        $0.setTitleColor(.gray, for: .disabled)
        $0.setTitle(NSLocalizedString("login.login", comment: ""), for: .normal)
        $0.layer.borderWidth = 2
        $0.layer.borderColor = UIColor.white.cgColor
        $0.layer.cornerRadius = 10
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        bindRx()
        tapViewGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubviews(homeButton, idTextField, passwdTextField)
        
        idTextField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(300)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(40)
            $0.width.equalTo(200)
        }
        
        passwdTextField.snp.makeConstraints {
            $0.top.equalTo(idTextField.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(40)
            $0.width.equalTo(200)
        }
        
        homeButton.snp.makeConstraints {
            $0.top.equalTo(passwdTextField.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(50)
            $0.width.equalTo(200)
        }
    }
    
    private func bindRx() {
        
        homeButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            self.inputRelay.accept(LoginActionType.tapForHome)
        }
        .disposed(by: disposeBag)
        
        idTextField.rx.text.orEmpty
            .map { LoginActionType.inputId($0) }
            .bind(to: inputRelay)
            .disposed(by: disposeBag)
        
        passwdTextField.rx.text.orEmpty
            .map { LoginActionType.inputPwd($0) }
            .bind(to: inputRelay)
            .disposed(by: disposeBag)
    }
    
    @discardableResult
    func setupDI<T>(generic: PublishRelay<T>) -> Self {
        
        if let generic = generic as? PublishRelay<LoginActionType> {
            inputRelay.compactMap{ $0 as? LoginActionType }
                .bind(to: generic)
                .disposed(by: disposeBag)
        }
        return self
    }
    
    @discardableResult
    func setupDI<T>(observable: Observable<T>) -> Self {
       
        if let observable = observable as? Observable<(LoginValidType, Bool)> {
            
            let idObservable = bindInputText( observable: observable,
                                              loginType: .idValid,
                                              textField: idTextField)
            let pwdObservable = bindInputText(observable: observable,
                                              loginType: .pwdValid,
                                              textField: passwdTextField)
            Observable
                .combineLatest(idObservable, pwdObservable, resultSelector: { v1, v2 in v1 && v2 })
                .distinctUntilChanged()
                .asDriver(onErrorJustReturn: false)
                .drive(self.homeButton.rx.isEnabled)
                .disposed(by: disposeBag)
        }
        return self
    }
    
    private func bindInputText(
        observable: Observable<(LoginValidType, Bool)>,
        loginType: LoginValidType,
        textField: UITextField) -> Observable<(Bool)>{
            
            let retObserable = observable.filter { type, valid in
                type == loginType
            }
            .map(\.1)
            .distinctUntilChanged()
            
            retObserable
                .asDriver(onErrorJustReturn: false)
                .drive(onNext: { [weak self] isValid in
                    guard let `self` = self else { return }
                    print("input type \(loginType) valid \(isValid)")
                    self.setInputTextColor(textLable: textField, isValid: isValid)
                })
                .disposed(by: disposeBag)
            
            return retObserable
    }
        
    private func setInputTextColor(textLable: UITextField, isValid: Bool) {
        textLable.textColor = isValid ? .black : .red
    }
    
    private func setLoginButton(isValid: Bool) {
        homeButton.setTitleColor(.gray, for: .normal)
    }
}


extension LoginView: UITextFieldDelegate {
    
}

extension LoginView {
    func tapViewGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        endEditing(true)
    }
}
