//
//  ActivityIndicatorView.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/17.
//

import RxCocoa
import RxSwift
import Then
import UIKit

class BaseViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    lazy var activityIndicator = UIActivityIndicatorView().then {
        $0.frame = CGRect(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.size.width,
            height: UIScreen.main.bounds.size.height)
        $0.center = self.view.center
        $0.color = .white
        $0.style = .large
        $0.hidesWhenStopped = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(activityIndicator)
    }
    
    func startActivityIndicator() {
        if !view.isDescendant(of: activityIndicator) {
            view.bringSubviewToFront(activityIndicator)
        }
        activityIndicator.startAnimating()
    }
    
    func stopActivityIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func setupLoadChager(observable: Observable<LoadChangeAction>) {
        observable
            .subscribe { [weak self] element in
                guard let `self` = self else { return }
                switch element {
                case .loaderStart:
                    self.startActivityIndicator()
                case .loaderStop:
                    self.stopActivityIndicator()
                default:
                    return
                }
            }
            .disposed(by: disposeBag)
    }
}
