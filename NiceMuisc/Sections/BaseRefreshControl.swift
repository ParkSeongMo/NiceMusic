//
//  BaseRefreshControl.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/04/06.
//

import UIKit


protocol BaseRefreshContrl {
    func getRefreshControl(_ selector: Selector) -> UIRefreshControl
}


extension BaseRefreshContrl {
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
