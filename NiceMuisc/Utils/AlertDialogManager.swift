//
//  AlertDialogManager.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/28.
//

import UIKit
import RxRelay

enum AlertAction {
    case cancelBtnTap
    case okBtnTap
}

class AlertDialogManager {
    
    static let shared = AlertDialogManager()
    
    var observable: PublishRelay<AlertAction>?
    
    func showAlertDialog(title: String, message: String, observable: PublishRelay<AlertAction>) {
        self.observable = observable
                
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let alertDeleteBtn = UIAlertAction(title: "Cancel", style: .destructive) { (action) in
            self.observable?.accept(.cancelBtnTap)
        }
        
        let alertSuccessBtn = UIAlertAction(title: "OK", style: .default) { (action) in
            self.observable?.accept(.okBtnTap)
        }
        
        alert.addAction(alertDeleteBtn)
        alert.addAction(alertSuccessBtn)
        
        
        if let vc = UIApplication.shared.keyWindow?.visibleViewController as? UIViewController {
            vc.present(alert, animated: true, completion: nil)
        }
    }
    
    func showAlertDialog(observable: PublishRelay<AlertAction>) {
        showAlertDialog(title: "서버 연동 에러",
                        message: "데이터를 가져오는 중 오류가 발생했습니다. 재시도 하시겠습니다",
                        observable: observable)
    }
}
