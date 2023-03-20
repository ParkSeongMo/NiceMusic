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
import RxRelay
import RxSwift

final class HomeTableViewCell: UITableViewCell {
    
    static let id = "HomeTableViewCell"
    private let cellHeight = 200
    private let cellWidth = 150
        
    private var items: [CommonCardModel] = []
    private var index: HomeIndex = .none
        
    private var action = PublishRelay<Any>()
    private let disposeBag = DisposeBag()
            
    private lazy var titleLabel = UILabel().then {
        $0.text = "title"
        $0.font = .boldSystemFont(ofSize: 18)
        $0.numberOfLines = 1
        $0.textColor = .white
    }
    
    private lazy var moreLabel = UIButton().then {
        $0.titleLabel?.font = .systemFont(ofSize: 15)
        $0.setTitleColor(.gray, for: .normal)
        $0.setTitle("전체보기 >", for: .normal)
    }
    
    private lazy var collectionViewFlowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumLineSpacing = 28
        $0.minimumInteritemSpacing = 0
        $0.itemSize = .init(width: cellWidth, height: cellHeight)
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewFlowLayout).then {
        $0.dataSource = self
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
        bindrx()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func setupLayout() {
                        
        backgroundColor = .black
        
        self.contentView.addSubviews(titleLabel, moreLabel, collectionView)
       
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(30)
        }
                
        moreLabel.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.right.equalToSuperview().offset(-10)
        }
                
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(5)
        }
    }
    
    private func bindrx() {
        moreLabel.rx.tap
            .bind { [weak self] in
                guard let `self` = self else { return }
                self.action.accept(HomeActionType.tapAllforList(self.index))
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let `self` = self else { return }
                self.action.accept(HomeActionType.tapItemForDetail(
                    self.parsingHomeIndexToDetailType(index: self.index),
                    self.items[indexPath.item].title,
                    self.items[indexPath.item].subTitle))
            })
            .disposed(by: disposeBag)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.prepare(index: .none, items: [])
    }
    
    func prepare(index: HomeIndex, items: [CommonCardModel]?) {
        
        self.index = index
        self.titleLabel.text = index.title
        
        self.items = items ?? [CommonCardModel]()
//        if let items = items {
//            self.items = items
//        } else {
//            self.items = [CommonCardModel]()
//        }
        collectionView.reloadData()
        collectionView.performBatchUpdates {
            collectionView.scrollsToTop = true
        }
    }
    
    func bindAction(reley: PublishRelay<Any>) {
        self.action = reley
    }
    
    private func parsingHomeIndexToDetailType(index: HomeIndex) -> DetailType {
        switch index {
        case .topArtist, .topLocalArtist:
            return .artist
        case .topTrack, .topLocalTrack:
            return .track
        default:
            return .none
        }
    }
}

extension HomeTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {        
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
