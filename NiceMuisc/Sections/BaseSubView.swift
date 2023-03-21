//
//  BaseSubView.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/21.
//

import RxRelay
import RxSwift
import Then
import UIKit

class BaseSubView: UIView, SubViewDI {
    
    var inputRelay = PublishRelay<Any>()
    var outputRelay = PublishRelay<Any>()
    
    let disposeBag = DisposeBag()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupDI(loadChanger: Observable<LoadChangeAction>) {
        loadChanger
            .subscribe { element in
                switch element {
                case .loaderStart:
                    LoadingIndicator.showLoading()
                case .loaderStop:
                    LoadingIndicator.hideLoading()
                default:
                    return
                }
            }
            .disposed(by: disposeBag)
    }
}

extension BaseSubView {
    func getRefreshControl(_ selector: Selector) -> UIRefreshControl {
        
        let refreshControl = UIRefreshControl()
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]
        refreshControl.attributedTitle = NSAttributedString(string: "당겨서 새로고침", attributes: attributes)
        refreshControl.addTarget(self, action: selector, for: .valueChanged)
        refreshControl.tintColor = .white
        
        return refreshControl
    }
}

