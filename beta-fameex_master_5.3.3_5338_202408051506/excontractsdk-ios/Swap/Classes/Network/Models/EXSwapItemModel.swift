//
//  EXSwapItemModel.swift
//  Chainup
//
//  Created by ZYJ on 2023/1/5.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

public enum EXPriceFluctuationType {
    case normal
    case up
    case down
}
public class EXSwapItemModel: EXCOBaseModel {

    public var instrument_id:Int64 = 0
    var index_px = "" // 指数价格 English: Index price
    var fair_px = ""   // 标记价格 English: Mark price
    public var symbol = ""
    public var last_px = ""
    
    var open = ""
    var close = ""
    public var low = ""
    public var high = ""
    var avg_px = ""
    var last_qty = ""
    public var qty24 = ""
    public var change_rate = ""
    var change_value = ""
    var selected = false
    func getName() -> String {
        
        if let info = ex_contractInfo {
            return symbol + " " + info.contractShowType
        }
        return ""
    }
    
    public var ex_contractInfo: EXContractsModel? {
        if instrument_id == -1 { //全部 English: whole
            let a = EXContractsModel()
            a.contractOtherName = "cp_contract_all_contracts".ex_localized()
            return a
        }
        return EXSwapPublicInfo.shared.getSwapInfo(instrument_id)
    }
    
    public func trendType() -> EXPriceFluctuationType {
            
        if change_rate.count > 0 {
            if change_rate.greaterThan(BTZERO) {
                return .up
            }else if change_rate.lessThan(BTZERO) {
                return .down
            }
        }
        return .normal
    }
    
    public func bgColor() -> UIColor {
        switch trendType() {
        case .up,.normal:
            return UIColor.ThemekLine.up15
        case .down:
            return UIColor.ThemekLine.down15
        }
        
    }
    
    public func getCurrentRate() -> (String,String,Int){
        EXSwapPlatformSDK.shared.getFiatCoinSymbolBack?()
        //获取法币symbol English: Obtain the legal currency symbol
        let symbol = EXSwapPrivateConfig.shared.fiatCoinSymbol
        if symbol == "" {
            return ("","",2)
        }
        let rateModel = EXSwapPublicInfo.shared.symboRate
        if rateModel.symbolRateList == nil {
            return ("","",2)
        }
        
        var usdtTousdRate = "1"
        if self.ex_contractInfo?.quote_coin == "usd"{
            //混合合约 English: Mixed contract
            //是usd转cny用，先usd转usdt，然后usdt转cny English: It's for converting USD to CNY. First, convert USD to USDT, and then USDT to CNY
            usdtTousdRate = rateModel.usdtToUsdRate
        }
      
        
        for item in rateModel.symbolRateList! {
            if item.quoteSymbol == symbol { //法币 English: Fiat currency
                let t =  EXSwapPrivateConfig.shared.coinInfo
                //print("item = \(item)")
                if (item.rate.isEmpty || item.rate == "0"){
                    return ("","",2)
                }
                let lang_logo = t.0 //rmb 符号 English: Rmb symbol
//                return show
                return (lang_logo,item.rate.bigMul(usdtTousdRate),2)
            }
        }
        return ("","",2)
      
    }
    
    public func showRatePrice() -> String{
        EXSwapPlatformSDK.shared.getFiatCoinSymbolBack?()
        //获取法币symbol English: Obtain the legal currency symbol
       let symbol = EXSwapPrivateConfig.shared.fiatCoinSymbol
        if symbol == "" {
            return ""
        }
        
       let rateModel = EXSwapPublicInfo.shared.symboRate
        if rateModel.symbolRateList == nil {
            return ""
        }
        
        if self.ex_contractInfo?.quote_coin == "usd"{
            //混合合约 English: Mixed contract
            //是usd转cny用，先usd转usdt，然后usdt转cny English: It's for converting USD to CNY. First, convert USD to USDT, and then USDT to CNY
            let usdtTousdRate = rateModel.usdtToUsdRate
            last_px = last_px.stringByMultiplying(multiple: usdtTousdRate, decimal: 0)
        }
      
        
        for item in rateModel.symbolRateList! {
            if item.quoteSymbol == symbol { //法币 English: Fiat currency
                let t =  EXSwapPrivateConfig.shared.coinInfo
                //print("item = \(item)")
                if (item.rate.isEmpty || item.rate == "0"){
                    return ""
                }
                let lang_logo = t.0 //rmb 符号 English: Rmb symbol
                let result = last_px.stringByMultiplying(multiple: item.rate, decimal: 2)
                let show = "≈\(lang_logo)" + result
                return show
            }
        }
        return ""
      
    }
    //获取汇率 English: Obtain exchange rate
    func getCurRate() -> EXSymboRate{
        EXSwapPlatformSDK.shared.getFiatCoinSymbolBack?()
        //获取法币symbol English: Obtain the legal currency symbol
       let symbol = EXSwapPrivateConfig.shared.fiatCoinSymbol
        if symbol == "" {
            return EXSymboRate()
        }
        
       let rateModel = EXSwapPublicInfo.shared.symboRate
        if rateModel.symbolRateList == nil {
            return EXSymboRate()
        }
        for item in rateModel.symbolRateList! {
            if item.quoteSymbol == symbol { //法币 English: Fiat currency
                if (item.rate.isEmpty || item.rate == "0"){
                    return EXSymboRate()
                }
                return item
            }
        }
        return EXSymboRate()
      
    }
    public var isCoin : Bool {
        return EXStoreData.storeBool(forKey: EXS_UNIT_VOL)
    }
    //MARK: fix
    //24小时折合usdt 可开多 面值 English: 24 hours equivalent to USDT can open multiple denominations
    public var qty24UsdValue: String{
        if qty24.count > 0 {
            //数量 * 面值 * 汇率 English: Quantity * face value * exchange rate
            var value = qty24
            if let info = ex_contractInfo {
                value = EXFormula.ticket(toCoin: qty24, contract: info)
            }
            
            let rate = getCurRate()
            return value.stringByMultiplying(multiple: rate.rate, decimal: 2)
            //            return value.count > 0 ? EXSTools.dealDataFormate(value) : "0"
        }
        return ""
    }
    
    
    
    public var qty24Volume:String {
            
        if qty24.count > 0 {
            return EXSTools.dealVolumeAmountformat(amount: qty24,model: self.ex_contractInfo)
        }
        return ""
    }
    public var qty24VolumeDisplay:String {
        return qty24Volume + " " + (ex_contractInfo?.volumeUnit ?? "")
    }
    //计价币的显示 English: Display of Pricing Currency
    public  var qty24BaseCoinUnit:String {
        var value = "--"
        if qty24.count > 0 {
            if let info = ex_contractInfo {
                value = EXFormula.ticket(toCoin: qty24, contract: info)
            }
            value = value.count > 0 ? EXSTools.dealDataFormate(value) : "0"
            return value + " " + (ex_contractInfo?.base_coin ?? "")
        }
        return value
    }
    
    
    
    
    ///24 量方法封装 2个参数必传 English: /24 quantity method encapsulates 2 mandatory parameters
    public class func qty24VolumeDisplay(instrument_id: Int64, qty24: String) ->String {
        let item = EXSwapItemModel()
        item.instrument_id = instrument_id
        item.qty24 = qty24
        return item.qty24VolumeDisplay
    }
    //搜索 English: search
    public class func getItemsWithkeyWord(kw:String) -> [EXSwapItemModel]?{
        let all = EXSwapPublicInfo.shared.getAllSwapInfo()
        if all == nil {
            return nil
        }
        var result =  [EXSwapItemModel]()
        for contract in all! {
            if contract.showName().uppercased().contains(kw.uppercased()){
                let item = contract.transToSwapModel()
                result.append(item)
            }
        }
        return result.sorted { a, b in
            return (a.ex_contractInfo?.sort  ?? 0) <  (b.ex_contractInfo?.sort  ?? 0)
        }
    }
    //配置默认的订阅数据 English: Configure default subscription data
    public func setDefaultTicerData(){
        if let subKey = self.ex_contractInfo?.subSymbol{
            if let dic = EXContractMarketReqVm.shared().wsReviewData[subKey] as? [AnyHashable : Any]{
               // //print("subKey = \(subKey) dic = \(dic)")
                if let ticker = EXCOTickerModel.yy_model(with:dic){
                    self.change_rate = ticker.rose
                    self.last_px = ticker.close
                    self.qty24 = ticker.vol
                  //  //print("ticker.rose = \(ticker.rose) ticker.close = \(ticker.close) ticker.vol =\(ticker.vol)")
                }
            }
        }
    }
    /// 从缓存中获取上一次最新的数据 English: /Retrieve the latest data from the cache
    class func refreshMaketInfo(list: [EXSwapItemModel]){
        for item in list{
            item.setDefaultTicerData()
        }
    }
}


