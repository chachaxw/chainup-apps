//
//  EXSInputItemModel.swift
//  Chainup
//
//  Created by cwd on 2022/11/14.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit

enum CalculatorVCType{
    case profirt //收益 English: income
    case forceClose //强平 English: Qiangping
    case close //平仓 English: Closing position
}

enum CalculatorInputType{
    case lever //杠杆 English: lever
    case tip
    case openPrice //开仓 English: open a granary to provide relief
    case closePrice //平仓 English: Closing position
    case amount //数量 English: quantity
    case posiAmount //仓位数量 English: Number of positions
    case availableBalance //可用余额 English: Available balance
    case reurnRate //回报率 English: Return rate
}


class EXSInputItemModel {
    var title = "" //标题 English: title
    var placeHoder = ""//占位 English: seize a seat
    var value = "" //输入的值 English: Input value
    var unit = "" //单位 English: unit
    var type = CalculatorInputType.lever
    var decimal: Int = 0 //
    
    ///获取输入框类型 English: /Get input box type
    static func getInputList(vcType: CalculatorVCType) -> [EXSInputItemModel]{
        return getAllInputList(vcType: vcType)
    }
    
    ///获取结果展示 English: /Obtaining Results Display
    
    static func getresultShowList(vcType: CalculatorVCType) -> [EXSInputItemModel]{
        
        var list = [EXSInputItemModel]()
        if vcType == .profirt {
            let a = EXSInputItemModel()
            a.title = "cp_calculator_text13".ex_localized()  //"cp_calculator_text13"="开仓保证金"; English: "Cp_calculator_text13"="Opening Margin";
            a.value = "-- USDT"
            let b = EXSInputItemModel()
            b.title = "cp_calculator_text14".ex_localized()  // "cp_calculator_text14"="收益额"; English: "Cp_calculator_text14"="Revenue amount";
            b.value = "-- USDT"
            let c = EXSInputItemModel()
            c.title = "cp_calculator_text15".ex_localized()  //  "cp_calculator_text15"="回报率"; English: "Cp_calculator_text15"="Return rate";
            c.value = "-- %"
            list = [a,b,c]

        }else if vcType == .forceClose{
            let a = EXSInputItemModel()
            a.title = "cp_calculator_text20".ex_localized()  // "cp_calculator_text20"="强平价格"; English: "Cp_calculator_text20"="Strong flat price";
            a.value = "-- USDT"
            list = [a]
        }else {
            let a = EXSInputItemModel()
            a.title = "cp_calculator_text19".ex_localized()  // "cp_calculator_text19"="平仓价格"; English: "Cp_calculator_text19"="Closing price";
            a.value = "-- USDT"
            list = [a]
        }
        return list
    }
    
    //收益 和 强平 English: Revenue and Strong Balance
    static func getAllInputList(vcType: CalculatorVCType, openMode: EXContractOpenMode = .isolated) -> [EXSInputItemModel] {
        
        var list = [EXSInputItemModel]()
        
        let lever = EXSInputItemModel()
        lever.title = "cp_content_text17".ex_localized()
        lever.placeHoder = ""
        lever.type = .lever
        
        let tip = EXSInputItemModel()
        tip.type = .tip
        tip.value = "1000" //seize a seat
        
        let openPrice = EXSInputItemModel()
        openPrice.title = "cp_calculator_text8".ex_localized()
        openPrice.placeHoder = ""
        openPrice.type = .openPrice
       
        
        let closePrice = EXSInputItemModel()
        closePrice.title = "cp_calculator_text3".ex_localized()
        closePrice.placeHoder = ""
        closePrice.type = .closePrice
       
        
        let amount = EXSInputItemModel()
        amount.title = "cp_overview_text8".ex_localized()
        amount.placeHoder = ""
        amount.type = .amount
        
        
        
        let  posiAmount = EXSInputItemModel()
        posiAmount.title = "cp_calculator_text38".ex_localized()
        posiAmount.placeHoder = ""
        posiAmount.type = .posiAmount
        
        let availableBalance = EXSInputItemModel()
        availableBalance.title = "cp_calculator_text43".ex_localized()
        availableBalance.placeHoder = ""
        availableBalance.value = ""
        availableBalance.type = .availableBalance
       
        let reurnRate = EXSInputItemModel()
        reurnRate.title = "cp_calculator_text15".ex_localized()
        reurnRate.placeHoder = ""
        reurnRate.type = .reurnRate
        
        if vcType == .profirt{
            list = [lever,openPrice,closePrice,amount]
        }else if vcType == .forceClose {
            if openMode == .isolated {
                list = [lever,openPrice,posiAmount]
            }else{
                list = [lever,tip,openPrice,posiAmount,availableBalance]
            }
           
        }else{
            list = [lever,openPrice,reurnRate]
        }
        return list
    }
    
}




class EXSwapDataViewModel:EXCOBaseModel {
    var cachesLadderInfo = [Int64:EXContractLadderInfo]()
    var updateData:(()->())?
    func fetchLadderInfo() {
        if let model = contractModel {
            //有缓存不请求 English: Cache not requested
            if let info = cachesLadderInfo[model.instrument_id]{
                self.updateSelfData(model: model, info: info)
                return
            }
            EXContractNetwork.getLadderInfo(contractId: model.instrument_id) {[weak self] (info) in
                //没办法，这里service返回就是这样 第一个ladderList其实是字典 English: There's no way, the service returns like this. The first ladderList is actually a dictionary
                guard let self = `self` else { return }
                self.updateSelfData(model: model, info: info)
            } failure: { (error) in
                
            }
        }
    }
    
    func updateSelfData(model:EXContractsModel,info: EXContractLadderInfo){
        self.leverAndMaxCoinDic = EXSTools.generateLeverAndMaxCoinDic(maxLever: model.maxLever, minLever: model.minLever, leverCeiling: info.leverCeiling)
        self.contractModel?.ladderList = info.ladderList.ladderList
        self.updateData?()
    }
    var contractModel : EXContractsModel?

    override init() {
        super.init()
       
    }
    /// 价格单位 English: /Price unit
    var priceUnit:String {
    
        return contractModel?.quote_coin ?? ""
    }
    
    /// 成本单位 English: /Cost unit
    var costUnit:String {
        return contractModel?.margin_coin ?? ""
    }
    
    /// 数量单位 English: /Quantity unit
    var volumeUnit : String {
        
        return contractModel?.volumeUnit ?? "-"
    }
    var leverAndMaxCoinDic = [String:String]()
    var leverage : String = "20"

    var itemModel : EXSwapItemModel? {
        didSet {
            if itemModel != nil {
                self.contractModel = itemModel!.ex_contractInfo
                swapType = self.contractModel?.showName() ?? ""
            }
        }
    }
    var swapType : String = "--"
    var maxCoinTipLabelText:String {
        if var value = leverAndMaxCoinDic[leverage],let  model = contractModel {
            if !model.isCoin {
                value = EXFormula.coin(toTicket: value, price: "", contract: model).toString(0)
            }else{
                value = value.toVolumePrecision(withContractID: model.instrument_id)
            }
            return  value + " " + (model.volumeUnit)
        }
        return ""
    }
}

    

