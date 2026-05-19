//
//  EXAppConfigManager.swift
//  Chainup
//
//  Created by liuxuan on 2023/9/7.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import RxSwift
import Tiercel
import EXKit
import Swap
enum EXAppConfigModules {
    case home //home page
    case market //market
    case transaction //Trading (currency+leverage)
    case fiat //Fiat currency
    case contract //contract
    case assets //asset
}

enum EXAppContractType {
    case old //Old contract
    case new //New contract
    case forceNew //Force new contracts without switching
}

class IncrementConfig: SuperEntity {
    var isNew = ""
    var name = ""
    var status = ""
    override func setEntityWithDict(_ dict: [String : Any]) {
        super.setEntityWithDict(dict)
        status = dictContains("status")
        isNew = dictContains("isNew")
        name = dictContains("name")
    }

}
class EXAppConfigManager: NSObject {
    var lastAppModules:[EXAppConfigModules] = [.home,.market,.transaction,.assets]
    //MARK: Single Example
    let disposeBag = DisposeBag()
    var configVm:EXAppConfigVM = EXAppConfigVM()
//    var incrementConfig:IncrementConfig = IncrementConfig()
    //Due to the old version writing method, use behavior and give a default value once
    var appModules:[EXAppConfigModules] = [.home,.market,.transaction,.assets]
    var onPbV5Publish : BehaviorSubject<Bool> = BehaviorSubject.init(value: false)
    let configDownloader:SessionManager = SessionManager.init("configManager", configuration: SessionConfiguration())
    ///Restrict access
    let limitVisit: PublishSubject<EXApplimitVisitModel> = PublishSubject()
    
    //↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓ Parameters written in the contract ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
    var online_swap_guide = "https://bikiuser.zendesk.com/hc/zh-cn/sections/360007889891" //Contract Guidelines
    var online_swap_ADL = "https://bikiuser.zendesk.com/hc/zh-cn/articles/360039490271" //Automatic position reduction
    var online_swap_Close = "https://bikiuser.zendesk.com/hc/zh-cn/sections/360007889891" //Compulsory closing of positions
    //The lever switch of the contract does not go through publicinfo assignment
    var isOpenGloblelever = false
    var changLan = false
    //↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑ Parameters of contract writing ↑↑↑↑↑↑↑↑
    
    func resetBehaviorSubject(){
        self.onPbV5Publish = BehaviorSubject.init(value: false)
    }

    static let sharedInstance: EXAppConfigManager = {
        let instance = EXAppConfigManager()
        if let cacheV5 = EXAppCache.sharedCache.getPbV5Cache() {
            instance.updateAppModules(model: cacheV5)
            instance.configVm.appConfigVmWith(config: cacheV5)
        }
        return instance
    }()
    
    func updateAppModules(model:EXAppConfigModel) {
        if EXHomeViewModel.isContractStatus() {
            if model.otcOpen == "1" {
                appModules = [.home,.fiat,.contract,.assets]
            }else {
                appModules = [.home,.contract,.assets]
            }
        }else {
            if model.otcOpen == "1",model.contractOpen == "1" {
                appModules = [.home,.market,.transaction,.contract,.assets]
            }else if model.otcOpen == "1" {
                appModules = [.home,.market,.transaction,.assets]
            }else if model.contractOpen == "1" {
                appModules = [.home,.market,.transaction,.contract,.assets]
            }
        }
    }
    
    func configDownloadIcons(model:AppPersonalIcon) {
//        configDownloader.multiDownload(model.allIcons())
        configDownloader.multiDownload(model.allIcons(),fileNames: model.allIconFileName())
        configDownloader.completion { (manager) in
//            print("Total tasks:  (manager. succededTasks. count)/ (manager. tasks. count)")
        }
    }
    
    ///Access restriction check
    func checkVistStatus() {
        appApi.hideAutoLoading()
        appApi.rx.request(.checkVisitStatus).MJObjectMap(EXApplimitVisitModel.self).subscribe { [weak self] event in
            guard let `self` = self else { return }
            switch event {
            case .success(let model):
                self.limitVisit.onNext(model)
            break
            case .failure(_):
                break
            }
        }.disposed(by: self.disposeBag)
    }
    
    
    func fetchAppConfig() {
//        print("fetchAppConfig changeLan = \(changeLan)")
        appApi.hideAutoLoading()
        appApi.rx.request(.publicInfo)
            .MJObjectMap(EXAppConfigModel.self, false)
            .subscribe{ event in
                switch event {
                case .success(let model):
                    self.handleAppConfig(model: model)
                    break
                case .failure(_):
                    break
                }
        }.disposed(by:self.disposeBag)
    }
    
    func handleAppConfig(model:EXAppConfigModel) {
        self.updateAppModules(model: model)
        //VM reorganizes model information, and all previous encapsulation is placed in this VM
        self.configVm.appConfigVmWith(config: model)
        //Todo old logic, request otcpub when enabled
        if model.otcOpen == "1" {
            OTCPulbicManager.sharedInstance.getData()
        }
        
        if self.changLan == false { //
            //Todo old logic, when enabled, initSwapSDk
            if model.contractOpen == "1" {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.prePareContractSDK()
            }
            
            if model.online_service_config == "1"{
                DispatchQueue.global().async {
                    EXZenDeskManger.manger.initSDK()
                }
            }
        }
        if let cacheV5 = EXAppCache.sharedCache.getPbV5Cache() {
            let oldIcon = cacheV5.app_personal_icon.allIcons().joined(separator: ",")
            let newIcon = model.app_personal_icon.allIcons().joined(separator: ",")
            if oldIcon != newIcon {
                self.configDownloadIcons(model: model.app_personal_icon)
            }
            if model.otcOpen != cacheV5.otcOpen ||
                model.contractOpen != cacheV5.contractOpen ||
                model.lever_open != cacheV5.lever_open ||
                model.contract_version_settings != cacheV5.contract_version_settings {
            }
        }else {
            self.updateAppModules(model: model)
            self.configDownloadIcons(model: model.app_personal_icon)
        }
        
        EXAppCache.sharedCache.updatePbV5Model(model: model)
        self.updateConfigToContract()
        self.onPbV5Publish.onNext(true)
        if self.changLan == false { //normal launch
            let userHasChooseLan = XUserDefault.getUserHasChooseLan() // user changeLan result here
            let defLan = EXAppConfigManager.sharedInstance.configVm.languageModel?.defLan
            /**
             When using the default configuration language for the first time, when the user actively switches languages, the user's language will prevail
             */
            EXLogger.debug(scene: EXLanguage.loggerScene, message: "current:\(EXLanguage.current), deflan:\(defLan ?? "-")")
            if let defLan = defLan, !userHasChooseLan, defLan != EXLanguage.current {
                let canUpdateWithLocal = EXLanguage.updateCurrentLanguage(to: defLan)
                if canUpdateWithLocal {
                    EXLogger.debug(scene: EXLanguage.loggerScene, message: "using local of \(defLan)")
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.configEXkits()
                    EXLanguageTools.shareInstance.setLanguage(langeuage: defLan)
                    BusinessTools.reloadWindow()
                }
                let shouldReloadAfterDownloaded = !canUpdateWithLocal
                EXLogger.debug(scene: EXLanguage.loggerScene, message: "download localizations of \(defLan)")
                LanguageTools.shareInstance.tryDownloadCurrentLan(lanID: defLan) { success in
                    EXLogger.debug(scene: EXLanguage.loggerScene, message: "download localizations of \(defLan) \(success ? "success" : "failed")")
                    guard success, !XUserDefault.getUserHasChooseLan(), EXLanguage.updateCurrentLanguage(to: defLan) else { return }
                    guard shouldReloadAfterDownloaded else { return }
                    EXLogger.debug(scene: EXLanguage.loggerScene, message: "reload app window")
                    BusinessTools.reloadWindow()
                }
            }else{
                let language = EXLanguage.current
                EXLogger.debug(scene: EXLanguage.loggerScene, message: "update via download localizations of current:\(language)")
                LanguageTools.shareInstance.tryDownloadCurrentLan(lanID: EXLanguage.current){ success in
                    if success { EXLanguage.reload() }
                    EXLogger.debug(scene: EXLanguage.loggerScene, message: "download localizations of \(language) \(success ? "success" : "failed")")
                }
            }
        }
//        let window = UIApplication.shared.keyWindow
//        let nav = AppDelegate().initNavBarV()
//        window?.rootViewController = nav
       
       
      
    }
    //Update some configurations of contract sdk
    func updateConfigToContract(){
        EXSwapPrivateConfig.shared.sharePage = EXAppConfigManager.sharedInstance.getSharingPage()
        let m = EXAppConfigManager.sharedInstance.getCoCouponSwitch()
        EXSwapPrivateConfig.shared.coCouponSwitchUrl = m.url
        EXSwapPrivateConfig.shared.coCouponSwitchUrlStatus = m.status
        EXSwapPrivateConfig.shared.companyDomain = EXAppConfigManager.sharedInstance.companyDomain()
        
    }
}

//MARK: Merchant Configuration&Module Configuration
extension EXAppConfigManager {
    //Obtain Merchant ID
    func companyID() ->String {
        return configVm.cfgModel.companyId
    }
    //Obtain the main domain name
    func companyDomain() -> String {
        return configVm.cfgModel.companyDomain
    }
    //Get homepage pop-up copy
    func homePopWindowTxt() -> String {
        return configVm.cfgModel.popWindow_txt
    }
    //Whether to open the contract
    func didOpenContract() -> Bool {
        return configVm.cfgModel.contractOpen == "1"
    }
    
    //Enable legal currency or not
    func didOpenFiat() ->Bool {
        return configVm.cfgModel.otcOpen == "1"
    }
  
    func didOpenQRLogin() -> Bool {
        return configVm.cfgModel.QRLogin == "1"
    }
    //Is there a lever
    func didOpenLever() ->Bool {
        return configVm.cfgModel.lever_open == "1"
    }
    
    func didOpenCrossLever() -> Bool{
        return configVm.cfgModel.lever_cross_open == "1"
    }
    
    func didOpenIsolatedLever() -> Bool {
        return configVm.cfgModel.lever_open == "1"
    }
    
    //Is there a grid
    func didOpenQuant() ->Bool {
        return configVm.cfgModel.grid_trade_switch == "1" && EXAppMarketManager.sharedInstance.getAllQuantMarketNameArray().count > 0
    }
    //
    func didOpenOcAgent() -> Bool{
        return configVm.cfgModel.coAgentStatus == "1"
    }
    //Red envelope switch
    func didOpenRedPack() -> Bool {
        return configVm.cfgModel.red_packet_open == "1"
    }
    //Customer service loading SDK
    func didOpenServiceOnline() -> Bool {
        return configVm.cfgModel.online_service_config == "1"
    }
    //Broker switch
    func didOpenUserAgent() -> Bool {
        return configVm.cfgModel.agentUserOpen == "1"
    }
    
    //Force Google
    func isRequireGoogle() -> Bool {
        return configVm.cfgModel.is_enforce_google_auth == "1"
    }
    
    //Negligible b2c configuration
    func didOpenB2C()-> Bool {
        return configVm.cfgModel.fiat_trade_open == "1"
    }
    
    //I don't see any difference between these two... Default_ Country_ Code, default_ Country_ Code_ Real. It seems to be for compatibility
    func getDefaultCountryCode() -> String {
        return configVm.cfgModel.default_country_code
    }
    
    func getDefaultCountryCodeReal() ->String {
        return configVm.cfgModel.default_country_code_real
    }
    
    
    
    func getRegionInfo() -> RegionEntity?{
        if let codeNumber = XUserDefault.getVauleForKey(key: XUserDefault.countryNumber) as? String, codeNumber.count > 0 {
            return getDefaultCountry(codeNumber)
        }else{
            return getDefaultCountry()
        }
        
    }
    
    ///Obtain default country (filtered blacklist)
    /// - Returns: RegionEntity
    func getDefaultCountry(_ dialingCode: String? = nil) -> RegionEntity? {
        var region: RegionEntity?
        var countryCode     = getDefaultCountryCode()
        var countryCodeReal = getDefaultCountryCodeReal()
        if let dCode = dialingCode{ //
            countryCodeReal = ""
            countryCode = dCode
        }
        
        if countryCodeReal.count > 0 {
            for _region in CountryList.getAllRegions() {
                if _region.numberCode == countryCodeReal {
                    region = _region
                    break
                }
            }
        }
       
        
        if countryCode.count > 0, region == nil {
            for _region in CountryList.getAllRegions() {
                if _region.dialingCode == countryCode {
                    region = _region
                    break
                }
            }
        }
        
        
        if CountryList.getAllRegions().count > 0, region == nil {
            region = CountryList.getAllRegions().first
        }
        return region
    }
    
    
    
    func getKlineScale() -> [String] {
        if configVm.cfgModel.klineScale.count == 0{
            return ["1min", "5min", "15min", "30min", "60min", "4h", "1day", "1week", "1month"]
        }
        return configVm.cfgModel.klineScale
    }
    ///Get menu array
    func getConvenienceKlineScale(isSwap:Bool = false) -> [String] {
        let klineScales = getKlineScale()
        var convenienceScales:[String] = [] //Key passed during subscription
        for scale in klineScales {
            if scale == "15min" {
                convenienceScales.append(scale)
            }else if scale == "60min" {
                convenienceScales.append(scale)
            }else if scale == "4h" {
                convenienceScales.append(scale)
            }else if scale == "1day" {
                convenienceScales.append(scale)
            }else if scale == "1week" {
                convenienceScales.append(scale)
            }
        }
        
        if isSwap{
            convenienceScales = ["15min", "60min","4h", "1day"]
        }
        
        var titles = [String]() //The copy displayed when laying out the interface
        for key in convenienceScales {
            let title = self.getkeyTitle(scale: key, isSwap: isSwap)
            titles.append(title)
            
        }
    
//        print("keys = >\(convenienceScales)")
        
        
        return convenienceScales //(convenienceScales,titles)
    }
    
    func getOtherKlineScale(isSwap:Bool = false) ->  [String] {
        let klineScales = getKlineScale()
        let conv = getConvenienceKlineScale()
        var menus:[String] = []
        for scale in klineScales {
            if !conv.contains(scale) {
                menus.append(scale)
            }
        }
        return menus
        
    }
    //Title of menu display
    func getkeyTitle(scale: String, isSwap: Bool) -> String{
      //Configured
      let keys = ["Line","1min", "5min", "15min", "30min", "60min", "4h", "1day", "1week", "1month"]
        let bibiTitles = ["kline_Line","kline_1min","kline_5min","kline_15min","kline_30min","kline_60min","kline_4h","kline_1day","kline_1week","kline_1month"].map { $0.localized()}
        
        if let index = keys.firstIndex(of: scale){
            let title = bibiTitles[index]
            return title
        }
        return ""
        
     //Key display name of the contract
//        "cp_extra_text40"="Line";
//        "cp_extra_text41"="1min";
//        "cp_extra_text42"="5min";
//        "cp_extra_text43"="15min";
//        "cp_extra_text44"="30min";
//        "cp_extra_text45"="1h";
//        "cp_extra_text46"="4h";
//        "cp_extra_text47"="1d";
//        "cp_extra_text48"="1w";
//        "cp_extra_text49"="1m";
        
        //Kline_Line ":" Time sharing test ",
        //Kline_1min ":" 1 point test ",
        //Kline_5min ":" 5-point test ",
        //Kline_15min ":" 15 minute test ",
        //Kline_30min ":" 30 minute test ",
        //Kline_60min ":" 1 hour test ",
        //Kline_4h ":" 4 hour test ",
        //Kline_1day ":" 1 day test ",
        //Kline_1week ":" 1 week test ",
        //Kline_1month ":" January test ",
        
    }
    func getAppLogo() -> AppConfigLogoListNew{
        return configVm.cfgModel.app_logo_list_new
    }
    
    func getAppTabIcon() ->AppPersonalIcon {
        return configVm.cfgModel.app_personal_icon
    }
    
    func getOnlineServiceURL() -> String {
        return configVm.cfgModel.online_service_url
    }
    
    func supportPush() -> Bool {
        return configVm.cfgModel.appPushSwitch == "1"
    }
    
    func getSupportRegistTypes() -> [String]  {
        return configVm.registTypes
    }
    
    func getSupportAccounts() ->[EXAccountType] {
        var accountTypes:[EXAccountType] = [.coin]
        if self.didOpenLever() {
            accountTypes.append(.leverage)
        }
        if self.didOpenFiat() {
            accountTypes.append(.otc)
        }
        if self.didOpenContract() {
            accountTypes.append(.contract)
        }
        return accountTypes
    }
    
    func hasMultiAccounts()->Bool {
        return getSupportAccounts().count > 2
    }
    
    func getLeverMutiple() ->String {
        return configVm.cfgModel.lever_cross_multiple
    }
}

//MARK: App Business Related Configuration
extension EXAppConfigManager {
    
    func getLanConfig() -> AppConfigLan {
        if let lanM = configVm.languageModel {
            return lanM
        }
        return AppConfigLan()
    }

    func getLanListAll() -> [AppCfgLanListItem] {
        let cfg = self.getLanConfig()
        return cfg.lanList
    }
    
    func getLanItem(lanId:String) -> AppCfgLanListItem? {
        getLanListAll().first(where: { $0.id == lanId })
    }
    
    func getAppTitleConfig() -> AppPersonalTitleItem {
        let lan = LanguageHandler.priviatePhoneLanguage
        if let titleInfo = configVm.cfgModel.app_personal_title[lan] as? [String:Any] {
            if let item = AppPersonalTitleItem.mj_object(withKeyValues: titleInfo) {
                return item
            }
        }
        return AppPersonalTitleItem()
    }
    
    
    func getUploadImgType() -> ExUploadImgType {
        if configVm.cfgModel.app_upload_img_type == "1" {
            return .oss
        }else {
            return .direct
        }
    }
    
    func isJiYanVerifactionType() -> Bool {
        return configVm.cfgModel.verificationType == "2"
    }
    
    func isAliVerifactionType() -> Bool {
        return configVm.cfgModel.verificationType == "1"
    }
    
    func getAliCaptchaUrl() -> String {
//        #if DEBUG
//        return "http://m.hiotc.pro/zh_CN/app_operation/aliVerify/" + "?appkey=\(getAliCaptchaAppkey())"
//        #else
        return configVm.cfgModel.nc_url + "?appkey=\(getAliCaptchaAppkey())"
//        #endif
    }
    
    func getAliCaptchaAppkey() -> String {
        return configVm.cfgModel.nc_appkey
    }
    
    func isOpenETFAreaLimit() -> Bool {
        return configVm.cfgModel.registerLocalLimitSwitch == "1"
    }
    
    func isOpenFaceID() -> Bool {
        return configVm.cfgModel.interfaceSwitch == "1"
    }
    
    //Explanation of leverage agreement
    func getLeverProtocolURL() ->String {
        return configVm.leverProtocolUrl
    }
    
    //Historical commission new interface switch
    func isOpenOrderCollect() ->Bool {
        return false //Privatization is not necessary,
    }
    
    //Currency Introduction Switch
    func isCoinIntroduceSupport(_ coinSymbol:String) -> Bool {
        if configVm.cfgModel.symbol_profile == "1" {
            return configVm.cfgModel.coinsymbol_introduce_names.contains(coinSymbol)
        }
        return false
    }
    
    //Obtain the transaction restriction copy interface for this currency, and use it on the transaction page. I'm not sure what it does
    func isSupportTradeLimit() ->Bool  {
        return configVm.cfgModel.has_trade_limit_open == "1"
    }
    
    //Whether to enable KYC authentication
    func getKycConfigModel(_ str : String) -> Bool{
        switch str {
        case "1"://Recharge
            return configVm.cfgModel.kycLimitConfig.deposite_kyc_open == "1"
        case "2"://Withdrawal
            return configVm.cfgModel.kycLimitConfig.withdraw_kyc_open == "1"
        case "3"://Currency trading
            return configVm.cfgModel.kycLimitConfig.exchange_trade_kyc_open == "1"
        case "4"://Leveraged trading
            return configVm.cfgModel.kycLimitConfig.lever_trade_kyc_open == "1"
        case "5"://Contract transfer
            return configVm.cfgModel.kycLimitConfig.contract_transfer_kyc_open == "1"
        default:
            return false
        }
    }
    
    //Help Center
    func getHelpCenter() ->String {
        return configVm.cfgModel.app_help_center
    }
    
    func getSharingPage() -> String {
        return configVm.cfgModel.sharingPage
    }
    
    func getUpdateWithDraw() -> AppUpdateSafeWithdraw {
        return configVm.cfgModel.update_safe_withdraw
    }
    func getUpdateWithDrawHour() -> String {
        var hour = "48"
        let config = EXAppConfigManager.sharedInstance.getUpdateWithDraw()
        if config.is_open == "1" {
            if !config.hour.isEmpty {
                if config.hour.greaterThan("0") && config.hour.lessThanOrEqual("100"){
                    hour = config.hour
                }
            }
        }
        return hour
    }
    
    func getKlineLogo() -> AppKlineLogo{
        return configVm.cfgModel.kline_background_logo_img
    }
    
    func getBlacklistedCountry() -> [String] {
        return configVm.cfgModel.limitCountryList
    }
    
    //It should be an old contract
    func getContractAgentUrl()->String {
        return configVm.cfgModel.co_agent_noticeUrl
    }
    
    func getCustomConfig()->String {
        return configVm.cfgModel.custom_config
    }
    
    func getSupportDownloadLocals() -> [String:String] {
        return configVm.cfgModel.locales
    }
    
    func getCoCouponSwitch() -> CoCouponSwitch {
        return configVm.cfgModel.coCouponSwitch
    }
    
    
    func getContractVersion() -> EXAppContractType {
        return .new
    }
    
    func getContractVersionStr() -> String {
        if getContractVersion() == .new  {
            return "2"
        }else {
            return "1"
        }
    }
    
    func getContractVersionDesc() -> String {
        if getContractVersion() == .new  {
            return "customSetting_text_coDescNew".localized()
        }else {
            return "customSetting_text_coDescOld".localized()
        }
    }
    
    func contractSupportSwitch() -> Bool {
        return configVm.cfgModel.contract_change_switch == "1" ? true : false
    }
}

