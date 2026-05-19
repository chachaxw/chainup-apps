//
//  EXLeverageCoinMapItem.swift
//  Chainup
//
//  Created by ljw on 2020/11/4.
//  Copyright © 2020 zewu wang. All rights reserved.
//

import UIKit


class EXLeverCoinItem: EXBaseModel {
    var showName:String = ""//币种显示名
    var configSymbol:String = ""//币种
    var normalBalance:String = ""//杠杆可用
    var lockBalance:String = ""//杠杆锁仓
    var indexPrice:String = ""//指数价格
    var totalBalance:String = ""//可用+锁仓
    var borrowBalance:String = ""//借贷
    var interest:String = ""//利息
    var netAssetBalance:String = ""//净值
    var netAssetBalanceValue:String = ""//净值折合btc
    var u_netAssetBalanceValue:String = ""//净值折合usdt
    var minBorrow:String = ""//最小借贷
    var minPayment:String = ""//最小还款
    var maxBorrow:String = ""//最大可借贷
    var rate:String = ""//利率
    var exNormalBalance:String = ""//币币可用
    var returnPrecision:String = ""//归还精度
    var symbolBalance:String = ""//币种btc折合资产： 借贷划转list排序使用
    var symbolNeedReturnBalance:String = ""//币种需要归还btc折合资产：还款list排序使用
    var name:String = "" //搜索用
    var assetSort:String = ""
}

