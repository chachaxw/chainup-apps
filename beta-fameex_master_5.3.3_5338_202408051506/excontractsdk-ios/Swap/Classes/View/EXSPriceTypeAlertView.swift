//
//  EXSPriceTypeAlertView.swift
//  Chainup
//
//  Created by 柴伟东 on 2022/2/10.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import EXKit
class EXSPriceTypeAlertView: UIView {

    /// 标题 English: /Title
    let titleLabel: UILabel = {
        let label = UILabel(text: "cl_roi_1".ex_localized(), font: UIFont.ThemeFont.HeadBold, textColor: UIColor.ThemeLabel.colorLite, alignment: .left)
        return label
    }()
    /// 取消 English: /Cancel
    lazy var cancelButton: UIButton = {
        let button = UIButton(buttonType: .custom, title: "cp_overview_text56".ex_localized(), titleFont: UIFont.ThemeFont.BodyRegular, titleColor: UIColor.ThemeLabel.colorMedium)
        button.ext_SetAddTarget(self, #selector(clickCancelButton))
        return button
    }()
    
    ///最新价格 English: /Latest prices
    lazy var newPriceButton: EXCheckButton = {
        let button = EXCheckButton()
        button.setTitle("cl_roi_2".ex_localized(), for: .normal)
        button.addTarget(self, action: #selector(updatePriceType), for: .touchUpInside)
        return button
    }()
    
    ///标记价格 English: /Mark price
    lazy var tagPriceButton: EXCheckButton = {
        let button = EXCheckButton()
        button.setTitle("cl_roi_3".ex_localized(), for: .normal)
        button.addTarget(self, action: #selector(updatePriceType), for: .touchUpInside)
        return button
    }()
    
    ///内容 English: /Content
    let contentLabel: UILabel = {
        let isNewPrice = EXStoreData.storeBool(forKey: EXS_IS_NEWPRICE)
        let content = isNewPrice ? "cl_roi_4" : "cl_roi_5"
        let label = UILabel(text: content.ex_localized(), font: UIFont.ThemeFont.SecondaryRegular, textColor: UIColor.ThemeLabel.colorMedium, alignment: .left)
        label.numberOfLines = 0
        return label
    }()
  
    ///确认按钮 English: /Confirm button
    lazy var sureButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("cp_calculator_text16".ex_localized(), for: .normal)
        button.titleLabel?.font = UIFont.ThemeFont.HeadBold
        button.addTarget(self, action: #selector(sure), for: .touchUpInside)
        button.setBackgroundColor(color: UIColor.ThemeView.highlight, forState: .selected)
        button.setBackgroundColor(color: UIColor.ThemeView.highlight, forState: .normal)
        button.setBackgroundColor(color: UIColor.ThemeView.highlight, forState: .highlighted)
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        return button
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.alertBg
        exs_roundCorners(corners: [.topLeft, .topRight], radius: 10)
        
        exs_addSubViews([titleLabel,cancelButton])
        exs_addSubViews([newPriceButton,tagPriceButton])
        exs_addSubViews([contentLabel])
        exs_addSubViews([sureButton])
        
        let isNewPrice = EXStoreData.storeBool(forKey: EXS_IS_NEWPRICE)
        newPriceButton.isSelected = isNewPrice
        tagPriceButton.isSelected = !isNewPrice

        let horMargin = 16
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(horMargin)
            make.top.equalToSuperview().offset(19)
            make.height.equalTo(20)
        }
        self.cancelButton.snp.makeConstraints { (make) in
            make.right.equalTo(-horMargin)
            make.top.height.equalTo(self.titleLabel)
        }
        
        self.newPriceButton.snp.makeConstraints { (make) in
           
            make.top.equalTo(self.titleLabel.snp.bottom).offset(28)
            make.left.equalToSuperview().offset(horMargin)
            make.height.equalTo(36)
        }
        self.tagPriceButton.snp.makeConstraints { (make) in
           
            make.top.equalTo(self.titleLabel.snp.bottom).offset(28)
            make.right.equalToSuperview().offset(-horMargin)
            make.left.equalTo(self.newPriceButton.snp.right).offset(10)
            make.width.equalTo(self.newPriceButton.snp_width)
            make.height.equalTo(36)
        }
       
        self.contentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.tagPriceButton.snp.bottom).offset(32)
            make.left.equalToSuperview().offset(horMargin)
            make.right.equalToSuperview().offset(-horMargin)
        }
        
        self.sureButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(contentLabel.snp.bottom).offset(12)
            make.right.equalTo(-16)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-44)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// 点击取消 English: /Click to cancel
    @objc func clickCancelButton() {
        EXAlert.dismiss()
    }
    
    @objc func updatePriceType(btn: EXCheckButton){
        self.newPriceButton.isSelected = false
        self.tagPriceButton.isSelected = false
        btn.isSelected = true
        let isNewPrice = btn == self.newPriceButton
        let content = isNewPrice ? "cl_roi_4" : "cl_roi_5"
        contentLabel.text = content.ex_localized()
    }
    
    @objc func sure() {
        let isNewPrice = self.newPriceButton.isSelected
        let priceType = isNewPrice ? "0" : "1"
        EXAlert.dismiss()
        EXContractNetwork.editUserConfig(id: 10, positionModel: "", coUnit: "",priceType: priceType ) { success in
            if success {
                let value = isNewPrice ? 1 : 0
                EXStoreData.setStoreObjectAndKey(value, key: EXS_IS_NEWPRICE)
            }
        }
    }
}

