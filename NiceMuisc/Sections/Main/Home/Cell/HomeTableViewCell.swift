//
//  HomeTableViewCell.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/14.
//

import Foundation
import UIKit
import SnapKit
import Then

final class HomeTableViewCell: UITableViewCell {
    
    static let id = "HomeTableViewCell"
    private let cellHeight = 200
    private let cellWidth = 150
        
    private var items: [CommonCardModel] = []
    
    lazy var titleLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 18)
        $0.numberOfLines = 1
        $0.textColor = .white
    }
    
    private lazy var moreLabel = UILabel().then {
        $0.text = "전체보기 >"
        $0.font = .systemFont(ofSize: 15)
        $0.numberOfLines = 1
        $0.textColor = .gray
    }
    
    private lazy var collectionViewFlowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumLineSpacing = 28
        $0.minimumInteritemSpacing = 0
        $0.itemSize = .init(width: cellWidth, height: cellHeight)
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewFlowLayout).then {
        $0.isScrollEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = true
        $0.contentInset = .zero
        $0.backgroundColor = .black
        $0.clipsToBounds = true
        $0.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: HomeCollectionViewCell.id)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupLayout() {
        
        backgroundColor = .black
        
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(30)
        }
                
        self.contentView.addSubview(moreLabel)
        moreLabel.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.right.equalToSuperview().offset(-10)
        }
                
        self.collectionView.dataSource = self
        self.contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(5)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.prepare(name: nil, items: [])
    }
    
    func prepare(name: String?, items: [CommonCardModel]?) {
        
//        print("HomeTableViewCell prepare \(name)")
        
//        guard let name = name else { return }
        self.titleLabel.text = name
        if let items = items {
            self.items = items
        } else {
            self.items = [CommonCardModel]()
        }
        collectionView.reloadData()
        collectionView.performBatchUpdates {
            collectionView.scrollsToTop = true
        }
    }
    
    
    
}

extension HomeTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        print("HomeTableViewCell count \(items.count)")
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
//        print("HomeTableViewCell title \(items[indexPath.row].title)")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCollectionViewCell.id, for: indexPath) as! HomeCollectionViewCell
        cell.prepare(
            title: items[indexPath.row].title,
            subTitle: items[indexPath.row].subTitle,
            rank: String(describing: indexPath.row+1),
            imageUrl: items[indexPath.row].image?[3].text)
        return cell
    }
}

extension HomeTableViewCell: UICollectionViewDelegate {

}


extension HomeTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 200)
    }
}
