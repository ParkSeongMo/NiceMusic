//
//  DetailImageView.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/17.
//

import SnapKit
import Then
import UIKit

final class DetailImageView: UIView {
    
    private lazy var imageView = UIImageView().then {
        $0.backgroundColor = .blue
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
        
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(300)
        }
    }
}
