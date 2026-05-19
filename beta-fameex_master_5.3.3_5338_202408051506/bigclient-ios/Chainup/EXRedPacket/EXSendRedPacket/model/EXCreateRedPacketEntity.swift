//
//  EXCreateRedPacketEntity.swift
//  Chainup
//
//  Created by zewu wang on 2023/7/2.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

//Send red envelope
class EXCreateRedPacketEntity: EXBaseModel {

    var toPayUri = ""
    var appKey = ""
    var userId = ""
    var assetType = ""
    var orderNum = ""
    
    var coinSymbol = "" //Red envelope currency
    var background = "" //Red envelope background image
    var nickName = "" //Red envelope sender's nickname
    var shareUrl = "" //Share Link Address
    var isVersion2 = "" //Upgrade field 2, if version2==1, call the new payment interface/red_ Packet/toPay
}

//Open platform
class EXPlatformPEntity : EXBaseModel{
    var payAmount = ""
    var outOrderId = ""
    var sign = ""
    var orderNum = ""
    var orderStatus = ""
    var appkey = ""
    var returnUrl = ""
}

