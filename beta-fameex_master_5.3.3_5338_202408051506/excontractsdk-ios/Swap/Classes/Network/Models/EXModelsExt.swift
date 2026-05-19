//
//  EXModelsExt.swift
//  Chainup
//
//  Created by ZYJ on 2023/11/8.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit


extension EXSwapPositionModel {
    
    var isCoin : Bool {
        return EXStoreData.storeBool(forKey: EXS_UNIT_VOL)
    }
 
    var curQtyVolume:String {
           
        return ex_contractInfo?.volumeDisplay(vol: cur_qty) ?? ""
    }
   
    var canCloseVolumeDisplay:String {
        
        return ex_contractInfo?.volumeDisplay(vol: canCloseVolume) ?? ""
    }
    
    
    func closeMinValueLimit(input: String) -> (Bool,String) {
        //最大平仓量校验   canCloseVolumeDisplay 张和币已转化过了 English: The maximum closing position verification canClosevolueDisplay Zhang and coins have been converted
//        EXLogLine(message: "input =\(input) , canCloseVolumeDisplay =\(canCloseVolumeDisplay)")
        if input.greaterThan(canCloseVolumeDisplay){
            return (false, "order_placement_text9".ex_localized())
        }
        //下单最小量校验 English: Minimum order quantity verification
        if let ex = self.ex_contractInfo{
            var min = ex.coinResultVo.minOrderVolume //返回的是张 /币前端来转化 English: Returned is the front-end conversion of Zhang/coin
            if isCoin{ //张转成币 English: Zhang converted into coins
                min = EXFormula.ticket(toCoin: min, contract: ex)
                if input.lessThan(min){
                    let tip = "order_placement_text7".ex_localized() + " " + min + " " + ex.volumeUnit// ex.marginCoin
                    return (false,tip)
                }
            }else{
                
                if input.lessThan(min) {
                    let tip = "order_placement_text7".ex_localized() + " " + min + " " + "cp_overview_text9".ex_localized()
                    return (false,tip)
                }
            }
        }
        return (true,"")
    }
    
}

extension EXContractsModel {
    var isCoin : Bool {
        return EXStoreData.storeBool(forKey: EXS_UNIT_VOL)
    }
 
    /// 数量单位 English: /Quantity unit
    var volumeUnit : String {
        if isCoin == false {
            return "cp_overview_text9".ex_localized()
        }
        return base_coin
    }
    
    var volumeDecial : String {
        if isCoin == false {
            return "0"
        }
        return qty_unit
    }
    var isVolumeDecialOne: Bool {
        return !volumeDecial.contains(".")
    }
    //vol 的 单位为张 English: The unit of vol is Zhang
    func volumeDisplay(vol:String) -> String {
        
        if isCoin {
            let value = EXFormula.ticket(toCoin: vol, contract: self)
            return value.toVolumePrecision(withContractID: instrument_id)
        }
        
        return vol.toString(0)
    }
    
    // 0.001 -> 1
    func orignVolum(vol: String) -> String{
        if isCoin {
            let value = EXFormula.coin(toTicket: vol,contract: self)
            return value.toVolumePrecision(withContractID: instrument_id)
        }
        return vol
    }
}

extension EXContractOrderModel {
    
    var isCoin : Bool {
        return EXStoreData.storeBool(forKey: EXS_UNIT_VOL)
    }
    
    var qtyDisplay:String {
        return ex_contractInfo?.volumeDisplay(vol: qty) ?? "0"
    }
    
    var cumQtyDisplay:String {
            
        return ex_contractInfo?.volumeDisplay(vol: cum_qty) ?? "0"
    }
}

