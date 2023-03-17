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


final class DetailView: UIView, SubViewDI {
    
    var inputRelay = RxRelay.PublishRelay<Any>()
    var outputRelay = RxRelay.PublishRelay<Any>()
    
    private let disposeBag = DisposeBag()
    
    var detailType: DetailType = .artist
    
    
    private lazy var scrollView = UIScrollView().then {
        $0.isScrollEnabled = true
        $0.alwaysBounceVertical = true
        $0.showsVerticalScrollIndicator = true
        $0.showsHorizontalScrollIndicator = false
        $0.contentInsetAdjustmentBehavior = .never
    }
    
    private lazy var scrollContainerView = UIView()
       
    private lazy var stackView = UIStackView().then {
        $0.backgroundColor = .red
        $0.distribution = .equalSpacing
        $0.alignment = .fill
        $0.axis = .vertical
    }
    
    
    func applySubviewTags() {
    }
        
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func setupLayout() {
                
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.leading.top.right.bottom.equalToSuperview()
        }
        scrollView.addSubview(scrollContainerView)
        scrollContainerView.snp.makeConstraints { make in
            make.leading.top.right.bottom.equalToSuperview()
        }
        scrollContainerView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.top.right.bottom.equalToSuperview()
        }
        
        stackView.addArrangedSubview(imageView)
        
        
    }
    
    @discardableResult
    func setupDI<T>(observable: Observable<T>) -> Self {
                    
                
        return self
    }
        
}
