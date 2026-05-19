//
//  EXStoreData.swift
//  Chainup
//
//  Created by ZYJ on 2023/1/8.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
let swapComfirmAlert = "swapComfirmAlert"//合约二次确认框 English: Contract secondary confirmation box
let swapKlineHistoryShow = "swapKlineHistoryShow"//历史委托显示 English: Historical delegation display
let swapAsset = "swapAsset"//合约资产 English: Contract assets
let swapTPSLComfirmAlertNotTip = "swapTPSLComfirmAlert"//合约二次确认框 English: Contract secondary confirmation box
public let EX_DATE_CYCLE = "EX_DATE_CYCLE" // 计算委托时间周期 English: Calculate the delegation time period
let EX_XUUID = "EX_XUUID"//设备id English: Device ID
let contract_market_selectId = "contract_market_selectId" //行情列表 默认选中自选,以后根据用户选择 English: The market list is selected as self selected by default, and in the future, it will be based on user selection
let contract_market_opened = "contract_market_opened" //第一次进入选择市场列表 English: First time entering the selection market list
let contract_filter_selectId = "filter_selectId" // 币对筛选记录选中的那一个tab English: The selected tab for coin pair filtering records
let contract_chart_hasSeted = "contract_chart_hasSet" //首页k 用户是否设置过 English: Has user k on the homepage been set
let contract_chart_top = "contract_chart_top" // 首页k 线是否居上 English: Is the K-line on the homepage on top
let contract_chart_open = "contract_chart_open" //首页k 是否显示 English: Is the homepage k displayed
let smallklineScaleKeyIndex = "smallklineScaleKeyIndex" //首页k 线 选中的时间 index /为避免与币币冲突 English: The time index selected by the K-line on the homepage/To avoid conflicts with coins
let contract_newfunction_first =  "contract_newfunction_first" //
let contract_transfer_todayTiped =  "contract_transfer_todayTiped" //提醒入金今天是否提示过 English: Did you remind me to deposit today
let contract_transfer_lastTipDay =  "contract_transfer_lastTipDay" //提醒入金的日期 English: Reminder of deposit date
let contract_stopLossAndProfit_firstTiped = "contract_stopLossAndProfit_firstip" //止盈止损是否提示过 English: Has the stop loss and profit warning been given
let contractCollectionCoinMaySymbols = "contractsCollectionCoinMaySymbols" //收藏合约币对symbol English: Collect contract coins for symbol
let positionOnlyCurrentContract = "positionOnlyCurrentContract" //当前持仓仅当前合约 English: Current position only for current contracts
let currentEntrustOnlyCurrentContract = "currentEntrustOnlyCurrentContract" //当前委托仅当前合约 English: The current commission only applies to the current contract
let planEntrustOnlyCurrentContract = "planEntrustOnlyCurrentContract" //计划委托仅当前合约 English: Planned commission only for the current contract
let klineGuide = "klineGuide" //计划委托仅当前合约 English: Planned commission only for the current contract

public class EXStoreData {
    
    
    public class func setStoreObjectAndKey(_ object: Any!, key: String!) {
        UserDefaults.standard.setValue(object, forKey: key)
        UserDefaults.standard.synchronize()
        
    }
    public class func storeObject(forKey:String) -> Any? {
        let a = UserDefaults.standard.object(forKey: forKey);
        return a;
    }
    public class func stirngObject(forKey key: String!) -> String? {
        return UserDefaults.standard.string(forKey: key)
    }
    
    public class func storeBool(forKey key: String!) -> Bool {
        return UserDefaults.standard.bool(forKey: key)
    }
    public class func clearObject(forKey key: String!) {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    public class func storeInt(forKey key: String!) -> Int {
        return UserDefaults.standard.integer(forKey: key)
    }
    
}
///币种自选相关 English: /Currency selection related
extension EXStoreData {
    
    //当账户切换时删除上一个用户的偏好记录 English: Delete the previous user's preference record when switching accounts
    class func clearUserPreference(){
        //清空 English: empty
        EXStoreData.setStoreObjectAndKey(false, key: currentEntrustOnlyCurrentContract)
        EXStoreData.setStoreObjectAndKey(false, key: planEntrustOnlyCurrentContract)
        EXStoreData.setStoreObjectAndKey(false, key: positionOnlyCurrentContract)
        EXStoreData.setStoreObjectAndKey(0, key: HAS_OPNE_CONTRACT)

    }
    public class func getContractNewfunctionFirstTiped() -> Bool{
        return EXStoreData.storeBool(forKey: contract_newfunction_first)
    }
    
    public class func setContractNewfunctionFirstTiped() {
        EXStoreData.setStoreObjectAndKey(true, key: contract_newfunction_first)
    }
    /**
     获取k English: Get k
     顶部是否显示 English: Is the top displayed
      
     */
    public class func getSmallKlineShowTop() -> Bool{
        //打开k 线显示 English: Open K-line display
        let open = EXStoreData.storeBool(forKey: contract_chart_open)
        if  open == false{
            return false
        }
        let showtop = EXStoreData.storeBool(forKey: contract_chart_top)
        return showtop
    }
    /**
     获取k 是否显示 English: Obtain whether k is displayed
     */
    public class func getSmallKlineShow() -> Bool{
        let open = EXStoreData.storeBool(forKey: contract_chart_open)
        return open
    }
    /**
     获取k 底部是否显示 English: Obtain whether the bottom of k is displayed
     */
    public class func getSmallKlineShowBottom() -> Bool{
        let open = EXStoreData.storeBool(forKey: contract_chart_open)
        if open == false{ //
            return false
        }
        //打开k 线显示 English: Open K-line display
        let top = EXStoreData.storeBool(forKey: contract_chart_top)
        return !top
    }
    
    //获取收藏的币对id English: Get the ID of the favorite coin pair
    public class func getCollectionCoinMap() -> [String] {
        if let array = EXStoreData.storeObject(forKey: contractCollectionCoinMaySymbols) as? [String]{
            return array.filter({return $0.count > 0})
        }
        return []
    }
    
    //覆盖收藏币对 English: Overwrite Favorite Coin Pairs
    public class func renewFavorites(_ swapIds:[String]){
        EXStoreData.setStoreObjectAndKey(swapIds, key: contractCollectionCoinMaySymbols)
    }
    
    //收藏币对 English: Collection Coin Pair
    public class func collectionCoinMap(_ swapId : String){
        if swapId.isEmpty {
            return
        }
        var array = getCollectionCoinMap()
        if array.contains(swapId) == false{
            array.append(swapId)
            EXStoreData.renewFavorites(array)
        }
    }
    
    //取消收藏 English: Cancel Favorite
    public class func cancelCollectionCoinMap(_ swapId : String){
        if swapId.isEmpty {
            return
        }
        var array = getCollectionCoinMap()
        if array.contains(swapId){
            if let index = array.firstIndex(of: swapId) , array.count > index{
                array.remove(at: index)
            }
        }
        EXStoreData.renewFavorites(array)
    }
    
    //判断是否收藏 English: Determine whether to bookmark
    public class func whetherCollectionCoinMap(_ swapId : String) -> Bool{
        let array = getCollectionCoinMap()
        if array.contains(swapId){
            return true
        }
        return false
    }
    
}
extension EXStoreData {
    //获取是否合约二次确认框 English: Obtain the second confirmation box for contract confirmation
    public class func getOnComfirmSwapAlert() -> Bool {
        if let str = storeObject(forKey: swapComfirmAlert) as? String {
            if str == "" {
                return true
            } else if str == "1" {
                return true
            } else {
                return false
            }
        }
        return true
    }
   
    //设置是否合约二次确认框 English: Set whether to confirm the contract with a secondary confirmation box
    public class func setComfirmSwapAlertStatus(_ status : Bool){
        if status == true {
            setStoreObjectAndKey("1", key: swapComfirmAlert)
        } else {
            setStoreObjectAndKey("0", key: swapComfirmAlert)
        }
    }
    
    //清楚本地的合约语言包 English: Clear local contract language pack
    public class func clearLocalLanguageDefaultsData(){
        let userDefaults = UserDefaults.standard
        let list = userDefaults.dictionaryRepresentation()
        for dic in list {
            let key = dic.key
            let prefix = "swap_dl"
            if key.starts(with: prefix){
                userDefaults.removeObject(forKey: key)
                userDefaults.synchronize()
            }
        }
    }
    
    
    //开启关闭资产 English: Open and close assets
    public class func switchAssets(_ bool : Bool){
        if bool == true{//开启 English: open
            setStoreObjectAndKey("1", key: swapAsset)
        }else{//关闭 English: close
            setStoreObjectAndKey("0", key: swapAsset)
        }
    }
    
    //查询资产状态 English: Query asset status
    public class func assetPrivacyIsOn () -> Bool{
        if let a = EXStoreData.stirngObject(forKey: swapAsset),a == "1"{
            return true
        }else{
            return false
        }
    }
}

