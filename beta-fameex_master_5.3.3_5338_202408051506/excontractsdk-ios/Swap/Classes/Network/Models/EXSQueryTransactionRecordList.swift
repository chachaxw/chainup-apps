//
//  SLQueryTransactionRecordList.swift
//  Chainup
//
//  Created by ZYJ on 2023/10/30.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

public class EXSQueryTransactionRecordList: EXCOBaseModel {
    //查询币种 English: Query Currency
    public var symbol:String = ""
    
    // 流水类型(不传查询全部) English: Flow type (do not query all)
    /// 1 转入 ,2 转出 ,3 结算多仓 ,4 结算空仓 ,5 资金费用 ,6 开仓手续费 ,7 平仓手续费 ,8 分摊 English: /1. Transfer in, 2. Transfer out, 3. Settlement of multiple positions, 4. Settlement of empty positions, 5. Capital expenses, 6. Opening fees, 7. Closing fees, 8. Allocation
    public var type = ""
   
   // 起始时间戳 English: Starting timestamp
    public  var beginTime:String = ""
    
   //截止时间戳 English: Deadline timestamp
    public var endTime:String = ""
    //分页条数 English: Number of page breaks
    public var limit = 20
    
    //页码 English: Page number
    public var page = 1
    
    public func getParams() -> [String: Any] {
        var dic:[String : Any] = [
            "symbol": self.symbol,
            "page": self.page,
            "limit": self.limit
        ]
        if self.type.count > 0 {
            dic["type"] = self.type
        }
        if beginTime.count > 0 {
            dic["beginTime"] = self.beginTime
        }
        if endTime.count > 0 {
            dic["endTime"] = self.endTime
        }
        return dic
    }
    
    
    
}

