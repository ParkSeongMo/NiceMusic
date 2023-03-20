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

final class DetailImageView: UIView {
    
    private lazy var imageView = UIImageView().then {
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        Log.d("DetailImageView setupLayout()")
        
        addSubview(imageView)
        
        imageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(300)
        }
        
        imageView.kf.setImage(with: URL(string: "https://lastfm.freetls.fastly.net/i/u/300x300/bfb84f4aa2ac69a5ffa98c0406b8bf10.png"), options: [.transition(ImageTransition.fade(0.3))])
    }
}
