//
//  OTCTalkPromptView.swift
//  Chainup
//
//  Created by zewu wang on 2023/10/17.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class OTCTalkPromptView: UIView {
    
    var type = OTCTalkType.user
    
    lazy var seperatorLine : UIView = {
        let seperator = UIView()
        seperator.backgroundColor = UIColor.ThemeView.seperator
        seperator.extUseAutoLayout()
        return seperator
    }()

    lazy var moneyNameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textAlignment = .center
        label.extSetText(LanguageTools.getString(key: "otc_text_tradingPrice"), textColor: UIColor.ThemeLabel.colorDark, fontSize: 12)
        return label
    }()
    
    lazy var moneyVauleLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textAlignment = .center
        label.extSetText("", textColor: UIColor.ThemeState.warning, fontSize: 14)
        label.font = self.themeHNMediumFont(size: 14)
        return label
    }()
    

    lazy var typeValueLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textAlignment = .right
        label.extSetText("", textColor: UIColor.ThemeLabel.colorLite, fontSize: 14)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.bg
        addSubViews([moneyNameLabel,moneyVauleLabel,typeValueLabel,seperatorLine])
        addConstraints()
    }
    
    func addConstraints() {

        moneyNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(15)
            make.left.equalTo(15)
            make.height.equalTo(12)
        }
        
        moneyVauleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(moneyNameLabel.snp.bottom).offset(5)
            make.left.equalTo(moneyNameLabel)
            make.right.lessThanOrEqualTo(typeValueLabel.snp.left)
            make.height.equalTo(16)
        }

        typeValueLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(moneyVauleLabel)
            make.height.equalTo(20)
        }
        
        seperatorLine.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    func setView(_ entity : EXOTCOrderDetailModel){
        moneyVauleLabel.text = entity.totalPrice.formatCurrencyMoney(entity.paycoin) + " " + entity.paycoin
        typeValueLabel.text = entity.getStatusTitle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

