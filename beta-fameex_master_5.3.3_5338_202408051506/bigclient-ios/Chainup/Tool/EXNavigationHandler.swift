//
//  EXNavigationHandler.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/25.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import URLNavigator
import EXKit
import Swap
//0. webView 1. coinmap_ Market 2. Coinmap_ Trading Currency Pair Trading Page 3. Coinmap_ Details Coin Pair Details Page 4. otc_ Buy OTC - Purchase 5. OTC_ Sell Off the Counter - Sell 6. Order_ Record order record 7. account_ Transfer account transfer 8. otc_ Account assets - off exchange account 9. coin_ Account Asset Currency Account 10.safe_ Set Security Settings 11. safe_ Money Security Settings - Fund Password 12. personal_ Information Personal Data 13. personal_ Invitation Profile - Invitation Code 14. Collection_ Way payment method 15. real_ Name real name authentication

enum EXRouterActionKey:String {
    case taskCenter = "reward_center"
    case MarketPage = "coinmap_market"
    case TransactionPage = "coinmap_trading"
    case TransactionDetail = "coinmap_details"
    case OTCBuy = "otc_buy"
    case OTCSell = "otc_sell"
    //Cannot jump to the following page without logging in
    case digitalCurrencyDeposits = "digital_currency_deposits"
    case credit_card_deposit = "credit_card_deposit"
    case OTCOrder = "order_record"
    case Transfer = "account_transfer"
    case AssetOTC = "otc_account"
    case AssetCoin = "coin_account"
    case SafeSetting = "safe_set"
    case SafeMoney = "safe_money"
    case PersonalInfo = "personal_information"
    case Invitation = "personal_invitation"
    case OTCPayment = "collection_way"
    case AuthRealName = "real_name"
    case CommonWeb = "web"
    case BindGoogle = "bindGoogle"
    case BindPhone = "bindPhone"
    case SetUp = "setUp"
    case KYCSuccessful = "KYCSuccessful"
    case RealNameOne = "RealNameOne"
    case MarketETF = "market_etf"
    case ContractTransaction = "contract_transaction"
    case ContractFollowOrder = "contract_follow_order"
    case ContractAgent = "config_contract_agent_key"
    case Personal = "personal"
    case ContractRecord = "contract_record"
    case financial = "account_freeStaking"
    case appSearch = "appSearch"

}

class EXNavigationHandler: NSObject {
    static let `handler` = EXNavigationHandler()
    private var navigator: NavigatorType?

    open class var sharedHandler: EXNavigationHandler {
        let navigator = Navigator()
        EXNavigator.initialize(navigator: navigator)
        handler.navigator = navigator
        return handler
    }
    
    //hiexCommand://trade?coinPair=xxx&action=xxx
    func commandTradingCoin(_ symbol:String,_ action:String) {
        let command =  "hiexCommand://trade?" + "symbol=\(symbol)&action=\(action)&tradeType=exchange"
        self.navigator?.open(command)
    }
    
    //hiexCommand://trade?coinSymbol=xxx&action=xxx
    func commandToOTC(_ symbol:String,_ action:String) {
        let command =  "hiexCommand://trade?" + "symbol=\(symbol)&action=\(action)&tradeType=otc"
        self.navigator?.open(command)
    }
    
    //hiexCommand://trade?coinSymbol=xxx&action=xxx
    func commandToContract(_ contractId:String,_ action:String) {
        let command =  "hiexCommand://trade?" + "contractId=\(contractId)&action=\(action)&tradeType=contract"
        self.navigator?.open(command)
    }
    
    //hiexCommand://trade?action=xxx
    func commandToAsset(_ action:String) {
        let command =  "hiexCommand://trade?" + "action=\(action)&tradeType=asset"
        self.navigator?.open(command)
    }

    func commonJumpCommand(_ action:String,_ extra:String = "",_ title:String = "") {
        let command =  "hiexCommand://commonJump?" + "action=\(action)&extra=\(extra)&title=\(title)"
        self.navigator?.open(command)
    }
}

enum EXNavigator {
    static func initialize(navigator: NavigatorType) {
        //Processing commands
        navigator.handle("hiexCommand://trade") { (url, values, context) -> Bool in
            // No navigator match, do analytics or fallback function here
            EXNavigationExcute.handleCommandTrade(url)
            return true
        }
        
        //Handling jump commands on the homepage
        navigator.handle("hiexCommand://commonJump") { (url, values, context) -> Bool in
            EXNavigationExcute.handleCommonCommandJump(url)
            return true
        }
        
        
        navigator.register("hiexIndoorJump://indoorvc") { (url, values, context) -> UIViewController? in
            let vcname = url.queryParameters["name"]
            if let name = vcname {
                if name == "EXGoogleBindingVC" {
                    return EXGoogleBindingVC()
                }else {
                    return nil
                }
            }else {
                return nil
            }
        }
    }
}


class EXNavigationExcute: NSObject {
    
    static func handleCommonCommandJump(_ cmd:URLConvertible) {
        guard let action = cmd.queryParameters["action"] else { return }
        guard let topVc = AppService.topViewController() else { return }
         if action == EXRouterActionKey.CommonWeb.rawValue {
            guard let webUrl = cmd.queryParameters["extra"] else { return }
             if webUrl.contains("kolTradersListNew"){//heyue gendan
                 if XUserDefault.isOffLine(){
                     BusinessTools.modalLoginVC()
                     return
                 }
             }
            guard let _ = URL.init(string: webUrl) else { return }
            let webTitle = cmd.queryParameters["title"]
            let web = WebVC()
            web.customTitle = webTitle ?? ""
            if let httpurl = webUrl.removingPercentEncoding {
                web.loadUrl(httpurl)
            }else {
                web.loadUrl(webUrl)
            }
            topVc.navigationController?.pushViewController(web, animated: true)
         }else if action == EXRouterActionKey.taskCenter.rawValue{
             let task = EXTaskCenterViewController()
             topVc.navigationController?.pushViewController(task, animated: true)
         }else if action == EXRouterActionKey.appSearch.rawValue {
            let marketvc = MarketSearchVC()
             if let toContract = cmd.queryParameters["extra"], toContract.isEmpty == false{
                 marketvc.selectContract = true
             }
             
            topVc.navigationController?.pushViewController(marketvc, animated: true)
        }else if action == EXRouterActionKey.MarketPage.rawValue {
            if let idx = EXAppConfigManager.sharedInstance.appModules.firstIndex(of: .market) {
                self.cyl_topmostViewController()?.cyl_popSelectTabBarChildViewController(at: UInt(idx))
            }
        }else if action == EXRouterActionKey.TransactionPage.rawValue {
            
            guard let coinPair = cmd.queryParameters["extra"] else { return }
            self.cyl_dismissAll {
                if let idx = EXAppConfigManager.sharedInstance.appModules.firstIndex(of: .transaction) {
                    self.cyl_topmostViewController()?.cyl_popSelectTabBarChildViewController(at: UInt(idx), completion: { (rvc) in
                        if let vc = rvc as? EXTradeCmdProtocal {
                            vc.excuteCmd(symbol: coinPair, action: "buy")
                        }
                    })
                }
            }
        }else if action == EXRouterActionKey.TransactionDetail.rawValue {
            
            guard let coinPair = cmd.queryParameters["extra"] else { return }
            let entity = EXAppMarketManager.sharedInstance.getCoinMapEntityBySymbol(coinPair)
            if entity.name == ""{
                EXAlert.showFail(msg: LanguageTools.getString(key: "common_tip_hasNoCoinPair"))
                return
            }
//            let dvc = EXKLineDetailVC()
//            dvc.entity = entity
            let dvc = EXKlineDetailNewVC(entity: entity)
            topVc.navigationController?.pushViewController(dvc, animated: true)
 
        }else if action == EXRouterActionKey.OTCBuy.rawValue {
            let coinPair = cmd.queryParameters["extra"] ?? ""
            if EXHomeViewModel.isContractStatus() {
                if let idx = EXAppConfigManager.sharedInstance.appModules.firstIndex(of: .fiat) {
                    self.cyl_topmostViewController()?.cyl_popSelectTabBarChildViewController(at: UInt(idx), completion: { (rvc) in
                        if let vc = rvc as? EXTradeCmdProtocal {
                            vc.excuteCmd(symbol: coinPair, action: "buy")
                        }
                    })
                }else {
                    EXAlert.showFail(msg: "common_tip_notSupportOTC".localized())
                }
            }else {
                if EXAppConfigManager.sharedInstance.didOpenFiat() {
                    let otc = EXOTCHomeContainerVc.instanceFromStoryboard(name: StoryBoardNameOTC)
                    otc.excuteCmd(symbol: coinPair, action: "buy")
                    topVc.navigationController?.pushViewController(otc, animated: true)
                }else {
                    EXAlert.showFail(msg: "common_tip_notSupportOTC".localized())
                }
            }
        }else if action == EXRouterActionKey.OTCSell.rawValue {
            let coinPair = cmd.queryParameters["extra"] ?? ""
            if EXHomeViewModel.isContractStatus() {
                if let idx = EXAppConfigManager.sharedInstance.appModules.firstIndex(of: .fiat) {
                    self.cyl_topmostViewController()?.cyl_popSelectTabBarChildViewController(at: UInt(idx), completion: { (rvc) in
                        if let vc = rvc as? EXTradeCmdProtocal {
                            vc.excuteCmd(symbol: coinPair, action: "sell")
                        }
                    })
                }else {
                    EXAlert.showFail(msg: "common_tip_notSupportOTC".localized())
                }
            }else {
                if EXAppConfigManager.sharedInstance.didOpenFiat() {
                    let otc = EXOTCHomeContainerVc.instanceFromStoryboard(name: StoryBoardNameOTC)
                    otc.excuteCmd(symbol: coinPair, action: "sell")
                    topVc.navigationController?.pushViewController(otc, animated: true)
                }else {
                    EXAlert.showFail(msg: "common_tip_notSupportOTC".localized())
                }
            }

        }else if action == EXRouterActionKey.ContractTransaction.rawValue {
            self.cyl_dismissAll {
                if let idx = EXAppConfigManager.sharedInstance.appModules.firstIndex(of: .contract) {
                    self.cyl_topmostViewController()?.cyl_popSelectTabBarChildViewController(at: UInt(idx))
                }
            }
        }else if action == EXRouterActionKey.MarketETF.rawValue {
            if let idx = EXAppConfigManager.sharedInstance.appModules.firstIndex(of: .market) {
                self.cyl_topmostViewController()?.cyl_popSelectTabBarChildViewController(at: UInt(idx), completion: { (rvc) in
                    if let vc = rvc as? EXTradeCmdProtocal {
                        vc.excuteCmd(symbol: "ETF", action: "")
                    }
                })
            }
        
        }else if action == EXRouterActionKey.ContractAgent.rawValue {
           
            BusinessTools.sharedInstance().modalLoginVC("") {
                
                let contractAgent = EXContractAgentHomeVc.init()
                topVc.navigationController?.pushViewController(contractAgent, animated: true)
            }
            
        }else if action == EXRouterActionKey.Personal.rawValue {
            //Face++pops up, turn it off before entering
            if let pvc = topVc.presentingViewController {
                pvc.dismiss(animated: false) {
                    if let topVc = AppService.topViewController() {
                        let meVC = EXMEVC()
                        topVc.navigationController?.pushViewController(meVC, animated: true)
                    }
                }
            }else {
                let meVC = EXMEVC()
                topVc.navigationController?.pushViewController(meVC, animated: true)
            }

        }else {
            //If not logged in, do not redirect
            if XUserDefault.getToken() == nil{
                BusinessTools.modalLoginVC()
                return
            }
            if action == EXRouterActionKey.credit_card_deposit.rawValue{
                let v = EXQuickBuyCoinViewController()
                topVc.cyl_push(v, animated: true)
                return
            }else if action == EXRouterActionKey.digitalCurrencyDeposits.rawValue {
                var coinPair = "USDT"
                if let coin = cmd.queryParameters["extra"]  {
                    coinPair = coin
                }
                let charge = EXCoinRechageVc.instanceFromStoryboard(name: StoryBoardNameAsset)
                charge.symbol = coinPair
                charge.backLastOne = true
                topVc.cyl_push(charge, animated: true)
            }else if action == EXRouterActionKey.OTCOrder.rawValue {
                let otclist = EXOTCHistoryListVc.instanceFromStoryboard(name: StoryBoardNameOTC)
                topVc.navigationController?.pushViewController(otclist, animated: true)
            }else if action == EXRouterActionKey.Transfer.rawValue {
                let transfer = EXAccountTransferVc.instanceFromStoryboard(name: StoryBoardNameAsset)
                transfer.transferFlow = .exchangeToOther
                topVc.navigationController?.pushViewController(transfer, animated: true)
            }else if action == EXRouterActionKey.AssetOTC.rawValue {
                if let idx = EXAppConfigManager.sharedInstance.appModules.firstIndex(of: .assets) {
                    self.cyl_topmostViewController()?.cyl_popSelectTabBarChildViewController(at: UInt(idx), completion: { (rvc) in
                        if let vc = rvc as? EXTradeCmdProtocal {
                            vc.excuteCmd(symbol: "", action: "otc")
                        }
                    })
                }else {
                    let topVc = AppService.topViewController()
                    let asset = EXAssetsVc.init()
                    asset.assetType = .otc
                    topVc?.navigationController?.pushViewController(asset, animated: true)
                }
            }else if action == EXRouterActionKey.AssetCoin.rawValue {
                if let idx = EXAppConfigManager.sharedInstance.appModules.firstIndex(of: .assets) {
                    self.cyl_topmostViewController()?.cyl_popSelectTabBarChildViewController(at: UInt(idx), completion: { (rvc) in
                        if let vc = rvc as? EXTradeCmdProtocal {
                            vc.excuteCmd(symbol: "", action: "coin")
                        }
                    })
                }else {
                    let topVc = AppService.topViewController()
                    let asset = EXAssetsVc.init()
                    asset.assetType = .coin
                    topVc?.navigationController?.pushViewController(asset, animated: true)
                }
            }else if action == EXRouterActionKey.SafeSetting.rawValue {
                let safevc = EXSecurityCenterVC()
                topVc.navigationController?.pushViewController(safevc, animated: true)
            }else if action == EXRouterActionKey.SafeMoney.rawValue {
                let otcpwd = EXChangeOTCPWVC()
                topVc.navigationController?.pushViewController(otcpwd, animated: true)
            }else if action == EXRouterActionKey.PersonalInfo.rawValue {
                let userInfo = EXMyInfoVC()
                topVc.navigationController?.pushViewController(userInfo, animated: true)
            }else if action == EXRouterActionKey.OTCPayment.rawValue {
                let userInfo = EXOTCAvailablePaymentVc.instanceFromStoryboard(name:StoryBoardNameAsset)
                topVc.navigationController?.pushViewController(userInfo, animated: true)
            }else if action == EXRouterActionKey.AuthRealName.rawValue {
                let user = UserInfoEntity.sharedInstance()
                if user.authLevel == UserAuthLevel.pending.rawValue {
                    let realName = EXRealNameThreeVC()
                    EXAlert.showVc(controller: realName,ratio: 0.9)
//                    topVc.navigationController?.pushViewController(realName, animated: true)
                }else {
                    let realName = EXIDAuthenticViewController()
                    topVc.navigationController?.pushViewController(realName, animated: true)
                }
            }else if action == EXRouterActionKey.Invitation.rawValue{
                BusinessTools.sharedInstance().modalLoginVC("") {
                    let contractAgent = EXContractAgentHomeVc.init()
                    topVc.navigationController?.pushViewController(contractAgent, animated: true)
                }
            }else if action == EXRouterActionKey.BindGoogle.rawValue{
                let userInfo = EXGoogleBindingVC()
                topVc.navigationController?.pushViewController(userInfo, animated: true)
            }else if action == EXRouterActionKey.BindPhone.rawValue{
                let userInfo = EXMoblieBindingVC()
                topVc.navigationController?.pushViewController(userInfo, animated: true)
            }else if action == EXRouterActionKey.SetUp.rawValue{
                if EXOTCSafetyCheckVm.manager.checkOTCBasicRequire(topVc) {
                    let listVc = EXOTCSupportPaymentMethodVc.instanceFromStoryboard(name: StoryBoardNameAsset)
                    topVc.navigationController?.pushViewController(listVc, animated: true)
                }
            }else if action == EXRouterActionKey.KYCSuccessful.rawValue{
                let userInfo = EXRealNameThreeVC()
                EXAlert.showVc(controller: userInfo,ratio: 0.9)
//                topVc.navigationController?.pushViewController(userInfo, animated: true)
            }else if action == EXRouterActionKey.RealNameOne.rawValue{
                let userInfo = EXRealNameOneVC()
                userInfo.mainView.regionEntity = RegionManager.sharedInstance.regionEntity
                topVc.navigationController?.pushViewController(userInfo, animated: true)
            }else if action == EXRouterActionKey.ContractRecord.rawValue {
                if EXAppConfigManager.sharedInstance.getContractVersion() == .new {
                
                    let assetsRecordVC = EXSAssetsRecordVC()
                    assetsRecordVC.isBouns = true
                    topVc.navigationController?.pushViewController(assetsRecordVC, animated: true)
                }else {
                    
//                    let assetsRecordVC = SLAssetsRecordVC()
//                    assetsRecordVC.isBouns = true
//                    topVc.navigationController?.pushViewController(assetsRecordVC, animated: true)
                }
                
            }else if action == EXRouterActionKey.financial.rawValue {
                let vc = EXPosHomeVC()
                topVc.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    
    static func handleCommandTrade(_ cmd:URLConvertible) {
        guard let tradeType = cmd.queryParameters["tradeType"] else { return }

        if tradeType == "exchange" {
            //Processing commands
            guard let coinPair = cmd.queryParameters["symbol"] else { return }
            guard let action = cmd.queryParameters["action"] else { return }
            
            self.cyl_dismissAll {
                if let idx = EXAppConfigManager.sharedInstance.appModules.firstIndex(of: .transaction) {
                    self.cyl_topmostViewController()?.cyl_popSelectTabBarChildViewController(at: UInt(idx), completion: { (rvc) in
                        if let vc = rvc as? EXTradeCmdProtocal {
                            vc.excuteCmd(symbol: coinPair, action: action)
                        }
                    })
                }
            }
        }else if tradeType == "otc" {
            guard let coinName = cmd.queryParameters["symbol"] else { return }
            guard let action = cmd.queryParameters["action"] else { return }
            if EXHomeViewModel.isContractStatus() {
                if let idx = EXAppConfigManager.sharedInstance.appModules.firstIndex(of: .fiat) {
                    self.cyl_topmostViewController()?.cyl_popSelectTabBarChildViewController(at: UInt(idx), completion: { (rvc) in
                        if let vc = rvc as? EXTradeCmdProtocal {
                            vc.excuteCmd(symbol: coinName, action: action)
                        }
                    })
                }
            }else {
                if EXAppConfigManager.sharedInstance.didOpenFiat() {
                    let topVc = AppService.topViewController()
                    let otc = EXOTCHomeContainerVc.instanceFromStoryboard(name: StoryBoardNameOTC)
                    topVc?.navigationController?.pushViewController(otc, animated: true)
                }
            }

        }else if tradeType == "contract" {
            guard let contractId = cmd.queryParameters["contractId"] else { return }
            guard let action = cmd.queryParameters["action"] else { return }
            
            if let idx = EXAppConfigManager.sharedInstance.appModules.firstIndex(of: .contract) {
                self.cyl_topmostViewController()?.cyl_popSelectTabBarChildViewController(at: UInt(idx), completion: { (rvc) in
                    if let vc = rvc as? EXTradeCmdProtocal {
                        vc.excuteCmd(symbol: contractId, action: action)
                    }
                })
            }
            
        }else if tradeType == "asset" {
            guard let action = cmd.queryParameters["action"] else { return }

            if let idx = EXAppConfigManager.sharedInstance.appModules.firstIndex(of: .assets) {
                self.cyl_topmostViewController()?.cyl_popSelectTabBarChildViewController(at: UInt(idx), completion: { (rvc) in
                    if let vc = rvc as? EXTradeCmdProtocal {
                        vc.excuteCmd(symbol: "", action: action)
                    }
                })
            }else {
                let topVc = AppService.topViewController()
                let asset = EXAssetsVc.init()
                var assetType:EXAccountType = .coin
                if action == "otc" {
                    assetType = .otc
                }else if action == "contract" {
                    assetType = .contract
                }else if action == "leverage"{
                    assetType = .leverage
                }
                asset.assetType = assetType
                topVc?.navigationController?.pushViewController(asset, animated: true)
            }
        }
    }
}

