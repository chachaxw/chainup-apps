//
//  EXContractRowView.swift
//  Chainup
//
//  Created by liuxuan on 2019/7/11.
//  Copyright © 2019 zewu wang. All rights reserved.
//

import UIKit

class EXRowModel:NSObject {
    var title:String = ""
    var titleColor:UIColor = UIColor.ThemeLabel.colorMedium
    var action:String = ""
    var actionColor:UIColor = UIColor.ThemeLabel.colorLite
    var titleFont:UIFont = UIFont.ThemeFont.BodyRegular
    var actionFont:UIFont =  UIFont.ThemeFont.BodyRegular
}

class EXContactRowView: NibBaseView {
    
    @IBOutlet var rowTitle: UILabel!
    @IBOutlet var rowActionBtn: UIButton!
    
    typealias ActionBtnCallback = () -> ()
    var actionCallback : ActionBtnCallback?
    
    func configRows(_ rowModel:EXRowModel) {
        rowTitle.text = rowModel.title
        rowTitle.font = rowModel.titleFont
        rowTitle.textColor = rowModel.titleColor
        rowActionBtn.setTitle(rowModel.action, for: .normal)
        rowActionBtn.setTitleColor(rowModel.actionColor, for: .normal)
        rowActionBtn.titleLabel?.font = rowModel.actionFont
    }
    
    @IBAction func actionBtnDidClick(_ sender: Any) {
        actionCallback?()
    }
    
}
