//
//  EXOTCHistoryModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/4.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXOTCHistoryListItem: NSObject {

    @objc var adsId = ""// 12324,//Advertising ID
    @objc var sequence = ""// "11908627",
    @objc var coinSymbol = ""// "btc",//
    @objc var type = ""// "买入",//type
    @objc var side = ""// "BUY",//type
    @objc var payMode = ""// "btc",//Payment method
    @objc var paySymbol = ""//Legal currency unit
    @objc var price = ""// 1,//price
    @objc var totalPrice = ""// 1,//Transaction amount
    @objc var volume = ""// 0.02,//quantity
    @objc var nickName = ""// "1.000",//Counterparty
    @objc var status = ""// ,//
    @objc var status_text = ""// "待支付",//Order Status
    @objc var id = ""// 12,
    @objc var isOnline = ""
    @objc var otcNickName = ""
    
    @objc var imageUrl = ""
    @objc var createTime = "" {
        didSet {
            if createTime.count == 13 {
                createTime = String(createTime.dropLast(3))
            }
        }
    }
    
    func fmtPrice()->String {
        price = NSString.init(string: price).decimalString(EXAppMarketManager.sharedInstance.getRatePrecision())
        return price
    }
    
    func fmtTotal() ->String {
        totalPrice = NSString.init(string: totalPrice).decimalString(EXAppMarketManager.sharedInstance.getRatePrecision())
        return totalPrice
    }
    
    func fmtVolumeBalance() ->String {
        if self.coinSymbol.isEmpty {
            return volume
        }else {
            let precion = EXAppMarketManager.sharedInstance.getCoinPrecision(self.coinSymbol)
            volume = NSString.init(string: volume).decimalString(precion)
            return volume
        }
    }
    
    
    func getOrderTime() -> String {
        if let timeStamp = Double(self.createTime) {
            let createTime = Date.init(timeIntervalSince1970: timeStamp)
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd HH:mm"
            return formatter.string(from: createTime)
        }
        return ""
    }
}


class EXOTCHistoryModel: NSObject {
    @objc var count:Int = 0
    @objc var orderList:[EXOTCHistoryListItem] = []
    
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.orderList = EXOTCHistoryListItem.mj_objectArray(withKeyValuesArray: self.orderList).copy() as! [EXOTCHistoryListItem]
        
    }
}

