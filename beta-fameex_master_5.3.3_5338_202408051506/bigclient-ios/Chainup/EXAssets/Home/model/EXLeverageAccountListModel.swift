//
//  EXLeverageAccountListModel.swift
//  Chainup
//
//  Created by ljw on 2023/11/4.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXLeverageAccountListModel: EXBaseModel {
    static let shareInstance = EXLeverageAccountListModel()
    var memoryLeverCoinMapListArr = [EXLeverageCoinMapItem]()//Memory storage
    var totalBalanceSymbol = ""
    var totalBalance = ""
    var leverCoinMapListArr = [EXLeverageCoinMapItem]()
    var netAssetBalance = ""
    var leverMap : [String : Any] = [:]
    {
        didSet{
            for item in leverMap.values {
                if let model = EXLeverageCoinMapItem.mj_object(withKeyValues: item) {
                    leverCoinMapListArr.append(model)
                  let coinMap =  EXAppMarketManager.sharedInstance.getCoinMapEntityByName(model.name)
                    if coinMap.name.count > 0 {
                        model.doubleSort = coinMap.doubleSort
                    }
                }
            }
            leverCoinMapListArr = leverCoinMapListArr.sorted(by: { (item1, item2) -> Bool in
               return item1.doubleSort < item2.doubleSort
            })
        }
    }
    
}



class EXLeverCrossListModel: EXBaseModel {
    var memoryLeverCoinMapListArr = [EXLeverCoinItem]()//内存存储
    var totalBalanceSymbol = ""
    var leverMapBalanceSymbol = ""
    var totalBalance = ""
    var leverCoinMapListArr = [EXLeverCoinItem]()
    var netAssetBalance = ""
    var totalBorrowBalance:String = ""//总借款数
    var multiple:String = "" //全仓杠杆倍数
    var riskRate:String = "" //风险率
    var burstRiskRate:String = ""
    var remindRiskRate:String = ""

    var leverMap : [String : Any] = [:]
    {
        didSet{
            for item in leverMap.values {
                if let model = EXLeverCoinItem.mj_object(withKeyValues: item) {
                    leverCoinMapListArr.append(model)
                }
            }
            leverCoinMapListArr = leverCoinMapListArr.sorted(by: { (item1, item2) -> Bool in
                return (Double(item1.assetSort) ?? 0) < (Double(item2.assetSort) ?? 0)
            })
        }
    }
}

