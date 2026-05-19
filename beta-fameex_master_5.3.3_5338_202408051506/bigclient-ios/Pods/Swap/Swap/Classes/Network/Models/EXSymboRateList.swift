//
//  EXSymboRateList.swift
//  Chainup
//
//  Created by cwd on 2022/7/20.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import HandyJSON
public class EXContractBaseHanyJsonModel:NSObject,HandyJSON{
    required public override init() {
        super.init()
    }
}

public class EXSymboRateList: EXContractBaseHanyJsonModel{
    var symbolRateList: [EXSymboRate]?
    var usdtToUsdRate = ""
}
class EXSymboRate: EXContractBaseHanyJsonModel {
   var baseSymbol = "" //基础币种（比如：USDT） English: Base currency (e.g. USDT)
   var quoteSymbol = "" //折算币种（比如：CNY） English: Conversion currency (e.g. CNY)
   var rate = "" //汇率（比如：6.666，不保留小数位） English: Exchange rate (e.g. 6.666, do not retain decimal places)
}

