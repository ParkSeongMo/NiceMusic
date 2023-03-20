//
//  HomeCollectionViewCell.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/14.
//

import Foundation
import UIKit
import Kingfisher

final class HomeCollectionViewCell: UICollectionViewCell {
    
    static let id = "HomeCollectionViewCell"    
    
    private lazy var imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    
    private lazy var titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 15)
        $0.numberOfLines = 1
        $0.textColor = .white
    }
    
    private lazy var subTitleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12)
        $0.numberOfLines = 1
        $0.textColor = .white
    }
    
    private lazy var rankLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 25)
        $0.numberOfLines = 1
        $0.textColor = .white
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
                
        self.contentView.addSubviews(imageView, titleLabel, subTitleLabel, rankLabel)               
        imageView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalToSuperview()
            $0.right.equalToSuperview()
            $0.height.equalTo(150)
            $0.width.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(5)
            $0.top.equalTo(imageView.snp.bottom).offset(5)
            $0.right.equalToSuperview().offset(-25)
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(5)
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.right.equalToSuperview().offset(-25)
        }
        
        rankLabel.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-5)
            $0.bottom.equalTo(subTitleLabel.snp.bottom)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        prepare(title: nil, subTitle: nil, rank: nil, imageUrl: nil)
    }
    
    func prepare(title: String?, subTitle: String?, rank: String?, imageUrl: String?) {
        self.titleLabel.text = title
        self.subTitleLabel.text = subTitle
        self.rankLabel.text = rank
        if let url = imageUrl {
            self.imageView.kf.setImage(with: URL(string: url), options: [.transition(ImageTransition.fade(0.3))])
        }
    }
}
