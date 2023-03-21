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
    
    private lazy var homeButton = UIButton().then {
        $0.titleLabel?.font = .systemFont(ofSize: 15)
        $0.setTitleColor(.white, for: .normal)
        $0.setTitle("Go to home", for: .normal)
        $0.layer.borderWidth = 2
        $0.layer.borderColor = UIColor.white.cgColor
        $0.layer.cornerRadius = 10
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
                
        addSubviews(homeButton)
        
        homeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(100)
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
