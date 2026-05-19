//
//  EXAppConfigModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/9/7.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import EXKit
import Swap
class CoCouponSwitch:EXBaseModel {
    var url:String = ""
    var status:String = "0"
}

class AppConfigLogoListNew:EXBaseModel {
    var logo_black:String = ""
    var logo_white:String = ""
}

class AppKlineLogo: EXBaseModel{
    var app_img = ""
    var app_img_night = ""
}

class AppPersonalIcon:EXBaseModel {
    var tabbar_home_default_night:String = ""
    var tabbar_fiat_default_daytime:String = ""
    var tabbar_home_default_daytime:String = ""
    var tabbar_home_selected:String = ""
    var tabbar_contract_default_daytime:String = ""
    var tabbar_assets_default_night:String = ""
    var tabbar_contract_selected:String = ""
    var tabbar_assets_default_daytime:String = ""
    var tabbar_fiat_default_night:String = ""
    var tabbar_quotes_selected:String = ""
    var tabbar_fiat_selected:String = ""
    var tabbar_exchange_default_night:String = ""
    var tabbar_exchange_default_daytime:String = ""
    var tabbar_quotes_default_night:String = ""
    var tabbar_exchange_selected:String = ""
    var tabbar_quotes_default_daytime:String = ""
    var tabbar_contract_default_night:String = ""
    var tabbar_assets_selected:String = ""
    
    func allIcons() -> [String] {
        let icons = [tabbar_home_default_night,
                     tabbar_fiat_default_daytime,
                     tabbar_home_default_daytime,
                     tabbar_home_selected,
                     tabbar_contract_default_daytime,
                     tabbar_assets_default_night,
                     tabbar_contract_selected,
                     tabbar_assets_default_daytime,
                     tabbar_fiat_default_night,
                     tabbar_quotes_selected,
                     tabbar_fiat_selected,
                     tabbar_exchange_default_night,
                     tabbar_exchange_default_daytime,
                     tabbar_quotes_default_night,
                     tabbar_exchange_selected,
                     tabbar_quotes_default_daytime,
                     tabbar_contract_default_night,
                     tabbar_assets_selected].filter({return $0.count > 0})
        return icons
    }
    
    func allIconFileName() -> [String] {
        return self.allIcons().map({return AppService.md5($0) + "@2x"})
    }
}

class AppUpdateSafeWithdraw:EXBaseModel {
    var hour:String = ""
    var is_open:String = ""
}

class AppKlineColor:EXBaseModel {
    var up:String = ""
    var down:String = ""
}

class AppkycLimitConfig:EXBaseModel {
    var withdraw_kyc_open :String = ""
    var exchange_trade_kyc_open :String = ""
    var lever_trade_kyc_open :String = ""
    var deposite_kyc_open :String = ""
    var contract_transfer_kyc_open :String = ""
}


///Access restriction check
class EXApplimitVisitModel: EXBaseModel {
    
    enum EXLimitVisitStatus {
        case access //allow
        case forbid //prohibit
    }
    var status: String = "" ///Access status 0: Allow 1: Prohibit access
    var visitStatus: EXLimitVisitStatus{
        get {
           return self.checkVisitStatus()
        }
    }
    var countryNames: String = ""
    
    private func checkVisitStatus() -> EXLimitVisitStatus {
        if self.status == "1" {
            return .forbid
        } else {
            return .access
        }
    }
    
}
class Lan: EXBaseModel{
    var defLan: String = ""
    var lanList = [LanItem]()
    override func mj_keyValuesDidFinishConvertingToObject() {
        if let array = LanItem.mj_objectArray(withKeyValuesArray: lanList) as? [LanItem]{
            self.lanList = array
#if DEBUG
//            for lan in self.lanList{
//                print("lan-\(lan.name) -\(lan.id)")
//            }
#endif
            
        }
        
    }
    
   
}

class LanItem: EXBaseModel{
    var name: String = ""
    var id: String = ""
}
class EXAppConfigModel: EXBaseModel {
    var timeZone: String = ""
    var fundRate:String = "" //It seems like the exchange rate of ETF funds
    //Various switches
    var coAgentStatus: String = "0" //Contract Broker Switch
    var open_order_collect:String = "0"//Switch for coin order history search
    var red_packet_open:String = "" //Red envelope switch
    var otc_default_coin:String = "" //OTC default currency
    var symbol_profile:String = "" //Currency Introduction Switch
    var coinsymbol_introduce_names:[String] = [] //All currencies that support currency introductions
    var has_trade_limit_open:String = ""//1 on 0 off, 1 obtain the transaction restriction copy interface for this currency pair
    var contractOpen:String = ""//Contract switch
    var lever_open:String = "" //Lever switch
    var lever_cross_open:String = ""
    
    var otcOpen:String = "" //Otc switch
    var QRLogin: String = ""
    var is_enforce_google_auth = "0"//Google security level, on 0 off, 1 on. Default on, client first
    var agentUserOpen = ""//Broker switch
    var grid_trade_switch:String = "" //Grid switch
    var online_service_config: String = "" //Customer service loading SDK
    var minHoldAccount:String = ""//
    var coinModelList:[CoinListEntity] = []
    var coinList : [String:Any] = [:]//Currency List
    //Various configurations
    var popWindow_txt:String = ""//Copy pop-up on homepage
    var lan = Lan()//Language configuration for 'defLan+lanList'
    public var langList = [EXSLanguageModel]()//Language Configuration
    var kycLimitConfig:AppkycLimitConfig = AppkycLimitConfig()
    var app_help_center:String = ""//Configure the Help Center, if the field is empty, use the default Help Center
    var online_service_url = ""//Online customer service address
    
    var coCouponSwitch:CoCouponSwitch = CoCouponSwitch() //URL+status contract configuration
    var co_agent_noticeUrl:String = "" //The configuration of the contract broker seems to be useless now
    var protocol_url_list : [String : Any] = [:]//Obtain a list of leverage agreements configured by language
    var companyDomain:String = ""//Merchant Master Domain Name
    var sharingPage:String = ""
    var companyId:String = ""
    var futuresType: String = ""
    var app_logo_list_new :AppConfigLogoListNew = AppConfigLogoListNew() //Logo of K line
    var app_personal_title:[String:Any] = [:]//Title of the bottom tab configured by language
    var app_personal_icon :AppPersonalIcon = AppPersonalIcon() //Custom tab icon
    var update_safe_withdraw :AppUpdateSafeWithdraw = AppUpdateSafeWithdraw() //Limit the switch and time for xx hours of coin withdrawal
    var usdt_open_omni: String = ""//Where 1 represents displaying OMNI and 0 represents hiding
    var default_country_code:String = ""//Default country code in the background, such as 156
    var default_country_code_real = ""//Default country code in the background, such as 156
    
    var verificationType:String = ""
    var domain: String = ""//cloudflare 
    /**
     判断【app_access_open：0关闭；1开启】是否为1，则验证，否则不验证；
     Verify if the value of [app access open: 0 closed; 1 open] is 1, otherwise do not verify;
     */
    var app_access_open: String = ""
    /**
     app_access_open 】为1  开启时，判断【app_sys_conf_validate： 0 混合模式，1 阿里云，2 极验，3 cloudflare】中配置参数
            A. 为 0 则随机调用 1、2、3 验证。
            B. 为 1 则调用 阿里云验证 ，阿里云相关参数传给前端；
            C. 为 2 则调用极验验证；
              【sys_conf_geetest_config】极验配置相关数据传给前端
            D. 为 3 则调用 cloudflare
              【sys_conf_cloudflare_config】cloudflare 配置相关数据传给前端
     
     
     App_ Access_ When open is set to 1, check the configuration parameters in [app_sys_conf_validate: 0 hybrid mode, 1 Alibaba Cloud, 2 polar verification, 3 cloudflare]
     A. If it is 0, randomly call 1, 2, and 3 validation.
     B. If it is 1, call Alibaba Cloud verification, and pass the relevant parameters of Alibaba Cloud to the front-end;
     C. If it is 2, extreme validation will be called;
     【 sys_conf_geetest_config 】 Transfer extreme configuration related data to the front-end
     D. If it is 3, call cloudflare
     [sys_conf_cloudflare configuration] Cloudflare configuration related data is transmitted to the front-end
     */
    var app_sys_conf_validate: String = ""
    
    //Default value
    var klineScale:[String] = []
    var app_upload_img_type = "0"//Which method to use to upload images: app_ Upload_ Img_ Type: 0 Use old uploaded images, 1 Use token to upload images
    var appPushSwitch = "0"
    var interfaceSwitch = "0"//Real name authentication face switch 0 off 1 on
    var limitCountryList : [String] = []//Blocked countries
    
    var kline_background_logo_img:AppKlineLogo = AppKlineLogo()
    var custom_config:String = "" //Free configuration, JSON string
    var locales:[String:String] = [:]//Configure the downloaded language pack file, where key is the language and value is the download URL
    var user_reg_type : String = ""
    var registerLocalLimitSwitch: String = ""//Do you want to display regional prompts for registration
    var lever_cross_multiple:String = ""
    var incrementConfig:IncrementConfig = IncrementConfig()
    //The user configured registration list, JSON string, and also need to be parsed. { "el_GR ": [2],  "id_ID ": [2],  "ja_JP ": [2],  "tr_TR ": [2],  "vi_VN ": [2],  "en_US ": [2],  "ko_KR ": [2],  "zh_CN ": [2]}
    
    //It shouldn't be useful
    //    var otcUrl:String = ""
    //    var depositOpen:String = ""//Coin switch
    //    var emailOptCode:Any? //No configuration used
    //    var localPublicInfoTime:String = ""
    //    var maket_index:String = ""
    //    var mobileOpen:String = ""
    //    var thirdInfo:Any?
    //    var wind_control_switch:String = ""//It seems to be used in OTC
    //    var wsUrl:String = ""
    //    var app_logo_list:[String : Any] = [:]
    //    var subAccountSwitch:String = ""
    //    var smsOptCode:[String:Any] = [:]
    //    var footer_style:String = ""
    //    var optional_symbol_server_open:String = ""
    //    var bank_name_equal_auth:String = ""
    //    var nc_lang:String = ""
    //    var localPublicInfoTimeFormat:String = ""
    //    var klineColor:AppKlineColor = AppKlineColor()//K line up and down configuration colors
    //    var protocol_url:String = ""
    var nc_appkey:String = ""
    var nc_url:String = ""
    var fiat_trade_open:String = "0"
    var contract_version_settings:String = ""//0-Old version contract 1-New version contract
    var contract_change_switch:String = ""//0- No display switch entrance 1- Display switch entrance
    var membership_level_open = ""// 0:关闭 1:开启会员等级功能
    var membership_level_url = ""//返回/app_operation/rateDiscount/   表示跳转会员等级页面url
    
    override func mj_keyValuesDidFinishConvertingToObject() {
        if self.klineScale.count > 0 {
            self.klineScale.insert("1min", at: 0)
        }else {
            self.klineScale = ["1min","1min", "5min", "15min", "30min", "60min", "1day", "1week", "1month"]
        }
        
        if let dic = self.incrementConfig.mj_JSONObject() as? [String:Any] {
            self.incrementConfig.setEntityWithDict(dic)
        }
        self.lan = Lan.mj_object(withKeyValues: self.lan)
        langList = EXSLanguageModel.mj_objectArray(withKeyValuesArray: self.langList).copy() as! [EXSLanguageModel]
        langList = langList.sorted(by: { a, b in
            a.sort < b.sort
        })
        self.coinModelList.removeAll()
        for(_,value) in self.coinList {
            if let map = CoinListEntity.mj_object(withKeyValues: value) {
                self.coinModelList.append(map)
            }
        }
        self.coinModelList.sort { (a, b) -> Bool in
            return b.sort > a.sort
        }
    }
    
    func findCoin(coin: String) -> (coinImageUrl: String, showName: String) {
        for item in coinModelList {
            if item.name == coin {
                var disPlayName = item.longName
                if item.longName.isEmpty {
                    disPlayName = item.showName
                }
                return (item.icon,disPlayName)
            }
        }
        return ("","")
    }
}

