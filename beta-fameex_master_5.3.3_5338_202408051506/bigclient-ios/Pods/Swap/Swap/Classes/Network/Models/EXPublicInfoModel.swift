//
//  SLPublicInfoModel.swift
//  Chainup
//
//  Created by ZYJ on 2023/10/14.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
    
public class EXPublicInfoModel: EXCOBaseModel {

    var contractList = [EXContractsModel]()
    var originalCoinList = [String]() //真实保证金币种集合 English: Collection of genuine guaranteed gold coins
    var wsUrl = ""
    var currentTimeMillis:TimeInterval = 0
    var currentRemoteTime:Date?
    var marginCoinList = [String]()
    var langList = [EXSLanguageModel]()
    var allAmountUrl = "" //盈亏分析查询总资产url English: Profit and loss analysis query total asset URL
    var contractProInfo = "" //合约跳转地址 English: Contract jump address
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["contractList":EXContractsModel.self,
                "langList":EXSLanguageModel.self]
    }

}

