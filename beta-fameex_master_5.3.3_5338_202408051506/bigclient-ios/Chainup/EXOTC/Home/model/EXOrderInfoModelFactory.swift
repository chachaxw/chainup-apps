//
//  EXOrderInfoModelFactory.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/29.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXOrderInfoModelFactory: NSObject {

    func getDefaultInfoModels(detailModel:EXOTCOrderDetailModel) ->[OTCOrderInfoModel] {
        var orderModels:[OTCOrderInfoModel] = []
        let status = detailModel.status
//        let nameModel = OTCOrderInfoModel.init()
//        nameModel.title = "otcSafeAlert_action_nickname".localized()
//
//        if let isBuyer = detailModel.isBuyer() {
//            if isBuyer {
//                nameModel.value = detailModel.seller?.realName ?? ""
//            }else {
//                nameModel.value = detailModel.buyer?.realName ?? ""
//            }
//        }
//
//        orderModels.append(nameModel)
        
        let realNameModel = OTCOrderInfoModel.init()
        realNameModel.actionType = detailModel.supportRealName() ? .actionContact : .none
        realNameModel.title = "common_text_realNameTitle".localized()
        if let isBuyer = detailModel.isBuyer() {
            if isBuyer {
                realNameModel.value = detailModel.seller?.realName ?? ""
            }else {
                realNameModel.value = detailModel.buyer?.realName ?? ""
            }
        }
        orderModels.append(realNameModel)

        
        let priceModel = OTCOrderInfoModel.init()
        priceModel.title = "journalAccount_text_amount".localized() + "(\(detailModel.paycoin))"
        priceModel.valueColor = UIColor.ThemeState.warning
        if detailModel.status == EXOTCOrderDetailStatus.orderCanceled.rawValue ||
            detailModel.status == EXOTCOrderDetailStatus.orderComplete.rawValue ||
            detailModel.status == EXOTCOrderDetailStatus.orderComplainDone.rawValue ||
            detailModel.status == EXOTCOrderDetailStatus.orderAppealCancel.rawValue {
            priceModel.actionType = .none
        }else {
            if detailModel.status == EXOTCOrderDetailStatus.orderPay.rawValue {
                if let isBuyer = detailModel.isBuyer() {
                    if isBuyer {
                        priceModel.actionType = self.showAction(status) ? .actionCopy : .none
                    }
                }
            }
            priceModel.actionType = .none
        }
        priceModel.actionType = .actionCopy
        priceModel.value = detailModel.totalPrice.formatCurrencyMoney(detailModel.paycoin,format: .fiatFormat)
        orderModels.append(priceModel)

        let volumeModel = OTCOrderInfoModel.init()
        volumeModel.title = "charge_text_volume".localized() + "(\(detailModel.coin.aliasName()))"
        volumeModel.value = detailModel.volume.formatAmount(detailModel.coin)
        orderModels.append(volumeModel)

        let priceUnit = OTCOrderInfoModel.init()
        priceUnit.title = "otc_text_price".localized() + "(\(detailModel.paycoin))"
        priceUnit.value = detailModel.price.formatCurrencyMoney(detailModel.paycoin,format: .fiatFormat)
        orderModels.append(priceUnit)

        let codeModel = OTCOrderInfoModel.init()
        codeModel.title = "withdraw_text_referenceNumber".localized()
        if detailModel.status == EXOTCOrderDetailStatus.orderCanceled.rawValue || detailModel.status == EXOTCOrderDetailStatus.orderComplete.rawValue ||
            detailModel.status == EXOTCOrderDetailStatus.orderComplainDone.rawValue ||
            detailModel.status == EXOTCOrderDetailStatus.orderAppealCancel.rawValue {
            codeModel.actionType = .none
        }else {
            if detailModel.status == EXOTCOrderDetailStatus.orderPay.rawValue {
                if let isBuyer = detailModel.isBuyer() {
                    if isBuyer {
                        codeModel.actionType = self.showAction(status) ? .actionCopy : .none
                    }
                }
            }
            codeModel.actionType = .none
        }
        codeModel.value = detailModel.fmtSequence()
//        orderModels.append(codeModel)

        
        let timeModel = OTCOrderInfoModel.init()
        timeModel.title = "otc_text_orderCTime".localized()
        timeModel.value = detailModel.ctime
        orderModels.append(timeModel)

        let remarkModel = OTCOrderInfoModel.init()
        remarkModel.title = "address_text_remark".localized()
        remarkModel.value = detailModel.desc
        orderModels.append(remarkModel)

        if detailModel.status == EXOTCOrderDetailStatus.orderCanceled.rawValue || detailModel.status == EXOTCOrderDetailStatus.orderAppealCancel.rawValue{
            let cancelModel = OTCOrderInfoModel.init()
            cancelModel.title = "otc_text_orderCancelReason".localized()
            if detailModel.cancelStatus == OTCCancelType.buyerCancel.rawValue {
                cancelModel.value = "otc_text_cancelByBuyer".localized()
            }else if detailModel.cancelStatus == OTCCancelType.timeLimit.rawValue {
                cancelModel.value = "otc_text_cancelReasonNotPay".localized()

            }else if detailModel.cancelStatus == OTCCancelType.complainCancel.rawValue {
                cancelModel.value = "otc_text_cancelByAppeal".localized()
            }
            
            if cancelModel.value != "" {
                orderModels.append(cancelModel)
            }
        }
        return orderModels
    }
    
    func showAction(_ status:String)->Bool {
        if status == EXOTCOrderDetailStatus.orderPay.rawValue ||
            status == EXOTCOrderDetailStatus.orderDidPay.rawValue ||
            status == EXOTCOrderDetailStatus.orderComplain.rawValue {
            return true
        }
        return false
    }
    
    func getPayTypeModels(detailModel :EXOTCOrderDetailModel,idx:Int) -> [OTCOrderInfoModel] {
        var models:[OTCOrderInfoModel] = []
        let status = detailModel.status
        if detailModel.payment.count > idx {
            let model = detailModel.payment[idx]
            
            
            if model.payment == OTCPayInfoType.UnionPay.rawValue {
                let bankNameModel = OTCOrderInfoModel.init()
                bankNameModel.title = "otc_text_bankName".localized()
                bankNameModel.value = model.bankName
                let subbankNameModel = OTCOrderInfoModel.init()
                subbankNameModel.title = "otc_text_bankBranchName".localized()
                subbankNameModel.value = model.bankOfDeposit
                let accountNameModel = OTCOrderInfoModel.init()
                accountNameModel.actionType = self.showAction(status) ? .actionCopy : .none
                accountNameModel.title = "otc_text_bankCardOwnerName".localized()
                accountNameModel.value = model.userName
                let cardNumberModel = OTCOrderInfoModel.init()
                cardNumberModel.title = "otc_text_paymentCardNumber".localized()
                cardNumberModel.actionType = self.showAction(status) ? .actionCopy : .none
                cardNumberModel.value = model.account
                models.append(bankNameModel)
                models.append(subbankNameModel)
                models.append(accountNameModel)
                models.append(cardNumberModel)
            }else if model.payment == OTCPayInfoType.AliPay.rawValue {
                let accountNameModel = OTCOrderInfoModel.init()
                accountNameModel.actionType = self.showAction(status) ? .actionCopy : .none
                accountNameModel.title = "otc_text_payee".localized()
                accountNameModel.value = model.userName
                let cardNumberModel = OTCOrderInfoModel.init()
                cardNumberModel.title = "alipay_text_account".localized()
                cardNumberModel.actionType = self.showAction(status) ? .actionCopy : .none
                cardNumberModel.value = model.account
                let qrModel = OTCOrderInfoModel.init()
                qrModel.title = "alipay_text_qrcode".localized()
                qrModel.actionType = .actionQRCode
                qrModel.valueIcon = model.qrcodeImg
                models.append(accountNameModel)
                models.append(cardNumberModel)
                models.append(qrModel)
            }else if model.payment == OTCPayInfoType.WxPay.rawValue {
                let accountNameModel = OTCOrderInfoModel.init()
                accountNameModel.actionType = self.showAction(status) ? .actionCopy : .none
                accountNameModel.title = "otc_text_payee".localized()
                accountNameModel.value = model.userName
                let cardNumberModel = OTCOrderInfoModel.init()
                cardNumberModel.title = "otc_text_wxID".localized()
                cardNumberModel.actionType =  self.showAction(status) ? .actionCopy : .none
                cardNumberModel.value = model.account
                let qrModel = OTCOrderInfoModel.init()
                qrModel.title = "wxpay_text_qrcode".localized()
                qrModel.actionType =  .actionQRCode
                qrModel.valueIcon = model.qrcodeImg
                models.append(accountNameModel)
                models.append(cardNumberModel)
                models.append(qrModel)
            }else if model.payment == OTCPayInfoType.Paypal.rawValue {
                let userNameModel = OTCOrderInfoModel.init()
                userNameModel.title = "otc_text_payee".localized()
                userNameModel.value = model.userName
                userNameModel.actionType = self.showAction(status) ? .actionCopy : .none
                let accountNameModel = OTCOrderInfoModel.init()
                accountNameModel.actionType = self.showAction(status) ? .actionCopy : .none
                accountNameModel.title = "otc_6".localized()
                accountNameModel.value = model.account
                models.append(userNameModel)
                models.append(accountNameModel)
            }else if model.payment == OTCPayInfoType.WestUnio.rawValue {
                let userNameModel = OTCOrderInfoModel.init()
                userNameModel.title = "otc_text_payee".localized()
                userNameModel.actionType = self.showAction(status) ? .actionCopy : .none
                userNameModel.value = model.userName
                let addressModel = OTCOrderInfoModel.init()
                addressModel.actionType = self.showAction(status) ? .actionCopy : .none
                addressModel.title = "otc_tip_pleaseInputWestUnio".localized()
                addressModel.value = model.remittanceInformation
                models.append(userNameModel)
                models.append(addressModel)
            }else if model.payment == OTCPayInfoType.SWIFT.rawValue {
                let userNameModel = OTCOrderInfoModel.init()
                userNameModel.title = "otc_text_payee".localized()
                userNameModel.actionType = self.showAction(status) ? .actionCopy : .none
                userNameModel.value = model.userName
                let addressModel = OTCOrderInfoModel.init()
                addressModel.actionType = self.showAction(status) ? .actionCopy : .none
                addressModel.title = "otc_tip_pleaseInputSWIFT".localized()
                addressModel.value = model.account
                models.append(userNameModel)
                models.append(addressModel)
            }else if model.payment == OTCPayInfoType.PayNow.rawValue {
                let userNameModel = OTCOrderInfoModel.init()
                userNameModel.title = "otc_text_payee".localized()
                userNameModel.actionType = self.showAction(status) ? .actionCopy : .none
                userNameModel.value = model.userName
                let accountNameModel = OTCOrderInfoModel.init()
                accountNameModel.actionType = self.showAction(status) ? .actionCopy : .none
                accountNameModel.title = "otc_6".localized()
                accountNameModel.value = model.account
                models.append(userNameModel)
                models.append(accountNameModel)
            }else if model.payment == OTCPayInfoType.Paytm.rawValue {
                let accountNameModel = OTCOrderInfoModel.init()
                accountNameModel.actionType = self.showAction(status) ? .actionCopy : .none
                accountNameModel.title = "otc_6".localized()
                accountNameModel.value = model.bankName
                let cardNumberModel = OTCOrderInfoModel.init()
                cardNumberModel.title = "otc_text_paymentCardNumber".localized()
                cardNumberModel.actionType = self.showAction(status) ? .actionCopy : .none
                cardNumberModel.value = model.account
                let qrModel = OTCOrderInfoModel.init()
                qrModel.title = "otc_text_paymentQRcode".localized()
                qrModel.actionType = .actionQRCode
                qrModel.valueIcon = model.qrcodeImg
                models.append(accountNameModel)
                models.append(cardNumberModel)
                models.append(qrModel)
            }else if model.payment == OTCPayInfoType.QIWI.rawValue {
                let userNameModel = OTCOrderInfoModel.init()
                userNameModel.title = "otc_text_payee".localized()
                userNameModel.actionType = self.showAction(status) ? .actionCopy : .none
                userNameModel.value = model.userName
                let accountNameModel = OTCOrderInfoModel.init()
                accountNameModel.actionType = self.showAction(status) ? .actionCopy : .none
                accountNameModel.title = "otc_6".localized()
                accountNameModel.value = model.account
                models.append(userNameModel)
                models.append(accountNameModel)
            }else if model.payment == OTCPayInfoType.Interact.rawValue {
                let userNameModel = OTCOrderInfoModel.init()
                userNameModel.title = "otc_text_payee".localized()
                userNameModel.actionType = self.showAction(status) ? .actionCopy : .none
                userNameModel.value = model.userName
                let accountNameModel = OTCOrderInfoModel.init()
                accountNameModel.actionType = self.showAction(status) ? .actionCopy : .none
                accountNameModel.title = "otc_6".localized()
                accountNameModel.value = model.account
                models.append(userNameModel)
                models.append(accountNameModel)
            }else if model.payment == OTCPayInfoType.IMPS.rawValue {
                let userNameModel = OTCOrderInfoModel.init()
                userNameModel.title = "otc_text_payee".localized()
                userNameModel.actionType = self.showAction(status) ? .actionCopy : .none
                userNameModel.value = model.userName
                let accountNameModel = OTCOrderInfoModel.init()
                accountNameModel.actionType = self.showAction(status) ? .actionCopy : .none
                accountNameModel.title = "otc_6".localized()
                accountNameModel.value = model.account

                let icfsA = OTCOrderInfoModel.init()
                icfsA.actionType = self.showAction(status) ? .actionCopy : .none
                icfsA.title = "otc_text_payee".localized()
                icfsA.value = model.ifscCode
                let icfsB = OTCOrderInfoModel.init()
                icfsB.actionType = self.showAction(status) ? .actionCopy : .none
                icfsB.title = "otc_text_payee".localized()
                icfsB.value = model.ifscCode

                let qrModel = OTCOrderInfoModel.init()
                qrModel.title = "otc_text_paymentQRcode".localized()
                qrModel.actionType = .actionQRCode
                qrModel.valueIcon = model.qrcodeImg
                
                models.append(userNameModel)
                models.append(accountNameModel)
                models.append(icfsA)
                models.append(icfsB)
                models.append(qrModel)
            }else if model.payment == OTCPayInfoType.UPI.rawValue {
                let userNameModel = OTCOrderInfoModel.init()
                userNameModel.title = "otc_text_payee".localized()
                userNameModel.actionType = self.showAction(status) ? .actionCopy : .none
                userNameModel.value = model.userName

                let accountNameModel = OTCOrderInfoModel.init()
                accountNameModel.actionType = self.showAction(status) ? .actionCopy : .none
                accountNameModel.title = "otc_6".localized()
                accountNameModel.value = model.account
                
                let qrModel = OTCOrderInfoModel.init()
                qrModel.title = "otc_text_paymentQRcode".localized()
                qrModel.actionType = .actionQRCode
                qrModel.valueIcon = model.qrcodeImg
                
                models.append(userNameModel)
                models.append(accountNameModel)
                models.append(qrModel)
            }else{
                //Seven new types added by hsien
                //name
                let name = OTCOrderInfoModel()
                name.title = "otc_5".localized()
                name.value =  model.userName
                name.actionType = self.showAction(status) ? .actionCopy : .none
                //Account
                let accountItem = OTCOrderInfoModel()
                accountItem.title = "otc_6".localized()
                accountItem.value = model.account
                accountItem.actionType = self.showAction(status) ? .actionCopy : .none
                //Bank Name
                let bank = OTCOrderInfoModel()
                bank.title = "otc_7".localized()
                bank.value = model.bankName
                bank.actionType = self.showAction(status) ? .actionCopy : .none
//                //Bank Branch Name
//                let bankbranch = OTCOrderInfoModel()
//                bankbranch.title = "otc_text_bankBranchName".localized()
//                bankbranch.value = model.bankOfDeposit
//                bankbranch.actionType = self.showAction(status) ? .actionCopy : .none
                //ID number
                let idnumb = OTCOrderInfoModel()
                idnumb.title = "otc_1".localized()
                idnumb.actionType = self.showAction(status) ? .actionCopy : .none
                idnumb.value = model.idNumber
                //account type
                let accpuntType = OTCOrderInfoModel()
                accpuntType.title = "otc_2".localized()
                accpuntType.value = model.accountType
//                accpuntType.actionType = self.showAction(status) ? .actionCopy : .none
                //Email
                let email = OTCOrderInfoModel()
                email.title = "otc_3".localized()
                email.actionType = self.showAction(status) ? .actionCopy : .none
                email.value = model.email
                //Cross bank transfer
                let code = OTCOrderInfoModel()
                code.title = "otc_4".localized()
                code.actionType = self.showAction(status) ? .actionCopy : .none
                code.value = model.cci
                if model.payment  == OTCPayInfoType.ZHILI.rawValue {
                    models = [name,idnumb,bank,accpuntType,accountItem,email]
                }else if model.payment  == OTCPayInfoType.MILU.rawValue {
                    models = [name,bank,accountItem,code]
                }else if model.payment  == OTCPayInfoType.AGENTING.rawValue {
                    models = [name,accountItem,accpuntType,idnumb,bank]
                }else if model.payment  == OTCPayInfoType.YAPE.rawValue {
                    models = [name,accountItem]
                }else if model.payment  == OTCPayInfoType.PlIN.rawValue {
                    models = [name,accountItem]
                }else{
                    models = [name,accountItem,email]
                }
            }
        }
        
        if status == EXOTCOrderDetailStatus.orderComplete.rawValue ||
            status == EXOTCOrderDetailStatus.orderComplainDone.rawValue {
            let payTimeModel = OTCOrderInfoModel.init()
            payTimeModel.title = "otc_text_payTime".localized()
            payTimeModel.value = detailModel.payTime
            models.append(payTimeModel)
            let sendTimeModel = OTCOrderInfoModel.init()
            sendTimeModel.title = "otc_text_sendCoinTime".localized()
            sendTimeModel.value = detailModel.sendCoinTime
            models.append(sendTimeModel)
        }else if  status == EXOTCOrderDetailStatus.orderComplain.rawValue {
            let payTimeModel = OTCOrderInfoModel.init()
            payTimeModel.title = "otc_text_payTime".localized()
            payTimeModel.value = detailModel.payTime
            models.append(payTimeModel)
        }

        return models
    }
}

