//
//  EXOTCOrderDetailModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/29.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit


class OTCUserModel: NSObject {
    @objc var uid = ""
    @objc var otcNickName = ""
    @objc var mobileNumber = ""
    @objc var countryCode = ""
    @objc var imageUrl = ""
    @objc var isOnline = ""
    @objc var completeOrders = ""
    @objc var realName = ""
    @objc var email = ""
}


class EXOTCPaymentModel:NSObject {
    @objc var bankName:String = ""
    @objc var payment:String = ""
    @objc var qrcodeImg:String = ""
    
}

class EXOTCOrderDetailModel: NSObject {
    @objc var seller:OTCUserModel?
    @objc var buyer:OTCUserModel?
    @objc var payment:[OTCAccountModel] = []
    @objc var complainId = ""
    @objc var totalPrice = ""
    @objc var complainCommand = ""
    @objc var paycoin = ""
    @objc var volume = ""
    @objc var sequence = ""
    @objc var isComplainUser = ""
    @objc var price = ""
    @objc var coin = ""
    @objc var payKey = ""
    @objc var status = ""
    @objc var isBlockTrade = ""
    @objc var cancelStatus = ""
    @objc var desc = ""
    @objc var otcAuthnameOpen = "" //Display real name switch, 0, not displayed, 1 displayed
    @objc var isTwoMin = "" //0: Display for 2 minutes Copy 1: Email and phone number will only be given
    @objc var showWarnTip = ""
    @objc var sendCoinTime = "" {
        didSet {
            sendCoinTime = DateTools.strToTimeString(sendCoinTime,dateFormat: "yyyy-MM-dd HH:mm:ss")
        }
    }
    
    @objc var payTime = "" {
        didSet {
            payTime = DateTools.strToTimeString(payTime,dateFormat: "yyyy-MM-dd HH:mm:ss")
        }
    }
    
    @objc var ctime = "" {
        didSet {
            ctime = DateTools.strToTimeString(ctime,dateFormat: "yyyy-MM-dd HH:mm:ss")
        }
    }
    
    
    @objc var limitTime :String = "" {
        didSet {
            limitTime = NSString.init(string: limitTime).dividing(by: "1000", decimals: 0)
        }
    }
    
    func fmtSequence() -> String {
        if sequence.count > 6 {
            return String(sequence.suffix(6))
        }
        return sequence
    }
    
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.payment = OTCAccountModel.mj_objectArray(withKeyValuesArray: self.payment).copy() as! [OTCAccountModel]
    }
    
    override static func mj_replacedKeyFromPropertyName() -> [AnyHashable : Any]! {
        return ["desc":"description"]
    }
    
    func supportRealName() -> Bool {
        if self.otcAuthnameOpen == "1" {
            return true
        }else {
            return false
        }
    }
    
    func isBuyer() -> Bool? {
        
        if let buyUid = self.buyer?.uid {
            if buyUid == UserInfoEntity.sharedInstance().uid {
                return true
            }
        }
        if let sellUid = self.seller?.uid {
            if sellUid == UserInfoEntity.sharedInstance().uid {
                return false
            }
        }
        return nil
    }
    
    func isOrderDuringReview() -> Bool {
        return self.status == EXOTCOrderDetailStatus.orderPay.rawValue && showWarnTip == "1";
    }
    
    func isSeller() -> Bool? {
        //In the sales order, seller uid==self. uid
        if let buyUid = self.buyer?.uid {
            if buyUid == UserInfoEntity.sharedInstance().uid {
                return false
            }
        }
        if let sellUid = self.seller?.uid {
            if sellUid == UserInfoEntity.sharedInstance().uid {
                return true
            }
        }
        return nil
    }


    func getCurrentTitleModelForDisplay() -> OTCOrderInfoModel{
        let model = OTCOrderInfoModel()
        model.title = "otc_text_orderId".localized() + " " + self.sequence
        return model
    }
    
    func getCurrentTitleModelForPayTitle(_ payTypeIdx:Int) -> OTCOrderInfoModel {
        let model = OTCOrderInfoModel()
        //Is it waiting for coins to be released or received, completed or in the process of appeal

        if self.status == EXOTCOrderDetailStatus.orderComplete.rawValue ||
            status == EXOTCOrderDetailStatus.orderDidPay.rawValue ||
            status == EXOTCOrderDetailStatus.orderComplainDone.rawValue ||
            status == EXOTCOrderDetailStatus.orderComplain.rawValue {
            if let isBuyer = self.isBuyer() {
                if isBuyer {
                    model.title = "common_text_paymentInfoBuyer".localized()
                }else {
                    model.title = "common_text_paymentInfoSeller".localized()
                }
            }
        }else {
            if status == EXOTCOrderDetailStatus.orderPay.rawValue {
                if self.payment.count > 0 {
                    model.value = payment.count > 1 ? "otc_action_changePayment".localized() : ""
                    model.valueIcon = payment.count > 1 ? "enter" : ""
                }
            }
            
            var selectedIdx = payTypeIdx
            if self.payKey.count > 0 {
                for (idx, item) in payment.enumerated() {
                    if item.payment == self.payKey {
                        selectedIdx = idx
                        break
                    }
                }
            }
            if self.payment.count > selectedIdx {
                let payments = self.payment[selectedIdx]
                let key = payments.payment
                if let pmodel = self.getPayMentModel(key) {
                    model.title = pmodel.title
                    model.titleIcon = pmodel.icon
                }
            }
        }
    
        return model
    }
    
    func getPayMentModel(_ key:String)-> OTCPaymentModel? {
        let tmpModel = OTCPulbicManager.sharedInstance.getOtcPaymentModel(key)
        if let payMentModel = tmpModel {
            return payMentModel
        }
        return nil
    }
    
    func getPayConfirmAlertInfo(idx:Int) -> [EXConfirmPayAlertModel] {
        var confirmInfos:[EXConfirmPayAlertModel] = []
        
        if self.payment.count > idx {
            let payments = self.payment[idx]
            let model = EXConfirmPayAlertModel()
            model.title = "common_text_paymentTypeBuyer".localized()
            if let pmodel = self.getPayMentModel(payments.payment) {
                model.value = pmodel.title
            }
            confirmInfos.append(model)
            let model2 = EXConfirmPayAlertModel()
            model2.title = "otc_text_payee".localized()
            model2.value = payments.userName
            confirmInfos.append(model2)
            let model3 = EXConfirmPayAlertModel()
            model3.title = "otc_text_paymentAmount".localized()
            model3.value = self.totalPrice.formatCurrencyMoney(self.paycoin,format: .fiatFormat) + "(\(self.paycoin))"
            model3.valueColor = UIColor.ThemeState.warning
            confirmInfos.append(model3)
        }
        return confirmInfos
    }
    
    func getStatusTitle() -> String {
        var title :String = ""
        if self.status == EXOTCOrderDetailStatus.orderPay.rawValue{
            if let isbuyer = self.isBuyer() {
                if isbuyer {
                    title = "otc_text_orderWaitPay".localized()
                }else {
                    title = "otc_text_orderWaitMoney".localized()
                }
            }
        }else if self.status == EXOTCOrderDetailStatus.orderDidPay.rawValue {
            if let isBuyer = self.isBuyer() {
                if isBuyer {
                    title = "otc_text_waitReceiveCoin".localized()
                }else {
                    title = "otc_text_orderWaitSendCoin".localized()
                }
            }
        }else if self.status == EXOTCOrderDetailStatus.orderComplete.rawValue {
            title = "otc_text_orderComplete".localized()
        }else if self.status == EXOTCOrderDetailStatus.orderComplain.rawValue {
            title = "otc_text_orderAppeal".localized()
        }else if self.status == EXOTCOrderDetailStatus.orderCanceled.rawValue {
            title = "otc_text_orderCancel".localized()
        }else if self.status == EXOTCOrderDetailStatus.orderPending.rawValue {
            title = "otc_sell_coin".localized()
        }else if self.status == EXOTCOrderDetailStatus.orderAbnormal.rawValue {
            title = "contract_text_orderError".localized()
        }else if self.status == EXOTCOrderDetailStatus.orderComplainDone.rawValue {
            title = "otc_text_orderComplete".localized()
        }else if self.status == EXOTCOrderDetailStatus.orderAppealCancel.rawValue {
            title = "otc_text_orderCancel".localized()
        }
        return title
    }
    
    
    func orderComplete() -> Bool {
        if status == EXOTCOrderDetailStatus.orderComplete.rawValue ||
            status == EXOTCOrderDetailStatus.orderCanceled.rawValue ||
            status == EXOTCOrderDetailStatus.orderAbnormal.rawValue ||
            status == EXOTCOrderDetailStatus.orderAppealCancel.rawValue ||
            status == EXOTCOrderDetailStatus.orderComplainDone.rawValue {
            return true
        }
        return false
    }
}


