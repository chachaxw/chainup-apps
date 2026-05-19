//
//  EXSingleBtnFooter.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/2.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class SingleFooterBtnStyle : NSObject {
    var bg:UIColor = UIColor.ThemeView.highlight
    var titleColor:UIColor = UIColor.ThemeLabel.white
    var borderColor:UIColor?
    
}


class EXSingleBtnFooter: NibBaseView {
    @IBOutlet var footerBtn: EXFlatBtn!
    var style:SingleFooterBtnStyle = SingleFooterBtnStyle() {
        didSet {
            footerBtn.bgColor = style.bg
            footerBtn.setTitleColor(style.titleColor, for: .normal)
            if let border = style.borderColor {
                footerBtn.layer.borderColor = border.cgColor
                footerBtn.layer.borderWidth = 1.0
            }
        }
    }
    
    override func onCreate() {
        footerBtn.clearColors()
        self.style = SingleFooterBtnStyle()
    }
    
}
