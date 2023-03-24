//
//  SearchTabView.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/23.
//

import UIKit
import RxSwift
import RxCocoa



final class SearchTabView: DescendantView {
    
    private let disposeBag = DisposeBag()
    private let items: [String:Int] = [DetailType.track.title : DetailType.track.searchIndex,
                                       DetailType.artist.title : DetailType.artist.searchIndex,
                                       DetailType.album.title : DetailType.album.searchIndex]
    private let types: [Int:DetailType] = [DetailType.track.searchIndex : DetailType.track,
                                       DetailType.artist.searchIndex : DetailType.artist,
                                       DetailType.album.searchIndex : DetailType.album,]
    private var currentSearchIndex = DetailType.track.searchIndex
    
    private lazy var buttonStackView = UIStackView().then {
        $0.spacing = 5
        $0.distribution = .fillEqually
        $0.alignment = .fill
        $0.axis = .horizontal
    }
    private lazy var emptyLabel = UILabel().then {
        $0.text = "검색 결과가 없습니다."
        $0.font = .boldSystemFont(ofSize: 15)
        $0.numberOfLines = 1
        $0.textColor = .white
    }
    private var buttons:[UIButton] = []
    private var tableViews:[UITableView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupLayout() {
       
        setupButtonStackView()
        setupTableView()
        
        addSubview(emptyLabel)
        
        emptyLabel.snp.makeConstraints {
            $0.centerY.centerX.equalToSuperview()
        }
        emptyLabel.isHidden = true
        
        showSelectedButton(tag: currentSearchIndex)
        showSelectedTableView(tag: currentSearchIndex)
    }
    
    
    private func setupButtonStackView() {
        
        addSubview(buttonStackView)
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        let sortedItem = items.sorted { $0.1 < $1.1 }
        for (key, value) in sortedItem {
            Log.d("button key:\(key), value:\(value)")
            let button = UIButton().then {
                $0.titleLabel?.font = .systemFont(ofSize: 15)
                $0.setTitleColor(.white, for: .normal)
                $0.setTitleColor(.gray, for: .selected)
                $0.setTitleColor(.gray, for: .highlighted)
                $0.setTitle(key, for: .normal)
                $0.tag = value
                $0.layer.borderWidth = 2
                $0.layer.borderColor = UIColor.white.cgColor
                $0.layer.cornerRadius = 8
            }
            buttons.append(button)
            
            button.rx.tap.bind { [weak self] in
                guard let `self` = self else { return }
                self.currentSearchIndex = button.tag
                self.showSelectedTableView(tag: button.tag)
                self.showSelectedButton(tag: button.tag)
            }
            .disposed(by: disposeBag)
            
            self.buttonStackView.addArrangedSubview(button)
        }
    }
    
    private func showSelectedButton(tag: Int) {
        for btn in self.buttons {
            if btn.tag == tag {
                btn.isSelected = true
                btn.layer.borderColor = UIColor.gray.cgColor
            } else {
                btn.isSelected = false
                btn.layer.borderColor = UIColor.white.cgColor
            }
        }
        
    }
    
    private func setupTableView() {
        let view = UIView()
        addSubview(view)
        view.snp.makeConstraints {
            $0.top.equalTo(buttonStackView.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        for (_, value) in items {
                        
            let tableView = UITableView(frame: .zero, style: .plain).then {
                $0.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
                $0.separatorInsetReference = .fromCellEdges
                $0.separatorStyle = .singleLine
                $0.separatorColor = .gray
                
                $0.tag = value
                $0.rowHeight = 70
                $0.backgroundColor = .black
                $0.bounces = true
                $0.showsVerticalScrollIndicator = true
                $0.contentInset = .zero
                $0.register(ListTableViewCell.self, forCellReuseIdentifier: ListTableViewCell.id)
            }
            
            view.addSubview(tableView)
            tableView.snp.makeConstraints {
                $0.directionalEdges.equalToSuperview()
            }
            
            tableView.rx.modelSelected(CommonCardModel.self)
                .subscribe(onNext: { [weak self] item in
                    guard let `self` = self else { return }
                    self.delegate?.inputRelay.accept(SearchActionType.tapItemForDetail(self.types[self.currentSearchIndex]!, item.title, item.subTitle))
                })
                .disposed(by: disposeBag)
            
            tableView.rx.contentOffset
                .subscribe({ [weak self] _ in
                    guard let `self` = self else { return }
                    if tableView.isNearBottomEdge() {
                        Log.d("click isNearBottomEdge")
//                        self.delegate?.inputRelay.accept(ListActionType.more)
                    }
                }).disposed(by: disposeBag)
            
            
            tableViews.append(tableView)
            
        }
    }
    
    private func showSelectedTableView(tag: Int) {
             
        for index in 0...tableViews.count-1 {
            Log.d("index:\(index), tag:\(tag)")
            
            // TODO 서버 응답에 따라 결과가 없는 테이블뷰는 결과 없음 표출
            if index == (tag) {
                tableViews[index].isHidden = false
            } else {
                tableViews[index].isHidden = true
            }
        }
    }
        
    @discardableResult
    func setupDI<T>(observable: Observable<(DetailType,[T])>) -> Self {
        
        if let observable = observable as? Observable<(DetailType, [CommonCardModel])> {
            bindTableView(observable: observable, type: .track)
            bindTableView(observable: observable, type: .artist)
            bindTableView(observable: observable, type: .album)
        }
        
        return self
    }
    
    private func bindTableView(observable: Observable<(DetailType, [CommonCardModel])>, type: DetailType) {
        
        observable
            .filter { ($0.0 as DetailType) == type }
            .map { $0.1 }
            .bind(to: tableViews[type.searchIndex].rx.items) {  tableView, _, element in
                if let cell = tableView.dequeueReusableCell(withIdentifier: ListTableViewCell.id) as? ListTableViewCell {
                    cell.prepare(
                        title: element.title,
                        subTitle: element.subTitle,
                        imageUrl: element.image?.isEmpty == true ? "" : element.image?[2].text)
                    cell.selectionStyle = .none
                    return cell
                }
                return UITableViewCell()
            }
            .disposed(by: disposeBag)
    }
}
