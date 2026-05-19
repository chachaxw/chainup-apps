//
//  EXSwapPersonInfo.swift
//  Chainup
//
//  Created by ZYJ on 2023/1/8.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

public class EXSwapPersonInfo {
    
    static let `manager` = EXSwapPersonInfo()
    public class var shared: EXSwapPersonInfo {
        
        return manager
    }
    var historyKlineDataDict = [Int64:EXKlineOrderList](); // 仓位(合约id为key) English: Position (Contract ID is key)
    var positionDict = [Int64:[EXSwapPositionModel]](); // 仓位(合约id为key) English: Position (Contract ID is key)
    var coinPositionDict = [String:[EXSwapPositionModel]](); // 仓位(保证金币种为key) English: Position (with guaranteed gold currency as key)
    var swapOrderDict = [Int64:[EXContractOrderModel]]();   // 当前订单(合约id为key) English: Current order (contract ID is key)
    var swapPlanOrderDict = [Int64:[EXContractOrderModel]]();   // 当前订单(合约id为key) English: Current order (contract ID is key)
    var swapAssetDict = [String:EXCItemCoinModel]();   // 合约资产 English: Contract assets
    
    //MARK:- 合约仓位 English: MARK: - Contract Position
    func setPositions(_ positions: [EXSwapPositionModel]!, instrumentID instrument_id: Int64) {
        if (instrument_id <= 0) {
            return;
        }
        if (positions.count > 0 ) {
            self.positionDict[instrument_id] = positions
        } else {
            self.positionDict.removeValue(forKey: instrument_id)
        }
    }
    
    func getPositions(_ instrument_id: Int64) -> [EXSwapPositionModel]? {
        if (instrument_id <= 0) {
            return nil;
        }
        return self.positionDict[instrument_id]
    }
    
    func setPositions(_ positions: [EXSwapPositionModel]!, marginCoin: String!) {
        if (marginCoin == nil) {
            return;
        }
        if (positions.count > 0 ) {
            self.coinPositionDict[marginCoin] = positions
        } else {
            self.coinPositionDict.removeValue(forKey: marginCoin)
        }
    }
    func getCodePositions(_ marginCoin: String!) -> [EXSwapPositionModel]? {
        if (marginCoin == nil) {
            return nil;
        }
        if (self.coinPositionDict.keys.contains(marginCoin)) {
            return self.coinPositionDict[marginCoin]
        }
        return nil;
    }
    
    func removeAllCodePositions() {
        self.coinPositionDict.removeAll()
    }
    func removeAllPositions() {
        self.positionDict.removeAll()
    }
    //MARK:- k 线委托订单 English: MARK: - K-line commission order
    func setKlineOrders(_ orders: EXKlineOrderList, instrumentID instrument_id: Int64) {
        if (instrument_id <= 0) {
            return
        }
        if (orders.orderList.count > 0) {
            self.historyKlineDataDict[instrument_id] = orders
        } else {
            if (self.historyKlineDataDict.keys.contains(instrument_id)) {
                self.historyKlineDataDict.removeValue(forKey: instrument_id)
            }
        }
    }
    func getKlineOrders(_ instrument_id: Int64) -> EXKlineOrderList? {
        if (instrument_id <= 0) {
            return nil
        }
        if (self.historyKlineDataDict.keys.contains(instrument_id) ) {
            return self.historyKlineDataDict[instrument_id]
        }
        return nil
    }
    
    //MARK:- 委托订单 English: MARK: - Commissioned orders
    func setOrders(_ orders: [EXContractOrderModel]!, instrumentID instrument_id: Int64) {
        if (instrument_id <= 0) {
            return;
        }
        if (orders.count > 0 ) {
            self.swapOrderDict[instrument_id] = orders
        } else {
            if (self.swapOrderDict.keys.contains(instrument_id)) {
                self.swapOrderDict.removeValue(forKey: instrument_id)
            }
        }
    }
    func getOrders(_ instrument_id: Int64) -> [EXContractOrderModel]? {
        if (instrument_id <= 0) {
            return nil;
        }
        if (self.swapOrderDict.keys.contains(instrument_id) ) {
            return self.swapOrderDict[instrument_id];
        }
        return nil;
    }
    //MARK:- 计划委托订单 English: MARK: - Planned commission order
    func setPlanOrders(_ orders: [EXContractOrderModel]!, instrumentID instrument_id: Int64) {
        if (instrument_id <= 0) {
            return;
        }
        if (orders.count > 0 ) {
            self.swapPlanOrderDict[instrument_id] = orders
            
        } else {
            if (self.swapPlanOrderDict.keys.contains(instrument_id)) {
                self.swapPlanOrderDict.removeValue(forKey: instrument_id);
            }
        }
    }
    func getPlanOrders(_ instrument_id: Int64) -> [EXContractOrderModel]! {
        if (instrument_id <= 0) {
            return nil;
        }
        if (self.swapPlanOrderDict.keys.contains(instrument_id)) {
            return self.swapPlanOrderDict[instrument_id];
        }
        return nil;
    }
    //MARK:- 合约资产 English: MARK: - Contract Assets
    func setSwapAssets(_ swapAssets: [EXCItemCoinModel]!) {
        for coinItem in swapAssets {
            self.swapAssetDict[coinItem.coin_code] = coinItem
        }
    }
    
    func setSwapAsset(_ swapAsset: EXCItemCoinModel!, marginCode: String!) {
        
        self.swapAssetDict[marginCode] = swapAsset
    }
    func getSwapAssetItem(withCoin coinCode: String!) -> EXCItemCoinModel! {
        if (coinCode.isEmpty) {
            return nil;
        }
        
        if (!self.swapAssetDict.keys.contains(coinCode)) {
            return nil;
        }
        return self.swapAssetDict[coinCode];
    }
    
    public func getAllSwapAssetItem() -> [EXCItemCoinModel]? {
        return Array(self.swapAssetDict.values)
    }
    //MARK:- 清除用户资产数据 English: MARK: - Clear user asset data
    public func clearPersonalSwapInfo() {
        self.positionDict.removeAll()
        self.coinPositionDict.removeAll()
        self.swapOrderDict.removeAll()
        self.swapAssetDict.removeAll()
    }
}

