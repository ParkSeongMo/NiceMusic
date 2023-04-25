//
//  ListTableViewCell.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/16.
//

import Foundation
import UIKit
import Kingfisher

final class ListTableViewCell: UITableViewCell {
    
    static let id = "HomeTableViewCell"
    
    private lazy var imageview = UIImageView().then {
        $0.isSkeletonable = true
        $0.layer.cornerRadius = 10
        $0.contentMode = .scaleAspectFill
    }
    
    private lazy var titleLabel = UILabel().then {
        $0.isSkeletonable = true
        $0.font = .systemFont(ofSize: 15)
        $0.numberOfLines = 1
        $0.textColor = .white
    }
    
    private lazy var subTitleLabel = UILabel().then {
        $0.isSkeletonable = true
        $0.font = .systemFont(ofSize: 12)
        $0.numberOfLines = 1
        $0.textColor = .white
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
                
        self.backgroundColor = .black
        
        self.contentView.addSubviews(imageview, titleLabel, subTitleLabel)
                
        imageview.snp.makeConstraints {
           $0.left.equalToSuperview().offset(10)
           $0.top.equalToSuperview()
           $0.height.width.equalTo(70)
        }
        
        titleLabel.snp.makeConstraints {
           $0.left.equalTo(imageview.snp.right).offset(5)
           $0.top.equalToSuperview().offset(5)
           $0.right.equalToSuperview().offset(5)
        }
        
        subTitleLabel.snp.makeConstraints {
           $0.left.equalTo(titleLabel.snp.left)
           $0.top.equalTo(titleLabel.snp.bottom).offset(5)
           $0.right.equalToSuperview().offset(5)
        }
    }
        
    override func prepareForReuse() {
        super.prepareForReuse()
        prepare(title: nil, subTitle: nil, imageUrl: nil)
    }
    
    func prepare(title: String?, subTitle: String?, imageUrl: String?) {
        self.titleLabel.text = title
        self.subTitleLabel.text = subTitle
        if let url = imageUrl {
            self.imageview.kf.setImage(with: URL(string: url), options: [.transition(ImageTransition.fade(0.3))])
        }
    }
    
}
