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
    
    var subViews: [UIView] = []
    
    private lazy var scrollView = UIScrollView().then {
        $0.isScrollEnabled = true
        $0.alwaysBounceVertical = true
        $0.showsVerticalScrollIndicator = true
        $0.showsHorizontalScrollIndicator = false
    }
           
    private lazy var stackView = UIStackView().then {
        $0.backgroundColor = .red
        $0.distribution = .equalSpacing
        $0.alignment = .fill
        $0.axis = .vertical
    }
    
    private lazy var detailImageView = DetailImageView()
           
    
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
    }
    
    
    private func setupSubviews() {
        subViews = [
            detailImageView
        ]
    }
    
    @discardableResult
    func setupDI<T>(observable: Observable<T>) -> Self {
                                    
        return self
    }        
}
