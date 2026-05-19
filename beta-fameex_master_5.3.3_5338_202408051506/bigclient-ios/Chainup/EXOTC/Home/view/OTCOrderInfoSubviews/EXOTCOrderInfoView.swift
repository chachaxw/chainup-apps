//
//  EXOTCOrderInfoView.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/28.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
//Copy/QR code/No
enum OTCOrderInfoActionType {
    case actionCopy
    case actionQRCode
    case actionContact
    case none
}

class OTCOrderInfoModel:NSObject {
    
    var title:String = ""
    var titleColor:UIColor = UIColor.ThemeLabel.colorMedium
    var value:String = ""
    var valueColor:UIColor = UIColor.ThemeLabel.colorLite
    var actionType:OTCOrderInfoActionType = .none
    var titleIcon:String = ""
    var valueIcon:String = ""
    
    static func getModel(title:String,value:String) ->OTCOrderInfoModel{
        let model = OTCOrderInfoModel()
        model.title = title
        model.value = value
        return model
    }
}

class EXOTCOrderInfoView: NibBaseView {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var actionBtn: UIButton!
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var rightIconWidth: NSLayoutConstraint!
    
    override func onCreate() {
        rightIconWidth.constant = 0
    }
    
    func bindInfoWith(model:OTCOrderInfoModel) {
        titleLabel.text = model.title
        titleLabel.textColor = model.titleColor
        contentLabel.text = model.value
        contentLabel.textColor = model.valueColor
    }
}

