//
//  EXKLineScaleView.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/18.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXKLineScaleView: NibBaseView {

    @IBOutlet var bgBtn: UIButton!
    @IBOutlet var scaleBtn: EXButton!
    @IBOutlet var identifer: UIView!
    var identiferKey:String = ""
    
    override func onCreate() {
        scaleBtn.titleLabel?.minimumRegular()
        scaleBtn.clearColors()
        scaleBtn.setTitleColor(UIColor.ThemekLine.labcolorMedium, for: .normal)
        scaleBtn.setTitleColor(UIColor.ThemekLine.labcolorLite, for: .selected)
        identifer.backgroundColor = UIColor.ThemekLine.viewHighlight
    }
    
    func setTitle(title :String ) {
        scaleBtn.setTitle(title, for: .normal)
    }
    
    func setSelected(isSelect:Bool) {
        scaleBtn.isSelected = isSelect
        identifer.isHidden = !isSelect
    }
    
}
