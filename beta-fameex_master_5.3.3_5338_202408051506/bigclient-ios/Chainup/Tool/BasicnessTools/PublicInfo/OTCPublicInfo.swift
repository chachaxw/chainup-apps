////
////  OTCPublicInfo.swift
////  Chainup
////
////  Created by zewu wang on 2023/10/16.
////  Copyright © 2023年 zewu wang. All rights reserved.
////
//
//import UIKit
//import RxSwift
//
//class OTCPublicInfo: NSObject {
//    
//    var subject = BehaviorSubject.init(value: 0)
//    
//    //MARK: Single Example
//    public static var sharedInstance : OTCPublicInfo{
//        struct Static {
//            static let instance : OTCPublicInfo = OTCPublicInfo()
//        }
//        return Static.instance
//    }
//    
//}
//
//extension OTCPublicInfo{
//    
//    func getData(){
//        let url = NetManager.sharedInstance.url(EXNetworkDoctor.sharedManager.getOtcAPIHost(), model: NetDefine.otc, action: NetDefine.otc_public_info)
//        let param = NetManager.sharedInstance.handleParamter()
//        NetManager.sharedInstance.sendRequest(url, parameters: param, isShowLoading : false,success: { (result, response, nil) in
//            guard let result = result as? [String : Any] else{return}
//            guard let data = result["data"] as? [String : Any] else{return}
//            OTCPulbicEntity.sharedInstance.setEntityWithDict(data)
//            self.subject.onNext(1)
//        }) { (state , error , nil) in
//            
//        }
//    }
//    
//}
//
//class OTCPulbicEntity: SuperEntity {
//    
//    //MARK: Single Example
//    public static var sharedInstance : OTCPulbicEntity{
//        struct Static {
//            static let instance : OTCPulbicEntity = OTCPulbicEntity()
//        }
//        return Static.instance
//    }
//    
//    var exsymbols = ""//Currency for off site development
//    
//    var payments : [OTCPaymentsEntity] = []//Payment method
//    
//    var paycoins : [OTCPaycoinsEntity] = []//payment currency 
//    
//    var feeOtcList : [OTCFeeOtcListEntity] = []//Off site rate (new)
//    
//    var defaultCoin = ""
//    
//    var defaultSeach = ""
//    
//    var otcDefaultPaycoin = ""//Off site default payment method
//    
//    var otcChatWS = ""
//    
//    var rateUrl = ""
//    
//    var countryNumberInfo : [OTCCountryNumberInfoEntity] = []//Country List
//    
//    override func setEntityWithDict(_ dict: [String : Any]) {
//        super.setEntityWithDict(dict)
//        defaultCoin = dictContains("defaultCoin")
//        defaultSeach = dictContains("defaultSeach")
//        otcDefaultPaycoin = dictContains("otcDefaultPaycoin")
//        otcChatWS = dictContains("otcChatWS")
//        rateUrl = dictContains("rateUrl")
//        if let array = dict["payments"] as? [[String : Any]]{
//            var arr : [OTCPaymentsEntity] = []
//            for dict in array{
//                let entity = OTCPaymentsEntity()
//                entity.setEntityWithDict(dict)
//                if entity.used == true{
//                    
//                    arr.append(entity)
//                }
//            }
//            payments = arr
//        }
//        if let array = dict["paycoins"] as? [[String : Any]]{
//            var arr : [OTCPaycoinsEntity] = []
//            for dict in array{
//                let entity = OTCPaycoinsEntity()
//                entity.setEntityWithDict(dict)
//                if entity.used == true{
//                    
//                    arr.append(entity)
//                }
//            }
//            paycoins = arr
//        }
//        if let array = dict["feeOtcList"] as? [[String : Any]]{
//            var arr : [OTCFeeOtcListEntity] = []
//            for dict in array{
//                let entity = OTCFeeOtcListEntity()
//                entity.setEntityWithDict(dict)
//            
//                arr.append(entity)
//            }
//            feeOtcList = arr
//        }
//        if let array = dict["countryNumberInfo"] as? [[String : Any]]{
//            var arr : [OTCCountryNumberInfoEntity] = []
//            for dict in array{
//                let entity = OTCCountryNumberInfoEntity()
//                entity.setEntityWithDict(dict)
//                if entity.open == true{
//                    
//                    arr.append(entity)
//                }
//            }
//            countryNumberInfo = arr
//        }
//    }
//    
//}
//
//class OTCPaymentsEntity: SuperEntity {
//    var key1 = ""//Key for payment method/currency, value passed to the backend
//    
//    var title = ""//Value displayed in the foreground
//    
//    var icon = ""//icon
//    var account = ""//
//    var numberCode = ""//
//    var open = false//
//    var used = false//Enable or not
//    var selected = false
//    override func setEntityWithDict(_ dict: [String : Any]) {
//        super.setEntityWithDict(dict)
//        key1 = dictContains("key")
//        title = dictContains("title")
//        icon = dictContains("icon")
//        if let tmpUsed = dict["used"] as? Bool{
//            used = tmpUsed
//        }
//        account = dictContains("account")
//        numberCode = dictContains("numberCode")
//        if let tmpUsed = dict["open"] as? Bool{
//            open = tmpUsed
//        }
//    
//        selected = false
//    }
//}
//
//class OTCPaycoinsEntity : SuperEntity {
//    var key1 = ""//Key for payment method/currency, value passed to the backend
//    
//    var title = ""//Value displayed in the foreground
//    
//    var icon = ""//icon
//    var account = ""
//    var numberCode = ""
//    var selected = false
//    var used = false//Enable or not
//    var open = false//Enable or not
//
//    override func setEntityWithDict(_ dict: [String : Any]) {
//        super.setEntityWithDict(dict)
//        key1 = dictContains("key")
//        title = dictContains("title")
//        icon = dictContains("icon")
//        account = dictContains("account")
//        numberCode = dictContains("numberCode")
//
//        if let tmpUsed = dict["used"] as? Bool{
//            used = tmpUsed
//        }
//        if let tmpUsed = dict["open"] as? Bool{
//            open = tmpUsed
//        }
//
//    }
//}
//
//class OTCFeeOtcListEntity : SuperEntity {
//    var symbol = ""//currency
//    
//    var rate = ""//rate 
//    
//    override func setEntityWithDict(_ dict: [String : Any]) {
//        super.setEntityWithDict(dict)
//        symbol = dictContains("symbol")
//        rate = dictContains("rate")
//    }
//}
//
//class OTCCountryNumberInfoEntity: SuperEntity {
//    var key1 = ""
//    var title = ""  //Country name
//    var icon = ""
//    var account = ""
//    var used = false
//    var selected = false
//    var numberCode = ""//National Numeric Code
//    
//    var open = false
//    
//    override func setEntityWithDict(_ dict: [String : Any]) {
//        super.setEntityWithDict(dict)
//        key1 = dictContains("key")
//        title = dictContains("title")
//        icon = dictContains("icon")
//        account = dictContains("account")
//        numberCode = dictContains("numberCode")
//        
//        
//        if let tmpUsed = dict["used"] as? Bool{
//            used = tmpUsed
//        }
//        
//        if let tmpUsed = dict["open"] as? Bool{
//            open = tmpUsed
//        }
//    }
//    
//}

