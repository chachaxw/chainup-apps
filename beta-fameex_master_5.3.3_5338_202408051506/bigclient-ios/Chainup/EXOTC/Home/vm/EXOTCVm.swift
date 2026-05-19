//
//  EXOrderDetailVm.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/2.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit

class EXOTCVm: NSObject {
    let modelConfiger = EXOrderInfoModelFactory()
    var currentVc:UIViewController?
    let disposebag = DisposeBag()
    var otcCoinMap:CoinMapItem = CoinMapItem()

   func otcOrderPreCheck(advertId:String,type:OTCTradeType,vc:UIViewController,emptyBalance:Bool?,hasPayment:Bool,sellerPayment:[OTCPaymentModel],myPaymentModel:CommonAryModel){
        currentVc = vc
        if XUserDefault.isOffLine() {
            BusinessTools.modalLoginVC()
            return
        }
        let user = UserInfoEntity.sharedInstance()
        if type == .otcbuy {
            if user.hasNickName(),user.didpassRealName() {
                //Request Valad
                self.precheckAdvert(advertId,type)
            }else {
                let safety = EXOTCSafetyAlert()
                var message = "otcSafeAlert_text_otcBuyDesc".localized()
                if EXAppConfigManager.sharedInstance.didOpenB2C(){
                    message = "otcSafeAlert_text_otcBuyDesc_forotc".localized()
                }
                safety.configAlert(title: "common_text_tip".localized(),
                                   message: message,
                                   safeItems: [.nickName,.reaName])
                safety.alertCallback = {[weak self] type in
                    self?.handleAlertCallback(type)
                }
                EXAlert.showAlert(alertView: safety)
            }
        }else {
            
            if user.otcBasicCheckPass() &&
                user.otcSafetyCheckPass() && isPaymentValid(sellerPayment: sellerPayment, myPaymentModel: myPaymentModel){
                if let empty = emptyBalance {
                    if empty {
                        let normalalert = EXNormalAlert()
                        var message = "otc_tip_lessCoin".localized()
                        if EXHomeViewModel.isContractStatus() {
                            message = "onlyCo_otc_tip_lessCoin".localized()
                        }
                        if EXAppConfigManager.sharedInstance.didOpenB2C(){
                            message = "otc_tip_lessCoin_forotc".localized()
                            if EXHomeViewModel.isContractStatus() {
                                message = "onlyCo_otc_tip_lessCoin_forotc".localized()
                            }
                        }
                        normalalert.configAlert(title: "common_text_tip".localized(), message:message, passiveBtnTitle: "common_text_btnCancel".localized(), positiveBtnTitle: "alert_action_toTransfer".localized())
                        normalalert.alertCallback = {[weak self] tag in
                            if tag == 0 {
                                self?.toTransferAction()
                            }
                        }
                        EXAlert.showAlert(alertView: normalalert)
                    }else {
                        self.precheckAdvert(advertId,type)
                    }
                }else {
                    self.precheckAdvert(advertId,type)
                }
            }else {
                if !user.otcBasicCheckPass() {
                    if EXAppConfigManager.sharedInstance.isRequireGoogle() {
                        let safety = EXOTCSafetyAlert()
                        var message = "otcSafeAlert_text_title".localized()
                        if EXAppConfigManager.sharedInstance.didOpenB2C(){
                            message = "otcSafeAlert_text_title_forotc".localized()
                        }
                        safety.configAlert(title: "common_text_tip".localized(),
                                           message: message,
                                           safeItems: [.nickName,.bindGoogle,.reaName])
                        safety.alertCallback = {[weak self] type in
                            self?.handleAlertCallback(type)
                        }
                        EXAlert.showAlert(alertView: safety)
                    }else {
                        let safety = EXOTCSafetyAlert()
                        var message = "otcSafeAlert_text_title".localized()
                        if EXAppConfigManager.sharedInstance.didOpenB2C(){
                            message = "otcSafeAlert_text_title_forotc".localized()
                        }
                        safety.configAlert(title: "common_text_tip".localized(),
                                           message: message,
                                           safeItems: [.nickName,.bindGoolgeOrPhone,.reaName])
                        safety.alertCallback = {[weak self] type in
                            self?.handleAlertCallback(type)
                        }
                        EXAlert.showAlert(alertView: safety)
                    }

                    return
                }
//                if !user.otcSafetyCheckPass() {
//                    let safety = EXOTCSafetyAlert()
//                    safety.hasPayment = hasPayment
//                    var message = "otcSafeAlert_text_settingDesc".localized()
//                    if EXAppConfigManager.sharedInstance.didOpenB2C(){
//                        message = "otcSafeAlert_text_settingDesc_forotc".localized()
//                    }
//                    safety.configAlert(title: "common_text_tip".localized(),
//                                       message: message,
//                                       safeItems: [.paypwd,.payType])
//                    safety.alertCallback = {[weak self] type in
//                        self?.handleAlertCallback(type)
//                    }
//                    EXAlert.showAlert(alertView: safety)
//                    return
//                }
                
                if !isPaymentValid(sellerPayment: sellerPayment, myPaymentModel: myPaymentModel){
                    
                    if myPaymentModel.dictAry.isEmpty{
                        let safety = EXOTCSafetyAlert()
                        safety.hasPayment = hasPayment
                        var message = "otcSafeAlert_text_settingDesc".localized()
                        if EXAppConfigManager.sharedInstance.didOpenB2C(){
                            message = "otcSafeAlert_text_settingDesc_forotc".localized()
                        }
                        safety.configAlert(title: "common_text_tip".localized(),
                                           message: message,
                                           safeItems: [.payType])
                        safety.alertCallback = {[weak self] type in
                            self?.handleAlertCallback(type)
                        }
                        EXAlert.showAlert(alertView: safety)
                        return
                    }
                    
                    
                    
                                   
                   let sellerTypes = getPaymentTypes(payment: sellerPayment)
                   
                   let normalalert = EXNormalAlert()
                   let message = "\("otc_sting_buyerOnlyCan".localized())\(sellerTypes)\("otc_string_youNeedDo".localized())"
                   normalalert.configAlert(title: "common_text_tip".localized(), message: message, passiveBtnTitle: "common_text_btnCancel".localized(), positiveBtnTitle: "otc_string_goActivate".localized())
                   normalalert.alertCallback = { tag in
                       
                       if (tag == 0) {
                          self.handleAlertCallback(.payType)
                       }
                   }
                
                   EXAlert.showAlert(alertView: normalalert)
                   
               }
            }
        }
    }
    
//    func otcOrderPreCheck(advertId:String,type:OTCTradeType,vc:UIViewController,emptyBalance:Bool?,hasPayment:Bool,sellerPayment:[OTCPaymentModel],myPaymentModel:CommonAryModel){
//        currentVc = vc
//        if XUserDefault.isOffLine() {
//            BusinessTools.modalLoginVC()
//            return
//        }
//        let user = UserInfoEntity.sharedInstance()
//        if type == .otcbuy {
//            if user.hasNickName(),user.didpassRealName() {
//                //Request Valad
//                self.precheckAdvert(advertId,type)
//            }else {
//                let safety = EXOTCSafetyAlert()
//                var message = "otcSafeAlert_text_otcBuyDesc".localized()
//                if EXAppConfigManager.sharedInstance.didOpenB2C(){
//                    message = "otcSafeAlert_text_otcBuyDesc_forotc".localized()
//                }
//                safety.configAlert(title: "common_text_tip".localized(),
//                                   message: message,
//                                   safeItems: [.nickName,.reaName])
//                safety.alertCallback = {[weak self] type in
//                    self?.handleAlertCallback(type)
//                }
//                EXAlert.showAlert(alertView: safety)
//            }
//        }else {
//            if !isPaymentValid(sellerPayment: sellerPayment, myPaymentModel: myPaymentModel){
//                let sellerTypes = getPaymentTypes(payment: sellerPayment)
//                let normalalert = EXNormalAlert()
//                let message = "\("otc_sting_buyerOnlyCan".localized())\(sellerTypes)\("otc_string_youNeedDo".localized())"
//                normalalert.configAlert(title: "common_text_tip".localized(), message: message, passiveBtnTitle: "common_text_btnCancel".localized(), positiveBtnTitle: "otc_string_goActivate".localized())
//                normalalert.alertCallback = { tag in
//                    
//                    if (tag == 0) {
//                        self.handleAlertCallback(.payType)
//                    }
//                }
//                EXAlert.showAlert(alertView: normalalert)
//                return
//            }
//            
//            if let empty = emptyBalance {
//                if empty {
//                    let normalalert = EXNormalAlert()
//                    var message = "otc_tip_lessCoin".localized()
//                    if EXHomeViewModel.isContractStatus() {
//                        message = "onlyCo_otc_tip_lessCoin".localized()
//                    }
//                    if EXAppConfigManager.sharedInstance.didOpenB2C(){
//                        message = "otc_tip_lessCoin_forotc".localized()
//                        if EXHomeViewModel.isContractStatus() {
//                            message = "onlyCo_otc_tip_lessCoin_forotc".localized()
//                        }
//                    }
//                    normalalert.configAlert(title: "common_text_tip".localized(), message:message, passiveBtnTitle: "common_text_btnCancel".localized(), positiveBtnTitle: "alert_action_toTransfer".localized())
//                    normalalert.alertCallback = {[weak self] tag in
//                        if tag == 0 {
//                            self?.toTransferAction()
//                        }
//                    }
//                    EXAlert.showAlert(alertView: normalalert)
//                    return
//                }
//            }
//            self.precheckAdvert(advertId,type)
//        }
//    }
     
    
    
    
    func isPaymentValid(sellerPayment:[OTCPaymentModel],myPaymentModel:CommonAryModel) -> Bool {
        
        if myPaymentModel.dictAry.count == 0 { return false }
        
        let sellerPaymentKeys = sellerPayment.map{$0.key}
        
        var listData:[EXOTCPaymentListModel] = []
        for item in myPaymentModel.dictAry {
            if let modeleItem = EXOTCPaymentListModel.mj_object(withKeyValues: item) {
                listData.append(modeleItem)
            }
        }
        let myPaymentsKeys = listData.map{$0.payment}
        
        let type = getPaymentTypes(payment: sellerPayment)
        
        print(type)
        
        var isContain = false
        for item in myPaymentsKeys {
            
            if sellerPaymentKeys.contains(item){
                
                isContain = true
                break
            }
            
        }
        return isContain
        
    }
    
    func getPaymentTypes(payment:[OTCPaymentModel]) -> String {
        
        let types = payment.map{$0.title}
        
        return types.joined(separator: ",")
        
    }
    
    func taskSign(_ vc:UIViewController,types: [SafetyTypes]){
        currentVc = vc
        let safety = EXOTCSafetyAlert()
        var message = "rewardCenter_text40".localized()
        safety.configAlert(title: "common_text_tip".localized(),
                           message: message,
                           safeItems: types)
        safety.alertCallback = {[weak self] type in
            self?.handleAlertCallback(type)
        }
        EXAlert.showSheet(sheetView: safety) //(alertView: safety)
    }
    
    
    func otcMerchantPasswordSet(_ vc:UIViewController){
        currentVc = vc
        let safety = EXOTCSafetyAlert()
        var message = "otcSafeAlert_text_title".localized()
        if EXAppConfigManager.sharedInstance.didOpenB2C(){
            message = "otcSafeAlert_text_title_forotc".localized()
        }
        safety.configAlert(title: "common_text_tip".localized(),
                           message: message,
                           safeItems: [.paypwd])
        safety.alertCallback = {[weak self] type in
            self?.handleAlertCallback(type)
        }
        EXAlert.showAlert(alertView: safety)
    }
    func b2cRealNameSet(_ vc:UIViewController, typeStr: String){
           currentVc = vc
           let safety = EXOTCSafetyAlert()
           safety.configAlert(title: "common_text_tip".localized(),
                              message: typeStr,
                              safeItems: [.reaName])
           safety.alertCallback = {[weak self] type in
               self?.handleAlertCallback(type)
           }
           EXAlert.showAlert(alertView: safety)
       }
    private func precheckAdvert(_ aId:String,_ type:OTCTradeType){
        var adType = ""
        if type == .otcbuy {
            adType = "buy"
        }else if type == .otcsell {
            adType = "sell"
        }
        otcApi.rx.request(.validateAdvert(adId: aId, type: adType))
            .MJObjectMap(EXVoidModel.self, false)
            .subscribe{[weak self] event in
                switch event {
                case .success(_):
                    self?.nextStep(type: type, adverseId: aId)
                    break
                case .failure(let error):
                    self?.handlePreCheckError(error)
                    break
                }
            }.disposed(by: disposebag)
    }
    
    func handlePreCheckError(_ err:Error) {
        let preCheckErr = err as NSError
        let errCode = preCheckErr.code
        
        if errCode == OTCPrecheckErrors.userCancelLimit.rawValue {
            let normalalert = EXNormalAlert()
            normalalert.configSigleAlert(title: "common_text_tip".localized(), message:preCheckErr.localizedDescription)
            EXAlert.showAlert(alertView: normalalert)
        }
//        else if errCode == OTCPrecheckErrors.userSaleNoStock.rawValue {

//        }
        else if errCode == OTCPrecheckErrors.userUnCompleteOrderLimit.rawValue {
            let normalalert = EXNormalAlert()
            normalalert.configAlert(title: "common_text_tip".localized(), message:err.localizedDescription, passiveBtnTitle: "common_text_btnCancel".localized(), positiveBtnTitle: "alert_action_toDealWith".localized())
            normalalert.alertCallback = {[weak self] tag in
                if tag == 0 {
                    self?.toOrderHistory()
                }
            }
            EXAlert.showAlert(alertView: normalalert)
        }else {
            EXAlert.showFail(msg: preCheckErr.localizedDescription)
        }
    }
    
    private func toTransferAction() {
        guard let vc = currentVc else {return}
        let transfer = EXAccountTransferVc.instanceFromStoryboard(name: StoryBoardNameAsset)
        transfer.otcModel = self.otcCoinMap
        transfer.transferFlow = .otcToExchange
        vc.navigationController?.pushViewController(transfer, animated: true)
    }
    
    private func toOrderHistory() {
        guard let vc = currentVc else {return}
        let nvc = EXOTCHistoryListVc.instanceFromStoryboard(name: StoryBoardNameOTC)
        vc.navigationController?.pushViewController(nvc, animated: true)
    }
    
    func nextStep(type:OTCTradeType,adverseId:String) {
        guard let vc = currentVc else {return}
        let nvc = EXOTCCreateOrderVC()
        nvc.advertId = adverseId
        nvc.tradeType = type
        nvc.errorCallback = {[weak self] in
            self?.handleErrorRefresh(vc)
        }
        vc.navigationController?.pushViewController(nvc, animated: true)
    }
    
    private func handleErrorRefresh(_ hostVc:UIViewController) {
        if let vc = hostVc as? EXRefreshProtocal {
            vc.refreshProtocalTrigger()
        }
    }
    
    private func handleAlertCallback(_ safeType:SafetyTypes) {
        guard let vc = currentVc else {return}
        
        switch safeType {
        case .bindGoolgeOrPhone:
            let google = EXSecurityCenterVC()
            vc.navigationController?.pushViewController(google, animated: true)
            break
        case .nickName:
            let info = EXMyInfoVC()
            vc.navigationController?.pushViewController(info, animated: true)
            break
        case .reaName:
//            let user = UserInfoEntity.sharedInstance()
//            if user.authLevel == UserAuthLevel.pending.rawValue {
////                EXAlert.showWarning(msg: "noun_login_pending".localized())
//                let vc = EXRealNameThreeVC()
//                EXAlert.showVc(controller: vc,ratio: 0.9)
//                
//            }else {
                let realName = EXIDAuthenticViewController()
                vc.navigationController?.pushViewController(realName, animated: true)
//            }
            break
        case .paypwd:
            let pwd = EXChangeOTCPWVC()
            vc.navigationController?.pushViewController(pwd, animated: true)
            break
        case .payType:
            let listVc = EXOTCAvailablePaymentVc.instanceFromStoryboard(name: StoryBoardNameAsset)  //EXOTCSupportPaymentMethodVc.instanceFromStoryboard(name: StoryBoardNameAsset)
            vc.navigationController?.pushViewController(listVc, animated: true)
            break
        case .bindGoogle:
            let google = EXGoogleBindingVC()
            vc.navigationController?.pushViewController(google, animated: true)
            break
        case .bindPhone:
            let bindPhone = EXMoblieBindingVC()
            vc.navigationController?.pushViewController(bindPhone, animated: true)
            break
        case .none:
            break
        }
    }
    
    
    func orderInfoSections(model:EXOTCOrderDetailModel)-> [OTCOrderInfoModel] {
        let infoModels = modelConfiger.getDefaultInfoModels(detailModel: model)
        return infoModels
    }
    
    func paymentsInfoSections(model:EXOTCOrderDetailModel,paymentTypeIdx:Int)->[OTCOrderInfoModel] {
        
        if model.status == EXOTCOrderDetailStatus.orderCanceled.rawValue ||
            model.status == EXOTCOrderDetailStatus.orderAppealCancel.rawValue {
            return []
        }
        
        if model.status == EXOTCOrderDetailStatus.orderPay.rawValue {
            if let isBuyer = model.isBuyer() {
                if !isBuyer {
                    return []
                }
            }
        }
        var selectIdx = paymentTypeIdx

        if model.payKey.count > 0 {
            for (idx,payment) in model.payment.enumerated() {
                if model.payKey == payment.payment {
                    selectIdx = idx
                    break
                }
            }
        }
        
        let payinfoModels = modelConfiger.getPayTypeModels(detailModel: model,idx:selectIdx)
        return payinfoModels
    }
    
    func shouldShowFooterBar(withStatus:String) ->Bool {
        var shouldShow = true
        if withStatus == EXOTCOrderDetailStatus.orderCanceled.rawValue {
            shouldShow = false
        }else if withStatus == EXOTCOrderDetailStatus.orderComplete.rawValue {
            shouldShow = false
        }else if withStatus == EXOTCOrderDetailStatus.orderComplainDone.rawValue {
            shouldShow = false
        }else if withStatus == EXOTCOrderDetailStatus.orderAppealCancel.rawValue {
            shouldShow = false
        }else if withStatus == EXOTCOrderDetailStatus.orderAbnormal.rawValue {
            shouldShow = false
        }
        
        return shouldShow
    }
    
    func orderTipMessage(_ model:EXOTCOrderDetailModel) -> String? {
        
        if model.isOrderDuringReview() { return "otc_tip_orderDuringReview".localized()}
        
        if model.status == EXOTCOrderDetailStatus.orderPay.rawValue {
            if let isBuyer = model.isBuyer() {
                if isBuyer {
                    return "otc_tip_buyerConfirmPaid".localized()
                }else {
                    return "otc_tip_remindSellerWaitPay".localized()
                }
            }
        }else if model.status == EXOTCOrderDetailStatus.orderDidPay.rawValue {
            if let isBuyer = model.isBuyer() {
                if isBuyer {
                    if EXAppConfigManager.sharedInstance.didOpenB2C(){
                        return "otc_tip_remindBuyerWaitConfirm_forotc".localized()
                    }else{
                        return "otc_tip_remindBuyerWaitConfirm".localized()
                    }
                }else {
                    return "otc_tip_remindSellerDidReceive".localized()
                }
            }
        }else if model.status == EXOTCOrderDetailStatus.orderComplete.rawValue ||
            model.status == EXOTCOrderDetailStatus.orderComplainDone.rawValue{
            if let isBuyer = model.isBuyer() {
                if isBuyer {
                    if EXAppConfigManager.sharedInstance.didOpenB2C(){
                        return "otc_tip_buyerOrderComplete_forotc".localized()
                    }else{
                        return "otc_tip_buyerOrderComplete".localized()
                    }
                }else {
                    if EXAppConfigManager.sharedInstance.didOpenB2C(){
                        return "otc_tip_buyerOrderComplete_forotc".localized()
                    }else{
                        return "otc_tip_sellerOrderComplete".localized()
                    }
                }
            }
        }else if model.status == EXOTCOrderDetailStatus.orderComplain.rawValue {
            if model.isComplainUser == "1" {
                let tip = "otc_tip_appealOffence".localized()
                return String.init(format: tip, model.complainCommand)
            }else if model.isComplainUser == "0" {
                return "otc_tip_appealDefense".localized()
            }
        }
        return nil
    }
    
    func handleFooterBarStyle(withTradeType:OTCTradeType,detailModel:EXOTCOrderDetailModel,bindFooterBar:EXCountDownBtnFooter) {
        if withTradeType == .none {
            return
        }else {
            //Canceled Completed
            if detailModel.status == EXOTCOrderDetailStatus.orderCanceled.rawValue ||
                detailModel.status == EXOTCOrderDetailStatus.orderComplete.rawValue ||
                detailModel.status == EXOTCOrderDetailStatus.orderComplainDone.rawValue ||
                detailModel.status == EXOTCOrderDetailStatus.orderAppealCancel.rawValue {
                bindFooterBar.isHidden = true
                return
            }
            bindFooterBar.isHidden = false
            
            if detailModel.status == EXOTCOrderDetailStatus.orderComplain.rawValue {
                //In the appeal, it is the complainant
                bindFooterBar.rightBtn.isEnabled = true
                if detailModel.isComplainUser == "1" {
                    bindFooterBar.setTitle(left: "otc_action_cancelAppeal".localized(), right: "otc_text_orderPendingAppeal".localized())
                    bindFooterBar.rightBtn.isEnabled = false
                }else {
                    bindFooterBar.setSingleBtnStyle()
                    bindFooterBar.setSigleBtn(title: "otc_tip_appealCharged".localized())
                    bindFooterBar.rightBtn.isEnabled = false
                }
                return
            }
            var leftStr = ""
            var rightStr = ""
            if let isBuyer = detailModel.isBuyer() {
                if isBuyer {
                    //Buyer, to be paid
                    bindFooterBar.rightBtn.isEnabled = true
                    if detailModel.status == EXOTCOrderDetailStatus.orderPay.rawValue {
                        leftStr = "common_text_btnCancel"
                        rightStr = "otc_action_buyerDidPay"
                        bindFooterBar.startFire()
                    }else if detailModel.status == EXOTCOrderDetailStatus.orderPending.rawValue {
                        //Currency to be received
                        leftStr = "otc_action_appeal"
                        rightStr = "otc_text_sellerSendingCoin"
                        bindFooterBar.stopCounting()
                    }else if detailModel.status == EXOTCOrderDetailStatus.orderDidPay.rawValue {
                        //Currency to be received
                        leftStr = "otc_action_appeal"
                        rightStr = "otc_tip_sellerPendingCoin"
                        bindFooterBar.stopCounting()
                        bindFooterBar.rightBtn.isEnabled = false
                    }
                }else {
                    //Seller, to be paid
                    bindFooterBar.rightBtn.isEnabled = true
                    if detailModel.status == EXOTCOrderDetailStatus.orderPay.rawValue {
                        bindFooterBar.startFire()
                        bindFooterBar.rightBtn.isEnabled = false
                        leftStr = ""
                        rightStr = "otc_text_waitPay"
                    }else if detailModel.status == EXOTCOrderDetailStatus.orderPending.rawValue {
                        //Currency to be released
                        leftStr = "otc_action_appeal"
                        rightStr = "otc_action_confirmSendCoin"
                        bindFooterBar.stopCounting()
                    }else if detailModel.status == EXOTCOrderDetailStatus.orderDidPay.rawValue {
                        //Currency to be received
                        leftStr = "otc_action_appeal"
                        rightStr = "otc_action_confirmSendCoin"
                        bindFooterBar.stopCounting()
                    }
                }
            }
            
            if detailModel.isOrderDuringReview() {
                rightStr = "otc_action_refreshOrder"
            }
            
            bindFooterBar.setTitle(left: leftStr.localized(), right: rightStr.localized())
        }
    }
    
    func getFooterBarActionType(tradeType:OTCTradeType,
                                detailModel:EXOTCOrderDetailModel,
                                isLeftBtn:Bool = true) -> EXOTCFooterBtnAction {
        if tradeType == .none {
            return .actionNone
        }else {
            
            if detailModel.status == EXOTCOrderDetailStatus.orderCanceled.rawValue ||
                detailModel.status == EXOTCOrderDetailStatus.orderComplete.rawValue  ||
                detailModel.status == EXOTCOrderDetailStatus.orderComplainDone.rawValue ||
                detailModel.status == EXOTCOrderDetailStatus.orderAppealCancel.rawValue {
                return .actionNone
            }
            if detailModel.status == EXOTCOrderDetailStatus.orderComplain.rawValue {
                //In the appeal, it is the complainant
                if detailModel.isComplainUser == "1" {
                    return .actionCancelComplain
                }else {
                    return .actionNone
                }
            }
            
            if isLeftBtn {
         
                if tradeType == .otcbuy {
                    if detailModel.status == EXOTCOrderDetailStatus.orderPay.rawValue {
                        if let isBuyer = detailModel.isBuyer() {
                            //Buyer can cancel, seller cannot cancel
                            if isBuyer {
                                return .actionCancel
                            }
                        }
                        return .actionNone
                    }else if detailModel.status == EXOTCOrderDetailStatus.orderPending.rawValue {
                        //Currency to be received
                        return .actionToComplain
                    }else if detailModel.status == EXOTCOrderDetailStatus.orderDidPay.rawValue {
                        //Currency to be received
                        if let isBuyer = detailModel.isBuyer() {
                            if isBuyer {
                                return .actionToComplain
                            }
                        }
                        //stay
                        return .actionNone
                    }
                }else if tradeType == .otcsell {
                    if detailModel.status == EXOTCOrderDetailStatus.orderDidPay.rawValue {
                        if let isSeller = detailModel.isSeller() {
                            if isSeller {
                                return .actionToComplain
                            }
                        }
                        //Currency to be released
                        return .actionNone
                    }
                }
                return .actionNone
            }else {
                if detailModel.isOrderDuringReview() { return .actionRefresh }
                //Right button
                if detailModel.status == EXOTCOrderDetailStatus.orderPay.rawValue {
                    if let isBuyer = detailModel.isBuyer() {
                        //Buyer confirms payment has been made
                        if isBuyer {
                            return .actionDidPay
                        }
                    }
                    return .actionNone
                }else if detailModel.status == EXOTCOrderDetailStatus.orderDidPay.rawValue {
                    if let isBuyer = detailModel.isBuyer() {
                        //Waiting for coin release
                        if isBuyer {
                            return .actionNone
                        }
                    }
                    //Confirm receipt and release currency
                    return .actionDidReceive
                }else if detailModel.status == EXOTCOrderDetailStatus.orderPending.rawValue {
                    //Currency to be received
                    return .actionDidReceive
                }
                return .actionNone
            }
        }
    }
}

