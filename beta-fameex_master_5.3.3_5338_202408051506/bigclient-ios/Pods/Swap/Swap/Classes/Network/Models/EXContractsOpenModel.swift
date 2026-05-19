//
//  EXContractsOpenModel.swift
//  Chainup
//
//  Created by ZYJ on 2023/11/11.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXContractsOpenModel: EXCOBaseModel {
    
    var freezAssets = ""
    var maxOpenLong = "0" //最大可开以币为单位 English: The maximum amount that can be opened is in coins
    var maxOpenShort = "0"
    var maxOpenValue = "" //最大的可开价值 English: Maximum exploitable value
    
    init(orderModel: EXContractOrderModel, contractInfo: EXContractsModel, assets asset: EXCItemCoinModel) {
        super.init()
        calculateAdvanceOpenCost(withOrder: orderModel, contractInfo: contractInfo, assets: asset)
    }
    
    func calculateAdvanceOpenCost(withOrder orderModel: EXContractOrderModel, contractInfo: EXContractsModel, assets asset: EXCItemCoinModel) {
        //print("asset = \(asset.canUseAmount)")
        let position = EXFormula.getUserPosition(withCoinCode: orderModel.ex_contractInfo?.margin_coin ?? "", contractID: orderModel.instrument_id, contractWay: orderModel.side)
        var price = orderModel.px
        if price.count > 0 {
            
            if orderModel.category == .plan {
                
                price = orderModel.exec_px
            }
            
            var orderValue = EXFormula.calculateContractValue(withVol: orderModel.qty, price: price, contract: contractInfo)
            
            if orderModel.category == .market || orderModel.category == .planMarket {
                
                orderValue = orderModel.qty
            }
            if orderModel.openOrderType == .value{
                orderValue = orderModel.qty
            }
            if orderValue.greaterThan(BTZERO) {
                freezAssets = orderValue.bigMul(contractInfo.marginRate).bigDiv(orderModel.leverage).toValuePrecision(withContract: contractInfo.instrument_id,holdzero: false)
            }
            if orderModel.side == .buy_OpenLong {
                maxOpenLong = EXFormula.calculateVolume(withAsset: asset.canUseAmount, price: price, lever: orderModel.leverage, position: position, contractInfo: contractInfo)
//                //print(" maxOpenLong = \(maxOpenLong)")
            }else if orderModel.side == .sell_OpenShort {
                maxOpenShort = EXFormula.calculateVolume(withAsset: asset.canUseAmount, price: price, lever: orderModel.leverage, position: position, contractInfo: contractInfo)
//                //print(" maxOpenShort = \(maxOpenShort)")
            }
            //最大可开价值 English: Maximum exploitable value
            var num = asset.canUseAmount.bigMul(orderModel.leverage)
            if !contractInfo.isReverse {
                num = num.bigDiv(contractInfo.marginRate)
            }
            maxOpenValue = num
//            //print("maxOpenValue = \(maxOpenValue)")
        }
    }
}

