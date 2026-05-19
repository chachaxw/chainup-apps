//
//  EXJumpTipView.swift
//  Chainup
//
//  Created by 柴伟东 on 2022/2/28.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import EXKit
class EXJumpTipView: UIView {
    var sureBlock: EXComVoidBlock?
    
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(text:"", font: .Ex.medium(28), textColor: .Ex.text1, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        label.numberOfLines = 0
        return label
    }()
    lazy var kycLabel: UILabel = {
        let label = UILabel(text:"".localized(), font: UIFont.Ex.medium(12), textColor: UIColor.Ex.text2, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        label.numberOfLines = 0
        return label
    }()
    lazy var line: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.ThemeView.seperator
        return v
    }()
    
    lazy var tipTitleLabel: UILabel = {
        let label = UILabel(text: "creditCard_text8".localized(), font: UIFont.Ex.medium(12), textColor:  UIColor.Ex.text2, alignment: NSTextAlignment.left)
        label.numberOfLines = 0
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var contentView: UITextView = {
        let c = UITextView()
//        c.textColor = UIColor.ThemeLabel.colorMedium
        c.isEditable = false
//        c.text = "creditCard_text9".localized()
        c.backgroundColor = UIColor.ThemeView.bg
        let str = "creditCard_text9".localized().lineSpacingString(font: UIFont.ThemeFont.BodyRegular, color:  UIColor.ThemeLabel.colorMedium, lineSpacing: 5,textAligment: .left)
        c.attributedText = str
        return c
    }()
    
    
    lazy var sureBtn:EXButton = {
        let btnSell = EXButton()
        btnSell.setTitle("cl_lever_text4".localized(), for: .normal)
//        btnSell.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
        btnSell.setTitleColor(UIColor.white, for: .normal)
        btnSell.setTitleColor(UIColor.white, for: .selected)
        btnSell.isSelected = false
        btnSell.backgroundColor = UIColor.ThemeView.highlight
        btnSell.layer.cornerRadius = 4
        btnSell.layer.masksToBounds = true
        btnSell.addTarget(self, action: #selector(sure), for: .touchUpInside)
        return btnSell
    }()
    
    
    
     override init(frame: CGRect){
         super.init(frame: frame)
         self.addSubViews([titleLabel,kycLabel,line,tipTitleLabel,contentView,sureBtn])
         titleLabel.snp.makeConstraints { make in
             make.top.equalToSuperview().offset(19)
             make.left.equalToSuperview().offset(15)
             make.right.equalToSuperview().offset(-15)
         }
         kycLabel.snp.makeConstraints { make in
             make.top.equalTo(titleLabel.snp.bottom).offset(30)
             make.left.equalToSuperview().offset(15)
             make.right.equalToSuperview().offset(-15)
         }
         line.snp.makeConstraints { make in
             make.top.equalTo(kycLabel.snp_bottom).offset(16)
             make.left.equalToSuperview().offset(15)
             make.right.equalToSuperview().offset(-15)
             make.height.equalTo(0.5)
         }
         tipTitleLabel.snp.makeConstraints { make in
             make.top.equalTo(line.snp_bottom).offset(21)
             make.left.equalToSuperview().offset(15)
             make.right.equalToSuperview()
         }
         contentView.snp.makeConstraints { make in
             make.top.equalTo(tipTitleLabel.snp_bottom).offset(13)
             make.left.equalToSuperview().offset(13)
             make.right.equalToSuperview().offset(-15)
         }
         
         sureBtn.snp.makeConstraints { make in
             make.top.equalTo(contentView.snp_bottom)
             make.left.equalToSuperview().offset(16)
             make.right.equalToSuperview().offset(-16)
             make.height.equalTo(44)
             make.bottom.equalToSuperview().offset(-16)
         }
     }
     
     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
     
     @objc func sure(){
         sureBlock?()
     }
     
 }
