//
//  EXIntroduceItem.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/24.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXIntroduceItem: NibBaseView {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    var showCopy:Bool = false
    var onClick:((EXIntroduceItem)->())?
//    typealias ZoomActionBlock = () -> ()
//    var onZoomActionCallback : ZoomActionBlock?

    
    override func onCreate() {
        titleLabel.font = UIFont.ThemeFont.BodyRegular
        contentLabel.font = UIFont.ThemeFont.BodyRegular
        titleLabel.textColor = UIColor.ThemekLine.labcolorMedium
        contentLabel.textColor = UIColor.ThemekLine.labcolorLite
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.onTapGesture))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func onTapGesture() {
        self.onClick?(self)
    }
    
    func bind(title:String,value:String,showCopy:Bool = false){
        self.showCopy = showCopy
        titleLabel.text = title
        if value.count > 0 {
            contentLabel.text = value
        }else {
            contentLabel.text = "--"
        }
    }
}
