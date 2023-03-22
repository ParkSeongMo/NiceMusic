//
//  DetailView.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/17.
//

import Foundation
import RxSwift
import RxRelay
import UIKit


final class DetailView: BaseSubView {
        
    var detailType: DetailType = .artist
    
    var subViews: [DescendantView] = [] {
        willSet {
            newValue.forEach {
                $0.delegate = self
            }
        }
    }
    
    private lazy var scrollView = UIScrollView().then {
        $0.isScrollEnabled = true
        $0.alwaysBounceVertical = true
        $0.showsVerticalScrollIndicator = true
        $0.showsHorizontalScrollIndicator = false
    }
           
    private lazy var stackView = UIStackView().then {
        $0.distribution = .equalSpacing
        $0.alignment = .fill
        $0.axis = .vertical
    }
    
    private lazy var detailImageView = DetailImageView()
    private lazy var infoView = DetailInfoView()
    private lazy var trackView = DetailTrackView()
    private lazy var descView = DetailDescView()
              
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupLayout()        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
             
        addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.width.equalToSuperview()
        }
        
        subViews.forEach {
            stackView.addArrangedSubview($0)
        }
        
        if detailType != .album {
            trackView.isHidden = true
        }
    }
        
    private func setupSubviews() {
        subViews = [
            detailImageView,
            infoView,
            trackView,
            descView
        ]
    }
    
    
    @discardableResult
    func setupDI<T>(generic: PublishRelay<T>) -> Self {
        if let generic = generic as? PublishRelay<DetailActionType> {
            inputRelay.compactMap { $0 as? DetailActionType }
                .bind(to: generic)
                .disposed(by: disposeBag)
        }
        
        return self
    }
    
    @discardableResult
    func setupDI<T>(observable: Observable<T>) -> Self {
                                    
        if let observable = observable as? Observable<DetailModel> {
            observable.subscribe(onNext: { [weak self] element in
                self?.outputRelay.accept(element)
            })
            .disposed(by: disposeBag)
        }
        return self
    }        
}
