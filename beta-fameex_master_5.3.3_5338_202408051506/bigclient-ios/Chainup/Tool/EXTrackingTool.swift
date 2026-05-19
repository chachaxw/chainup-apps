//
//  EXTracking.swift
//  Chainup
//
//  Created by liuxuan on 2023/12/30.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
import Swap
import FirebaseAnalytics


struct FirebaseKey {
    static let HomePageview = "HomePageview"
    static let Home_Search_click = "Home_Search_click"
    static let Home_TopGainers_click = "Home_TopGainers_click"
    static let Home_TopLosers_click = "Home_TopLosers_click"
    static let Home_VOLLeaders_click = "Home_VOLLeaders_click"
    static let Marketpageview = "Marketpageview"
    static let Market_Favorites_click = "Market_Favorites_click"
    static let Market_Name_click = "Market_Name_click"
    static let Market_Lastprice_click = "Market_Lastprice_click"
    static let Market_Change_click = "Market_Change_click"
    static let Tradepageview = "Tradepageview"
    static let Trade_Exchange_click = "Trade_Exchange_click"
    static let Trade_Grid_click = "Trade_Grid_click"
    static let Trade_Margin_click = "Trade_Margin_click"
    static let Trade_P2P_click = "Trade_P2P_click"
    static let Trade_Kline_click = "Trade_Kline_click"
    static let ContractPageview = "ContractPageview"
    static let BalancePageview = "BalancePageview"
    static let Balance_exchange_click = "Balance_exchange_click"
    static let Balance_contract_click = "Balance_contract_click"
    static let Balance_p2p_click = "Balance_p2p_click"
    static let Balance_margin_click = "Balance_margin_click"
    static let Balance_saving_click = "Balance_saving_click"
    static let Balance_Deposit_click = "Balance_Deposit_click"
    static let Balance_Withdraw_click = "Balance_Withdraw_click"
    static let Balance_Transfer_click = "Balance_Transfer_click"
    static let Balance_Transactions_click = "Balance_Transactions_click"
    static let Balance_Hidesmallbalance_click = "Balance_Hidesmallbalance_click"
    static let Balance_search_click = "Balance_search_click"
}

enum EXTrackingPage:String {
    case home = "HomePage"
    case market = "MarketPage"
    case fiat = "FiatPage"
    case contract = "ContractPage"
    case assets = "AssetsPage"
    case leverage = "LeveragePage"
    case transaction = "SpotTransactionPage"
    case swapfirst = "合约-首页"
    case swaplossrecord = "合约-盈亏记录"
    case swapfundtransfer = "合约-资金划转"
    case swapCapitalFlow = "合约-资金流水"
    case swapcontractinformation = "合约-合约信息"
    case swaptransactionsettings = "合约-交易设置"
    case swapallcommissioned = "合约-全部委托"
    case swapcurrentcommission = "合约-当前委托"
    case swaphistoricalcommission = "合约-历史委托"
    case swapcommissiondetails = "合约-委托详情"

}

enum EXTrackingEvent:String {
    case trackOrderCreate = "OrderCreate"
    case trackOrderCancel = "OrderCancel"
    case trackLeverCreate = "LeverCreate"
    case trackLeverCancel = "LeverCancel"
    case httpTrack = "httpTrack"
    case httpTrackLow = "httpTrackLow"
    case httpError = "httpError"
    case wsTrack = "wsTrack"
    case wsTrackLow = "wsTrackLow"
    case wsTrackError = "wsTrackError"
    case swapOpenPosition = "合约-下单区-开仓"
    case swapordersplaced10 = "合约-下单百分比-10%"
    case swapordersplaced20 = "合约-下单百分比-20%"
    case swapordersplaced50 = "合约-下单百分比-50%"
    case swapordersplaced100 = "合约-下单百分比-100%"
    case swapClosePosition = "合约-下单区-平仓"
    case swapCloseOpponent1 = "合约-下单区-对手1档"
    case swapCloseOpponent5 = "合约-下单区-对手5档"
    case swapCloseOpponent10 = "合约-下单区-对手10档"
    case swapOrderAreaTransfer = "合约-下单区-划转"
    case swapPositionClose  = "合约-持仓-平仓"
    case swapPositionMarketPrice  = "合约-持仓-市价"
    case swapbestcounterparty = "合约-持仓-对手方最优"
    case swapOwnBest = "合约-持仓-本方最优"
    case swapOwnShare = "合约-持仓-分享"
}

extension EXTracking {
    
//    private func setGloable(key:String,v:String) {
//        TalkingData.setGlobalKV(key, value:v)
//    }
//        
//    func addGlobaleUser(uid:String) {
//        TalkingData.setGlobalKV("ex_uid", value:uid)
//    }
//
//    func removeGloableUser() {
//        TalkingData.removeGlobalKV("ex_uid")
//    }

    //Precautions:
    //TrackPageBegin and trackPageEnd must be called in pairs.
    func trackPage(name:EXTrackingPage,isEnter:Bool) {
        if isEnter {
            track(event: name.rawValue, parameters: nil)
        }
    }
    
    @available(*, deprecated, message: "use track(event:parameters:) instead")
    func track(event:EXTrackingEvent,label:String = "",info:[String:Any]) {
        track(event: event.rawValue, parameters: info)
    }
    
    func uploadInterFaceData(model:EXInterfaceData) {
        if model.duration == "" {
            return
        }
        appApi.hideAutoLoading()
        appApi.rx.request(.saveInterfaceData(line: model.line,
                                             duration: model.duration,
                                             page: model.page,
                                             action: model.action,
                                             errorType: model.errorType))
            .MJObjectMap(EXVoidModel.self, false)
            .subscribe(onSuccess: { (_) in
            }) { (error) in
            }.disposed(by: disposeBag)
    }
}


enum EXInterfacePage:String {
    case home = "home"
    case market = "market"
    case kline = "kline"
    case transaction = "transaction"
    case wsService = "wsService"
}

enum EXInterfaceAction:String {
    case subBatch = "sub_batch"
    case subHistory = "sub_history"
    case subDepth = "sub_depth"
    case httpHome = "http_home"
    case wsHandShake = "ws_open"
}

class EXInterfaceData:EXBaseModel {
    var line:String = ""
    var duration:String = ""
    var page:String = ""
    var action:String = ""
    var errorType:String = ""
    
    required init(page:EXInterfacePage,action:EXInterfaceAction) {
        if EXKitStanders.isOverSeasVersion() == false {
            self.line = EXNetworkDoctor.sharedManager.getAppAPIHost().hostStr()
        }else {
            self.line = NetDefine.http_host_url.hostStr()
        }
        self.page = page.rawValue
        self.action = action.rawValue
    }
}


extension EXTracking {
    @available(*, deprecated, message: "use track(event:parameters:) instead")
    func trackFirebase(firebaseKey:String,info:[String:Any] = [:]) {
        track(event: firebaseKey, parameters: info)
    }
}

extension EXTracking {
    /// A flag for QA to debug firebase event via the log system, this value can be injected by the settings of a jenkins job.
    static let firebase_debug: Bool = Bundle.main.infoDictionary?["qa_firebase_test"] as? Int == 1
    func setup() {
        ///
        Self.logEventBlock = { (eventID:String,parameters:[String:Any]?) in
            Analytics.logEvent(eventID, parameters: parameters)
            if Self.firebase_debug {
                EXLogger.debug(scene: "firebase", message: "[EXTracking][Firebase/Analytics] event:\(eventID) parameters:\(parameters?.description ?? "-")")
            }
        }
        Self.updateUserIDBlock = { userid in
            Analytics.setUserID(userid)
        }
        Self.updateUserPropertyBlock = { (name:String, value:String?) in
            Analytics.setUserProperty(value, forName: name)
        }
        if XUserDefault.isOffLine() == false {
            EXTracking.shared.login(with: UserInfoEntity.sharedInstance().uid)
        }else{
            EXTracking.shared.logout()
        }
        _ = NotificationCenter.default.rx.notification(EXNoti.loginSuccess.notiName)
            .take(until: UIApplication.rx.willTerminate)
            .subscribe(onNext: { _ in
                EXTracking.shared.track(event: "login_ok")
                EXTracking.shared.login(with: UserInfoEntity.sharedInstance().uid)
            })
        _ = NotificationCenter.default.rx.notification(EXNoti.logout.notiName)
            .take(until: UIApplication.rx.willTerminate)
            .subscribe(onNext: { _ in
                EXTracking.shared.logout()
            })
        _ = NotificationCenter.default.rx.notification(EXNoti.lanDownloadSuccess.notiName)
            .take(until: UIApplication.rx.willTerminate)
            .subscribe(onNext: { _ in
                EXTracking.shared.updateGlobalAttributes(.lan, value: LanguageHandler.phoneLanguage)
            })
        if Self.firebase_debug {
            /// For more details, you can view the source code of FIRLogger.
            UserDefaults.standard.set(true, forKey: kFIRPersistedDebugModeKey)
        }
    }
}
