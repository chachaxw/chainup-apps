//
//  EXKlineETFHeader.swift
//  Chainup
//
//  Created by liuxuan on 2023/10/13.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXKlineETFHeader: UIView {
    
    lazy var bg:UIView = {
        let bg = UIView()
        bg.backgroundColor = UIColor.ThemekLine.navBg
        return bg
    }()
    
    lazy var iconImg:UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage.themeImageNamed(imageName:"quotes_fundingrate")
        return icon
    }()
    
    lazy var fundingTitle:UILabel = {
        let label = UILabel.init()
        label.text = "etf_fund_rate".localized()
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textColor = UIColor.ThemekLine.labcolorMedium
        label.textAlignment = .right
        return label
    }()
    
    lazy var fundingRate:UILabel = {
        let label = UILabel.init()
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textColor = UIColor.ThemekLine.labcolorLite
        label.textAlignment = .right
        return label
    }()
    
    lazy var netValueTitle:UILabel = {
        let label = UILabel.init()
        label.text = "etf_text_networth".localized()
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textColor = UIColor.ThemekLine.labcolorMedium
        label.textAlignment = .right
        return label
    }()
    
    lazy var netValue:UILabel = {
        let label = UILabel.init()
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textColor = UIColor.ThemekLine.labcolorLite
        label.textAlignment = .right
        label.text = "--"
        return label
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(bg)
        
        bg.addSubViews([iconImg,fundingTitle,fundingRate,netValueTitle,netValue])
        bg.layer.cornerRadius = 4
        bg.layer.masksToBounds = true
        
        bg.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.bottom.equalToSuperview()
        }
        
        iconImg.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
        
        fundingTitle.snp.makeConstraints { (make) in
            make.left.equalTo(iconImg.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }
        
        fundingRate.snp.makeConstraints { (make) in
            make.left.equalTo(fundingTitle.snp.right).offset(8)
            make.centerY.equalTo(fundingTitle.snp_centerY)
        }
        
        netValueTitle.snp.makeConstraints { (make) in
            make.right.equalTo(netValue.snp.left).offset(-8)
            make.centerY.equalTo(fundingTitle.snp_centerY)
        }
        
        netValue.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalTo(fundingTitle.snp_centerY)
        }
    }
    
    func setNetWorth(model:EXETFNetValueModel,symbol:String) {
        if model.price.count > 0 {
            netValue.text = model.price
        }else {
            netValue.text = "--"
        }
        
        let rate =  EXAppMarketManager.sharedInstance.getFundRate(symbol)
        if rate.count > 0 {
            fundingRate.text = rate + "%"
        }else {
            fundingRate.text = "--"
        }
    }

}
