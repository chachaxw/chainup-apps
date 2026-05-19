//
//  EXSwapPublicInfo.swift
//  Chainup
//
//  Created by ZYJ on 2023/11/14.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

public class EXSwapPublicInfo {
    
    static let `manager` = EXSwapPublicInfo()
    open class var shared: EXSwapPublicInfo {
        return manager
    }
    private var swapDict = [Int64:EXContractsModel]()
    public var facePrecisionDict = [Int64:Int]()//面值精度 English: Face value accuracy
    private var tickerDict = [Int64:EXSwapItemModel]()
    private var orderBooks = EXDepthModel()
    var languages = [EXSLanguageModel]()
    public var symboRate = EXSymboRateList()
    public var marginCoinList = [String]()
    public var maiginOrignPair = [String: String]()
    public var onChangeCoinsCallback: (() -> Void)?
    var localAndRemoteTimeInterval:TimeInterval = 0
//    private var orderBooks = []()
    var infoModel = EXPublicInfoModel() //新加的便于扩展 English: Newly added for easy expansion

    func setSwapInfo(_ swapArr: [EXContractsModel]) {
        swapDict.removeAll()
        for model in swapArr {
            
            swapDict[model.instrument_id] = model
                //保证金别名-> 保证金原名 English: Deposit alias ->Deposit original name
            if !model.marginCoin.isEmpty && !model.originalCoin.isEmpty{
                maiginOrignPair[model.marginCoin] = model.originalCoin
            }
        }
        onChangeCoinsCallback?()
       // print("maiginOrignPair =\(maiginOrignPair)")
    }
  
    //获取所有的 EXContractsModel English: Get all EXContractsModels
    public func getAllSwapInfo() -> [EXContractsModel]? {
        var ret = [EXContractsModel]()
        for v in swapDict.values {
            ret.append(v)
        }
        if ret.count > 0 {
            return ret
        }else {
            
            return nil
        }
    }
    
    public func getItemWithOrginSymbol(orginCode: String) -> EXContractsModel?{
        for item in self.infoModel.contractList{
            if orginCode == item.originalCoin{
                return item
            }
        }
        return nil
    }
    ////获取所有的 EXSwapItemModel English: Get all EXSwapItemModels
    public func getAllSwapTickers() -> [EXSwapItemModel]? {
        let allInfo = self.getAllSwapInfo()
        if let list = allInfo, list.count > 0 {
            var tickers = [EXSwapItemModel]()
            for item in list {
                let itemModel = EXSwapItemModel()
                itemModel.instrument_id = item.instrument_id;
                itemModel.symbol = item.symbol;
//                itemModel.ex_contractInfo = item;
                tickers.append(itemModel)
            }
            return tickers
        }
        return nil
    }
    
    func getSwapInfo(_ id:Int64) -> EXContractsModel? {
        
        return swapDict[id]
    }
    
    func setMarketTickers(_ tickers:[EXSwapItemModel]) {
        for ticker in tickers {
            tickerDict[ticker.instrument_id] = ticker
        }
    }
    
    func getTicker(_ id:Int64) ->EXSwapItemModel? {
        return tickerDict[id]
    }
    
    func deleteTicker(_ id:Int64) {
        tickerDict.removeValue(forKey: id)
    }
    
    
    func getSwapOrigin(_ id:Int64) -> String? {
        let item = self.getSwapInfo(id)
        if item == nil{
            return nil
        }
        return item!.originalCoin
    }
    //获取自选 English: Get Selected
    func getFavirate(ids: [String]) -> [EXSwapItemModel]?{
        if ids.count == 0 {
            return nil
        }
        var temp = [EXSwapItemModel]()
        for id in ids {
            if id.isEmpty {
                continue
            }
            let swap = self.getTicker(Int64(id)!)
            if swap != nil{
                temp.append(swap!)
            }
        }
        return temp
    }
    
    
    func getTickersWithArea(_ area:BTContract_Block_Type) -> [EXSwapItemModel]? {
        
        if area == .CONTRACT_BLOCK_ALL { //全部 添加一个数据源 English: Add a data source for all
            
            let item = EXSwapItemModel()
            item.instrument_id = -1
            return [item]
        }
        
        var retArr = [EXSwapItemModel]()
        for ticker in tickerDict.values {
            
            if area == .CONTRACT_BLOCK_UNKOWN {
                retArr.append(ticker)
            }else if ticker.ex_contractInfo?.area == area {
                retArr.append(ticker)
            }
        }
        if retArr.count > 0 {
            
            return retArr.sorted { a, b in
                a.instrument_id < b.instrument_id
            }
        }else {
            return nil
        }
    }
    
    func setOrderBookAsks(_ asks:[EXOrderBookModel]?) {
        if let askArr = asks,askArr.count > 0 {
            orderBooks.sells = askArr
        }else{
            orderBooks.sells = [EXOrderBookModel]()
        }
    }
    func setOrderBookBids(_ bids:[EXOrderBookModel]?) {
        if let bidArr = bids,bidArr.count > 0 {
            orderBooks.buys = bidArr
        }else{
            orderBooks.buys = [EXOrderBookModel]()
        }
    }
    
    func getAskOrderBooks(_ count:Int) -> [EXOrderBookModel]? {
        
        if (count == 0) {
            return self.orderBooks.sells;
        }
        
        if self.orderBooks.sells.count == 0 {
            return nil
        }
        
        if (self.orderBooks.sells.count > count) {
            let result:[EXOrderBookModel] = Array(self.orderBooks.sells[0...count])
            return result;
        }
        return self.orderBooks.sells;
        
    }
    
    func getBidOrderBooks(_ count:Int) -> [EXOrderBookModel]? {
        
        if (count == 0) {
            return self.orderBooks.buys;
        }
        if self.orderBooks.buys.count == 0 {
            return nil
        }
        if (self.orderBooks.buys.count > count) {
            
            let result:[EXOrderBookModel] = Array(self.orderBooks.buys[0...count])
           
            
            return result;
        }
        return self.orderBooks.buys;
        
    }
    
    func clearOrderBooks() {
        
        self.orderBooks.sells = [EXOrderBookModel]();
        self.orderBooks.buys = [EXOrderBookModel]()
    }
}

extension EXSwapPublicInfo {
    
    private struct AssociatedKeys {
        static var marginCoinList: String?
        static var localAndRemoteTimeInterval:TimeInterval = 0

    }
    
    public func getContractsModelWithMarginCoin(marginCoin:String) -> EXContractsModel? {
        
        if let  allInfo = self.getAllSwapInfo() {
            
            for item in allInfo {
                if item.margin_coin == marginCoin {
                    return item
                }
            }
            
        }
        return nil
    }
 
    public func getSortTickers(area:BTContract_Block_Type) -> [EXSwapItemModel]? {
        
        if var tickers = getTickersWithArea(area), tickers.count > 0 {
            
            tickers.sort { (first, second) -> Bool in
                if let firstInfo = first.ex_contractInfo,
                   let secondInfo = second.ex_contractInfo {
                    return firstInfo.sort < secondInfo.sort
                }
                return first.instrument_id < second.instrument_id
            }
            return tickers
        }
        return nil
    }
    
    public func getSortAreaArray() -> [BTContract_Block_Type] {
        return [.CONTRACT_BLOCK_USDT, .CONTRACT_BLOCK_STAND, .CONTRACT_BLOCK_INVERSE, .CONTRACT_BLOCK_SIMULATION]
    }
}


