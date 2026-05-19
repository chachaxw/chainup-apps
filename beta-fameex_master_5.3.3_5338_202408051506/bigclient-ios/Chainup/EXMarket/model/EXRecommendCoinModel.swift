//
//  EXRecommendCoinModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/10/9.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
import Swap
class EXRecommendCoinModel: EXBaseModel {
    var recommendCoin:String = ""
}

class EXFavoriteRecommend: EXBaseModel{
    //Obtain contract list
    class func getSwapRecommandList() -> [RecommendItem]{
        var items = [RecommendItem]()
        if var swaps = EXSwapPublicInfo.shared.getAllSwapInfo(){
            swaps = swaps.sorted(by: { a, b in
                return a.sort < b.sort
            })
            if swaps.count > 6 {
                swaps = [EXContractsModel](swaps.prefix(6))
            }
            items = swaps.map { model -> RecommendItem in
                let item = RecommendItem()
                item.index = String(model.instrument_id)
                item.attrtitle  = model.nameAttrStr()
                item.subtitle = model.symbol
                item.sigle = true
                item.isSelected = true
                return item
            }
        }
        return items
    }
    
    //Obtain coin list
    class func getCoinRecommandList() -> [RecommendItem]{
        var items = [RecommendItem]()
        let marketCoins = EXAppMarketManager.sharedInstance.getAllShowCoinMapInfo()
        for (idx,model) in marketCoins.enumerated() {
            if idx < 6 {
                let item = RecommendItem()
                item.index = model.name.lowercased().replacingOccurrences(of: "/", with: "")
                item.attrtitle  =           String.getCoinMapAttr(model.showName,leftFont:UIFont.ThemeFont.HeadBold)
                if model.longName.count > 0 {
                    item.subtitle = model.longName
                }else {
                    item.subtitle = model.showName
                }
                item.isSelected = true
                items.append(item)
            }else {
                break
            }
        }
        return items
    }
    
    
}

