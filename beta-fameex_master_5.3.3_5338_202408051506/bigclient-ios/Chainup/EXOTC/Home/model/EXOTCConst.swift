//
//  EXOTCConst.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/29.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import Foundation

enum OTCTradeType:Int {
    case otcbuy = 0
    case otcsell = 1
    case none = 2
}

enum OTCCancelType:String {
    case buyerCancel = "1"//Buyer cancels on their own
    case complainCancel = "2"//Appeal determines that the buyer did not make payment
    case timeLimit = "3"//overtime
}

enum OTCPrecheckErrors:Int {
    case orderOffline = 2007 //The advertisement has been removed from the shelves
    case userCancelLimit = 2079 //Too many cancellations
    case userUnCompleteOrderLimit = 2069 //Maximum limit for orders in progress, 3 in progress
//    case userSaleNoStock = 1233 //Users sell without any remaining coins
}

enum OTCOrderSaveErrors:Int {
    case orderOffline = 2007 //The advertisement has been removed from the shelves
    case orderNeedRefresh = 2062 //Advertising information needs to be updated
}

enum OTCTradeSideKey:String {
    case otcBuy = "BUY"
    case otcSell = "SELL"
}

enum OTCRelationType:String {
    case blackList = "BLACKLIST"
    case stranger = "STRANGER"
}

enum OTCPaymentType:Int {
    case paymentMoney = 0
    case paymentVolume = 1
}

enum OTCPaymentTypeKey:String {
    case payByMoney = "price"
    case payByVolume = "volume"
}

enum EXOTCFooterBtnAction {
    case actionCancel
    case actionDidPay
    case actionRefresh
    case actionToComplain
    case actionDidReceive
    case actionCancelComplain
    case actionNone
}

enum EXOTCOrderDetailStatus:String {
    case orderPay = "1"
    case orderDidPay = "2"
    case orderComplete = "3"
    case orderCanceled = "4"
    case orderComplain = "5"
    case orderPending = "6"//Coining
    case orderAbnormal = "7" //abnormal
    case orderComplainDone = "8"//Appeal handling ok
    case orderAppealCancel = "9"//Appeal cancellation
}

enum OTCAppealReasonType:String {
    case sellerWontDeliver = "8" //The seller did not place any coins
    case buyerNoPay = "9" //The buyer did not make payment
    case payMoreError = "10" //The payment amount is greater than the order amount
    case payeeLessError = "11"//Receipt less than order amount
    case otherReason = "12"//other
    case none = "otc_shensu_reason_choose"
}

enum OTCPayInfoType:String {
    case UnionPay = "otc.payment.domestic.bank.transfer" //UnionPay
    case WxPay = "otc.payment.wxpay"//WeChat
    case AliPay = "otc.payment.alipay"//Alipay
    case Paypal = "otc.payment.paypal"//PayPal 
    case WestUnio = "otc.payment.western.union"//Western Union
    case SWIFT = "otc.payment.swift" //swift
    case PayNow = "otc.payment.paynow"//paynow
    case Paytm = "otc.payment.paytm" //paytm
    case QIWI = "otc.payment.qiwi"//qiwi
    case Interact = "otc.payment.interac"//interac
    case IMPS = "otc.payment.imps"//imps
    case UPI = "otc.payment.upi"//upi
    case ZHILI = "otc.payment.chilebank"//Chile
    case MILU = "otc.payment.perubank"//Peru otc.payment.perubank
    case AGENTING = "otc.payment.argentinabank"//Argentina
    case YAPE = "otc.payment.yape" //Yape
    case PlIN = "otc.payment.plin" //Plin
    case MERCADOADO = "otc.payment.mercadopago"//mercadoado
    case MODOSMART  = "otc.payment.modosmart"//modosmart
    case NIRILIYA = "otc.payment.nigeriabank" //Nigeria
    case FIRSTMONIE = "otc.payment.firstmonie" //firstmonie
    case FLUTTERWAVE = "otc.payment.flutterwave"//flutterwave
    case POCKETMONI = "otc.payment.pocketmoni"//Pocketmoni
    
    
}

/*
PAY_ PENDING (1, "otc. order. status. pay. paying", "to be paid"),
PAID (2, "otc. order. status. pay", "paid"),
Completed (3, "otc. order. status. completed", "Transaction completed"),
CANCELED (4, "otc. order. status. canceled", "canceled"),
APPEAL (5, "otc. order. status. appeal. pending", "in appeal"),
PAY_ COIN (6, "otc. order. status. pay. coin", "Coining"),
EXCEPTION_ ORDER (7, "otc. order. status. exception. order", "Abnormal Order"),
 
APPEAL_ Completed (8, "otc. order. status. appeal. completed", "Appeal processing completed"),
APPEAL_ Completed_ CANCELED (9, "otc. order. status. appeal. canceled", "appeal cancellation");
 */

enum OTCOrderStatusKey:String {
    case All = "ALL" //whole
    case Pending = "1" //Pending payment
    case DidPay = "2" //To be received
    case Complete = "3,8" //Completed
    case Cancel = "4,9" //Canceled
    case Appeal = "5" //In appeal
    case PayCoin = "6" //To be released, to be received in currency
}


struct OrderWarningMsg {
    let orderPayBuyer = "".localized()
    let orderPaySeller = "".localized()
    let orderSendingBuyer = "".localized()
    let orderSendingSeller = "".localized()
    let orderComplainFrom = "".localized()
    let orderComplainTo = "".localized()
    let orderCompleteBuyer = "".localized()
    let orderCompleteSeller = "".localized()
}


