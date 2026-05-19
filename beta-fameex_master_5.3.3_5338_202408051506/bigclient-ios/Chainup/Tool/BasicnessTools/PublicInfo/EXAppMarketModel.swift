//
//  EXAppMarketModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/9/8.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit

class EXAppMarketModel: EXBaseModel {
    var marketSort : [String] = []//currency
    var market : [String:Any] = [:]//Currency pairs per market
    var coinList : [String:Any] = [:]//Currency List
    var followCoinList : [String:Any] = [:]//From coin list
    var rate : [String:Any] = [:]//exchange rate
}

