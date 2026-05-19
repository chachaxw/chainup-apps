//
//  EXKlineFooter.swift
//  Chainup
//
//  Created by liuxuan on 2023/10/16.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXKlineFooter: UIView {
    var footerType:KLineAccountType
    
    lazy var footerBg:UIView = {
        let bg = UIView()
        bg.backgroundColor = UIColor.ThemekLine.viewBg
        return bg
    }()
    
    lazy var lineV:UIView = {
        let bg = UIView()
        bg.backgroundColor = UIColor.ThemekLine.viewSeperator
        return bg
    }()
    
    lazy var buyBtn:UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = UIColor.ThemekLine.up
        btn.titleLabel?.font = UIFont.ThemeFont.HeadMedium
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.layer.cornerRadius = 4
        return btn
    }()
    
    lazy var sellBtn:UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = UIColor.ThemekLine.down
        btn.titleLabel?.font = UIFont.ThemeFont.HeadMedium
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.layer.cornerRadius = 4
        return btn
    }()
    
    required init(type:KLineAccountType) {
        self.footerType = type
        super.init(frame: CGRect.zero)
        configFooterBtn()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configFooterBtn() {
        addSubview(footerBg)
        addSubview(lineV)
        footerBg.addSubview(buyBtn)
        footerBg.addSubview(sellBtn)
        lineV.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(1/UIScreen.main.scale)
        }
        footerBg.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        buyBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.width.equalTo(sellBtn.snp_width)
            make.height.equalTo(44)
            make.top.equalToSuperview().offset(10)
            make.right.equalTo(sellBtn.snp.left).offset(-10)
        }
        sellBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.width.equalTo(buyBtn.snp_width)
            make.height.equalTo(44)
            make.top.equalToSuperview().offset(10)
            make.left.equalTo(buyBtn.snp.right).offset(10)
        }
        self.buyBtn.setTitle("contract_action_buy".localized(), for: .normal)
        self.sellBtn.setTitle("contract_action_sell".localized(), for: .normal)
        
    }
}
