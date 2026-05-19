//
//  EXSInfoModel.swift
//  Chainup
//
//  Created by ZYJ on 2023/12/4.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXSInstrunceAmountHistoryModel: EXCOBaseModel {

    var ctime = ""
    var amount = ""
}

class EXSInstrunceRecordHistoryModel: EXCOBaseModel {

    var ctime = ""
    var type = ""
    var hisAmount = ""
    
    var typeDisplay:String {
        if type == "1" {
            return "接管盈利注入"
        }
        if type == "2" {
            return "风险准备金支出"
        }
        return ""
    }
}

class EXSInstranceModel: EXCOBaseModel {

    var brokenLineList = [EXSInstrunceAmountHistoryModel]()
    var historyList = [EXSInstrunceRecordHistoryModel]()
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["brokenLineList":EXSInstrunceAmountHistoryModel.self,
                "historyList":EXSInstrunceRecordHistoryModel.self]
    }

}

class EXSFundingRateDetailModel:EXCOBaseModel {
    var amount = ""
    var ctime = ""
    var contractName = ""
}
class EXSFundingRateModel:EXCOBaseModel {
    var historyList = [EXSFundingRateDetailModel]()
    var brokenLineList = [EXSFundingRateDetailModel]()
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["brokenLineList":EXSFundingRateDetailModel.self,
                "historyList":EXSFundingRateDetailModel.self]
    }
}

//余额 English: balance
class EXSInstrunceblanceAmountModel: EXCOBaseModel{
    var amount: String = ""
//    {
//        didSet{
//            let value =  String(format: "%.1f",amount)
//            showString =  EXStingTool.showInComma(source: value)
//        }
//    }
    var showString: String = ""
}

