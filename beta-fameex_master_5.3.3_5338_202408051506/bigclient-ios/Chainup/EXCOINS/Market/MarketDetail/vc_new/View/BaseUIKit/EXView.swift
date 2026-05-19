//
//  EXView.swift
//  Chainup
//
//  Created by youbin on 2023/6/14.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXView: UIView, EXViewProtocol {
    
    required init(viewModel: EXViewModelProtocol?) {
        super.init(frame: .zero)
        setupView()
        bindViewModel()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///Add child controls and Layout layout
    func setupView() {
        
    }
    
    ///Bind Response Event
    func bindViewModel() {
        
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

