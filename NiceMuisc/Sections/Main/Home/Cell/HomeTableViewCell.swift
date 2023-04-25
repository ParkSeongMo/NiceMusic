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
    private let titleFontSize = 18.0
    private let moreFontSize = 15.0
        
    private var items: [CommonCardModel] = []
    private var index: HomeIndex = .none
        
    private var action = PublishRelay<Any>()
    private var response = PublishRelay<[CommonCardModel]>()
    private let disposeBag = DisposeBag()
            
    private lazy var titleLabel = UILabel().then {
        $0.isSkeletonable = true
        $0.text = ""
        $0.font = .boldSystemFont(ofSize: titleFontSize)
        $0.numberOfLines = 1
        $0.textColor = .white
    }
    
    private lazy var moreLabel = UIButton().then {
        $0.isSkeletonable = true
        $0.titleLabel?.font = .systemFont(ofSize: moreFontSize)
        $0.setTitleColor(.gray, for: .normal)
        $0.setTitle(NSLocalizedString("common.showAll", comment: ""), for: .normal)
    }
              
    private lazy var moreImageView = UIImageView().then {
        $0.isSkeletonable = true
        $0.image = UIImage(
            systemName: "chevron.right",
            withConfiguration:
                UIImage.SymbolConfiguration(font: .systemFont(ofSize: moreFontSize)))
        $0.tintColor = .white
    }
    
    private lazy var collectionViewFlowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumLineSpacing = 28
        $0.minimumInteritemSpacing = 0
        $0.itemSize = .init(width: cellWidth, height: cellHeight)
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewFlowLayout).then {
        $0.isSkeletonable = true
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
        
        self.contentView.addSubviews(titleLabel, moreLabel, collectionView, moreImageView)
       
        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(10)
            $0.top.equalToSuperview().offset(30)
        }
        
        moreImageView.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.right.equalToSuperview().offset(-10)
        }
        
        moreLabel.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.right.equalTo(moreImageView.snp.left).offset(-5)
        }       
                
        collectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.left.equalToSuperview().offset(5)
            $0.right.equalToSuperview().offset(5)
            $0.bottom.equalToSuperview().offset(5)
        }
    }
    
    private func bindrx() {
        moreLabel.rx.tap
            .bind { [weak self] in
                guard let `self` = self else { return }
                self.action.accept(HomeActionType.tapAllForList(self.index))
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let `self` = self else { return }
                self.action.accept(HomeActionType.tapItemForDetail(
                    self.index.detailType,
                    self.items[indexPath.item].title,
                    self.items[indexPath.item].subTitle))
            })
            .disposed(by: disposeBag)
                
        response.bind(to: collectionView.rx.items(
            cellIdentifier: HomeCollectionViewCell.id,
            cellType: HomeCollectionViewCell.self)) {
                index, item, cell in
                cell.prepare(
                    title: item.title,
                    subTitle: item.subTitle,
                    rank: String(describing: index+1),
                    imageUrl: item.image?[3].text)
        }
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
        
        response.accept(self.items)
        
        collectionView.performBatchUpdates {
            collectionView.scrollsToTop = true
        }
    }
    
    func bindAction(reley: PublishRelay<Any>) {
        self.action = reley
    }
}
