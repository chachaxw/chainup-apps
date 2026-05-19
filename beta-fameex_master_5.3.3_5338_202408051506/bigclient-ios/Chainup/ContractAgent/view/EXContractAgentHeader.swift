//
//  EXContractAgentHeader.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/3.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXContractAgentStepFlexible:UIView {
    
    lazy var arrowIcon:UIImageView = {
        let img:UIImageView  = UIImageView.init()
        img.image = UIImage.themeImageNamed(imageName: "arrow")
        return img
    }()
  
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(arrowIcon)
        
        arrowIcon.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.height.equalTo(12)
            make.width.equalTo(32)
            make.top.equalToSuperview().offset(12)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class EXContractAgentStepItem:UIControl {
    
    lazy var stepIcon:UIImageView = {
        let img:UIImageView  = UIImageView.init()
        return img
    }()
    
    lazy var stepLabel:UILabel = {
        let label:UILabel  = UILabel.init()
        label.numberOfLines = 4
        label.textAlignment = .center
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textColor = UIColor.ThemeLabel.colorLite
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(stepIcon)
        addSubview(stepLabel)

        stepIcon.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(36)
            make.top.equalToSuperview()
        }
        
        stepLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(stepIcon.snp.bottom).offset(12)
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
    
    func setText(text:String) {
    
        let att = NSMutableAttributedString(string: text)
        att.yy_lineSpacing = 3
        att.yy_alignment = .center
        stepLabel.attributedText = att
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
let  EXContractAgentHeaderImageRatio = 309 / 375
class EXContractAgentHeader: UIView {
    
    lazy var headerBg:UIImageView = {
        let img:UIImageView  = UIImageView.init()
        if LanguageTools.isHan() {
            img.image = UIImage.themeImageNamed(imageName: "contract_agnet_banner")
        }else {
            img.image = UIImage.themeImageNamed(imageName: "contract_agnet_banner_english")
        }
        return img
    }()
    
    lazy var container:UIStackView = {
        let stacker :UIStackView = UIStackView.init()
        stacker.axis = .horizontal
        return stacker
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(headerBg)
        addSubview(container)
        
        headerBg.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(headerBg.snp.width).multipliedBy(0.707)
        }
        
        container.snp.makeConstraints { (make) in
            make.top.equalTo(headerBg.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        configContainer()
    }
    
    func configContainer() {
        let width = (SCREEN_WIDTH - 30 - 64) / 3
        let stepA:EXContractAgentStepItem = EXContractAgentStepItem.init()
        stepA.stepIcon.image = UIImage.svgImage(named: "icon1", version: .five)
        stepA.setText(text: "send_invitation".localized())
        stepA.snp.makeConstraints { (make) in
            make.width.equalTo(width)
        }
        
        let flexibleA = EXContractAgentStepFlexible.init()
        flexibleA.snp.makeConstraints { (make) in
            make.width.equalTo(32)
        }
        
        let stepB:EXContractAgentStepItem = EXContractAgentStepItem.init()
        stepB.stepIcon.image = UIImage.svgImage(named: "icon2", version: .five)
        stepB.setText(text: "invitee_complete_registration_transaction".localized())
        stepB.snp.makeConstraints { (make) in
            make.width.equalTo(width)
        }
        
        let flexibleB = EXContractAgentStepFlexible.init()
        flexibleB.snp.makeConstraints { (make) in
            make.width.equalTo(32)
        }
      
        let stepC:EXContractAgentStepItem = EXContractAgentStepItem.init()
        stepC.stepIcon.image = UIImage.svgImage(named: "icon3", version: .five)
        stepC.setText(text: "receive_corresponding_ratio_commission".localized())
        
        container.addArrangedSubview(stepA)
        container.addArrangedSubview(flexibleA)
        container.addArrangedSubview(stepB)
        container.addArrangedSubview(flexibleB)
        container.addArrangedSubview(stepC)
        
        stepC.snp.makeConstraints { (make) in
            make.width.equalTo(width)
            make.top.bottom.equalToSuperview()
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
