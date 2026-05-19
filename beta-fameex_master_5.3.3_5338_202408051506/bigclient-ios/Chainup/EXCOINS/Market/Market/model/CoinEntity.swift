//
//  CoinEntity.swift
//  AppProject
//
//  Created by zewu wang on 2023/8/6.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit

class CoinEntity: SuperEntity {

    var name = LanguageTools.getString(key: "market_text_customZone")
    
    var showLine = false
    
}


class CoinDetailsEntity : SuperEntity{
    
    var app_serial_number:Int = -1
    var symbol:String = "" //Add app from data
    
    var subject : BehaviorSubject<String> = BehaviorSubject.init(value: "")

    var name = ""
    
    var amount = "--"//Turnover
    var close = "--"
    var high = "--"
    var low = "--"
    var open = "--"
    var rose = "--"
    var vol = "--"
    var precision = 2
    var volprecision = 2
    var rose1 : Float = 0
    
    var color = UIColor.ThemekLine.labcolorDark
    
    var rmb = ""
    var backColor =  UIColor.ThemekLine.labcolorDark
    var doubleClose : Double = 0
    
    var nameWidth : CGFloat = 0
    var nameAttrStr: NSMutableAttributedString = NSMutableAttributedString.init(string: "")
    
    var marketTag:String = ""
    var marketTagWidth:CGFloat = 0
    var doubleSort : Double = 1000

    //Old logic, move it over first, don't handle it
    func updateModelWithTicker(ticker:EXTickerModel){
        self.amount = ticker.amount.decimalString(volprecision)
        self.high = ticker.high.decimalString(precision)
        self.low = ticker.low.decimalString(precision)
        self.open = ticker.open.decimalString(precision)
        self.close = ticker.close.decimalString1(precision)
        self.doubleClose = Double(close) ?? 0
        self.rose = ticker.showRose
        self.rose1 = ticker.roseNumber
        if rose1 == 0{
            backColor = UIColor.ThemekLine.labcolorDark
            color = UIColor.ThemekLine.labcolorDark
        }else if rose1 < 0{
            backColor = UIColor.ThemekLine.down
            color = UIColor.ThemekLine.down
        }else{
            backColor = UIColor.ThemekLine.up
            color = UIColor.ThemekLine.up
        }
        
        if ticker.vol == ""{
            vol = "--"
        }else {
            vol = NSString.init(string: ticker.vol).decimalString(volprecision)
            vol = NumberHandler.privateDealDataFormate(vol)
        }

        let array = name.components(separatedBy: "/")
        if array.count > 1{
            let t = EXAppMarketManager.sharedInstance.getCoinExchangeRate(array[1])
            if let rmb = NSString.init(string: close).multiplyingBy1(t.1, decimals: t.2,holdZero: true){
                self.rmb = "≈\(t.0)" + rmb
            }
        }
    }
    
    override func setEntityWithDict(_ dict: [String : Any]) {
        super.setEntityWithDict(dict)
        amount = NSString.init(string: dictContains("amount")).decimalString(volprecision)
        if dictContains("amount") == ""{
            amount = "--"
        }
        close = NSString.init(string: dictContains("close")).decimalString1(precision)
        if dictContains("close") == ""{
            close = "--"
        }
        doubleClose = Double(close) ?? 0
        
        high = NSString.init(string: dictContains("high")).decimalString(precision)
        if dictContains("high") == ""{
            high = "--"
        }
        low = NSString.init(string: dictContains("low")).decimalString(precision)
        if dictContains("low") == ""{
            low = "--"
        }
        open = NSString.init(string: dictContains("open")).decimalString(precision)
        if dictContains("open") == ""{
            open = "--"
        }
        rose = dictContains("rose")
        if rose.contains("-"){
            rose = rose.replacingOccurrences(of: "-", with: "")
            rose = "-" + NSString.init(string: rose).multiplyingBy1( "100", decimals: 2,holdZero: true)
            if let r = Int(rose) , r == 0{
                rose = rose.replacingOccurrences(of: "-", with: "")
            }
        }else{
            rose = NSString.init(string: dictContains("rose")).multiplyingBy1("100", decimals: 2,holdZero: true)
        }
        if let rose1 = Float(self.rose){
            if rose1 == 0{
                rose = "0.00" + "%"
                backColor = UIColor.ThemekLine.labcolorDark
                color = UIColor.ThemekLine.labcolorDark
            }else if rose1 < 0{
                rose = rose + "%"
                backColor = UIColor.ThemekLine.down
                color = UIColor.ThemekLine.down
            }else{
                rose = "+" + rose + "%"
                backColor = UIColor.ThemekLine.up
                color = UIColor.ThemekLine.up
            }
            self.rose1 = rose1
        }
        if dictContains("rose") == ""{
            rose = "--"
        }
        vol = NSString.init(string: dictContains("vol")).decimalString(volprecision)
        vol = NumberHandler.privateDealDataFormate(vol)
        if dictContains("vol") == ""{
            vol = "--"
        }
        
        let array = name.components(separatedBy: "/")
        if array.count > 1{
            let t = EXAppMarketManager.sharedInstance.getCoinExchangeRate(array[1])
            if let rmb = NSString.init(string: close).multiplyingBy1(t.1, decimals: t.2,holdZero: true){
                self.rmb = "≈\(t.0)" + rmb
            }
        }
        nameAttrStr = String.getCoinMapAttr(name.aliasCoinMapName(),leftFont:UIFont().themeHNBoldFont(size: 16),rightFont: UIFont.ThemeFont.SecondaryMedium)
        let symbol = EXAppMarketManager.sharedInstance.getMarketLeft(name)
        marketTag = EXAppMarketManager.sharedInstance.getCoinMarketTag(symbol)
        nameWidth = nameAttrStr.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 14), options: .usesLineFragmentOrigin, context: nil).width
    }
    
    //Market optimization version plus
    func handleNameAndTags() {
        nameAttrStr = String.getCoinMapAttr(name.aliasCoinMapName(),leftFont:UIFont().themeHNBoldFont(size: 16))
        let symbol = EXAppMarketManager.sharedInstance.getMarketLeft(name)
        marketTag = EXAppMarketManager.sharedInstance.getCoinMarketTag(symbol)
        nameWidth = nameAttrStr.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 14), options: .usesLineFragmentOrigin, context: nil).width
    }
    
    //Keep this method for now, it won't affect other places
    func nameAttr() -> NSMutableAttributedString{
        let array = name.aliasCoinMapName().components(separatedBy: "/")
        let att = NSMutableAttributedString.init(string:"")
        if array.count >= 2 {
            att.append(NSAttributedString.init(string: array[0], attributes: [NSAttributedString.Key.font : UIFont().themeHNBoldFont(size: 16)]))
            att.append(NSAttributedString.init(string: array[1], attributes: [NSAttributedString.Key.font : UIFont.ThemeFont.SecondaryRegular]))
        }else {
            att.append(NSAttributedString.init(string: name.aliasCoinMapName(), attributes: [NSAttributedString.Key.font :  UIFont.ThemeFont.SecondaryRegular]))
        }
        return att
    }
    
    
}

class EXNoReadEntity : EXBaseModel{
    var noReadMsgCount = "0"//Unread
}

