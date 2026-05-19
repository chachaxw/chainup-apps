//
//  EXLeverDropDownPanel.swift
//  Chainup
//
//  Created by liuxuan on 2023/12/11.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXLeverRiskPanel:UIView {
    
    lazy var riskDial:UIImageView = {
        let bg = UIImageView()
        bg.contentMode = .scaleAspectFit
        bg.image = UIImage.themeImageNamed(imageName: "coins_pointer1")
        return bg
    }()
    
    lazy var tipIcon:UIImageView = {
        let bg = UIImageView()
        bg.contentMode = .scaleToFill
        bg.image = UIImage.themeImageNamed(imageName: "public_hint").reSizeImage(reSize: CGSize(width: 12, height: 12))
        return bg
    }()
    
    lazy var titleLabel:UILabel = {
        let title = UILabel.init()
        title.font = UIFont.ThemeFont.BodyMedium
        title.textColor = UIColor.ThemeLabel.colorLite
        return title
    }()
    
    lazy var subTitleLabel:UILabel = {
        let title = UILabel.init()
        title.font = UIFont.ThemeFont.BodyMedium
        title.textColor = UIColor.ThemeLabel.colorLite
        return title
    }()
    
    lazy var descLabel:UILabel = {
        let desc = UILabel.init()
        desc.font = UIFont.ThemeFont.SecondaryRegular
        desc.numberOfLines = 0
        desc.textColor = UIColor.ThemeLabel.colorMedium
        desc.text = "leverage_risk_prompt".localized()
        return desc
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.bgTab
        self.addSubViews([riskDial,tipIcon,titleLabel,subTitleLabel,descLabel])
        riskDial.snp.makeConstraints { (make) in
            make.top.equalTo(16)
            make.left.equalTo(12)
            make.width.equalTo(50)
            make.height.equalTo(26)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(riskDial.snp.centerY)
            make.left.equalTo(riskDial.snp.right).offset(10)
            make.right.equalTo(subTitleLabel.snp.left)
        }
        
        subTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(riskDial.snp.centerY)
            make.left.equalTo(titleLabel.snp.right)
            make.right.lessThanOrEqualToSuperview().offset(-16)
        }
        
        tipIcon.snp.makeConstraints { (make) in
            make.top.equalTo(riskDial.snp.bottom).offset(15)
            make.left.equalTo(riskDial.snp.left)
            make.width.height.equalTo(12)
        }
        
        descLabel.snp.makeConstraints { (make) in
            make.top.equalTo(riskDial.snp.bottom).offset(15)
            make.left.equalTo(tipIcon.snp.right).offset(2)
            make.right.equalToSuperview().offset(-12)
        }
    }
}

class EXLeverDropDownPanel: UIView {
    
    typealias PanelClickBlock = ()->()
    var borrowBlock:PanelClickBlock?
    var returnBlock:PanelClickBlock?
    var transferBlock:PanelClickBlock?
    
    lazy var titleLabel:UILabel = {
        let title = UILabel.init()
        title.font = UIFont.ThemeFont.H3Bold
        title.textColor = UIColor.ThemeLabel.colorLite
        return title
    }()
    
    lazy var panelBg:EXLeverRiskPanel = {
        let bg = EXLeverRiskPanel()
        bg.backgroundColor = UIColor.ThemeView.bgTab
        return bg
    }()
    
    lazy var lossCutTitle:UILabel = {
        let title = UILabel.init()
        title.font = UIFont.ThemeFont.SecondaryRegular
        title.textColor = UIColor.ThemeLabel.colorMedium
        return title
    }()
    
    lazy var coinAvailble:UILabel = {
        let title = UILabel.init()
        title.font = UIFont.ThemeFont.SecondaryRegular
        title.textColor = UIColor.ThemeLabel.colorMedium
        return title
    }()
    
    lazy var marketAvailble:UILabel = {
        let title = UILabel.init()
        title.font = UIFont.ThemeFont.SecondaryRegular
        title.textColor = UIColor.ThemeLabel.colorMedium
        return title
    }()
    
    lazy var lossCutValue:UILabel = {
        let title = UILabel.init()
        title.font = UIFont.ThemeFont.SecondaryRegular
        title.textColor = UIColor.ThemeLabel.colorLite
        return title
    }()
    
    lazy var coinAvailbleValue:UILabel = {
        let title = UILabel.init()
        title.font = UIFont.ThemeFont.SecondaryRegular
        title.textColor = UIColor.ThemeLabel.colorLite
        return title
    }()
    
    lazy var marketAvailbleValue:UILabel = {
        let title = UILabel.init()
        title.font = UIFont.ThemeFont.SecondaryRegular
        title.textColor = UIColor.ThemeLabel.colorLite
        return title
    }()
    
    lazy var borrowBtn:UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.titleLabel?.font = UIFont.ThemeFont.BodyRegular
        btn.setTitleColor(UIColor.ThemeView.highlight, for: .normal)
        btn.layer.cornerRadius = 4
        btn.layer.borderWidth = 0.5
        btn.layer.borderColor = UIColor.ThemeView.highlight.cgColor
        btn.setTitle( "leverage_borrow".localized(), for: .normal)
        btn.addTarget(self, action: #selector(panelBtnAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var returnBtn:UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.titleLabel?.font = UIFont.ThemeFont.BodyRegular
        btn.setTitleColor(UIColor.ThemeView.highlight, for: .normal)
        btn.layer.cornerRadius = 4
        btn.layer.borderWidth = 0.5
        btn.layer.borderColor = UIColor.ThemeView.highlight.cgColor
        btn.setTitle( "leverage_return".localized(), for: .normal)
        btn.addTarget(self, action: #selector(panelBtnAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var transferBtn:UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.titleLabel?.font = UIFont.ThemeFont.BodyRegular
        btn.setTitleColor(UIColor.ThemeView.highlight, for: .normal)
        btn.layer.cornerRadius = 4
        btn.layer.borderWidth = 0.5
        btn.layer.borderColor = UIColor.ThemeView.highlight.cgColor
        btn.setTitle( "assets_action_transfer".localized(), for: .normal)
        btn.addTarget(self, action: #selector(panelBtnAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var handlerIcon:UIImageView = {
        let icon = UIImageView.init()
        icon.image = UIImage.themeImageNamed(imageName: "coins_menu")
        return icon
    }()
    
    
    @objc func panelBtnAction(_ sender:UIButton) {
        if sender == borrowBtn {
            self.borrowBlock?()
        }else if sender == returnBtn {
            self.returnBlock?()
        }else if sender == transferBtn {
            self.transferBlock?()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.bg
        self.addSubViews([titleLabel,panelBg,lossCutTitle,lossCutValue,coinAvailble,coinAvailbleValue,marketAvailble,marketAvailbleValue,borrowBtn,returnBtn,transferBtn,handlerIcon])
        titleLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(panelBg.snp.top).offset(-16)
            make.left.equalTo(15)
            make.right.equalToSuperview().offset(-15)
        }
        
        panelBg.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(NAV_SCREEN_HEIGHT)
            make.left.equalTo(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(101)
        }
        
        lossCutTitle.snp.makeConstraints { (make) in
            make.top.equalTo(panelBg.snp.bottom).offset(16)
            make.left.equalTo(15)
            make.right.lessThanOrEqualTo(lossCutValue.snp.left).offset(-5)
        }
        
        lossCutValue.snp.makeConstraints { (make) in
            make.centerY.equalTo(lossCutTitle)
            make.right.equalToSuperview().offset(-15)
        }
        
        coinAvailble.snp.makeConstraints { (make) in
            make.top.equalTo(lossCutTitle.snp.bottom).offset(16)
            make.left.equalTo(15)
            make.right.lessThanOrEqualTo(coinAvailbleValue.snp.left).offset(-5)
        }
        
        coinAvailbleValue.snp.makeConstraints { (make) in
            make.centerY.equalTo(coinAvailble)
            make.right.equalToSuperview().offset(-15)
        }
        
        marketAvailble.snp.makeConstraints { (make) in
            make.top.equalTo(coinAvailble.snp.bottom).offset(16)
            make.left.equalTo(15)
            make.right.lessThanOrEqualTo(marketAvailbleValue.snp.left).offset(-5)
        }
        
        marketAvailbleValue.snp.makeConstraints { (make) in
            make.centerY.equalTo(marketAvailble)
            make.right.equalToSuperview().offset(-15)
        }
        
        borrowBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-27)
            make.left.equalTo(15)
            make.right.equalTo(returnBtn.snp.left).offset(-9)
            make.width.equalTo(returnBtn.snp_width)
        }
        
        returnBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(borrowBtn.snp.centerY)
            make.right.equalTo(transferBtn.snp.left).offset(-9)
            make.width.equalTo(transferBtn.snp_width)
        }
        
        transferBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(borrowBtn.snp.centerY)
            make.right.equalToSuperview().offset(-15)
            make.width.equalTo(borrowBtn.snp_width)
        }
        
        handlerIcon.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-6)
            make.centerX.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(5)
        }
    }
    
    func bindWithBalanceModel(_ model:EXLeverFinanceBalanceModel) {
        titleLabel.text = model.getSymbolCoin()
        lossCutValue.textColor =  .Ex.text1//model.riskColor()
        panelBg.subTitleLabel.textColor = model.riskColor()
        panelBg.titleLabel.text = "leverage_risk".localized().replacingOccurrences(of: "%", with: "")
        panelBg.subTitleLabel.text = model.fmsRiskRate()

        panelBg.riskDial.image = UIImage.themeImageNamed(imageName: "coins_pointer\(model.riskStep())")
        lossCutTitle.text = "leverage_text_blowingUp".localized() + " " + "(\(model.quoteCoin.aliasName()))"
        lossCutValue.text = model.fmsburstPrice()
        
        coinAvailble.text = "assets_text_available".localized() + " " + "(\(model.baseCoin.aliasName()))"
        coinAvailbleValue.text = model.fmsBaseNormalBalance()

        marketAvailble.text = "assets_text_available".localized() + " " + "(\(model.quoteCoin.aliasName()))"
        marketAvailbleValue.text = model.fmsQuoteNormalBalance()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
