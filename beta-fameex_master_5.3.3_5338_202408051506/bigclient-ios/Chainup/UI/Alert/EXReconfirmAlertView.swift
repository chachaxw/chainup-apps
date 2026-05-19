//
//  EXReconfirmAlertView.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/21.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXReconfirmAlertView: NibBaseView {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var checkCondition: EXCheckBox!
    @IBOutlet var positiveBtn: EXButton!
    @IBOutlet var passitiveBtn: EXButton!
    typealias AlertCallback = (Int) -> ()
    var alertCallback : AlertCallback?
    
    override func onCreate() {
        titleLabel.headBold()
        titleLabel.textColor = UIColor.ThemeLabel.colorLite
        messageLabel.textColor = UIColor.ThemeState.warning
        passitiveBtn.clearColors()
        positiveBtn.clearColors()
        passitiveBtn.setTitleColor(UIColor.ThemeLabel.colorHighlight, for: .normal)
        positiveBtn.setTitleColor(UIColor.ThemeLabel.colorHighlight, for: .normal)
        positiveBtn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .disabled)
        checkCondition.checkLabel.font = UIFont.ThemeFont.BodyRegular
        checkCondition.checkCallback = {[weak self] isCheck in
            self?.updateBtnEnabled(isCheck)
        }
        positiveBtn.isEnabled = false
        self.backgroundColor = UIColor.ThemeView.alertBg
    }
    
    func updateBtnEnabled(_ isEnable:Bool) {
        positiveBtn.isEnabled = isEnable
    }
    
    func configAlert(title:String,
                     message:String,
                     confirmCondition:String,
                     passiveBtnTitle:String = "common_text_btnCancel".localized(),
                     positiveBtnTitle:String="common_text_btnConfirm".localized())
    {
        titleLabel.text = title
        messageLabel.text = message
        checkCondition.text(content: confirmCondition)
        passitiveBtn.setTitle(passiveBtnTitle, for: .normal)
        positiveBtn.setTitle(positiveBtnTitle, for: .normal)
//        let msgHeight = message.textSizeWithFont(UIFont.ThemeFont.BodyRegular, width: SCREEN_WIDTH - 70).height + 8
//        let fullheight = 58+56+36+msgHeight
//        self.snp.makeConstraints { (make) in
//            make.width.equalTo(SCREEN_WIDTH - 30)
//            make.height.equalTo(fullheight)
//        }
////        self.frame = CGRect(x: 0, y: 0, width:SCREEN_WIDTH - 30, height: 58+56+36+msgHeight)
    }
    
    func configAttrAlert(title:String,
                     message:NSMutableAttributedString,
                     confirmCondition:String,
                     passiveBtnTitle:String = "common_text_btnCancel".localized(),
                     positiveBtnTitle:String="common_text_btnConfirm".localized())
    {
        titleLabel.text = title
        messageLabel.attributedText = message
        checkCondition.text(content: confirmCondition)
        passitiveBtn.setTitle(passiveBtnTitle, for: .normal)
        positiveBtn.setTitle(positiveBtnTitle, for: .normal)
//        let msgHeight = message.textSizeWithFont(UIFont.ThemeFont.BodyRegular, width: SCREEN_WIDTH - 70).height + 8
//        let fullheight = 58+56+36+msgHeight
//        self.snp.makeConstraints { (make) in
//            make.width.equalTo(SCREEN_WIDTH - 30)
//            make.height.equalTo(fullheight)
//        }
////        self.frame = CGRect(x: 0, y: 0, width:SCREEN_WIDTH - 30, height: 58+56+36+msgHeight)
    }
    
    @IBAction func positveAction(_ sender: EXButton) {
        alertCallback?(0)
        EXAlert.dismiss()
    }
    
    @IBAction func passtiveAction(_ sender: EXButton) {
        alertCallback?(1)
        EXAlert.dismiss()
    }
}
