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
    private let items = [DetailType.track, DetailType.artist, DetailType.album]
    
    private var currentSearchType = DetailType.track
    private var isHiddenEmptyView = [DetailType.track : true,
                                   DetailType.artist : true,
                                   DetailType.album : true]
    
    private lazy var buttonStackView = UIStackView().then {
        $0.spacing = 5
        $0.distribution = .fillEqually
        $0.alignment = .fill
        $0.axis = .horizontal
    }
    private lazy var emptyLabel = UILabel().then {
        $0.text = NSLocalizedString("search.emptySearchResult", comment: "")
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
       
        setupButtonStackViews()
        setupTableViews()
        
        addSubview(emptyLabel)
        
        emptyLabel.snp.makeConstraints {
            $0.centerY.centerX.equalToSuperview()
        }
        emptyLabel.isHidden = true
        
        let currentTag = currentSearchType.searchIndex
        showSelectedButton(tag: currentTag)
        showSelectedTableView(tag: currentTag)
        showEmptyView(index: currentTag)
    }
    
    
    private func setupButtonStackViews() {
        
        addSubview(buttonStackView)
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        for detailType in items {
            let button = setupTabButtonLayout(detailType: detailType)
            buttons.append(button)
            bindTabButtonRx(button: button)
            self.buttonStackView.addArrangedSubview(button)
        }
    }
    
    private func setupTabButtonLayout(detailType: DetailType) -> UIButton {
        let button = UIButton().then {
            $0.titleLabel?.font = .systemFont(ofSize: 15)
            $0.setTitleColor(.white, for: .normal)
            $0.setTitleColor(.gray, for: .selected)
            $0.setTitleColor(.gray, for: .highlighted)
            $0.setTitle(detailType.title, for: .normal)
            $0.tag = detailType.searchIndex
            $0.layer.borderWidth = 2
            $0.layer.borderColor = UIColor.white.cgColor
            $0.layer.cornerRadius = 8
        }
        
        return button
    }
    
    private func bindTabButtonRx(button: UIButton) {
        button.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            self.currentSearchType = self.parsingSearchIndexToDetailType(searchIndex: button.tag)
            self.showSelectedTableView(tag: button.tag)
            self.showSelectedButton(tag: button.tag)
            self.showEmptyView(index: button.tag)
        }
        .disposed(by: disposeBag)
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
    
    private func setupTableViews() {
        let view = UIView()
        
        addSubview(view)
        
        view.snp.makeConstraints {
            $0.top.equalTo(buttonStackView.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        for _ in items {
            let tableView = setupTableViewLayout(parentView: view)
            bindTableViewRx(tableView: tableView)
            tableViews.append(tableView)
        }
    }
    
    private func setupTableViewLayout(parentView: UIView) -> UITableView{
        let tableView = UITableView(frame: .zero, style: .plain).then {
            $0.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            $0.separatorInsetReference = .fromCellEdges
            $0.separatorStyle = .singleLine
            $0.separatorColor = .gray
            
            $0.rowHeight = 70
            $0.backgroundColor = .black
            $0.bounces = true
            $0.showsVerticalScrollIndicator = true
            $0.contentInset = .zero
            $0.register(ListTableViewCell.self, forCellReuseIdentifier: ListTableViewCell.id)
        }
        
        parentView.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.directionalEdges.equalToSuperview()
        }
                
        return tableView
    }
    
    private func bindTableViewRx(tableView: UITableView) {
        tableView.rx.modelSelected(CommonCardModel.self)
            .subscribe(onNext: { [weak self] item in
                guard let `self` = self else { return }
                self.delegate?.inputRelay.accept(
                    SearchActionType.tapItemForDetail(
                        self.currentSearchType,
                        item.title,
                        item.subTitle))
            })
            .disposed(by: disposeBag)
        
        tableView.rx.contentOffset
            .subscribe({ [weak self] _ in
                guard let `self` = self else { return }
                if tableView.isNearBottomEdge() {
                    self.delegate?.inputRelay.accept(
                        SearchActionType.more(self.currentSearchType))
                }
            }).disposed(by: disposeBag)
    }
    
    private func showSelectedTableView(tag: Int) {
        for index in 0...tableViews.count-1 {
            tableViews[index].isHidden = (index != (tag))
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
            .map(\.1)
            .subscribe(onNext: { [weak self] items in
                guard let `self` = self else { return }
                self.isHiddenEmptyView[type] = items.count > 0
                self.showEmptyView(index: type.searchIndex)
            })
            .disposed(by: disposeBag)
        
        observable
            .filter { ($0.0 as DetailType) == type }
            .map(\.1)
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
    
   private func showEmptyView(index: Int) {
       if index == currentSearchType.searchIndex {
           emptyLabel.isHidden = isHiddenEmptyView[currentSearchType]!
       }
    }
    
    private func parsingSearchIndexToDetailType(searchIndex: Int) -> DetailType {
        switch searchIndex{
        case DetailType.track.searchIndex:
            return DetailType.track
        case DetailType.artist.searchIndex:
            return DetailType.artist
        case DetailType.album.searchIndex:
            return DetailType.album
        default:
            return DetailType.none
        }
    }
}
