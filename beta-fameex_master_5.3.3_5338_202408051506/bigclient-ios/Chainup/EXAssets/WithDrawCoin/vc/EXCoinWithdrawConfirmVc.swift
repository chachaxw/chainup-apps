//
//  EXCoinWithdrawConfirmVc.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/5.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import EXKit

class EXCoinWithdrawConfirmVc: BaseVC,StoryBoardLoadable,NavigationPlugin {
    
    var confirmModel:EXWithDrawConfirmModel?
    @IBOutlet var addressView: EXAddressVerticalView!
    @IBOutlet var footer: EXCoinWithdrawFooter!
    @IBOutlet var trustView: EXAddressTrustView!
    @IBOutlet var topConstraint: NSLayoutConstraint!
    @IBOutlet var infoView: EXThreeColumnView!
    @IBOutlet var addressViewHeight: NSLayoutConstraint!
    
    typealias WithdrawSuccessCallback = () -> ()
    var onWithdrawSuccess:WithdrawSuccessCallback?
    var isLoading:Bool = false

    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll:nil, presenter: self)
        return nav
    }()
    
    func handleNavigation() {
        self.navigation.isLastNavigationStyle = true
        self.navigation.setdefaultType(type: .list)
        self.navigation.setTitle(title: "withdraw_action_confirm".localized())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleNavigation()
        handleFooter()
        handleInfoView()
        configItem()
    }
    
    func handleInfoView() {
        guard let item = self.confirmModel else {return}
        let model = ExThreeColumnDataModel()
        model.title = "common_text_coinsymbol".localized()
        model.content = item.symbol.aliasName()
        model.style = self.getStyle()
        let modelm = ExThreeColumnDataModel()
        modelm.title = "charge_text_volume".localized()
        modelm.content = item.amount
        modelm.style = self.getStyle()
        modelm.aliment = .left
        let modelr = ExThreeColumnDataModel()
        modelr.title = "withdraw_text_fee".localized()
        modelr.content = item.fee
        modelr.style = self.getStyle()
        infoView.bindItems(with: [model,modelm,modelr])
    }
    
    func getStyle()->ExThreeColumnStyle {
        let style = ExThreeColumnStyle()
        style.bottomLabelColor = UIColor.ThemeLabel.colorLite
        return style
    }
    
    func handleFooter() {
        footer.hideFooterTitle()
        footer.confirmBtn.rx.tap.asObservable()
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
                .subscribe(onNext: { [weak self] _ in
                    guard let `self` = self else { return }
                    self.confirmOrder()
                }).disposed(by: disposeBag)
        
//        footer.confirmBtn.addTarget(self, action: #selector(confirmOrder), for: .touchUpInside)
    }
    
    @objc func confirmOrder() {
        guard let item = self.confirmModel else {return}
        
        if item.addreeItem.trustType == "1" {
            self.confirmWithDraw(item, smsCode: nil, googleCode: nil, emailCode: nil,trustType: nil)
        }else {
            let user = UserInfoEntity.sharedInstance()
            var verifycations:[EXOldInputSheetModel] = []
            let trustType = trustView.trustSwitch.isOn ? 1 : 0
            if trustView.trustSwitch.isOn {
                if user.didBindPhone() {
                    let phone = EXOldInputSheetModel.setModel(withTitle:user.mobileNumber,key:"smsValidCode",placeHolder: "personal_text_smsCode".localized(), type: .sms)
                    verifycations.append(phone)
                }
                if user.didBindMail() {
                    let mail = EXOldInputSheetModel.setModel(withTitle:user.email,key:"emailValidCode",placeHolder: "personal_text_mailCode".localized(), type: .sms)
                    verifycations.append(mail)
                }
                
                if user.didBindGoolge() {
                    let google = EXOldInputSheetModel.setModel(withTitle:user.mobileNumber,key:"googleValidCode",placeHolder: "personal_text_googleCode".localized(), type: .paste)
                    verifycations.append(google)
                }
            }else {
                if user.didBindPhone() {
                    let phone = EXOldInputSheetModel.setModel(withTitle:user.mobileNumber,key:"smsValidCode",placeHolder: "personal_text_smsCode".localized(), type: .sms)
                    verifycations.append(phone)
                }else if user.didBindMail() {
                    let mail = EXOldInputSheetModel.setModel(withTitle:user.email,key:"emailValidCode",placeHolder: "personal_text_mailCode".localized(), type: .sms)
                    verifycations.append(mail)
                }
                if user.didBindGoolge() {
                    let google = EXOldInputSheetModel.setModel(withTitle:user.mobileNumber,key:"googleValidCode",placeHolder: "personal_text_googleCode".localized(), type: .paste)
                    verifycations.append(google)
                }
            }
            
      
            let sheet = EXOldActionSheetView()
            sheet.itemBtnCallback = {[weak self] key in
                self?.handleSheetAction(key)
            }
            sheet.configTextfields(title: "login_action_fogetpwdSafety".localized(), itemModels:verifycations)
            sheet.actionFormCallback = {[weak self] formDic in
                self?.confirmWithDraw(item, smsCode: formDic["smsValidCode"], googleCode:  formDic["googleValidCode"], emailCode: formDic["emailValidCode"], trustType: trustType)
            }
            EXAlert.showSheet(sheetView:sheet)
        }
    }
    
    
    func handleSheetAction(_ key:String ) {
        if key == "smsValidCode" {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
                appApi.rx.request(.getsmsValidCode(token: "", operationType: EXSendVerificationCode.withDraw, countryCode: "", mobile: ""))
                    .MJObjectMap(EXVoidModel.self)
                    .subscribe{[weak self] event in
                        switch event {
                        case .success(_):
                            break
                        case .failure(_):
                            break
                        }
                    }.disposed(by: self.disposeBag)
            }
        }else if key == "emailValidCode" {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
                appApi.rx.request(.getemailVallidCode(email: "", operationType: EXMailVerificationCode.withDraw, token: ""))
                    .MJObjectMap(EXVoidModel.self)
                    .subscribe{[weak self] event in
                        switch event {
                        case .success(_):
                            break
                        case .failure(_):
                            break
                        }
                    }.disposed(by: self.disposeBag)
            }
        }
    }
    
    private func confirmWithDraw(_ item:EXWithDrawConfirmModel,smsCode:String?,googleCode:String?,emailCode:String?,trustType:Int?) {
        //What the server needs is the received quantity, and verify the received amount+fee<=balance
        let amount = item.amount as NSString
        let decimal = EXAppMarketManager.sharedInstance.getCoinPrecision(item.symbol)
        let arriveAmount = amount.subtracting(item.fee, decimals: decimal)
        if let rst = arriveAmount {
            if isLoading {
                return
            }
            self.isLoading = true
            appApi.rx.request(.doWithDraw(address: item.addreeItem.address,
                                          trustType: trustType,
                                          remark: item.addreeItem.label,
                                          symbol: item.symbol,
                                          fee: item.fee,
                                          amount: rst,
                                          smsVaildCode: smsCode,
                                          googleValidCode: googleCode,
                                          emailValidCode: emailCode,
                                          addressID: item.addreeItem.id,
                                          capitalPwd: nil
                                         ))
                .MJObjectMap(EXWithdrawSuccessModel.self)
                .subscribe{[weak self] event in
                    self?.resetLoading()
                    switch event {
                    case .success(let model):
                        self?.handleWithDrawSuccess(model)
                        break
                    case .failure(_):
                        break
                    }
                }.disposed(by: self.disposeBag)
        }
    }
    
    func resetLoading() {
        self.isLoading = false
    }
    
    func handleWithDrawSuccess(_ model:EXWithdrawSuccessModel) {
        
        if model.isOpenUserCheck == "1" {
            if model.isOpenCompanyCheck == "1" {
                //todo face++
            }
            let verifyVc = EXCoinWithdrawVerifyVc.instanceFromStoryboard(name: StoryBoardNameAsset)
            verifyVc.withdrawID = model.withdrawId
            self.navigationController?.pushViewController(verifyVc, animated: true)
        }else {
            if let addressId = self.confirmModel?.addreeItem.id,addressId.count > 0 {
                EXAlert.showSuccess(msg: "withdraw_tip_withdrawSuccess".localized())
            }else {
                EXAlert.showSuccess(msg: "withdraw_tip_successWithSaveAddress".localized())
            }
            if let controllers = self.navigationController?.viewControllers {
                var isPoped = false
                for controller in controllers {
                    if controller.isKind(of: EXAssetsVc.self) {
                        isPoped = true
                        self.navigationController?.popToViewController(controller, animated: true)
                    }
                }
                if isPoped == false {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }else {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    func configItem() {
        guard let item = self.confirmModel else {return}
        addressViewHeight.constant = addressView.getHeight(item.addreeItem)
        let coinAddress = item.addreeItem.address
        if let _ = coinAddress.range(of: "_") {
            let addressAry = coinAddress.components(separatedBy: "_")
            if addressAry.count == 2 {
                addressView.addressLabel.text = addressAry[0]
                addressView.tagLabel.text = addressAry[1]
            }
        }else {
            addressView.hideTagLabel()
            addressView.addressLabel.text = coinAddress
        }
        addressView.remarkLabel.text = item.addreeItem.label
        addressView.showCheck(false)
        trustView.isTrusted(item.addreeItem.trustType == "1")
    }
    
    
    func largeTitleValueChanged(height: CGFloat) {
        topConstraint.constant = height
    }
}

