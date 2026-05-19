//
//  EXAppMarketVM.swift
//  Chainup
//
//  Created by liuxuan on 2023/9/8.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import EXKit
//币对 English: Coin pairs
public class EXSCoinMapEntity: EXCOBaseModel {
    var isSwap = false //是否是合约 English: Is it a contract
    var app_serial_number:Int = -1
    
    var volume = ""//卖的数量精度 English: Quantity accuracy of sales
    
    var symbol = ""
    
    var name = ""//币对名字 English: Coin pair name
    
    var limitPriceMin = ""//最低价格 English: Lowest price
    
    var marketSellMin = ""//最少价格 English: Minimum price
    
    var sort = ""
    
    var doubleSort : Double = 1000
    
    var price = ""//买的价格精度 English: Purchase price accuracy
    
    var marketBuyMin = ""
    
    var limitVolumeMin = ""
    
    var depth = ""
    
    var depthArray : [Int] = []
    var depthArrayShow : [String] = []

    var coinName = ""//基础货币名字 English: Base currency name
    
    var marketName = ""//市场名字 English: Market name
    
    var newcoinFlag = "0"//0主区 1创新区 2观察区 3减半区 English: 0 main area 1 innovation area 2 observation area 3 halving area
    
    var isShow = "1"//是否列表展示 1是 0否 English: Is the list displaying 1 Yes 0 No
    
    var showName = ""//别名 English: alias
    
    var multiple = ""//杠杆默认倍数 English: Default leverage multiple
    
    var isOpenLever = ""//杠杆开关，0关闭，1开启 English: Lever switch, 0 closed, 1 open
    
    var etfOpen = ""//是否为etf市场币对 0不是 1是 English: Is it ETF market currency pair 0, not 1? Yes

    var is_grid_open = ""//网格开关，0关闭，1开启 English: Grid switch, 0 off, 1 on
    var fundRate = ""//资金费率 English: Fund rate
    var longName = "" //全名 English: full name
    var etfBase:String = ""
    var etfMultiple:String = ""
    var etfSide:String = ""
    var etfUpAndDown:[String] = []
    
    func getAllSymbolsAndETFs() -> [String] {
        var tickers = self.symbol
        if self.etfUpAndDown.count > 0 {
            let etf = etfUpAndDown.joined(separator: ",")
            tickers.append(",\(etf)")
        }
        return tickers.components(separatedBy: ",")
    }
    
//    func marketEntity() -> CoinListEntity {
//        return EXAppMarketManager.sharedInstance.getCoinEntity(marketName) ?? CoinListEntity()
//    }
//    
//    func coinListEntity() -> CoinListEntity {
//        return EXAppMarketManager.sharedInstance.getCoinEntity(coinName) ?? CoinListEntity()
//    }
    
    public override func mj_keyValuesDidFinishConvertingToObject() {
        if showName == "" {
            showName = name
        }
        if let double = Double(sort){
            doubleSort = double
        }
        truncationDepth(depth)

        let array = self.name.components(separatedBy: "/")
        if array.count > 0{
            coinName = array[0]
//            coinListEntity = EXAppMarketManager.sharedInstance.getCoinEntity(coinName) ?? CoinListEntity()
        }
        if array.count > 1{
            marketName = array[1]
//            marketEntity = PublicInfoManager.sharedInstance.getCoinEntity(marketName) ?? CoinListEntity()
        }
        
        if self.depthArray.count > 0 {
            self.depthArrayShow = self.depthArray.map({ item -> String in
                return "1".mapPrecision(String(item) )
            })
        }
    }
    
    //截断 English: truncation
    func truncationDepth(_ depth : String){
        let array = depth.components(separatedBy: ",")
        for item in array{
            let s = item.replacingOccurrences(of: ".", with: "")
            depthArray.append(s.count - 1)
        }
    }
    
    func priceDecimal() ->Int {
        return Int(price) ?? 8
    }
    
    func volDecimal() ->Int {
        return Int(volume) ?? 8
    }
}

