//
//  SLUserConfig.swift
//  Chainup
//
//  Created by ZYJ on 2023/10/12.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
let EXS_IS_NEWPRICE = "EXS_IS_NEWPRICE"//盈亏计算方式 0 最新价格  1 标记价格 English: Profit and loss calculation method 0 latest price 1 marked price
let EXS_HOLD_MODE = "SL_HOLD_MODE"//持仓模式 English: Position holding mode
let HAS_OPNE_CONTRACT = "HAS_OPNE_CONTRACT"
let EXS_UNIT_VOL = "EXS_UNIT_VOL"//数量单位 English: Quantity unit
/**
 * 认证类型 English: *Certification type
 *  认证状态 0、未审核，1、通过，2、未通过, 3、未认证，4 无法获取用户信息，请刷新后重试 English: *Authentication status 0, Unaudited, 1, Passed, 2, Not Passed, 3, Not Authenticated, 4 Unable to obtain user information. Please refresh and try again
 */
enum EXSUserAuthLevel:String {
    case pending = "0"
    case pass = "1"
    case reject = "2"
    case newbie = "3"
    case notGet = "4"
}
enum SLMarginMode:Int {
    case cross = 1
    case fixed = 2
    
    var introduced: String {
        get {
            switch self {
            case .cross:
                return "cp_contract_setting_text1".ex_localized()
            case .fixed:
                return "cp_contract_setting_text2".ex_localized()
            }
        }
    }
}
enum SLPositionMode {
    case single
    case both
}
public class SLUserConfig: EXCOBaseModel {
    
    var contractId:Int64 = 0 {
        didSet {
            EXStoreData.setStoreObjectAndKey(SLMarginMode.init(rawValue: marginModel)?.introduced, key: "BTLeveageType"+String(contractId))
        }
    }
    //    当前保证金模式 1全仓, 2逐仓 English: Current margin model 1: full position, 2: position by position
    var marginModel = 0
    
    //    用户是否开通了合约交易 1已开通, 0未开通 English: Has the user opened a contract transaction? 1 has been opened, 0 has not been opened
    public var openContract:String = ""
    
    //    是否可以切换 1是, 0否 English: Can I switch between 1 Yes, 0 No
    var marginModelCanSwitch:String = ""
    //    当前杠杆倍数 English: Current leverage ratio
    var nowLevel:String = "20"
    
    //    最小杠杆倍数 English: Minimum leverage ratio
    var minLevel:String = ""
    
    //    最大杠杆倍数 English: Maximum leverage ratio
    var maxLevel:String = ""
    //    当前杠杆是否可以切换 English: Can the current lever be switched
    var levelCanSwitch:String = ""
    
    //    持仓类型 1持仓, 2双向持仓 English: Position Type 1 Position, 2 Bidirectional Positions
    var positionModel:String = ""
    
    //    当前持仓类型是否可以切换 English: Can the current position type be switched
    var positionModelCanSwitch:String = ""
    
    //    合约单位 1标的货币, 2张 English: Contract unit 1 subject currency, 2 sheets
    var coUnit:String = "1"
    
    //    系统当前时间戳 English: Current timestamp of the system
    var currentTimeMillis:String = ""
    //(用户)当前持仓最高支持杠杆 English: The highest supported leverage for the current position of the user
    var userMaxLevel:String = ""
    //标的货币单位; BTC等 English: The target currency unit; BTC, etc
    var multiplierCoin:String = ""
    
    var leverCeiling = [String:NSNumber]()
    var leverOriginCeiling = [String:NSNumber]()
    
    var leverAndMaxCoinDic = [String:String]()
   /*
     authLevel 认证状态    0、未审核，1、通过，2、未通过  3未认证 English: AuthLevel authentication status 0, not audited, 1, passed, 2, not passed, 3 not authenticated
     futuresLocalLimit    1 区域限制范围内  0 不在限制范围 English: FuturesLocalLimit 1 is within the restricted area, 0 is not within the restricted area
     */
    var futuresLocalLimit = ""//    1 区域限制范围内  0 不在限制范围 English: 0 is not within the restricted range of Zone 1
    var authLevel = ""//            0、未审核，1、通过，2、未通过  3未认证 English: 0. Unaudited, 1. Passed, 2. Not Passed, 3. Not Certified
    var brokerType = ""//            0 SAAS  1 私有化   2 合约云 English: 0 SAAS 1 Privatization 2 Contract Cloud
    var forceKycOpen = "" // 0：关闭（不强制kyc） 1：开启（强制kyc） English: 0: Turn off (do not force kyc) 1: Turn on (force kyc)
    var limitDomesticUserTrade = "" //  0：关闭（不限制） 1：开启（限制） English: 0: Off (unrestricted) 1: On (restricted)
    var couponTag = ""
    var expireTime = ""
    var priceBasis = "0" //0 最新价格  1 标记价格 English: 0 Latest Price 1 Mark Price
    var leverAndMaxValueDic = [String:String]()
    var isSwapYun:Bool {
        return brokerType == "2"
    }
    var shouldLimit:Bool {
        return futuresLocalLimit == "1"
    }
    // 是否通过kyc验证 English: Have you passed KYC verification
    var kycVailatePassed: Bool {
        if forceKycOpen == "1" { //需要验证 English: Verification required
            //验证通过 English: Verification passed
            if authLevel == "1"{
                return true
            }
            return false
        }
        return true
    }
    var areaLimitPassed: Bool {
        //如果开关为关，验证地区 English: If the switch is off, verify the region
        if forceKycOpen == "0" {
            return futuresLocalLimit == "0"
        }
        return true
    }
    
    func shouldQueryCoupon() -> Bool {
        
        return EXSwapPlatformSDK.shared.activeAccount != nil &&
            hasOpenContract() &&
            couponTag == "0"
    }
    public func hasOpenContract() -> Bool {
        return openContract == "1"
    }
    
    func marginModeCanChange() -> Bool {
    
        return marginModelCanSwitch == "1"
    }
    
    func leverageCanChange() -> Bool {
        return levelCanSwitch == "1"
    }
    
    func marginMode() -> SLMarginMode {
        
        if marginModel == 1 {
            return .cross
        }
        if marginModel == 2 {
            return .fixed
        }
        return .cross
    }
  
    func positionMode() -> SLPositionMode {
        if positionModel == "1" {
            return .single
        }
        if positionModel == "2" {
            return .both
        }
        return .both
    }
    
    func isPositionModeCanSwitch() -> Bool {
        return positionModelCanSwitch == "1"
    }
   
    public static var checkHasOpenContract : Bool {
        return EXStoreData.storeBool(forKey: HAS_OPNE_CONTRACT)
    }
    
    func modelCustomTransform(from dic: [AnyHashable : Any]) -> Bool {
        EXStoreData.setStoreObjectAndKey(priceBasis == "0" ? 1: 0, key: EXS_IS_NEWPRICE)
        EXStoreData.setStoreObjectAndKey(positionModel == "2" ? 1: 0, key: EXS_HOLD_MODE)
        EXStoreData.setStoreObjectAndKey(coUnit == "2" ? 0 : 1, key: EXS_UNIT_VOL)
        EXStoreData.setStoreObjectAndKey(hasOpenContract() ? 1 : 0, key: HAS_OPNE_CONTRACT)
        let idx = EXSwapPlanOrderValidityPeriod.initWithParm(parm: expireTime)
        EXStoreData.setStoreObjectAndKey(idx.rawValue, key: EX_DATE_CYCLE)
        leverAndMaxCoinDic = EXSTools.generateLeverAndMaxCoinDic(maxLever: maxLevel, minLever: minLevel, leverCeiling: leverCeiling)
        leverAndMaxValueDic = EXSTools.generateLeverAndMaxCoinDic(maxLever: maxLevel, minLever: minLevel, leverCeiling: leverOriginCeiling)
        return true
    }
}

