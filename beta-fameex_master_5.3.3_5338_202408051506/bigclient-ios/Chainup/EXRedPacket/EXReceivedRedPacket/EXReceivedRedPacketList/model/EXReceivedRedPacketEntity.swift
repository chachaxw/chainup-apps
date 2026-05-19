//
//  EXReceivedRedPacketEntity.swift
//  Chainup
//
//  Created by zewu wang on 2023/7/1.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXReceivedRedPacketEntity: EXBaseModel {

    var allAmount = "" //Total amount
    {
        didSet{
            allAmount = allAmount.decimalNumberWithDouble()
        }
    }
    var nickName = "" //User nickname
    var rateSymbol = "" //Equivalent to total currency
    var count = "" //Total number of red envelopes received
    
    //Equivalent to btc
    func fmsAllAmount() -> NSMutableAttributedString{
        let att = NSMutableAttributedString.init().add(string: allAmount, attrDic: [NSAttributedString.Key.font : UIFont.ThemeFont.H3Bold,NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorLite]).add(string: "BTC", attrDic: [NSAttributedString.Key.font : UIFont.ThemeFont.BodyBold,NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorMedium])
        return att
    }
    
    //Number of red packets sent
    func fmsAllCount() -> String{
        return String.init(format: "redpacket_received_num".localized(), count)
    }
    
}

class EXReceivedRedPacketListEntity : EXBaseModel{
    var mapList : [EXReceivedRedPacketListDetailEntity] = []
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.mapList = EXReceivedRedPacketListDetailEntity.mj_objectArray(withKeyValuesArray: self.mapList).copy() as! [EXReceivedRedPacketListDetailEntity]
    }
}

class EXReceivedRedPacketListDetailEntity : EXBaseModel{
    var amount = "" //Red envelope amount
    {
        didSet{
            amount = amount.decimalNumberWithDouble()
        }
    }
    var coinSymbol = "" //Red envelope currency
    var ctime = "" //Collection time
    var packetSn = ""//Red envelope identification
    var nickName = "" //Red envelope owner's nickname
    
    //Equivalent to legal currency
    func equivalentFiat() -> String{
        let rate = EXAppMarketManager.sharedInstance.getCoinExchangeRate(coinSymbol)
        if rate.0 == ""{//If you can't get it
            return ""
        }
        return "≈" + " " + rate.0 + (amount as NSString).multiplying(by: rate.1, decimals: rate.2)
    }
    
}

