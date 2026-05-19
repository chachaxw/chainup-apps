//
//  EXAccountBalanceModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/27.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit


class EXAccountCoinMapItem: EXBaseModel {
//    var withdrawAddressMap:[AddressItem] = []
//    var feeMin = ""
    var isFiat = ""
    var normal_balance = ""
    var allBalance = ""
    var present_coin_balance = ""
    var lock_position_balance = ""
    var btcValuatin = ""
    var sort = ""
//    var withdraw_min = ""
    var depositOpen = ""
    var total_balance = ""
    var nc_lock_balance = ""
//    var feeMax = ""
    var otcOpen = ""
    var depositMin = ""
//    var defaultFee = ""
    var checked = ""
    var coinName = ""
    var lock_balance = ""
    var exchange_symbol = ""
    var allBtcValuatin = ""
//    var withdraw_max = ""
    var withdrawOpen = ""
    var lock_grant_divided_balance = ""
    var overcharge_balance = ""//Customized users, recharge and lock in the balance. available
    var lock_position_v2_amount = ""//Token lockdown
    var coupon_balance = ""//Contract gift
    var innerTransferOpen = ""
    override func mj_keyValuesDidFinishConvertingToObject() {
//        self.withdrawAddressMap = AddressItem.mj_objectArray(withKeyValuesArray: self.withdrawAddressMap).copy() as! [AddressItem]
    }
    func isInnerTransferOpen() -> Bool {
        return withdrawOpen == "1" && innerTransferOpen == "1"
    }
}


class EXAccountBalanceModel: EXBaseModel {
    
    var totalBalanceSymbol = "--"
    var totalBalance = "--"
    var allCoinMapList :[EXAccountCoinMapItem] = []
    var allCoinMap : [String : Any] = [:] {
        didSet {
            var temp : [EXAccountCoinMapItem] = []
            for (key,value) in allCoinMap {
                if let item = value as? [String : Any] {
                    let model = EXAccountCoinMapItem.mj_object(withKeyValues: item)
                    model?.coinName = key
                    if let coinModel = model {
                        temp.append(coinModel)
                    }
                }
            }
            
            let array = temp.sorted { (model, model2) -> Bool in
                let sortNumber = [model.sort,model.coinName]
                let sortName = [model2.sort,model2.coinName]
                return sortNumber.lexicographicallyPrecedes(sortName, by: {
                    return  $0 .localizedStandardCompare($1) == .orderedAscending
                })
            }
            allCoinMapList = array
        }
    }
}

extension EXAccountBalanceModel{
    
    //Obtain currency account based on currency name
    func getItemWithCoinName(_ coinName : String) -> EXAccountCoinMapItem{
        var coinMapItem = EXAccountCoinMapItem()
        for item in allCoinMapList{
            if item.coinName == coinName{
                coinMapItem = item
            }
        }
        return coinMapItem
    }
}

