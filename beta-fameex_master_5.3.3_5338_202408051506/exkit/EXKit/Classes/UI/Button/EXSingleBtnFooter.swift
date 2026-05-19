//
//  EXSingleBtnFooter.swift
//  Chainup
//
//  Created by liuxuan on2020/4/2.
//  Copyright ©2020 zewu wang. All rights reserved.
//

import UIKit

public class SingleFooterBtnStyle : NSObject {
    public var bg:UIColor = UIColor.ThemeView.highlight
    public var titleColor:UIColor = UIColor.ThemeLabel.white
    public var borderColor:UIColor?
    
}

public class EXSingleBtnFooter: NibBaseView {
    @IBOutlet public var footerBtn: EXFlatBtn!
    public var style:SingleFooterBtnStyle = SingleFooterBtnStyle() {
        didSet {
            footerBtn.bgColor = style.bg
            footerBtn.setTitleColor(style.titleColor, for: .normal)
            if let border = style.borderColor {
                footerBtn.layer.borderColor = border.cgColor
                footerBtn.layer.borderWidth = 1.0
            }
        }
    }
    
    public override func onCreate() {
        footerBtn.clearColors()
        self.style = SingleFooterBtnStyle()
    }
    
    @IBAction public func onFooterBtnClick(_ sender: Any) {
        
    }
    
}
