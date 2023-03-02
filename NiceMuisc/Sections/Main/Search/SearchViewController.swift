//
//  SearchViewController.swift
//  NiceMuisc
//
//  Created by Seongmo Park on 2023/03/02.
//

import UIKit

class SearchViewController: UIViewController {
    
    private let viewModel:SearchViewModel
    
    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("HomeViewController viewDidLoad()")
        setupLayout()
    }
    
    private func setupLayout() {
        self.view.backgroundColor = .brown
    }
}
