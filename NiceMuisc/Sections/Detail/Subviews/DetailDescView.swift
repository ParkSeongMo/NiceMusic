//
//  DetailDescView.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/22.
//

import UIKit
import RxSwift
import SnapKit
import Then

final class DetailDescView: UIView {
        
    private let disposeBag = DisposeBag()
    
    private lazy var logoutButton = UIButton().then {
        $0.titleLabel?.font = .systemFont(ofSize: 15)
        $0.setTitleColor(.white, for: .normal)
        $0.setTitle("Logout2", for: .normal)
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
        backgroundColor = .yellow
        addSubview(logoutButton)
        logoutButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(100)
            $0.trailing.equalToSuperview().offset(-200)
            $0.height.equalTo(30)
            $0.width.equalTo(70)
            $0.bottom.equalToSuperview()
        }
    }
    
    
    private func bindRx() {
    }
}
