//
//  EXNormalAlert.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/9.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit


class EXNormalAlert: NibBaseView {

    @IBOutlet var titleView: UIView!
    @IBOutlet var messageView: UIView!
    @IBOutlet var btnView: UIView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var msgLabel: UILabel!
    @IBOutlet var passiveBtn: EXButton!
    @IBOutlet var positiveBtn: EXButton!
    @IBOutlet var btnHeight: NSLayoutConstraint!
    typealias AlertCallback = (Int) -> ()
    var alertCallback : AlertCallback?
    
    @IBOutlet var alertIconBg: UIView!
    @IBOutlet var alertIcon: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners(corners: [.allCorners], radius: 12)
    }
    
    func hideMessageAndRemakeTitle() {
        messageView.isHidden = true
//        titleConsHeight.constant = 64
    }
    
    override func onCreate() {
        self.alertIconBg.isHidden = true 
        self.backgroundColor = UIColor.ThemeView.alertBg
        titleLabel.headBold()
        titleLabel.textColor = UIColor.ThemeLabel.colorLite
        msgLabel.font = UIFont.ThemeFont.BodyRegular
        titleLabel.textColor = .Ex.text1
        msgLabel.textColor = .Ex.text2
        passiveBtn.setTitleColor(.Ex.text1, for: .normal)
        passiveBtn.backgroundColor = .ThemeView.card2
        passiveBtn.extSetCornerRadius(4.0)
        positiveBtn.setTitleColor(.ThemeLabel.white, for: .normal)
        positiveBtn.backgroundColor = .Ex.main1
        positiveBtn.extSetCornerRadius(4.0)
//        passiveBtn.selectStyle = .defultColorBlueLine
//        positiveBtn.selectStyle = .blueColor
    }
    
    func configSigleAlert(title:String?,
                          message:String,
                          sigleBtnTitle:String = "alert_common_iknow".localized(), lineHeight: CGFloat = 2)
    {
        passiveBtn.removeFromSuperview()
        if let altTitle = title,!altTitle.isEmpty {
            titleLabel.text = altTitle
        }else {
            titleView.snp.remakeConstraints { make in
                make.height.equalTo(20)
            }
        }
        if message.count > 0 {
            msgLabel.attributedText = message.lineSpacingString(font: msgLabel.font, color: msgLabel.textColor, lineSpacing: lineHeight, textAligment: .left)
        }else {
            self.hideMessageAndRemakeTitle()
        }
        positiveBtn.setTitle(sigleBtnTitle, for: .normal)
    }

    func configAlert(title:String?,
                     message:String,
                     passiveBtnTitle:String = "common_text_btnCancel".localized(),
                     positiveBtnTitle:String="common_text_btnConfirm".localized())
    {
        if let altTitle = title,!altTitle.isEmpty,altTitle.count > 0 {
            titleLabel.text = altTitle
        }
        if message.count > 0 {
            msgLabel.attributedText = message.lineSpacingString(font: msgLabel.font, color: msgLabel.textColor, lineSpacing:2, textAligment: .left)

        }else {
            hideMessageAndRemakeTitle()
        }
        passiveBtn.setTitle(passiveBtnTitle, for: .normal)
        positiveBtn.setTitle(positiveBtnTitle, for: .normal)
    }
    
    func configIconAlert(title:String?,
                         message:String,
                         icon:String,
                         passiveBtnTitle:String = "common_text_btnCancel".localized(),
                         positiveBtnTitle:String="common_text_btnConfirm".localized())
    {
        if icon.count > 0 {
            alertIconBg.isHidden = false
            alertIcon.image = UIImage.themeImageNamed(imageName: icon)
        }

        if let altTitle = title,!altTitle.isEmpty,altTitle.count > 0 {
            titleLabel.text = altTitle
        }else{
            titleView.isHidden = true
        }
        if message.count > 0 {
            msgLabel.attributedText = message.lineSpacingString(font: msgLabel.font, color: msgLabel.textColor, lineSpacing:2, textAligment: .left)
        }else {
            hideMessageAndRemakeTitle()
        }
        if passiveBtnTitle.isEmpty {
            passiveBtn.removeFromSuperview()
        }else {
            passiveBtn.setTitle(passiveBtnTitle, for: .normal)
        }
        positiveBtn.setTitle(positiveBtnTitle, for: .normal)
    }


    func configAttributeAlert(title:String?,
                     message:NSAttributedString,
                     passiveBtnTitle:String = "common_text_btnCancel".localized(),
                     positiveBtnTitle:String="common_text_btnConfirm".localized())
    {
        if let altTitle = title,!altTitle.isEmpty {
            titleLabel.text = altTitle
        }
        if message.string.count > 0 {
            msgLabel.attributedText = message
        }else {
            hideMessageAndRemakeTitle()
        }
        passiveBtn.setTitle(passiveBtnTitle, for: .normal)
        positiveBtn.setTitle(positiveBtnTitle, for: .normal)
    }
    
    @IBAction func positveAction(_ sender: EXButton) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
            self.alertCallback?(0)
        }
        EXAlert.dismiss()
    }
    
    @IBAction func passtiveAction(_ sender: EXButton) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
            self.alertCallback?(1)
        }
        EXAlert.dismiss()
    }
    
}
