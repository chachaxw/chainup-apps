//
//  EXCreditCoin.swift
//  Chainup
//
//  Created by 柴伟东 on 2022/3/31.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import HandyJSON
import Swap

class EXBaseArrayModel<T: HandyJSON>: EXBaseHanyJsonModel {
    var code: Int = 0
    var msg:String?
    var data: [T]?
}



class EXBaseHanyJsonModel:NSObject,HandyJSON{
    required override init() {
        super.init()
    }
}
struct EXCreditCoinData: HandyJSON{
    var coinSell_list: [EXCreditCoin]?
    var coin_list: [EXCreditCoin]?
    var fiat_list: [EXCreditCoin]?
    var can_user_amount: String?
    var status = 1
    var open :Bool {
        return self.status == 1
    }
}


struct EXCoinRateListData: HandyJSON{
    var target_max: String?
    var target_min: String?
    var min: String? = "0.0001"
    var max: String? = "1000"
    var rate_list: [EXCoinRate]?
}

struct EXPayData: HandyJSON{ //Display the number of digital currencies that can be exchanged by entering the legal currency quantity after selecting a third party
    var paycard_list:[EXPayServiceinfo]?
    
}


struct EXCreditCoin: HandyJSON {
    ///Interface raw data
    var id: String = ""
    var name: String = "" //Name enumeration: USDT, SDKL, EO
    var iconColor: String = "" //Icon color - enumeration for legal currency: rgb (41, 95, 157)
    var iconContent: String = "" //Icon content - for legal currency use
    var iconUrl: String = ""//Image URL - for digital currency
    var limitMin: String = "" //Minimum value - for fiat currency
    var limitMax: String = "" //Maximum value - for fiat currency
    var ctime: String = ""
    var mtime: String = ""
    var isFiat: Bool = false //Is it legal currency
    var alias: String = "" //alias
    var showName: String {
        if alias.isEmpty == false{
            return alias
        }
        return name
    }
    var mainChainSymbol: String = ""
    var thirdPartyProvider: String = ""
    ///App processing data
    var placeHolder: String {
        if isFiat {
          return "common_text_limitMin".localized() + limitMin + "-" + limitMax
        }else{
            
        }
        return ""
    }
    var coinPlaceHolder: String = ""//This needs to be calculated based on the exchange rate
    var limitTip: String = ""
    var amount: String = "" //Enter the final result
    ///Input is legal
}
struct EXCoinRate: HandyJSON{
    var name: String = "" //
    var rate: String = ""
    var service_pic: String = "" //Merchant icon ID (for use on the web, the web will store its own image and ID)
    var payment_pic: String = "" //Merchant payment method ID (payment method also stores ID)
    var maxLimit: String = ""
    var logo: String = ""
    var minLimit: String = ""
    var payment_list: [ExpayItemInfo]?
}
struct ExpayItemInfo:HandyJSON{
    var payment_method_name: String = ""
    var payment_pic: String = ""
    
}

struct EXPayServiceinfo:HandyJSON{
    var total_amount: String = "" //Total number of fiat coins spent
    var base_amount: String = "" //The actual number of fiat coins that may be purchased after deducting handling fees
    var amount: String = "" //Number of digital currencies
    var service_pic: String = ""
    var payment_pic: String = "" //Merchant payment method ID (payment)
    var quote_id: String = "" //Quotation ID
    var valid_until: String = ""//As of Effective Time
    var arrival_time: String = "" //Estimated time of receipt
    var rate: String = ""
    var name: String = ""
    var target_unit: String = ""
    var target_amount: String = ""
    var spot_price:String = ""
    var source_amount: String = ""
    var source_unit: String = ""
}

enum ServiceProviderType: String{
    case simplex = "Simplex"
    case banxa = "Banxa"
}
struct EXPayResult: HandyJSON{
    var data_map:EXPayResultInfo?
    var html: String = ""
    var serviceName: String = ""
    var serveiceType: ServiceProviderType {
        return ServiceProviderType(rawValue: serviceName) ?? .banxa
    }
    
}

struct EXPayResultInfo: HandyJSON{
    var payment_id: String = "" //Payment ID
    var return_url: String = "" //Redirected URL
    var api_version: String = "" //
    var partner_name: String = "" //Partner Name
    var payment_post_url: String = ""
}


///Payment Order Record with Bank Card
struct PayHistoryData: HandyJSON{
    var orderList:[EXPayRecord]?
    
}

struct EXPayRecord: HandyJSON{
    var side: String = ""
    var totalPrice: String = ""
    var nickName: String = ""
    var type: String = ""
    var buyerId: String = ""
    var adsId: String = ""
    var volume: String = ""
    var sequence: String = ""
    var realName: String = ""
    var coinSymbol: String = ""
    var price: String = ""
    var status_text: String = ""
    var status: String = ""
    var payCoin: String = ""
    var orderType: Int = 1
    var url: String = ""
    var ctime: String = ""
    var originType: Int = 1
               
}

