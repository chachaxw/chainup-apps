//
//  SLCurrentOrderList.swift
//  Chainup
//
//  Created by ZYJ on 2023/10/21.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

public class EXContractQueryCurrentOrderList: EXCOBaseModel {
    
    var needTrigger:Bool?
    var isHistory:Bool?{
        didSet {
            if let need = isHistory,need {
                limit = 20
            }
        }
    }
    var isKline = "0"//k线委托查询：1-k线委托查询： English: K-line commission inquiry: 1- K-line commission inquiry:
    var contractId:Int64 = 0
    //  订单类型: 1 限价, 2 市价 , 3 IOC，4 FOK，5 POST_ONLY English: Order types: 1 price limit, 2 market price, 3 IOC, 4 FOK, 5 POST_ ONLY
    var type = ""
    //页码 English: Page number
    var page = 1
    //每页条数 English: Number of entries per page
    var limit = 0
    // 起始时间戳 English: Starting timestamp
    var beginTime:TimeInterval?
    //结束时间戳 English: End timestamp
    var endTime:TimeInterval?
    
    func getParams() -> [String: Any] {
        var dic:[String : Any] = [
           // "contractId": self.contractId,
            "page": self.page,
            "limit": self.limit
        ]
        if self.contractId > 0 {
            dic["contractId"] = self.contractId
        }
        if type.count > 0 {
            dic["type"] = self.type
        }
        if self.isKline == "1" {
            dic["isKline"] = self.isKline
        }
        return dic
    }
    
}

class EXContractCurrentOrderList:EXCOBaseModel {
    
    var orderList = [EXContractOrderModel]()
    var trigOrderList = [EXContractOrderModel]()
    var count: Int = 0
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["orderList":EXContractOrderModel.self,
                "trigOrderList":EXContractOrderModel.self]
    }
}

class EXKlineOrderList:EXCOBaseModel {
    var KlineBuySellData = "KlineBuySellData"
    var orderList = [[String: Any]]()
    var count: Int = 0
}

