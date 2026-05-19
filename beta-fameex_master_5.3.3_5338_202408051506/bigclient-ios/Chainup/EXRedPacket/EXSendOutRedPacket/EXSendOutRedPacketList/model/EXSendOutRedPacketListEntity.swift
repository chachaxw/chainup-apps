//
//  EXSendOutRedPacketListEntity.swift
//  Chainup
//
//  Created by zewu wang on 2023/6/29.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXSendOutRedPacketListEntity: EXBaseModel {

    var redPacketList : [EXSendOutRedPacketListDetailEntity] = []
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.redPacketList = EXSendOutRedPacketListDetailEntity.mj_objectArray(withKeyValuesArray: self.redPacketList).copy() as! [EXSendOutRedPacketListDetailEntity]
    }
    
}

class EXSendOutRedPacketListDetailEntity : EXBaseModel {
    var amount = "" //Red envelope limit
    {
        didSet{
            amount = amount.decimalNumberWithDouble()
        }
    }
    var redPacketGetCount = ""//Number of red envelopes received
    var coinSymbol = "" //Red envelope currency
    var redPacketAllCount = "" //Total number of red envelopes
    var stime = "" //Red envelope distribution timestamp
    var packetSn = "" //Red envelope SN
    var type = "" //Red envelope type 0. Ordinary 1. Fighting for luck
    var status = "" //Status 1. Collecting 2. Collected 3. Expired
}

class EXSendOutRedPacketHeadEntity : EXBaseModel{
    
    var newCount = "" //Number of registered users
    var allAmount = ""//Equivalent btc quantity
    {
        didSet{
            allAmount = allAmount.decimalNumberWithDouble()
        }
    }
    var nickName = "" //nickname
    var rateSymbol = "" //Equivalent currency
    var allCount = ""//Total number of red envelopes
    var getCount = "" //Received quantity
    
    //invite
    func fmsNewCount() -> NSMutableAttributedString{
        let att = NSMutableAttributedString.init().add(string: "redpacket_sendout_invited".localized(), attrDic: [NSAttributedString.Key.font : UIFont.ThemeFont.SecondaryRegular,NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorMedium]).add(string: newCount + "redpacket_sendout_people".localized(), attrDic: [NSAttributedString.Key.font : UIFont.ThemeFont.H3Bold,NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorLite]).add(string: "redpacket_sendout_regist".localized(), attrDic: [NSAttributedString.Key.font : UIFont.ThemeFont.SecondaryRegular,NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorMedium])
        return att
    }
    
    //Equivalent to btc
    func fmsAllAmount() -> NSMutableAttributedString{
        let att = NSMutableAttributedString.init().add(string: allAmount, attrDic: [NSAttributedString.Key.font : UIFont.ThemeFont.H3Bold,NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorLite]).add(string: "BTC", attrDic: [NSAttributedString.Key.font : UIFont.ThemeFont.BodyBold,NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorMedium])
        return att
    }
    
    //Number of red packets sent
    func fmsAllCount() -> String{
        return String.init(format: "redpacket_sendout_total".localized(), allCount)
    }
    
    //Shared claim
    func fmsGetCount() -> String{
        return String.init(format: "redpacket_sendout_totalPeople".localized(), getCount)
    }
    
}

