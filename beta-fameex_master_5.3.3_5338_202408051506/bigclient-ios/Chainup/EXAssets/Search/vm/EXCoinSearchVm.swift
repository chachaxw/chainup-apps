//
//  EXCoinSearchVm.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/16.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import Swap
enum EXCoinSearchSourceType {
    case sourceForDeposit //Recharge currency
    case sourceForWithdraw //Withdrawal of currency
    case internalTransfer //Direct transfer within the station
    case sourceForAll //All
}

class EXCoinSearchVm: NSObject {
    
    var sourceType:EXCoinSearchSourceType = .sourceForAll
    
    func getFirstCoinModel(_ accountType:EXAccountType = .coin) -> CoinListEntity {
        let allcoins = self.getCoinDataSource(accountType)
        if accountType == .contract {
            for item in allcoins.values {
                for subItem in item {
                    
                    if subItem.name == "USDT" {
                        return subItem
                    }
                }
            }
        }
        let alphaKeys = Array(allcoins.keys).sorted(by: <)
        if alphaKeys.count > 0 {
            
            let firstKey = alphaKeys[0]
            
            if let coinLists = allcoins[firstKey] {
                if coinLists.count > 0 {
                    
                    return coinLists[0]
                }
            }
        }
        return CoinListEntity()
    }
    
    func getCoinDataSource(_ accountType:EXAccountType = .coin) -> [String:[CoinListEntity]] {
        let coins = EXAppMarketManager.sharedInstance.getAllCoinList()
        var allCoins:[String:[CoinListEntity]] = [:]
        var sorted = coins.sorted { $0.name < $1.name }
        var subsetCoins:[String] = []
        if accountType == .otc {
            let otccoins = EXAppMarketManager.sharedInstance.getAllOTCCoinList()
            for otcItem in otccoins {
                subsetCoins.append(otcItem.name)
            }
        }else if accountType == .contract {
            //Swap obtains user contract activation asset currency
            for item in EXSwapPersonInfo.shared.getAllSwapAssetItem() ?? [] {
                subsetCoins.append(item.coin_code)
            }
            var swapSorted = [CoinListEntity]()
            if coins.count == 0 {
                for item in EXSwapPersonInfo.shared.getAllSwapAssetItem() ?? [] {
                    let entity = CoinListEntity()
                    entity.name = item.coin_code
                    swapSorted.append(entity)
                }
                sorted = swapSorted.sorted { $0.name < $1.name }
                
            }
        }else if accountType == .coin {
            let balanceMap = EXAccountBalanceManager.manager.accountModel.allCoinMapList
            if sourceType == .sourceForDeposit {
                let openDepositCoins = balanceMap.filter({ (item) -> Bool in
                    return item.depositOpen == "1"
                })
                for depositOn in openDepositCoins {
                    subsetCoins.append(depositOn.coinName)
                }
            }else if sourceType == .sourceForWithdraw {
                let openWithdraws = balanceMap.filter({ (item) -> Bool in
                    return item.withdrawOpen == "1"
                })
                for withdrawOn in openWithdraws {
                    subsetCoins.append(withdrawOn.coinName)
                }
            }else if sourceType == .internalTransfer{
                let openWithdraws = balanceMap.filter({ (item) -> Bool in
                    return item.isInnerTransferOpen()
                })
                for withdrawOn in openWithdraws {
                    subsetCoins.append(withdrawOn.coinName)
                }
            }
        }
        for item in sorted {
            if subsetCoins.count > 0 {
                if subsetCoins.contains(item.name) {
                    let alpha = String(item.name.prefix(1))
                    if var itemList = allCoins[alpha] {
                        itemList.append(item)
                        allCoins[alpha] = itemList
                    }else {
                        allCoins[alpha] = [item]
                    }
                }
            }else {
                
                let alpha = String(item.name.prefix(1))
                if var itemList = allCoins[alpha] {
                    itemList.append(item)
                    allCoins[alpha] = itemList
                }else {
                    allCoins[alpha] = [item]
                }
            }
        }
        return allCoins
    }

}

