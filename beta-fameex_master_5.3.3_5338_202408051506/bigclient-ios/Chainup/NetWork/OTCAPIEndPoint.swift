//
//  OTCAPIEndPoint.swift
//  Chainup
//
//  Created by liuxuan on 2023/1/9.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import Moya

enum OTCAPIEndPoint {
    case whiteListSwitch(smsAuthCode: String?, googleCode: String?,emailAuthCode: String?,status: String)
    case capitalPasswordUnbinding(smsAuthCode : String? ,emailAuthCode : String?, googleCode : String?)
    case capitalPasswordForget(smsAuthCode : String? ,emailAuthCode : String?, googleCode : String?)
    case publicInfo
    case personRelationship(relationType : String , pageSize : String , page : String)//Blacklist
    case otcSearch(side:String, symbol:String, page:Int, payCoin:String?,price:String?,payments:String?,numberCode:String?,isBlockTrade:String?)
    case otcWantedSave(coin:String, side:String, payCoin:String, volume:String ,price:String,priceRate:String,priceRateType:String,minTrade:String,maxTrade:String,limitTime:String,dealVolume:String,days:String,payments:String,description:String,autoReply:String)//Advertising
    case otcCloseWanted(advertId:String)
    case otcWantedDetail(advertId:String)
    case otcOrderDetail(sequence:String)
    case otcComplainCancel(sequence:String)
    case otcConfirmOrder(sequence:String,capitalPwd:String?,smsAuthCode :String?,googleCode : String?)
    case otcBuyOrderSave(totalPrice:String,price:String,volume:String,advertId:String,remark:String?,type:String)
    case otcSellOrderSave(totalPrice:String,price:String,volume:String,advertId:String,remark:String?,type:String,capitalPword:String?,smsAuthCode :String?,googleCode : String?)
//    case otcchangepw(newCapitalPwd : String , smsAuthCode : String? ,emailAuthCode : String?, googleCode : String?)//Set legal currency fund password
    case otcSetPw(newCapitalPwd : String? , smsAuthCode : String? ,emailAuthCode : String?, googleCode : String?)//Set legal currency fund password
    case modifyOtcPw(newCapitalPwd : String? , smsAuthCode : String? ,emailCode : String?, googleCode : String?,capitalPwd: String?,checkOldFlag: String?,securityInfo: String?)//Set legal currency fund password

    case otcComplainOrder(sequence:String,complainId:String)//Submit appeal to modify order status
    case personHomePage(uid:String)
    case personAds(uid:String,pageSize:String,page:String,adType:String)
    case userContacts(uid:String,relationType:String)
    case userContactsRemove(uid:String)
    case validateAdvert(adId:String,type:String)
    case considerPrice(currencySymbol:String,coinSymbol:String)
    case orderPayed(sequenceId:String,payment:String)
    case orderCancel(sequenceId:String)
    case orderPaidCancel(sequenceId:String)
    case paymentFind(isOpen:String?)
    case otcPaymentAdd(payementKey:String,userName:String,account:String,qrcodeImg:String?,bankName:String?,bankOfDeposit:String?,smsAuthCode:String?,googleCode:String?,ifscCode:String? = nil,
                       isOpen:String? = nil,icon:String? = nil,title:String? = nil,accountType:String? = nil,coinName:String? = nil,color:String? = nil,email:String? = nil,cci:String? = nil,idNumber:String? = nil)
    case otcPaymentActive(paymentID:String,active:String)
    case otcPaymentUpdate(paymentID:String,userName:String,paymentKey:String,account:String,qrcodeImg:String?,bankName:String?,bankOfDeposit:String?,smsAuthCode:String?,googleCode:String?,ifscCode:String? = nil,isOpen:String? = nil,icon:String? = nil,title:String? = nil,accountType:String? = nil,coinName:String? = nil,color:String? = nil,email:String? = nil,cci:String? = nil,idNumber:String? = nil)
    case otcPaymentDelete(paymentID:String,smsAuthCode:String?,googleCode:String?)
    case getPersonAds(uid : String , pageSize : String , page : String , adType : String , closeHide : String)//Get personal Advertising management list
    case wantedDetailCheck//Pre advertising verification
}

extension OTCAPIEndPoint : TargetType {
    
    var baseURL: URL {
        return URL.init(string:  EXNetworkDoctor.sharedManager.getOtcAPIHost())!
//        return URL.init(string:NetDefine.http_host_url_otc)!
    }
    
    var path: String {
        switch self {
        case .whiteListSwitch:
            return "otc/withdrawWhiteListFlag"
        case .modifyOtcPw:
            return "otc/v5/capital_password/reset"
        case .capitalPasswordUnbinding:
            return "otc/capital_password/unbinding"
        case .capitalPasswordForget:
            return "otc/capital_password/forget"
        case .publicInfo:
            return "otc/public_info"
        case .personRelationship:
            return "otc/person_relationship"
        case .otcSearch:
            return "otc/search"
        case .otcWantedSave:
        return "otc/wanted_save"
        case .otcCloseWanted:
            return "otc/close_wanted"
        case .otcWantedDetail:
            return "otc/v4/wanted_detail"
        case .otcOrderDetail:
            return "v4/otc/order_detail"
        case .otcBuyOrderSave:
            return "v4/otc/buy_order_save"
        case .otcComplainCancel:
            return "otc/complain_cancel"
        case .otcConfirmOrder:
            return "otc/confirm_order_v1"
        case .otcSellOrderSave:
            return "v5/otc/sell_order_save"
//        case .otcchangepw:
//            return "otc/v4/capital_password/reset"
        case .otcSetPw:
            return "otc/v1/capital_password/set"
        case .otcComplainOrder:
            return "otc/complain_order"
        case .personHomePage:
            return "otc/person_home_page"
        case .personAds:
            return "otc/v4/person_ads"
        case .userContacts:
            return "otc/user_contacts"
        case .userContactsRemove:
            return "otc/user_contacts_remove"
        case .validateAdvert:
            return "otc/validateAdvert_v4"
        case .considerPrice:
            return "otc/consider_price_v4"
        case .orderPayed:
            return "v4/otc/order_payed"
        case .orderCancel:
            return "otc/order_cancel"
        case .orderPaidCancel:
            return "v4/otc/paid_order_cancel"
        case .paymentFind:
            return "otc/payment/find"
        case .otcPaymentAdd:
            return "otc/payment/add"
        case .otcPaymentActive:
            return "otc/payment/open"
        case .otcPaymentUpdate:
            return "otc/payment/update"
        case .otcPaymentDelete:
            return "otc/payment/delete"
        case .getPersonAds:
            return "otc/v4/person_ads"
        case .wantedDetailCheck:
            return "otc/v4/wanted_detail_check"
        }
    }
    
    var method: Moya.Method {
        switch self {
        default:
            return .post
        }
    }
    
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    var task: Task {
        var parameters: [String: Any] = [:]
        switch self {
        case .whiteListSwitch(let smsAuthCode, let googleCode, let emailAuthCode, let status):
            parameters["smsAuthCode"] = smsAuthCode
            parameters["googleCode"] = googleCode
            parameters["emailAuthCode"] = emailAuthCode
            parameters["flag"] = status
        case .modifyOtcPw(let newCapitalPwd, let smsAuthCode, let emailCode, let googleCode,let capitalPwd, let checkOldFlag,let securityInfo):
            parameters["newCapitalPwd"] = newCapitalPwd
            parameters["smsAuthCode"] = smsAuthCode
            parameters["emailAuthCode"] = emailCode
            parameters["googleCode"] = googleCode
            parameters["capitalPwd"] = capitalPwd
            parameters["checkOldFlag"] = checkOldFlag
            parameters["securityInfo"] = securityInfo
            break
        case .capitalPasswordUnbinding(let smsAuthCode, let emailAuthCode, let googleCode):
            parameters["smsAuthCode"] = smsAuthCode
            parameters["emailAuthCode"] = emailAuthCode
            parameters["googleCode"] = googleCode
            break
        case .capitalPasswordForget(let smsAuthCode, let emailAuthCode, let googleCode):
            parameters["smsAuthCode"] = smsAuthCode
            parameters["emailAuthCode"] = emailAuthCode
            parameters["googleCode"] = googleCode
            break
        case .publicInfo:
            break
        case .personRelationship(let relationType,let pageSize,let page):
            parameters["relationType"] = relationType
            parameters["pageSize"] = pageSize
            parameters["page"] = page
            break
        case .otcSearch(let side, let symbol, let page, let filterPayCoin,let filterPrice,let filterPayments,let filterNumberCode,let isblockTrade):
            parameters["side"] = side
            parameters["symbol"] = symbol
            parameters["page"] = page
            parameters["pageSize"] = "20"
            if let payCoin = filterPayCoin,payCoin != "ALL" {
                parameters["payCoin"] = payCoin
            }else {
                parameters["payCoin"] = "CNY"
            }
            if let price = filterPrice, !price.isEmpty {
                parameters["price"] = price
            }
            if let payments = filterPayments,payments != "ALL" {
                parameters["payments"] = payments
            }
            if let countryCode = filterNumberCode,countryCode != "ALL" {
                parameters["numberCode"] = countryCode
            }
            if let blockTrade = isblockTrade {
                parameters["isBlockTrade"] = blockTrade
            }else {
                parameters["isBlockTrade"] = "0"
            }
            break
        case .otcWantedSave(let coin,let side,let payCoin,let volume,let price,let priceRate,let priceRateType,let minTrade,let maxTrade,let limitTime,let dealVolume,let days,let payments,let description,let autoReply):
             parameters["coin"] = coin
             parameters["side"] = side
             parameters["payCoin"] = payCoin
             parameters["volume"] = volume
             parameters["price"] = price
             parameters["priceRate"] = priceRate
             parameters["priceRateType"] = priceRateType
             parameters["minTrade"] = minTrade
             parameters["maxTrade"] = maxTrade
             parameters["limitTime"] = limitTime
             parameters["dealVolume"] = dealVolume
             parameters["days"] = days
             if description.count > 0 {
                parameters["description"] = description
             }
             if autoReply.count > 0 {
               parameters["autoReply"] = autoReply
             }
             
             parameters["payments"] = payments
                 break
        case .otcCloseWanted(let advertId):
            parameters["advertId"] = advertId
            break
        case .otcWantedDetail(let advertId):
            parameters["advertId"] = advertId
            break
        case .otcOrderDetail(let sequence):
            parameters["sequence"] = sequence
            break
        case .otcBuyOrderSave(let totalPrice, let price, let volume, let advertId,  let remark, let type):
            parameters["advertId"] = advertId
            parameters["totalPrice"] = totalPrice
            parameters["volume"] = volume
            parameters["price"] = price
            parameters["type"] = type
            if let savedRemark = remark {
                parameters["description"] = savedRemark
            }else {
                parameters["description"] = ""
            }
            break
        case .otcSellOrderSave(let totalPrice, let price, let volume, let advertId,  let remark, let type,let pwd,let phoneCode, let google):
            parameters["advertId"] = advertId
            parameters["totalPrice"] = totalPrice
            parameters["volume"] = volume
            parameters["price"] = price
            parameters["type"] = type
            parameters["capitalPword"] = pwd
            parameters["smsAuthCode"] = phoneCode
            parameters["googleCode"] = google
            if let savedRemark = remark {
                parameters["description"] = savedRemark
            }else {
                parameters["description"] = ""
            }
            break
        case .otcComplainCancel(let sequence):
            parameters["sequence"] = sequence
            break
        case .otcConfirmOrder(let sequence,let pwd,let smsAuthCode, let googleCode):
            parameters["sequence"] = sequence
            parameters["capitalPword"] = pwd
            parameters["smsAuthCode"] = smsAuthCode
            parameters["googleCode"] = googleCode
            break
//        case .otcchangepw(let newCapitalPwd ,let smsAuthCode, let emailCode, let googleCode):
//            parameters["newCapitalPwd"] = newCapitalPwd
//            parameters["smsAuthCode"] = smsAuthCode
//            parameters["googleCode"] = googleCode
//            parameters["emailAuthCode"] = emailCode
        case .otcSetPw(let newCapitalPwd ,let smsAuthCode, let emailCode, let googleCode):
            parameters["capitalPwd"] = newCapitalPwd
            parameters["smsAuthCode"] = smsAuthCode
            parameters["googleCode"] = googleCode
            parameters["emailAuthCode"] = emailCode
        case .otcComplainOrder(let sequence,let complainId):
            parameters["sequence"] = sequence
            parameters["complainId"] = complainId
        case .personHomePage(let uid):
            parameters["uid"] = uid
        case .personAds(let uid, let pageSize, let page, let adType):
            parameters["uid"] = uid
            parameters["pageSize"] = pageSize
            parameters["page"] = page
            parameters["adType"] = adType
        case .userContacts(let uid, let relationType):
            parameters["otherUid"] = uid
            parameters["relationType"] = relationType
        case .userContactsRemove(let uid):
            parameters["friendId"] = uid
        case .validateAdvert(let adId, let type):
            parameters["advertId"] = adId
            parameters["advertType"] = type
        case .considerPrice(let currencySymbol, let coinSymbol):
            parameters["baseSymbol"] = currencySymbol
            parameters["coinSymbol"] = coinSymbol
        case .orderPayed(let sequenceId, let payment):
            parameters["sequence"] = sequenceId
            parameters["payment"] = payment
        case .orderCancel(let sequenceId):
            parameters["sequence"] = sequenceId
        case .orderPaidCancel(let sequenceId):
            parameters["sequence"] = sequenceId
        case .paymentFind(let isOpen):
            if let avalible = isOpen {
                parameters["isOpen"] = avalible
            }
        case .otcPaymentAdd(let payementKey, let userName,let account, let qrcodeImg, let bankName, let bankOfDeposit, let smsAuthCode, let googleCode, let ifscCode,let isOpen,let icon,let title,let accountType,let coinName,let color,let email, let cci, let idNumber):
            parameters["payment"] = payementKey
            parameters["userName"] = userName
            if payementKey == OTCPayInfoType.WestUnio.rawValue {
                parameters["remittanceInformation"] = account
                parameters["account"] = account
            }else {
                parameters["account"] = account
            }
            if let qrCode = qrcodeImg {
                parameters["qrcodeImg"] = qrCode
            }
            if let bank = bankName {
                parameters["bankName"] = bank
            }
            if let bankdeposit = bankOfDeposit {
                parameters["bankOfDeposit"] = bankdeposit
            }
        
            if let sms = smsAuthCode {
                parameters["smsAuthCode"] = sms
            }
            if let code = googleCode {
                parameters["googleCode"] = code
            }
            parameters["ifscCode"] = ifscCode
            parameters["isOpen"] = isOpen
            parameters["icon"] = icon
            parameters["title"] = title
            parameters["accountType"] = accountType
            parameters["coinName"] = coinName
            parameters["color"] = color
            parameters["email"] = email
            parameters["cci"] = cci
            parameters["idNumber"] = idNumber
        case .otcPaymentUpdate(let paymentID, let userName, let paymentKey, let account, let qrcodeImg, let bankName, let bankOfDeposit, let smsAuthCode, let googleCode, let ifscCode,let isOpen,let icon,let title,let accountType,let coinName,let color,let email, let cci, let idNumber):
            parameters["payment"] = paymentKey
            parameters["id"] = paymentID
            parameters["userName"] = userName
            if paymentKey == OTCPayInfoType.WestUnio.rawValue {
                parameters["remittanceInformation"] = account
                parameters["account"] = account
            }else {
                parameters["account"] = account
            }
            if let qrCode = qrcodeImg {
                parameters["qrcodeImg"] = qrCode
            }
            if let bank = bankName {
                parameters["bankName"] = bank
            }
            if let bankdeposit = bankOfDeposit {
                parameters["bankOfDeposit"] = bankdeposit
            }
            
            if let sms = smsAuthCode {
                parameters["smsAuthCode"] = sms
            }
            if let code = googleCode {
                parameters["googleCode"] = code
            }
            parameters["ifscCode"] = ifscCode
            parameters["isOpen"] = isOpen
            parameters["icon"] = icon
            parameters["title"] = title
            parameters["accountType"] = accountType
            parameters["coinName"] = coinName
            parameters["color"] = color
            parameters["email"] = email
            parameters["cci"] = cci
            parameters["idNumber"] = idNumber
        case .otcPaymentActive(let paymentID, let active):
            parameters["id"] = paymentID
            parameters["isOpen"] = active
        case .otcPaymentDelete(let paymentID, let smsAuthCode, let googleCode):
            parameters["id"] = paymentID
            if let sms = smsAuthCode {
                parameters["smsAuthCode"] = sms
            }
            if let code = googleCode {
                parameters["googleCode"] = code
            }
        case .getPersonAds(let uid,let pageSize,let page,let adType,let closeHide):
            parameters["uid"] = uid
            parameters["pageSize"] = pageSize
            parameters["page"] = page
            parameters["adType"] = adType
            parameters["closeHide"] = closeHide
        case .wantedDetailCheck:
            break
        }
        
        if self.method == .post {
            return .requestParameters(parameters: NetManager.sharedInstance.handleParamter(parameters), encoding: JSONEncoding.default)
        }else {
            return .requestParameters(parameters: NetManager.sharedInstance.handleParamter(parameters), encoding:URLEncoding.httpBody )
        }
    }
    
    var headers: [String : String]? {
        let header = NetManager.sharedInstance.getHeaderParams()
        return header
    }
}

