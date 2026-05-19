//
//  EXDropMenuBtn.swift
//  Chainup
//
//  Created by liuxuan on 2023/10/16.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXDropMenuBtn: UIButton {
    
    override var isSelected: Bool {
        willSet {
        }
        
        didSet {
            self.backgroundColor = isSelected ? UIColor.ThemekLine.viewBg : UIColor.ThemekLine.viewBgTab
            self.layer.borderColor = isSelected ? UIColor.ThemekLine.viewHighlight.cgColor : UIColor.ThemekLine.viewBg.cgColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configBtns()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configBtns()
    }
    
    func configBtns() {
        self.titleLabel?.font = UIFont.ThemeFont.SecondaryRegular
        self.backgroundColor = UIColor.ThemekLine.viewBgTab
        self.layer.cornerRadius = 4
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.ThemekLine.viewBg.cgColor
        self.setTitleColor(UIColor.ThemekLine.labcolorMedium, for: .normal)
        self.setTitleColor(UIColor.ThemekLine.labcolorHighlight, for: .selected)
    }
    
}
