//
//  UIWindow+.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/28.
//

import UIKit

extension UIWindow {
    public var visibleViewController: UIViewController? {
          return self.visibleViewControllerFrom(vc: self.rootViewController)
      }
    
    public func visibleViewControllerFrom(vc: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
           if let nc = vc as? UINavigationController {
               return self.visibleViewControllerFrom(vc: nc.visibleViewController)
           } else if let tc = vc as? UITabBarController {
               return self.visibleViewControllerFrom(vc: tc.selectedViewController)
           } else {
               if let pvc = vc?.presentedViewController {
                   return self.visibleViewControllerFrom(vc: pvc)
               } else {
                   return vc
               }
           }
       }
}

