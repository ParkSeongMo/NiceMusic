//
//  DetailImageView.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/17.
//

import SnapKit
import Then
import UIKit
import Kingfisher
import RxCocoa
import RxSwift

final class DetailImageView: DescendantView {
    
    private let disposeBag = DisposeBag()
    
    private lazy var imageView = UIImageView().then {
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
    }
    
    private lazy var logoutButton = UIButton().then {
        $0.titleLabel?.font = .systemFont(ofSize: 15)
        $0.setTitleColor(.white, for: .normal)
        $0.setTitle("Logout", for: .normal)
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
        Log.d("DetailImageView setupLayout()")
        
        addSubviews(imageView, logoutButton)
        
        imageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(300)
        }
        
        logoutButton.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(30)
            $0.width.equalTo(70)
        }
        
        
        imageView.kf.setImage(with: URL(string: "https://lastfm.freetls.fastly.net/i/u/300x300/bfb84f4aa2ac69a5ffa98c0406b8bf10.png"), options: [.transition(ImageTransition.fade(0.3))])
    }
    
    private func bindRx() {
        
        Log.d("bindRx")
        logoutButton.rx.tap.bind { [weak self] in
            Log.d("click logout button")
            guard let `self` = self else { return }
            self.delegate?.inputRelay.accept(DetailActionType.logout)
        }
        .disposed(by: disposeBag)
    }
}
