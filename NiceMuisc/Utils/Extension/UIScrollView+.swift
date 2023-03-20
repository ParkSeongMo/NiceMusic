//
//  UIScrollView+.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/16.
//

import UIKit

extension UIScrollView {
    func isNearBottomEdge(edgeOffset: CGFloat = 20.0) -> Bool {
        return self.contentOffset.y + self.frame.size.height + edgeOffset > self.contentSize.height
    }
}
