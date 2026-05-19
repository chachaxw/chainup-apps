//
//  EXTradeLimitInfoModel.swift
//  Chainup
//
//  Created by ljw on 2023/8/12.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXTradeLimitInfoModel: EXBaseModel {
    var trade_limit_sell_info = ""
    var trade_symbol_can_mk_trade = ""
    var trade_limit_buy_info = ""
    var trade_symbol_sell_limit = "" {
        didSet {
            trade_symbol_sell_limit = trade_symbol_sell_limit.decimalNumberWithDouble()
        }
    }
    var trade_symbol_buy_limit  = "" {
        didSet {
            trade_symbol_buy_limit = trade_symbol_buy_limit.decimalNumberWithDouble()
        }
    }
}
