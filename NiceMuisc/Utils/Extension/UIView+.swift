//
//  UIView+.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/20.
//

import UIKit

extension UIView {
    func addSubviews(_ views:UIView...) {
        for view in views {
            addSubview(view)
        }
    }
}
