//
//  EXFormula.swift
//  Chainup
//
//  Created by ZYJ on 2023/11/8.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
@objcMembers class EXFormula: EXCOBaseModel {
     class func getUserPosition(withCoinCode codeCoin: String, contractID: Int64, contractWay way: BTContractOrderWay) -> EXSwapPositionModel? {
        if let positionArr = EXSwapPersonInfo.shared.getPositions(contractID) {
            
            if(way == .buy_OpenLong) {
                
                for model in positionArr {
                    if (contractID == model.instrument_id) {
                        if (model.side == .openMore) {
                            return model;
                        }
                    }
                }
            } else if (way == .sell_OpenShort) {
                for model in positionArr {
                    if (contractID == model.instrument_id) {
                        if (model.side == .openEmpty) {
                            return model;
                        }
                    }
                }
            }
            
        }
        return nil;
    }
    class func ticket(toCoin vol: String, price: String =  "", contract: EXContractsModel?,holdzero: Bool = false) -> String {
        if contract == nil {
            return "0"
        }
        if vol.lessThan(BTZERO) {
            return BTZERO
        }
        if holdzero{
            var dec = 0
            if let pre = EXSwapPublicInfo.shared.facePrecisionDict[contract!.instrument_id]{
                dec = pre
            }else{
                dec = contract!.face_value.to_Precision()
            }
            return vol.bigMul(contract!.face_value).toString(dec,holdZero: true)
        }
        return vol.bigMul(contract!.face_value)
    }
    
     class func coin(toTicket vol: String, price: String = "", contract: EXContractsModel?) -> String {
        if contract == nil {
            return "0"
        }
        if vol.lessThan(BTZERO) {
            return BTZERO
        }
        return vol.bigDiv(contract!.face_value)
    }
    ///限价单用数量，数量为张数 English: /The quantity of price limit orders is the number of sheets
     class func calculateContractValue(withVol vol: String, price: String, contract contractModel: EXContractsModel?) -> String {
        if contractModel == nil {
            return BTZERO
        }
        if vol.lessThan(BTZERO) ||
            price.lessThan(BTZERO) ||
            contractModel!.face_value.lessThan(BTZERO){
            return BTZERO
        }
        if contractModel!.is_reverse {
            return vol.bigMul(contractModel!.face_value).bigDiv(price)
        }else {
            return vol.bigMul(contractModel!.face_value).bigMul(price)
        }
        
    }
    //MARK: 价值转换为张 English: MARK: Value conversion to Zhang
    class func valueToCoin(value:String, price: String,contractModel: EXContractsModel?) -> String{
        if contractModel == nil {
            return BTZERO
        }
        if contractModel?.face_value == nil{
            return BTZERO
        }
        if value.lessThan(BTZERO) ||
            price.lessThan(BTZERO) ||
            contractModel!.face_value.lessThan(BTZERO){
            return BTZERO
        }
        
        
        /*
         正向合约：委托数量（张） = 委托价值/委托价格/合约面值 English: Positive Contract: Number of Commissions (Zhang)=Commissioned Value/Commissioned Price/Contract Face Value
         反向合约：委托数量（张）=  委托价值*委托价格/合约面值 English: Reverse Contract: Number of Commissions (Zhang)=Commissioned Value * Commissioned Price/Contract Face Value
         */
       
        if contractModel!.is_reverse { //反向 English: reverse
//            //print("xxx==委托价值*委托价格/合约面值 = \(value) * \(price) / \(contractModel!.face_value)") English: Print ("xxx==commission value * commission price/contract face value=\ (value) * \ (price)/\ (contractModel!. face_value)")
            return value.bigMul(price).bigDiv(contractModel!.face_value).toString(0)
        }else {
//            //print("xxx==委托价值/委托价格/合约面值 = \(value) / \(price) / \(contractModel!.face_value)" ) English: Print ("xxx==commission value/commission price/contract face value=\ (value)/\ (price)/\ (contractModel!. face_value)")
            return value.bigDiv(price).bigDiv(contractModel!.face_value).toString(0)
        }
    }
    //MARK: 价值转换为币 English: MARK: Value conversion into coins
    /*
     若数量单位选择为计价币种，输入价格和数量后，折算为「币」，无论用户单位设置 币 or 张 English: If the quantity unit is selected as the pricing currency, after entering the price and quantity, it will be converted to "currency", regardless of whether the user's unit is set to "currency" or "sheet"
     正向合约：委托数量（币） = 委托价值/委托价格 English: Positive contract: Commissioned quantity (in currency)=Commissioned value/Commissioned price
     反向合约：委托数量（币）=  委托价值*委托价格 English: Reverse contract: Order quantity (in currency)=Order value * Order price
     委托价值为用户输入的计价币种的数量，委托价格为用户输入的价格 English: The commission value is the quantity of pricing currency entered by the user, and the commission price is the price entered by the user
     委托数量：保留精度为后端返回的合约面值精度，向下取，如计算结果为 2.09876 BTC，面值为 0.0001，委托数量为 2.0987 BTC English: Number of Commissions: Reserve the precision of the contract face value returned by the backend, and take it down. For example, if the calculation result is 2.09876 BTC, the face value is 0.0001, and the number of Commissions is 2.0987 BTC
     */
    class func valueTobi(value:String, price: String,contractModel: EXContractsModel?) -> String{
        if contractModel == nil {
            return BTZERO
        }
        if contractModel?.instrument_id == 0{
            return BTZERO
        }
        if value.lessThan(BTZERO) ||
            price.lessThan(BTZERO){
            return BTZERO
        }
        
        if contractModel!.is_reverse { //反向 English: reverse
            return value.bigMul(price).toVolumePrecision(withContractID: contractModel!.instrument_id,holdZero: false)
        }else {
            return value.bigDiv(price).toVolumePrecision(withContractID: contractModel!.instrument_id,holdZero: false)
        }
    }
    class func calculateContractValue(withCoinVol vol: String, price: String, contractModel: EXContractsModel?) -> String {
        if contractModel == nil {
            return BTZERO
        }
        if vol.lessThan(BTZERO) ||
            price.lessThan(BTZERO) ||
            contractModel!.face_value.lessThan(BTZERO){
            return BTZERO
        }
        if contractModel!.is_reverse {
            return vol.bigDiv(price)
        }else {
            return vol.bigMul(price)
        }
        
    }
    ///市价单用开仓价值计算 English: /Calculate market price based on opening value
    class func calculateContractValue(withValue value: String, price: String, contract contractModel: EXContractsModel?) -> String {
        if contractModel == nil {
            return BTZERO
        }
        
        if value.lessThan(BTZERO) ||
            price.lessThan(BTZERO){
            return BTZERO
        }
        
        if contractModel!.is_reverse {
            return value.bigMul(price) 
        }else {
            return value.bigDiv(price) 
        }
        
    }
    
     class func getUserPosition(with itemModel: EXSwapItemModel, contractWay way: BTContractOrderWay) -> EXSwapPositionModel {
        
        if let positions = EXSwapPersonInfo.shared.getPositions(itemModel.instrument_id) {
            
            if (positions.count > 0) {
                
                for position in positions {
                    
                    if way == .buy_OpenLong {
                        if position.side == .openMore {
                            return position;
                        }
                    }else if way == .sell_OpenShort {
                        if position.side == .openEmpty {
                            return position
                        }
                    }
                }
            }
        }
        
        return EXSwapPositionModel();
    }
    
     class func calculatePositionLeverage(withPosition position: EXSwapPositionModel, contract contractModel: EXContractsModel) -> String {
         //   实际杠杆（正向合约） = 仓位数量 * 标记价格 / 调整后仓位保证金 / 保证金汇率 English: Actual leverage (positive contract)=number of positions * marked price/adjusted position margin/margin exchange rate
        //    实际杠杆（反向合约） = 仓位数量 / 标记价格 / 调整后仓位保证金 / 保证金汇率 English: Actual leverage (reverse contract)=number of positions/marked price/adjusted position margin/margin exchange rate
         
         //仓位数量 English: Number of positions
         let postionValue = position.cur_qty.bigMul(contractModel.face_value)
         //标记价格 English: Mark price
         let tagPrice = position.index_px
         //逐仓保证金权益 English: Equity of margin for each position
         let marginValue = position.im
         //保证金汇率 English: Margin exchange rate
         let marginRate = contractModel.marginRate
         //反向 English: reverse
         let is_reverse = contractModel.is_reverse
         
         var result = ""
         if is_reverse{
             //（反向合约） = 仓位数量 / 标记价格 / 调整后仓位保证金 / 保证金汇率 English: (Reverse contract)=number of positions/marked price/adjusted position margin/margin exchange rate
             result = ((postionValue.bigDiv(tagPrice)).bigDiv(marginValue)).bigDiv(marginRate)
         }else{
             //(正向合约） = 仓位数量 * 标记价格 / 调整后仓位保证金 / 保证金汇率 English: (Positive contract)=number of positions * marked price/adjusted position margin/margin exchange rate
             result = ((postionValue.bigMul(tagPrice)).bigDiv(marginValue)).bigDiv(marginRate)

         }
         return result.exs_decimalString(1)
//         return result.exs_decimalString(1)
    }
    /*
     最大可开价值 = 可用余额 *杠杆 English: Maximum exploitable value=available balance * leverage
     按币下单 English: Order by Currency
     正向合约：最大可开（币） = 最大可开价值/委托价格 English: Positive contract: maximum open value (in currency)=maximum open value/commission price
     反向合约：最大可开（币） = 最大可开价值*委托价格 English: Reverse contract: maximum open value (in coins)=maximum open value * commission price
     
     
     */
     class func calculateVolume(withAsset asset: String, price: String, lever: String, position: EXSwapPositionModel?, contractInfo: EXContractsModel) -> String {
        
        if asset.lessThanOrEqual("0") {
            return "0"
        }
        let p = contractInfo.is_reverse ? price : DecimalOne.bigDiv(price)
        let info = contractInfo
        
        return asset.bigMul(lever).bigMul(p).bigDiv(info.marginRate)
    }
    /*
     *  强平价格（正向合约） =（逐仓权益 / 保证金汇率 - 仓位数量 * 仓位方向 * 标记价格） / （（维持保证金率 + 手续费率）* 仓位数量 - 仓位 * 仓位方向） English: *Strong flat price (positive contract)=(equity per position/margin exchange rate - number of positions * position direction * marked price)/(maintain margin rate+commission rate) * number of positions - position * position direction)
     *  强平价格（反向合约） =（（维持保证金率 + 手续费率）* 仓位数量 + 仓位 * 仓位方向）/ （逐仓权益 / 保证金汇率 + 仓位数量 * 仓位方向 / 标记价格） English: *Strong flat price (reverse contract)=(maintain margin ratio+commission rate) * number of positions+position * position direction)/(equity per position/margin exchange rate+number of positions * position direction/marked price)
     */
     class func calculatePositionLiquidatePrice(_ position: EXSwapPositionModel, contractInfo: EXContractsModel) -> String {
        let HV = position.cur_qty.bigMul(contractInfo.face_value)
        if HV.count > 0 {

            let p = position
            // 仓位数量 * 标记价格 =》区分正反向  // 正向：（仓位数量 * 仓位方向 * 标记价格） 反向： 仓位数量 * 仓位方向 / 标记价格 English: Forward: (number of positions * position direction * marked price) Reverse: number of positions * position direction/marked price
            if  p.cur_qty.count > 0 {
                let PV = calculateContractValue(withVol: position.cur_qty, price: p.index_px, contract: contractInfo)
                //仓位方向 English: Position direction
                var HD = position.side == .openMore ? "1" : "-1"
                if (contractInfo.is_reverse) {
                    HD = HD.bigMul("-1")
                }
                let rate = p.keepRate.bigAdd(p.maxFeeRate).bigMul(HV)
                if rate.count > 0 { //(维持保证金率 + 手续费率)*仓位数量 English: (Maintain margin rate+commission rate) * number of positions
                    //rate - 仓位 * 仓位方向 English: Rate - Position * Position Direction
                    let value1 = rate.bigSub((HV.bigMul(HD)))
                    let IM = position.im
                    if IM.count > 0 { // 逐仓权益 English: Equity per warehouse
                        let info = contractInfo
                        if  info.instrument_id > 0 {
                            //(逐仓权益 / 保证金汇率) - PV * 仓位方向 English: (Equity/Margin Exchange Rate) - PV * Position Direction
                            let marginV = IM.bigDiv(info.marginRate)
                            var value2 = marginV.bigSub((PV.bigMul(HD)))
                            if (contractInfo.is_reverse){ //反向 (逐仓权益 / 保证金汇率) + PV * 仓位方向 English: Reverse (equity/margin exchange rate per position)+PV * position direction
                                 value2 = marginV.bigAdd((PV.bigMul(HD)))
                            }
                            if marginV.count > 0 {

                                var LP = value2.bigDiv(value1)

                                if (contractInfo.is_reverse) {//反向 English: reverse
                                    LP = value1.bigDiv(value2)
                                   // LP = DecimalOne.bigDiv(LP)
                                }
                                if LP.count > 0 {

                                    return LP.toPricePrecision(withContractID: contractInfo.instrument_id)
                                }
                            }
                        }
                    }
                }
            }
        }
        return ""
    }
    
    /*
     
     1、逐仓减少保证金「可减少」： English: 1. Reducing margin by position is "reducible":
     可减少额= 逐仓保证金（不含未实现盈亏）- 仓位价值/杠杆 English: Deductible amount=Margin per position (excluding unrealized gains and losses) - Position value/leverage
     正向合约：仓位价值 = 标记价格*数量*面值 English: Positive contract: Position value=marked price * quantity * face value
     反向合约：仓位价值 = 数量*面值/标记价格 English: Reverse contract: Position value=quantity * face value/marked price
     2、逐仓增加、减少保证金「强平价」 English: 2. "Strong parity" of increasing and decreasing margin by position
     逐仓 多头：强平价格 = （仓位数量 * 标价价格 - 逐仓保证金权益 ） / （（1 - 维持保证金率 - 手续费率）* 仓位数量） English: Long position by position: Strong flat price=(Number of positions * List price - Equity of margin by position)/(1- Maintain margin rate - Handling rate) * Number of positions)
     逐仓 空头：强平价格 = （仓位数量 * 标价价格 + 逐仓保证金权益 ） / （（1 + 维持保证金率 + 手续费率）* 仓位数量） English: Short position by position: Strong flat price=(number of positions * bid price+equity of margin by position)/(1+maintenance margin rate+commission rate) * number of positions)
     反向合约 English: Reverse contract
     逐仓 多头：强平价格 = （1 + 维持保证金率 + 手续费率）* 仓位数量 /（（仓位数量/标价价格）+ 逐仓保证金权益） English: Long position by position: Strong flat price=(1+maintain margin ratio+commission rate) * number of positions/(number of positions/bid price)+equity of margin by position)
     逐仓 空头：强平价格 = （1 - 维持保证金率 - 手续费率）* 仓位数量 /（（仓位数量/持标价价格）- 逐仓保证金权益） English: Short position by position: Strong flat price=(1- Maintain margin ratio - Handling rate) * Number of positions/(Number of positions/Holding price) - Equity of margin by position)
     */
    class func adjustCalculatePositionLiquidatePrice(_ position: EXSwapPositionModel, contractInfo: EXContractsModel) -> String {
       //仓位数量 English: Number of positions
       let postionValue = position.cur_qty.bigMul(contractInfo.face_value)
       //标记价格 English: Mark price
       let tagPrice = position.index_px
       //逐仓保证金权益 English: Equity of margin for each position
       let marginValue = position.im
       //维持保证金率 English: Maintain margin ratio
       let keepRate = position.keepRate
       //手续费率 English: Handling fee rate
       let fee = position.maxFeeRate
        //仓位方向 English: Position direction
       let openMore = position.side == .openMore
       //反向 English: reverse
       let is_reverse = contractInfo.is_reverse
        var result = ""
        if is_reverse == false{
            // 正向合约 English: Forward contract
            if openMore{//多头 English: long
            // 多头：强平价格 = （仓位数量 * 标价价格 - 逐仓保证金权益 ） / （（1 - 维持保证金率 - 手续费率）* 仓位数量） English: Long position: Strong flat price=(Number of positions * List price - Equity of margin per position)/(1- Maintain margin rate - Handling rate) * Number of positions)
                result = (postionValue.bigMul(tagPrice).bigSub(marginValue)).bigDiv(("1".bigSub(keepRate).bigSub(fee)).bigMul(postionValue))
            }else{
             //空头：强平价格 = （仓位数量 * 标价价格 + 逐仓保证金权益 ） / （（1 + 维持保证金率 + 手续费率）* 仓位数量） English: Short position: Strong flat price=(number of positions * bid price+position by position margin equity)/(1+margin maintenance rate+commission rate) * number of positions)
                
                result = (postionValue.bigMul(tagPrice).bigAdd(marginValue)).bigDiv(("1".bigAdd(keepRate).bigAdd(fee)).bigMul(postionValue))
                
            }
        }else{
           // 反向合约 English: Reverse contract
            
            if openMore{
            // 多头：强平价格 = （1 + 维持保证金率 + 手续费率）* 仓位数量 /（（仓位数量/标价价格）+ 逐仓保证金权益） English: Long position: Strong flat price=(1+maintain margin ratio+commission rate) * number of positions/(number of positions/bid price)+equity of margin per position)
                
                result = (("1".bigAdd(keepRate).bigAdd(fee)).bigMul(postionValue)).bigDiv((postionValue.bigDiv(tagPrice)).bigAdd(marginValue))
                
            }else{
            //空头：强平价格 = （1 - 维持保证金率 - 手续费率）* 仓位数量 /（（仓位数量/持标价价格）- 逐仓保证金权益） English: Short position: Strong flat price=(1- Maintain margin ratio - Handling rate) * Number of positions/(Number of positions/Holding price) - Equity of margin per position)
                
                result = (("1".bigSub(keepRate).bigSub(fee)).bigMul(postionValue)).bigDiv((postionValue.bigDiv(tagPrice)).bigSub(marginValue))
            }
            
        }
        return result

   }
   
    
    //仓位数量 * 开仓价格 English: Number of positions * opening price
    class func calculateIMR(amout: String, price: String, contractModel: EXContractsModel?) -> String {
        let value = amout.bigMul(price)
        if  let info = contractModel {
            
            for ladder in info.ladderList {
                if value.lessThanOrEqual(ladder.maxPositionValue) && value.greaterThanOrEqual(ladder.minPositionValue) {
                    return ladder.minMarginRate
                }
            }
        }
        return ""
    }
    
    class func calculateClosePrice(_ order: EXContractOrderModel, ROI:String, contractInfo: EXContractsModel?) -> String {
        //仓位数量 单位为币 English: The number of positions is in currency
        if let info = contractInfo {
            //仓位方向 English: Position direction
            var HD = order.side == .buy_OpenLong ? "1" : "-1"
            if (info.is_reverse) {
                HD = HD.bigMul("-1")
            }
            ///杠杆 + 回报率 ，正向多仓为 + ，正向空仓为 -，反向多仓为-,反向空仓为+ English: /Leverage+return rate, positive long position is+, positive short position is -, negative long position is -, and negative short position is -+
            let value1 = order.leverage.bigAdd((ROI.bigMul(HD)))
            var value2 = order.px.bigDiv(order.leverage)
            if value1.count > 0,value2.count > 0 {
                
                
                if info.isReverse {
                    value2 = order.px.bigMul(order.leverage)
                }
                var CP = value2.bigMul(value1)
                if info.isReverse {
                    CP = value2.bigDiv(value1)
                }
                return CP
            }
        }
        return ""
    }
    
    /*** 强平价格（单位：计价货币） 仓位数量为币
             * 正向合约：
             * 多仓 强平价格 = （保证金数量 / 保证金汇率 - 仓位数量 * 开仓价格） / （（维持保证金率 + 手续费率 - 1）* 仓位数量）
             * 空仓 强平价格 = （保证金数量 / 保证金汇率 + 仓位数量 * 开仓价格） / （（维持保证金率 + 手续费率 + 1）* 仓位数量 ）
             *
             * 反向合约：
             * 多仓 强平价格 = （（维持保证金率 + 手续费率 + 1）* 仓位数量）/ （保证金数量 / 保证金汇率 + 仓位数量 / 开仓价格）
             * 空仓 强平价格 = （（维持保证金率 + 手续费率 - 1）* 仓位数量）/ （保证金数量 / 保证金汇率 - 仓位数量 / 开仓价格）
             *
             * 维持保证金率 = （仓位数量 * 标记价格）所在的挡位的维持保证金率
             * 手续费=0.075%
     
     qiangping price (unit: pricing currency), number of positions in currency
     *Positive contract:
     *Multi position strong leveling price=(margin quantity/margin exchange rate - number of positions * opening price)/(maintaining margin rate+handling rate -1) * number of positions)
     *Short position forced liquidation price=(margin quantity/margin exchange rate+number of positions * opening price)/(margin maintenance rate+handling rate+1) * number of positions)
     *
     *Reverse contract:
     *Multi position strong leveling price=(Maintain margin ratio+handling rate+1) * number of positions)/(Margin quantity/Margin exchange rate+number of positions/opening price)
     *Short position forced liquidation price=(maintain margin ratio+commission rate -1) * number of positions)/(margin quantity/margin exchange rate - number of positions/opening price)
     *
     *Maintain margin ratio=(number of positions * marked price) Maintain margin ratio for the level in which it is located
     *Handling fee=0.075%
     
     
             */
    class func newCalculateOrderLiquidatePrice(_ order: EXContractOrderModel, assets: EXCItemCoinModel?, contractInfo: EXContractsModel?) -> String {
        if let info  = contractInfo{
            //保证金数量 English: Deposit quantity
            let marginAmount = order.im
            //保证金汇率 English: Margin exchange rate
            let marginRate = info.marginRate
            //仓位数量 单位为币 English: The number of positions is in currency
            let positionAmount = order.qty
            //开仓价格 English: Opening price
            let openPrice = order.px
            // 仓位数量 * 开仓价格  区分正反向 English: Number of positions * opening price differentiation between forward and reverse directions
            let PV = calculateContractValue(withCoinVol: order.qty, price: order.px, contractModel: contractInfo)
            //维持保证金率 English: Maintain margin ratio
            let keepRate = calculateIMR(amout:  order.qty, price: order.px, contractModel: info)
            //手续费率 English: Handling fee rate
            let fee = order.maxFeeRate
//            //print("保证金数量=\(marginAmount) 保证金汇率=\(marginRate) 仓位数量=\(positionAmount) 开仓价格 =\(openPrice) 维持保证金率 =\(keepRate) 手续费率=\(fee)") English: Print ("Margin Quantity=Margin Exchange Rate=MarginRate Position Quantity=PositionAmount Opening Price=OpenPrice Maintain Margin Rate=KeepRate Handling Rate=Fee")
            
            var result = "0"
            // 保证金数量 / 保证金汇率 English: Deposit quantity/Deposit exchange rate
            let marginPart = marginAmount.bigDiv(marginRate)
            // 仓位数量 * 开仓价格 English: Number of positions * opening price
            var postionPart = positionAmount.bigMul(openPrice)
            // 维持保证金率 + 手续费率 English: Maintain margin rate+commission rate
            let ratePart = keepRate.bigAdd(fee)
            if (info.is_reverse){
                //反向 仓位数量 / 开仓价格 English: Reverse position quantity/opening price
                postionPart =  positionAmount.bigDiv(openPrice)
                if order.side == .buy_OpenLong {
                    //多仓 强平价格 = （（维持保证金率 + 手续费率 + 1）* 仓位数量）/ （保证金数量 / 保证金汇率 + 仓位数量 / 开仓价格） English: Multi position strong leveling price=(Maintain margin ratio+handling rate+1) * number of positions)/(Margin quantity/Margin exchange rate+number of positions/opening price)
                    result = (ratePart.bigAdd("1")).bigMul(positionAmount).bigDiv((marginPart.bigAdd(postionPart)))
                }else{
                    //空仓 强平价格 = （（维持保证金率 + 手续费率 - 1）* 仓位数量）/ （保证金数量 / 保证金汇率 - 仓位数量 / 开仓价格） English: Short position forced liquidation price=(maintain margin ratio+commission rate -1) * number of positions)/(margin quantity/margin exchange rate - number of positions/opening price)
                    result = (ratePart.bigSub("1")).bigMul(positionAmount).bigDiv((marginPart.bigSub(postionPart)))
                }
            }else{ //正向 English: Forward
                if order.side == .buy_OpenLong {
                    //多仓 强平价格 = （保证金数量 / 保证金汇率 - 仓位数量 * 开仓价格） / （（维持保证金率 + 手续费率 - 1）* 仓位数量） English: Multi position strong leveling price=(margin quantity/margin exchange rate - number of positions * opening price)/(maintaining margin rate+handling rate -1) * number of positions)
                    result = (marginPart.bigSub(postionPart)).bigDiv((ratePart.bigSub("1")).bigMul(positionAmount))
                    
                }else{
                    //空仓 强平价格 = （保证金数量 / 保证金汇率 + 仓位数量 * 开仓价格） / （（维持保证金率 + 手续费率 + 1）* 仓位数量 ） English: Short position forced liquidation price=(margin quantity/margin exchange rate+number of positions * opening price)/(margin maintenance rate+handling rate+1) * number of positions)
                    result = (marginPart.bigAdd(postionPart)).bigDiv((ratePart.bigAdd("1")).bigMul(positionAmount))
                }
            }
//            //print("result = \(result)")
            return result.toPricePrecision(withContractID: info.instrument_id)
        }
        
        return "0"
    }
    
    ///vol 单位为张 English: /The unit of vol is Zhang
     class func calculateCloseLongProfitAmount(_ vol: String, holdAvgPrice openPrice: String, markPrice closePrice: String, contractInfo: EXContractsModel) -> String {
        if (vol.lessThanOrEqual(BTZERO) ||
                openPrice.lessThanOrEqual(BTZERO) ||
                closePrice.lessThanOrEqual(BTZERO)) {
            return BTZERO;
        }
        
        if contractInfo.isReverse {
            let openValue = vol.bigDiv(openPrice)
            let closeValue = vol.bigDiv(closePrice)
            return (openValue.bigSub(closeValue)).bigDiv(contractInfo.marginRate)
        }
        let openValue = vol.bigMul(openPrice)
        let closeValue = vol.bigMul(closePrice)
        return (closeValue.bigSub(openValue)).bigDiv(contractInfo.marginRate)
    }
    
    class func calculateCloseShortProfitAmount(_ vol: String, holdAvgPrice openPrice: String, markPrice closePrice: String, contractInfo: EXContractsModel) -> String {
        if (vol.lessThanOrEqual(BTZERO) ||
                openPrice.lessThanOrEqual(BTZERO) ||
                closePrice.lessThanOrEqual(BTZERO)) {
            return BTZERO;
        }
        
        if contractInfo.isReverse {
            let openValue = vol.bigDiv(openPrice)
            let closeValue = vol.bigDiv(closePrice)
            return (closeValue.bigSub(openValue)).bigDiv(contractInfo.marginRate)
        }
        let openValue = vol.bigMul(openPrice)
        let closeValue = vol.bigMul(closePrice)
        return (openValue.bigSub(closeValue)).bigDiv(contractInfo.marginRate)
    }
    
    
}
extension EXFormula{
    /*
     .当可用余额<开仓保证金时，提示“可用余额不足以开仓”，开仓保证金的计算公式如下：
          正向：开仓保证金 = 开仓价格*仓位数量/杠杆倍数
          反向：开仓保证金 = 仓位数量/(开仓价格*杠杆倍数)
     
     English: When the available balance is less than the opening margin, it prompts "The available balance is not enough to open the position". The calculation formula for the opening margin is as follows:
     Positive: Opening margin=Opening price * Number of positions/leverage ratio
    Reverse: Opening margin=number of positions/(opening price * leverage ratio)
     */
    
    class func canOpenOrder(_ order: EXContractOrderModel, contractInfo: EXContractsModel?,canUse: String) -> Bool {
        let margin = self.getOpenMarginAmount(order, contractInfo: contractInfo)
        if canUse.lessThan(margin){
            EXAlert.showFail(msg: "cp_calculator_text44".ex_localized())
            return false
        }
        return true
        
    }
    class func getOpenMarginAmount(_ order: EXContractOrderModel, contractInfo: EXContractsModel?) -> String {
        //杠杆 English: lever
        let level = order.leverage
        //仓位数量 单位为币 English: The number of positions is in currency
        let positionAmount = order.qty
        //开仓价格 English: Opening price
        let openPrice = order.px
        //这里不用去分反向 公式里已区分计算 English: There is no need to differentiate calculations in the reverse formula here
        //数量 乘除 开仓价格 --已区分正反向  （正向 仓位数量 * 开仓价格 /反向 仓位数量 / 开仓价格） English: Quantity Multiplication and Division Opening Price - Distinguished between Forward and Reverse (Forward Position Quantity * Opening Price/Reverse Position Quantity/Opening Price)
        let a = calculateContractValue(withCoinVol: order.qty, price: order.px, contractModel: contractInfo)
        // 开仓保证金--已区分正反向 English: Opening margin - distinguished between forward and reverse
        let openMarginAmount = a.bigDiv(level)
        return openMarginAmount
    }
     /*
         逐仓计算方式 English: Calculation method by warehouse
         正向： English: Forward:
               开仓保证金 = 开仓价格*仓位数量/杠杆 English: Opening margin=opening price * number of positions/leverage
               多头：强平价格 = （仓位数量 * 开仓价格 - 开仓保证金 / 保证金汇率 ） / （（1 - 维持保证金率 - 手续费率）* 仓位数量） English: Long position: Strong flat price=(number of positions * opening price - opening margin/margin exchange rate)/(1- maintaining margin rate - handling rate) * number of positions)
                              ( a - b ) / d
               空头：强平价格 = （仓位数量 * 开仓价格 + 开仓保证金 / 保证金汇率 ） / （（1 + 维持保证金率 + 手续费率）* 仓位数量） English: Short position: Strong flat price=(number of positions * opening price+opening margin/margin exchange rate)/(1+maintaining margin rate+handling rate) * number of positions)
                              ( a + b ) / c
         反向： English: Reverse:
               开仓保证金 = 仓位数量/(开仓价格*杠杆倍数) =  仓位数量/开仓价格/杠杆倍数 English: Opening margin=number of positions/(opening price * leverage ratio)=number of positions/opening price/leverage ratio
               多头：强平价格 = （1 + 维持保证金率 + 手续费率）* 仓位数量 /（（仓位数量/开仓价格）+ 开仓保证金/保证金汇率） English: Bull: Strong Ping Price=(1+Maintain Margin Rate+Handling Rate) * Number of Positions/(Number of Positions/Opening Price)+Opening Margin/Margin Exchange Rate)
                                c / ( a + b)
               空头：强平价格 = （1 - 维持保证金率 - 手续费率）* 仓位数量 /（（仓位数量/开仓价格）- 开仓保证金/保证金汇率） English: Short position: Strong flat price=(1- Maintain margin ratio - Handling rate) * Number of positions/(Number of positions/Opening price) - Opening margin/Margin exchange rate)
                                d / ( a - b)
          公式化简: English: Formula simplification:
          let a = 仓位数量 * 开仓价格  ///  仓位数量/开仓价格 English: /Number of positions/opening price
          let b = 开仓保证金 / 保证金汇率 ==  a / 杠杆 / 保证金汇率 English: Let b=opening margin/margin exchange rate==a/leverage/margin exchange rate
          let c = (1 + 维持保证金率 + 手续费率) * 仓位数量 English: Let c=(1+margin maintenance rate+commission rate) * number of positions
          let d = (1 - 维持保证金率 - 手续费率) * 仓位数量 English: Let d=(1- Maintain margin rate - Handling rate) * Number of positions
         */
    class func isolatedCalculateOrderLiquidatePrice(_ order: EXContractOrderModel, assets: EXCItemCoinModel?, contractInfo: EXContractsModel?) -> String {
            if let info  = contractInfo{
                //杠杆 English: lever
                let level = order.leverage
                //保证金汇率 English: Margin exchange rate
                let marginRate = info.marginRate
                //仓位数量 单位为币 English: The number of positions is in currency
                let positionAmount = order.qty
                //开仓价格 English: Opening price
                let openPrice = order.px
                //这里不用去分反向 公式里已区分计算 English: There is no need to differentiate calculations in the reverse formula here
                //数量 乘除 开仓价格 --已区分正反向  （正向 仓位数量 * 开仓价格 /反向 仓位数量 / 开仓价格） English: Quantity Multiplication and Division Opening Price - Distinguished between Forward and Reverse (Forward Position Quantity * Opening Price/Reverse Position Quantity/Opening Price)
                let a = calculateContractValue(withCoinVol: order.qty, price: order.px, contractModel: contractInfo)
                // 开仓保证金--已区分正反向 English: Opening margin - distinguished between forward and reverse
                let openMarginAmount = a.bigDiv(level)
                // 开仓保证金 / 保证金汇率 English: Opening margin/margin exchange rate
                let b = openMarginAmount.bigDiv(marginRate)
                //维持保证金率 English: Maintain margin ratio
                let keepRate = calculateIMR(amout:  order.qty, price: order.px, contractModel: info)

                //手续费率 English: Handling fee rate
                let fee = order.maxFeeRate
                //print("保证金汇率=\(marginRate) 仓位数量=\(positionAmount) 开仓价格 =\(openPrice) 维持保证金率 =\(keepRate) 手续费率=\(fee) level = \(level)")
                var result = "0"
                // 维持保证金率 + 手续费率 English: Maintain margin rate+commission rate
                let ratePart = keepRate.bigAdd(fee)
               // let c = (1 + 维持保证金率 + 手续费率) * 仓位数量 English: Let c=(1+margin maintenance rate+commission rate) * number of positions
                let  c = ("1".bigAdd(ratePart)).bigMul(positionAmount)
               // let d = (1 - 维持保证金率 - 手续费率) * 仓位数量 English: Let d=(1- Maintain margin rate - Handling rate) * Number of positions
                let  d = ("1".bigSub(ratePart)).bigMul(positionAmount)
                if (info.is_reverse){
                    if order.side == .buy_OpenLong {
                        // 多头：c / ( a + b) English: Multiple headed: c/(a+b)
                        result = c.bigDiv((a.bigAdd(b)))
                    }else{
                        // 空头：d / ( a - b) English: Short position: d/(a - b)
                        result = d.bigDiv((a.bigSub(b)))
                    }
                }else{ //正向 English: Forward
                    if order.side == .buy_OpenLong {
                        // 多头： ( a - b ) / d English: Multiple headed: (a - b)/d
                        result = (a.bigSub(b)).bigDiv(d)
                        
                    }else{
                        // 空头 ( a + b ) / c English: Short position (a+b)/c
                        result = (a.bigAdd(b)).bigDiv(c)
                    }
                }
                //print("result = \(result)")
                return result.toPricePrecision(withContractID: info.instrument_id)
            }
            return "0"
        }
}

