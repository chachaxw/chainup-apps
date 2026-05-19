//
//  EXContranctTradeDetailListModel.swift
//  Chainup
//
//  Created by ZYJ on 2023/11/1.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXContractTradeDetailItem:EXCOBaseModel {
   //成交数量 English: Transaction quantity
    var volume:String = ""
    
    // 币对 English: Coin pairs
    var symbol:String = ""
    //价格精度 English: Price accuracy
   var pricePrecision = ""
    
    /*
     买卖方向（buy 买入，sell 卖出） English: Buying and selling direction (buy, sell)
     该字段和open字段合并展示; 示例如下: English: Merge and display this field with the open field; An example is as follows:
     open = open , side = buy (开多) English: Open=open, side=buy
     open = open,  side = sell (开空) English: Open=open, side=sell
     open = close,  side = buy(平多) English: Open=close, side=buy (Pingduo)
     open = close,  side = sell (平空) English: Open=close, side=sell (flat)
     **/
   var side = ""
    //开平仓方向(open 开仓，close 平仓) close标识只减仓 English: Direction of opening and closing positions (open position, close position). The close flag only reduces positions
   var open = ""
    //手续费币种 English: Currency of handling fee
   var feeCoin = ""
    //用户角色 English: User Role
   var role = ""

    //成交价格 English: Transaction price
   var price = ""
    
    // 手续费 English: Handling fees
   var fee = ""
  
   //成交时间 English: Transaction time
   var ctime = ""
 
    //成交记录ID English: Transaction record ID
   var id = ""
    
   //手续费币种价格精度 English: Price accuracy of handling fee currency
    var feeCoinPrecision:Int = 0
    var contractId = ""
    var isCompensate = false //新增字段,是否发生补偿,true发生补偿;false没补偿  New field, whether compensation occurs, true compensation occurs; faalse no compensation
    var isAdd = false//新增字段,是否展示+号,true展示;false不展示  whether to display the + sign, true display, false do notdisplay

}

class EXContractTradeDetailListModel:EXCOBaseModel {

    var tradeList = [EXContractTradeDetailItem]()
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["tradeList":EXContractTradeDetailItem.self]
    }
}

