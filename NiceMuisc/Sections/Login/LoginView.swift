//
//  MainView.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/21.
//

import UIKit
import RxRelay
import Then

final class LoginView: BaseSubView {
        
    private lazy var idTextField = UITextField().then {
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
        $0.titleLabel?.font = .systemFont(ofSize: 20)
        $0.setTitleColor(.white, for: .normal)
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
