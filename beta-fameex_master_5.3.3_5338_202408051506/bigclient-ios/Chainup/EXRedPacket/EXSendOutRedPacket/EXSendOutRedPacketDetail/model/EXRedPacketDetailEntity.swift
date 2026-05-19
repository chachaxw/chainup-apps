//
//  EXRedPacketDetailEntity.swift
//  Chainup
//
//  Created by zewu wang on 2023/6/29.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXRedPacketDetailEntity: EXBaseModel {
    var amount = ""//Total amount of red envelopes
    {
        didSet{
            amount = amount.decimalNumberWithDouble()
        }
    }
    var myAmount = ""//The amount of red envelopes I received
    {
        didSet{
            myAmount = myAmount.decimalNumberWithDouble()
        }
    }
    var QRCode = "" //Red envelope QR code
    var nickName = "" //Employer's nickname
    var count = ""//Number of red envelopes
    var tip = "" //WeChat reminder
    var url = "" //Red envelope link
    var status = "" //Red envelope status 1. Collecting 2. Collected 3. Expired
    var coinSymbol = ""//Red envelope currency
    var background = ""//Red envelope background image
    var getAmount = ""//Total amount of red envelopes received
    {
        didSet{
            getAmount = getAmount.decimalNumberWithDouble()
        }
    }
    var getCount = ""//Number of red envelopes received
    var mapList : [EXRedPacketListDetailEntity] = []
    
    func getMyAmount() -> NSMutableAttributedString{
        var att = NSMutableAttributedString()
        att = att.add(string: myAmount, attrDic: [NSAttributedString.Key.font : UIFont.ThemeFont.H1Bold , NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorLite]).add(string: " " + coinSymbol.aliasName(), attrDic: [NSAttributedString.Key.font : UIFont.ThemeFont.HeadBold , NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorMedium])
        return att
    }
    
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.mapList = EXRedPacketListDetailEntity.mj_objectArray(withKeyValuesArray: self.mapList).copy() as! [EXRedPacketListDetailEntity]
    }
    
    func dealcoinSymbol(){
        for model in mapList{
            model.coinSymbol = coinSymbol
        }
    }
}


class EXRedPacketListDetailEntity: EXBaseModel {
    
    var amount = "" //quantity
    {
        didSet{
            amount = amount.decimalNumberWithDouble()
        }
    }
    var coinSymbol = ""//Red envelope currency
    var nickName = ""//Recipient's nickname
    var ctime = ""//Collection time
    var isNew = ""//New user 0. No 1. Yes
    var isLucky = "" //Is 0 the best for luck? 0. No 1. Yes
 
    //Equivalent to legal currency
    func equivalentFiat() -> String{
        let rate = EXAppMarketManager.sharedInstance.getCoinExchangeRate(coinSymbol)
        if rate.0 == ""{//If you can't get it
            return ""
        }
        return "≈" + " " + rate.0 + (amount as NSString).multiplying(by: rate.1, decimals: rate.2)
    }
    
}

