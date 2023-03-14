//
//  HomeView.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/02.
//

import UIKit

final class HomeView: UIView {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout() 
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        backgroundColor = .yellow
    }
}
