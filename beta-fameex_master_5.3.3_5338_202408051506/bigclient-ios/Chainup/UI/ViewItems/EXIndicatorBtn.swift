//
//  EXIndicatorBtn.swift
//  Chainup
//
//  Created by liuxuan on 2023/12/16.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXIndicatorBtn: UIButton {
    
    lazy var indicator:UIView = {
        let indicator = UIView.init()
        indicator.backgroundColor = UIColor.ThemeView.highlight
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configIndicator()
    }
    
    func configIndicator() {
        self.addSubview(indicator)
        indicator.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.width.equalTo(20)
            make.height.equalTo(3)
            make.centerX.equalToSuperview()
        }
        indicator.isHidden = true
    }
    
    override var isSelected: Bool {
        didSet {
            indicator.isHidden = !isSelected
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configIndicator()
    }
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
