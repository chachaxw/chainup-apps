//
//  EXCrefitPayhistoryCell.swift
//  Chainup
//
//  Created by 柴伟东 on 2022/4/1.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import EXKit
import Swap
class EXCrefitPayhistoryCell: EXBaseTableViewCell {
    ///Name
    lazy var sideLabel: UILabel = {
        let label = UILabel(text: "", font: UIFont.ThemeFont.HeadBold, textColor: UIColor.ThemeState.fail, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    ///Coins
    lazy var coinLabel: UILabel = {
        let label = UILabel(text: "", font: UIFont.ThemeFont.HeadBold, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    ///
    lazy var timeLabel: UILabel = {
        let label = UILabel(text: "", font: UIFont.ThemeFont.SecondaryMedium, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    ///Name
    lazy var statusLabel: UILabel = {
        let label = UILabel(text: "", font: UIFont.ThemeFont.SecondaryMedium, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()

    lazy var line: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.ThemeView.seperator
        return v
    }()
    
    
    var firstTitleRow:EXShorizontalThreeLabelView = {
        let v = EXShorizontalThreeLabelView(user: .cell)
        v.config(titleColor: UIColor.ThemeLabel.colorDark, font: UIFont.ThemeFont.MinimumRegular)
        return v
    }()
    var firstValueRow:EXShorizontalThreeLabelView = {
        let v = EXShorizontalThreeLabelView(user: .cell)
        v.config(titleColor: UIColor.ThemeLabel.colorMedium, font: UIFont.ThemeFont.BodyRegular)
        return v
    }()
    var secondTitleRow:EXShorizontalThreeLabelView = {
        let v = EXShorizontalThreeLabelView(user: .cell)
        v.hideMiddleLabel()
        v.config(titleColor: UIColor.ThemeLabel.colorDark, font: UIFont.ThemeFont.MinimumRegular)
        return v
    }()
    
    var secondValueRow:EXShorizontalThreeLabelView = {
        let v = EXShorizontalThreeLabelView(user: .cell)
        v.hideMiddleLabel()
        v.config(titleColor: UIColor.ThemeLabel.colorMedium, font: UIFont.ThemeFont.BodyRegular)
        return v
    }()
    override func setUpView() {
        self.contentView.addSubViews([
            sideLabel,coinLabel,timeLabel,statusLabel,
            firstTitleRow,
            firstValueRow,
            secondTitleRow,
            secondValueRow,
            line
        ])
        sideLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(16)
        }
        coinLabel.snp.makeConstraints { make in
            make.left.equalTo(sideLabel.snp_right).offset(5)
            make.centerY.equalTo(sideLabel)
        }
        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(coinLabel.snp_right).offset(6)
            make.centerY.equalTo(coinLabel)
        }
        statusLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-14)
            make.centerY.equalTo(coinLabel)
        }
      
        firstTitleRow.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(sideLabel.snp_bottom).offset(16)
            make.height.equalTo(12)
        }
        
        firstValueRow.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(firstTitleRow.snp_bottom).offset(9)
            make.height.equalTo(14)
        }
        secondTitleRow.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(firstValueRow.snp_bottom).offset(15)
            make.height.equalTo(12)
        }
        secondValueRow.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(secondTitleRow.snp_bottom).offset(9)
            make.height.equalTo(14)
        }
        line.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
        }
    }
    
    
    var criditRecord: EXPayRecord? {
        didSet{
            guard let m = criditRecord else {return}
            if m.originType == 1{ //buy
                sideLabel.textColor = UIColor.ThemekLine.up
            }else {//sell
                sideLabel.textColor = UIColor.ThemekLine.down
            }
            sideLabel.text = m.type
            coinLabel.text = m.coinSymbol
            if m.ctime.isEmpty == false{
               let res = m.ctime.bigDiv("1000")
                if let time = Double(res){
                    self.timeLabel.text = DateTools.timeStampToString(time,dateFormat: "MM/dd HH:mm")
                }
            }
            statusLabel.text = m.status_text
            var priceValue = m.price
            var volumeValue = m.volume
//            if m.originType == 1{ //buy -fait volume- coin
//                priceValue = m.price.formatCurrencyMoney(m.payCoin,format:.fiatFormat)
//                volumeValue = m.volume.formatAmount(m.coinSymbol)
//            }else {//sell-coin volume-fait
//                priceValue = m.price.formatAmount(m.payCoin)
//                volumeValue = m.volume.formatCurrencyMoney(m.coinSymbol,format:.fiatFormat)
//            }
            let priceTitle = "quick_buy_coin_text2".localized() + "(\(m.payCoin))" //unit price
            let amountTitle = "quick_buy_coin_text3".localized() + "(\(m.coinSymbol))" //quantity
            let totalTitle = "quick_buy_coin_text4".localized() + "(\(m.payCoin))" //total
            let provierTitle = "quick_buy_coin_text6".localized() //Service provider
            let orderTitle = "quick_buy_coin_text5".localized()  //order form
            firstTitleRow.setData(left: priceTitle, middle: amountTitle, right: totalTitle)
            firstValueRow.setData(left: priceValue, middle: volumeValue, right: m.totalPrice)
            secondTitleRow.setData(left: orderTitle, middle:"", right: provierTitle)
            secondValueRow.setData(left: m.sequence, middle:"", right:  m.realName)
           
        }
    }
    
    
}

