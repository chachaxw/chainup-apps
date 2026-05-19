//
//  EXLeverMarginInfo.swift
//  Alamofire
//
//  Created by cwd on 2023/4/11.
//

import UIKit
class EXLeverMarginData: EXContractBaseHanyJsonModel {
    var leverMarginInfo = [EXLeverMarginItem]() //合约信息公示数据 English: Contract information disclosure data
    var coinAlias = "" //币种别名 English: Currency alias
    var mTime = "" //更新时间(时间戳) English: Update time (timestamp)
}

class EXLeverMarginItem:EXContractBaseHanyJsonModel{
    var level = "" //层级 English: Hierarchy
    var minPositionValue = "" //持仓最小值 English: Minimum position value
    var maxPositionValue = "" // 持仓最大值 English: Maximum position value
    var maxLever = "" //最高杠杆倍数 English: Maximum leverage ratio
    var minMarginRate = "" //维持保证金率 English: Maintain margin ratio
}

