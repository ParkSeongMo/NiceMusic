//
//  LoadChangeAction.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/17.
//

import Foundation
import UIKit
import SnapKit
import Then


enum LoadChangeAction {
    case none       // None
    case loaderStart
    case loaderStop
}

class LoadingIndicator {
    static func showLoading() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.last else { return }

            let loadingIndicatorView: LoadingIndicatorView
            if let existedView = window.subviews.first(where: { $0 is LoadingIndicatorView } ) as? LoadingIndicatorView {
                loadingIndicatorView = existedView
            } else {
                loadingIndicatorView = LoadingIndicatorView(frame: window.frame)
                window.addSubview(loadingIndicatorView)
            }

            loadingIndicatorView.startAnimating()
        }
    }

    static func hideLoading() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.last else { return }
            window.subviews
                .filter { $0 is LoadingIndicatorView }
                .forEach({ indicatorView in
                    guard let indicatorView = indicatorView as? LoadingIndicatorView else {
                        return
                    }
                    indicatorView.stopAnimating()
                    indicatorView.removeFromSuperview()
                })
        }
    }
}


class LoadingIndicatorView: UIView {
        
    private let loaderSize = 40
    
    private lazy var indicatorImageView = UIImageView().then {
        $0.frame = CGRect(
            x: Int(self.center.x) - loaderSize/2,
            y: Int(self.center.y) - loaderSize/2,
            width: loaderSize,
            height: loaderSize)
        $0.image = #imageLiteral(resourceName: "cm_ic_loading")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(indicatorImageView)
    }
    
    func startAnimating() {
        let rotation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = Double.pi * 2 //한바퀴
        rotation.duration = 0.7 // 한바퀴 도는데 걸리는 시간
        rotation.repeatCount = Float.infinity // 반복 횟수 = infinity(무한대)
        indicatorImageView.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    func stopAnimating() {
        indicatorImageView.layer.removeAllAnimations()
    }
}
