//
//  EXOTCPublicInfo.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/26.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class OTCAccountModel:NSObject {
    
    @objc var bankName:String = ""
    @objc var payment:String = ""
    @objc var qrcodeImg:String = ""
    @objc var userName:String = ""
    @objc var ifscCode:String = ""
    @objc var account:String = ""
    @objc var bankOfDeposit:String = ""
    @objc var accountType: String = ""
    @objc var email: String = ""
    @objc var cci: String = ""
    @objc var idNumber: String = ""
    @objc var remittanceInformation: String = ""
    
}

class OTCPaymentModel:EXBaseHanyJsonModel {
     var key:String = ""
     var title:String = ""
     var icon:String = ""
     var account:String = ""
     var used:String = ""
     var numberCode:String = ""
     var open:String = ""
     var payment:String = ""//Place an order for
    
/*Whether to display, for a user, to display the legal currency filter at the top of the list. The default is in the filter module,
As long as there is a currency hide with a value, it defaults to the list display style
     hide=0 or hide=1
   */
     var hide:String = ""
}

class OTCFeeOtcListItem : EXBaseHanyJsonModel {
     var symbol = ""//currency
     var rate = ""//rate
}

class EXOTCPublicInfo: EXBaseHanyJsonModel {
    
    var payments : [OTCPaymentModel] = []//Payment method
    var countryNumberInfo: [OTCPaymentModel] = []//Country List
    var paycoins : [OTCPaymentModel] = []//payment currency
    var feeOtcList : [OTCFeeOtcListItem] = []//Off site rate (new)
    var otcChatWS :String = ""//Otc chat ws
    var defaultCoin :String = ""//Otc default currency
    var defaultSeach :String = ""
    var otcDefaultPaycoin = ""//Off site default payment in legal currency
    var rateUrl = ""//Returned the website for exchange rate inquiry, it's not very useful
    var selected = false
    var used = false//Enable or not
    var open = false//Enable or not
    var otc_order_cancel_max_num = ""
    var wind_control_switch = ""
    
//    override func mj_keyValuesDidFinishConvertingToObject() {
//        self.payments = OTCPaymentModel.mj_objectArray(withKeyValuesArray: self.payments).copy() as! [OTCPaymentModel]
//        self.countryNumberInfo = OTCPaymentModel.mj_objectArray(withKeyValuesArray: self.countryNumberInfo).copy() as! [OTCPaymentModel]
//        self.paycoins = OTCPaymentModel.mj_objectArray(withKeyValuesArray: self.paycoins).copy() as! [OTCPaymentModel]
//        self.feeOtcList = OTCFeeOtcListItem.mj_objectArray(withKeyValuesArray: self.feeOtcList).copy() as! [OTCFeeOtcListItem]
//
//    }
}

