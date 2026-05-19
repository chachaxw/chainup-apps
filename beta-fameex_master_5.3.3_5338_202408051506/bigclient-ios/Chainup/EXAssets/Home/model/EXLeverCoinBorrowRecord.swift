//
//  EXLeverCoinBorrowRecord.swift
//  Chainup
//
//  Created by ljw on 2023/11/11.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXLeverCoinBorrowRecord: EXBaseModel {
    var quoteReturnPrecision: String = ""
    var baseTotalBorrow: String = ""
    var quoteCanBorrow: String = ""
    var quoteBorrowBalance: String = ""
    var quoteMinBorrow: String = ""
    var riskRate: String = ""
    var baseNormalBalance: String = ""
    var baseTotalBalance: String = ""
    var multiple: String = ""
    var quoteNormalBalance: String = ""
    var baseMinBorrow: String = ""
    var burstPrice: String = ""
    var quoteEXNormalBalance: String = ""
    var quoteCoin: String = ""
    var quoteMinPayment: String = ""
    var quoteCanTransfer: String = ""
    var baseCanBorrow: String = ""
    var baseBorrowBalance: String = ""
    var quoteLockBalance: String = ""
    var baseLockBalance: String = ""
    var name: String = ""
    var symbol: String = ""
    var baseReturnPrecision: String = ""
    var baseMinPayment: String = ""
    var quoteTotalBorrow: String = ""
    var quoteTotalBalance: String = ""
    var baseCanTransfer: String = ""
    var rate: String = "" {
        didSet {
            if rate.greaterThan("0"){
                let rest = rate.bigMul("100",decimals: 2,up: true)
                rate = rest + "%"
            }
        }
    }
    var baseCoin: String = ""
    var baseExNormalBalance: String = ""
    var symbolBalance : String = ""
    
    
    
}


class EXLeverCrossCoinModel: EXBaseModel {
    /*
     burstRiskRate = 1.1
     remindRiskRate = 1.3
     1.1 到1.3之间高分险 1.3到1.5中风险 1.5以上低风险
     */
    
    var canBorrow:String = ""//当前可借贷
    var canTransfer:String = ""//可划转
    var totalBalance:String = ""//可用+锁仓
    var exNormalBalance:String = ""//币币余额
    var totalBorrow:String = ""//已借贷+可借贷
    var multiple:String = ""
    var burstRiskRate:String = "" //风险率
    var remindRiskRate:String = ""//风险率
    var riskRate:String = "" //风险率
    
    var normalBalance:String = ""//杠杆可用
    var maxBorrow:String = ""//最大可借贷
    var borrowBalance:String = ""//已借贷
    var coinSymbol:String = ""
    var interest:String = ""//利息
    var rate:String = ""
    var lockBalance:String = ""//杠杆锁仓
    var name:String = ""
    var minPayment:String = ""//最小还款
    var returnPrecision:String = ""//base还款精度
    var minBorrow:String = ""//最小可借贷
    
//    //所有币种列表返回对象才会有的参数
//    var showName:String = ""//币种显示名
//    var configSymbol:String = ""//币种
//    var indexPrice:String = ""//指数价格
//    var netAssetBalance:String = ""//净值
//    var netAssetBalanceValue:String = ""//净值折合btc
//    var u_netAssetBalanceValue:String = ""//净值折合usdt
//    var symbolBalance:String = ""//币种btc折合资产： 借贷划转list排序使用
//    var symbolNeedReturnBalance:String = ""//币种需要归还btc折合资产：还款list排序使用
    
    func fmtHourlyRate() ->String {
        return "\(self.getHourlyRate())%"
    }
    
    func getHourlyRate() ->String {
        return rate.stringByMultiplying(multiple: "100", decimal: -1).stringByDividing(divide: "24", decimal: 6,roundDown: true)
    }
    
    func getDailyRate() ->String {
        return rate.stringByMultiplying(multiple: "100", decimal: 2)
    }
    
}


class EXLeverIsolatedCoinModel: EXBaseModel {
    //公共部分
    var quoteReturnPrecision: String = ""
    var baseTotalBorrow: String = ""
    var quoteInterest:String = ""
    var baseInterest:String = ""
    var quoteCanBorrow: String = ""
    var quoteBorrowBalance: String = ""
    var quoteMinBorrow: String = ""
    var riskRate: String = ""
    var baseNormalBalance: String = ""
    var baseTotalBalance: String = ""
    var multiple: String = ""
    var quoteNormalBalance: String = ""
    var baseMinBorrow: String = ""
    var burstPrice: String = ""
    var quoteEXNormalBalance: String = ""
    var quoteCoin: String = ""
    var quoteMinPayment: String = ""
    var baseCanBorrow: String = ""
    var baseBorrowBalance: String = ""
    var quoteLockBalance: String = ""
    var baseLockBalance: String = ""
    var name: String = ""
    var symbol: String = ""
    var baseReturnPrecision: String = ""
    var baseMinPayment: String = ""
    var quoteTotalBorrow: String = ""
    var quoteTotalBalance: String = ""
    var rate: String = ""
    var baseCoin: String = ""
    var baseExNormalBalance: String = ""
    var symbolBalance : String = ""
    var remindRiskRate:String = ""
    //只有请求单币种余额才会返回
    var baseCanTransfer: String = ""
    var quoteCanTransfer: String = ""
    var quoteNetAssetBalance:String = ""
    var baseNetAssetBalance:String = ""
    var burstRiskRate:String = ""
    var configSymbol:String = ""
    var baseNetAssetBalanceValue:String = ""
    var u_baseNetAssetBalanceValue:String = ""
    var u_quoteNetAssetBalanceValue:String = ""
    var indexPrice:String = ""//指数价格
    var quoteNetAssetBalanceValue:String = ""
    var symbolNeedReturnBalance:String = ""//币种需要归还btc折合资产：还款list排序使用
    var symbolNetAssetBalance:String = ""
    var assetSort:String = ""//排序
    
    func fmtHourlyRate() ->String {
        return "\(self.getHourlyRate())%"
    }
    
    func getHourlyRate() ->String {
        return rate.stringByMultiplying(multiple: "100", decimal: -1).stringByDividing(divide: "24", decimal:6,roundDown:true)
    }
    
    func getDailyRate() ->String {
        return rate.stringByMultiplying(multiple: "100", decimal: 2)
    }
}

extension String {
    
    func riskTitle(remind:String,brust:String) ->String {
        //999没风险,没有借贷
        //1.1 到1.3之间高分险 1.3到1.5中风险 1.5以上低风险
        // < 1.1 高风险
        var riskT:String = ""
        if self.isEquals("999") {
            riskT = "lever_risk_low".localized()
        }else {
            if self.isBiggerThan("1.5") {
                riskT = "lever_risk_low".localized()
            }else if self.isBiggerThan(brust),self.lessThanOrEqual(remind) {
                riskT = "lever_risk_high".localized()
            }else if self.isBiggerThan(remind),self.lessThanOrEqual("1.5"){
                riskT = "lever_risk_mid".localized()
            }else {
                if self.isEquals("0") {
                    riskT = ""
                }else {
                    riskT = "lever_risk_high".localized()
                }
            }
        }
        return riskT
    }
    
    func riskIcon(remind:String,brust:String) ->UIImage {
        
        //999没风险,没有借贷
        //1.1 到1.3之间高分险 1.3到1.5中风险 1.5以上低风险
        // < 1.1 高风险
        // 0 是爆仓,显示灰色-- 图标默认绿色的
        var riskIconName:String = ""
        if self.isEquals("999") {
            riskIconName = "margin_risk_diagram_green"
        }else {
            //1.1 到1.3之间高分险 1.3到1.5中风险 1.5以上低风险
            if self.isBiggerThan("1.5") {
                riskIconName = "margin_risk_diagram_green"
            }else if self.isBiggerThan(brust),self.lessThanOrEqual(remind) {
                riskIconName = "margin_risk_diagram_red".localized()
            }else if self.isBiggerThan(remind),self.lessThanOrEqual("1.5"){
                riskIconName = "margin_risk_diagram_orange".localized()
            }else {
                if self.isEquals("0") {
                    riskIconName = "margin_risk_diagram_green"
                }else {
                    riskIconName = "margin_risk_diagram_red".localized()
                }
            }
        }
        return UIImage.themeImageNamed(imageName: riskIconName)
    }
    
    func riskColor(remind:String,brust:String) ->UIColor {
        //999没风险,没有借贷
        //1.1 到1.3之间高分险 1.3到1.5中风险 1.5以上低风险
        // < 1.1 高风险
        
        var riskColor:UIColor = UIColor.ThemeState.success
        
        if self.isEquals("999") {
            riskColor = UIColor.ThemeState.success
        }else {
            //1.1 到1.3之间高分险 1.3到1.5中风险 1.5以上低风险
            if self.isBiggerThan("1.5") {
                riskColor = UIColor.ThemeState.success
            }else if self.isBiggerThan(brust),self.lessThanOrEqual(remind) {
                riskColor = UIColor.ThemeState.fail
            }else if self.isBiggerThan(remind),self.lessThanOrEqual("1.5"){
                riskColor = UIColor.ThemeState.warning
            }else {
                if self.isEquals("0") {
                    riskColor = UIColor.ThemeLabel.colorMedium
                }else {
                    riskColor = UIColor.ThemeState.fail
                }
            }
        }
        return riskColor
    }
}
