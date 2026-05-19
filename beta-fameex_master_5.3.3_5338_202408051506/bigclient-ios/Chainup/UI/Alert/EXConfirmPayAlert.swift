//
//  EXConfirmPayAlert.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/1.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXConfirmPayAlertModel :NSObject {
    @objc var title :String = ""
    @objc var titleColor :UIColor = UIColor.ThemeLabel.colorMedium
    @objc var value :String = ""
    @objc var valueColor :UIColor = UIColor.ThemeLabel.colorLite
}

class EXConfirmPayAlert: NibBaseView {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var payStacks: UIStackView!
    @IBOutlet var positiveBtn: EXButton!
    @IBOutlet var passiveBtn: EXButton!
    
    typealias AlertCallback = (Int) -> ()
    var alertCallback : AlertCallback?
    
    override func onCreate() {
        positiveBtn.clearColors()
        passiveBtn.clearColors()
        positiveBtn.setTitleColor(UIColor.ThemeView.highlight, for: .normal)
        passiveBtn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)

    }
    
    @IBAction func onBtnClicked(_ sender: EXButton) {
        EXAlert.dismiss()
        alertCallback?(sender.tag)
    }
    
    func configAlert(title:String,
                     message:String,
                     confirmPayInfo:[EXConfirmPayAlertModel],
                     passiveBtnTitle:String = "common_text_btnCancel".localized(),
                     positiveBtnTitle:String="common_text_btnConfirm".localized()) {
        titleLabel.text = title
        messageLabel.text = message
        positiveBtn.setTitle(positiveBtnTitle, for: .normal)
        passiveBtn.setTitle(passiveBtnTitle, for: .normal)

        for (idx,itemView)  in payStacks.arrangedSubviews.enumerated() {
            if confirmPayInfo.count > idx {
                let model = confirmPayInfo[idx]
                if let payItem = itemView as? EXConfirmPayItemView {
                    payItem.titleLabel.text = model.title
                    payItem.valueLabel.text = model.value
                    payItem.valueLabel.textColor = model.valueColor
                    payItem.titleLabel.textColor = model.titleColor
                }
            }
        }
    
    }
        
        
}
