//
//  EXSStringExt.swift
//  Chainup
//
//  Created by ZYJ on 2023/11/14.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
public let DecimalOne = "1"
public let BTZERO = "0.00"
extension String {
    //MARK: 合约的面值精度 multiplier 字段 English: MARK: Multiplier field for the face value accuracy of the contract
    public func toVolumePrecision(withContractID: Int64,holdZero: Bool = true) -> String {
        if self.isEmpty {
            return ""
        }
        if withContractID != 0, let model = EXSwapPublicInfo.shared.getSwapInfo(withContractID) {
            let unit = String(EXSTools.decimalValue(px_unit: model.qty_unit))
            return self.exs_formatAmountUseDecimal(unit,holdZero:holdZero)
        }
        return self
    }
    
    public func toPricePrecision(withContractID: Int64) -> String {
        if self.isEmpty {
            return ""
        }
        if withContractID != 0, let model = EXSwapPublicInfo.shared.getSwapInfo(withContractID) {
            let unit = String(EXSTools.decimalValue(px_unit: model.px_unit))
            return  self.exs_formatAmountUseDecimal(unit)
        }
        return self
    }
    //盈亏记录专用 English: Profit and loss record only
    public  func toValuePrecision(Precision: String) -> String {
        return self.exs_formatAmountUseDecimal(Precision)
    }
    public  func toValuePrecision(withContract: Int64,holdzero: Bool = true) -> String {
        if self.isEmpty {
            return ""
        }
        if withContract != 0, let model = EXSwapPublicInfo.shared.getSwapInfo(withContract) {
            let unit = String(EXSTools.decimalValue(px_unit: model.value_unit))
            return  self.exs_formatAmountUseDecimal(unit,holdZero: holdzero)
        }
        return self
    }
    
    //市价根据 minOrderMoney_unit 计算精度 English: Market price based on minOrderMoney_ Unit calculation accuracy
    public func marketPriceVolPrecision(withContract: Int64) -> String {
        if self.isEmpty {
            return ""
        }
        if withContract != 0, let model = EXSwapPublicInfo.shared.getSwapInfo(withContract) {
//            //print(" model.minOrderMoney_unit=\( model.minOrderMoney_unit)")
            let unit = String(EXSTools.decimalValue(px_unit: model.minOrderMoney_unit))
//            //print(" unit=\(unit)")
            return  self.exs_formatAmountUseDecimal(unit)
        }
        return self
    }
    
    public func marginPrecision(marginCoin:String?,holdZero: Bool = true) -> String {
        if marginCoin == nil {
            return self
        }
        var pre = "0"
        
        if let item = EXSwapPublicInfo.shared.getContractsModelWithMarginCoin(marginCoin: marginCoin ?? ""){
            pre = item.coinResultVo.marginCoinPrecision
        }
        
        return self.exs_formatAmountUseDecimal(pre, holdZero: holdZero)
    }
}


