//
//  EXFlatBtn.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/20.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXFlatBtn: EXButton {
    
    var bgColor:UIColor = UIColor.ThemeView.highlight {
        didSet {
            self.color = bgColor
            self.highlightedColor = bgColor.overlayWhite()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        setNeedsDisplay()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
        setNeedsDisplay()
    }
    
    fileprivate func configure() {
        self.cornerRadius = 0
        self.bgColor = UIColor.ThemeView.highlight
        self.setTitleColor(UIColor.white, for: .normal)
        adjustsImageWhenDisabled = false
        adjustsImageWhenHighlighted = false
    }
    
}
