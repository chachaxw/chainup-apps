//
//  EXKlineTickerHeader.swift
//  Chainup
//
//  Created by liuxuan on 2023/10/13.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXKlineTickerHeader: UIView {
    
    // left
    // priceLabel
    // rmbLabel rateLabel
    
    //right bg
    // htitle + h
    // ltitle + l
    // vtitle + v
    var isSwap = false
    lazy var priceLabel:UILabel = {
        let label = UILabel.init()
        label.font = self.themeHNMediumFont(size: 28)
        label.textColor = UIColor.ThemekLine.labcolorMedium
        label.textAlignment = .left
        return label
    }()
    
    lazy var rmbLabel:UILabel = {
        let label = UILabel.init()
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textColor = UIColor.ThemekLine.labcolorMedium
        label.textAlignment = .left
        return label
    }()
    
    lazy var rateLabel:UILabel = {
        let label = UILabel.init()
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textColor = UIColor.ThemekLine.labcolorMedium
        label.textAlignment = .left
        return label
    }()
    
    lazy var rightBg:UIView = {
        let bg = UIView()
        bg.backgroundColor = UIColor.ThemekLine.viewBg
        return bg
    }()
    
    lazy var centerGap:UIView = {
        let bg = UIView()
        bg.backgroundColor = UIColor.ThemekLine.viewBg
        return bg
    }()
    
    lazy var hTitleLabel:UILabel = {
        let label = UILabel.init()
        label.text = "kline_text_high".localized()
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textColor = UIColor.ThemekLine.labcolorMedium
        label.textAlignment = .right
        return label
    }()
    
    lazy var lTitleLabel:UILabel = {
        let label = UILabel.init()
        label.text = "kline_text_low".localized()
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textColor = UIColor.ThemekLine.labcolorMedium
        label.textAlignment = .right
        return label
    }()
    
    lazy var vTitleLabel:UILabel = {
        let label = UILabel.init()
        label.text = "common_text_dayVolume".localized()
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textColor = UIColor.ThemekLine.labcolorMedium
        label.textAlignment = .right
        return label
    }()
    
    lazy var hLabel:UILabel = {
        let label = UILabel.init()
        label.font = self.themeHNFont(size: 12)
        label.textColor = UIColor.ThemekLine.labcolorLite
        label.textAlignment = .right
        return label
    }()
    
    lazy var lLabel:UILabel = {
        let label = UILabel.init()
        label.font = self.themeHNFont(size: 12)
        label.textColor = UIColor.ThemekLine.labcolorLite
        label.textAlignment = .right
        return label
    }()
    
    lazy var vLabel:UILabel = {
        let label = UILabel.init()
        label.font = self.themeHNFont(size: 12)
        label.textColor = UIColor.ThemekLine.labcolorLite
        label.textAlignment = .right
        return label
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemekLine.viewBg
        self.addSubViews([priceLabel,rmbLabel,rateLabel,rightBg])
        rightBg.addSubViews([hTitleLabel,hLabel,lTitleLabel,centerGap,lLabel,vTitleLabel,vLabel])
        layoutTickers()
    }
    func reloadLable(){
/*Use copy of contract*/
//        self.isSwap = true
//        hTitleLabel.text = "cp_extra_text111".ex_localized()
//        lTitleLabel.text = "cp_extra_text112".ex_localized()
//        vTitleLabel.text = "cp_extra_text88".ex_localized()
//        rmbLabel.isHidden = true
//        rateLabel.snp.remakeConstraints { (make) in
//            make.centerY.equalToSuperview()
//            make.left.equalTo(priceLabel.snp.right).offset(8)
//            make.right.lessThanOrEqualTo(rightBg.snp.left).offset(-5)
//        }
//        priceLabel.snp.remakeConstraints { make in
//            make.centerY.equalToSuperview()
//            make.left.equalTo(15)
//            make.right.lessThanOrEqualTo(rightBg.snp.left).offset(-5)
//            make.height.equalTo(36)
//        }
    }
    
    func layoutTickers() {
        rightBg.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        rightBg.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        rmbLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 248), for: .horizontal)
        rmbLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 748), for: .horizontal)
        
        rateLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 249), for: .horizontal)
        rateLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 749), for: .horizontal)
        
        priceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(rightBg.snp.top)
            make.left.equalTo(15)
            make.right.lessThanOrEqualTo(rightBg.snp.left).offset(-5)
            make.height.equalTo(36)
        }
        rmbLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(rightBg.snp.bottom)
            make.left.equalTo(priceLabel.snp.left)
            make.right.equalTo(rateLabel.snp.left).offset(-8)
        }
        rateLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(rmbLabel.snp.centerY)
            make.left.equalTo(rmbLabel.snp.right).offset(8)
            make.right.lessThanOrEqualTo(rightBg.snp.left).offset(-5)
        }
        
        rightBg.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-15)
        }
        
        hTitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalTo(centerGap.snp.left)
            make.top.equalToSuperview()
        }
        
        lTitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalTo(centerGap.snp.left)
            make.top.equalTo(hTitleLabel.snp.bottom).offset(8)
        }
        
        vTitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalTo(centerGap.snp.left)
            make.top.equalTo(lTitleLabel.snp.bottom).offset(8)
            make.bottom.equalToSuperview()
        }
        
        centerGap.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(vTitleLabel.snp.right)
            make.width.equalTo(7)
        }
        
        hLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.left.equalTo(centerGap.snp.right)
            make.centerY.equalTo(hTitleLabel.snp.centerY)
        }
        
        lLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.left.equalTo(centerGap.snp.right)
            make.centerY.equalTo(lTitleLabel.snp.centerY)
        }
        
        vLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.left.equalTo(centerGap.snp.right)
            make.centerY.equalTo(vTitleLabel.snp.centerY)
        }
    }
}

extension EXKlineTickerHeader {
    
    func updateTicker(ticker:TickItem?,entity:CoinMapEntity) {
        if let tickItem = ticker {
            hLabel.text = tickItem.high.formatAmountUseDecimal(entity.price)
            lLabel.text = tickItem.low.formatAmountUseDecimal(entity.price)
            if self.isSwap {
                vLabel.text = tickItem.vol //Display style has been processed during data return
            }else{
                vLabel.text = tickItem.vol.formatAmountUseDecimal(entity.volume)
            }
            if tickItem.rose != "--" {
                rateLabel.text = tickItem.rose + "%"
                rateLabel.textColor = tickItem.roseTxtColor
            }
            priceLabel.text = tickItem.close.formatAmountUseDecimal(entity.price)
            priceLabel.textColor = tickItem.roseTxtColor
            let array = entity.name.components(separatedBy: "/")
            if array.count == 2 {
                let t = EXAppMarketManager.sharedInstance.getCoinExchangeRate(array[1])
                if let rmb = NSString.init(string: String(describing: tickItem.close)).multiplyingBy1(t.1, decimals: t.2){
                    rmbLabel.text = "≈\(t.0)" + rmb
                }
            }
        }else {
            let color =  UIColor.ThemekLine.labcolorMedium
            hLabel.text = "--"
            lLabel.text = "--"
            vLabel.text = "--"
            rmbLabel.text = "--"
            rateLabel.text = "--"
            priceLabel.text = "--"
            rateLabel.textColor = color
            priceLabel.textColor = color
        }
    }
}

