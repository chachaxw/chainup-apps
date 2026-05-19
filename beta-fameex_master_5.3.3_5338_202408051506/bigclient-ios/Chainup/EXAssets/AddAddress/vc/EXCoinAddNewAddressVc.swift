//
//  EXCoinAddNewAddressVc.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/5.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import EXKit

class EXCoinAddNewAddressVc: BaseVC,StoryBoardLoadable,NavigationPlugin {
    var coinModel: EXAccountCoinMapItem = EXAccountCoinMapItem()
    @IBOutlet weak var linkNameBackViewHCon: NSLayoutConstraint!
    @IBOutlet weak var linkNameBackView: UIView!
    
    @IBOutlet var addressScroll: UIScrollView!
    @IBOutlet var topConstraint: NSLayoutConstraint!
    @IBOutlet var itemContainer: UIStackView!
    @IBOutlet var emptyAddressView: EXCoinWithDrawEmptyAddress!
    @IBOutlet var emptyTagView: EXCoinWithDrawEmptyTagView!
    @IBOutlet var emptyRemarkView: EXCoinWithDrawEmptyRemark!
    @IBOutlet var trustView: EXCoinWithdrawTrustView!
    @IBOutlet var footerBar: EXCoinWithdrawFooter!
    var newAddress:String?
    var addressTag:String?
    var addressRemark:String?
    
    typealias NewAddressAddedCallback = ()->()
    var onAddressSuccessed:NewAddressAddedCallback?
    var mainChainName = ""//Main chain name
    var coinSymbol:String = ""//Subchain Name
    @IBOutlet var containerHeight: NSLayoutConstraint!
    
    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: addressScroll, presenter: self)
        return nav
    }()
    
    func handleNavigation() {
        let add = "add_address_title".localized()
        let title = String.localizedStringWithFormat(add, coinModel.coinName.aliasName())
                
        self.navigation.setTitle(title: title)
        navigation.backView.backgroundColor = UIColor.clear
        navigation.isLastNavigationStyle = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleNavigation()
        configAddressContainer()
        configRemark()
        configConfirmBtn()
        configTagView()
        configAddress()
        handleLinkName()
    }
    
    func configAddress() {
        emptyAddressView.withdrawAddress.input.rx.text.orEmpty.asObservable()
            .distinctUntilChanged()
            .subscribe(onNext: {[weak self] text in
                self?.newAddress = text
            }).disposed(by: self.disposeBag)
    }
    
    func configRemark() {
        emptyRemarkView.remarkField.input.rx.text.orEmpty.asObservable()
        .subscribe(onNext: { [weak self] remark in
            guard let `self` = self else { return }
            self.addressRemark = remark
        }).disposed(by: self.disposeBag)
    }
    
    func configTagView() {
        emptyTagView.tagView.input.rx.text.orEmpty.asObservable()
            .subscribe(onNext: { [weak self] tag in
                guard let `self` = self else { return }
                self.addressTag = tag
            }).disposed(by: self.disposeBag)
    }

    
    func tagNeeded() -> Bool {
        let tagNeeded = EXAppMarketManager.sharedInstance.coinNeedTag(self.coinSymbol)
        return tagNeeded
    }
    
    
    func tagForced() -> Bool {
        let tagForced = EXAppMarketManager.sharedInstance.isCoinForceWithdrawTag(coinSymbol)
        return tagForced
    }
    
    
    func configAddressContainer() {
        if self.coinSymbol.isEmpty {
            return
        }
        emptyAddressView.setWithdrawSingleScanMode()
        emptyTagView.isHidden = !self.tagNeeded()
        emptyAddressView.onQRScanCallback = {[weak self] in
            self?.scanAction()
        }
    }
    
    func configConfirmBtn() {
        footerBar.hideFooterTitle()

        footerBar.confirmBtn.rx.tap.asObservable()
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.newSubmitAddNewAddress()
            }).disposed(by: self.disposeBag)
        
        var inputsAry:[Observable<String>] = []
        
        let addressInput = emptyAddressView.withdrawAddress.input.rx.text.orEmpty.asObservable()
        let remarkInput = emptyRemarkView.remarkField.input.rx.text.orEmpty.asObservable()
        inputsAry.append(addressInput)
        inputsAry.append(remarkInput)
        if tagNeeded() {
            let tagInput = emptyTagView.tagView.input.rx.text.orEmpty.asObservable()
            inputsAry.append(tagInput)
        }
        Observable.combineLatest(inputsAry)
            .distinctUntilChanged()
            .map({ strary in
                var count = 0
                for str in strary {
                    if str.count > 0 {
                        count += 1
                    }
                }
                return (count == inputsAry.count)
            })
            .bind(to:footerBar.confirmBtn.rx.isEnabled)
            .disposed(by: self.disposeBag)
    }
    
    
    @objc func newSubmitAddNewAddress(){
        
        let manger = EXComSafeVaildManger()
        manger.safeCheck = .addressAdd
        manger.startSafeAlert()
        manger.resultCallBack = { result in
            self.verifiedSafety(result: result)
        }
    }
//    @objc func submitAddNewAddress() {
//        
//        let user = UserInfoEntity.sharedInstance()
//        
//        var verifycations:[EXOldInputSheetModel] = []
//        if trustView.trustSwitch.isOn {
//            if user.didBindPhone() {
//                let phone = EXOldInputSheetModel.setModel(withTitle:user.mobileNumber,key:"smsValidCode",placeHolder: "personal_text_smsCode".localized(), type: .sms)
//                verifycations.append(phone)
//            }
//            if user.didBindMail() {
//                let mail = EXOldInputSheetModel.setModel(withTitle:user.email,key:"emailValidCode",placeHolder: "personal_text_mailCode".localized(), type: .sms)
//                verifycations.append(mail)
//            }
//            if user.didBindGoolge() {
//                let google = EXOldInputSheetModel.setModel(withTitle:"personal_text_googleCode".localized(),key:"googleCode",placeHolder: "common_tip_googleAuth".localized(), type: .paste)
//                verifycations.append(google)
//            }
//        }else {
//            if user.didBindPhone() {
//                let phone = EXOldInputSheetModel.setModel(withTitle:user.mobileNumber,key:"smsValidCode",placeHolder: "personal_text_smsCode".localized(), type: .sms)
//                verifycations.append(phone)
//            }else {
//                if user.didBindMail() {
//                    let mail = EXOldInputSheetModel.setModel(withTitle:user.email,key:"emailValidCode",placeHolder: "personal_text_mailCode".localized(), type: .sms)
//                    verifycations.append(mail)
//                }
//            }
//            if user.didBindGoolge() {
//                let google = EXOldInputSheetModel.setModel(withTitle:"personal_text_googleCode".localized(),key:"googleCode",placeHolder: "common_tip_googleAuth".localized(), type: .paste)
//                verifycations.append(google)
//            }
//        }
//        
//
//        
//        let sheet = EXActionSheetView()
//        sheet.itemBtnCallback = {[weak self] key in
//            self?.handleSheetAction(key)
//        }
//        sheet.configTextfields(title: "login_action_fogetpwdSafety".localized(), itemModels:verifycations)
//        sheet.actionFormCallback = {[weak self] formDic in
//            self?.verifiedSafety(formDic)
//        }
//        EXAlert.showSheet(sheetView:sheet)
//    }
    
//    func handleSheetAction(_ key:String ) {
//        if key == "smsValidCode" {
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
//                
//                appApi.rx.request(.getsmsValidCode(token: "", operationType: EXSendVerificationCode.addNewAddress, countryCode: "", mobile: ""))
//                    .MJObjectMap(EXVoidModel.self)
//                    .subscribe{[weak self] event in
//                        switch event {
//                        case .success(_):
//                            break
//                        case .failure(_):
//                            break
//                        }
//                    }.disposed(by: self.disposeBag)
//            }
//        }else if key == "emailValidCode" {
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
//                appApi.rx.request(.getemailVallidCode(email: "", operationType: EXMailVerificationCode.addCoinAddr, token: ""))
//                    .MJObjectMap(EXVoidModel.self)
//                    .subscribe{[weak self] event in
//                        switch event {
//                        case .success(_):
//                            break
//                        case .failure(_):
//                            break
//                        }
//                    }.disposed(by: self.disposeBag)
//            }
//        }
//    }
    
    
    func verifiedSafety(result: EXCodeResult) {
        
        guard var address = self.newAddress else {return}
        guard let remark = self.addressRemark else {return}

        var tagNumber = ""
        if self.tagForced() {
            guard let tag = self.addressTag else {return}
            tagNumber = tag
            address.append("_\(tagNumber)")
        }else if self.tagNeeded() {
            if let tag = self.addressTag {
                tagNumber = tag
                address.append("_\(tagNumber)")
            }
        }
        
        appApi.rx.request(.addWithdrawAddress(address: address,
                                              label: remark,
                                              smsValidCode: result.phoneCode,
                                              emailValidCode: result.emailCode,
                                              googleCode: result.googleCode,
                                              coinSymbol: coinSymbol,
                                              trustOption: trustView.trustSwitch.isOn))
        .MJObjectMap(EXVoidModel.self)
        .subscribe{[weak self] event in
            switch event {
            case .success(_):
                self?.addAddressSuccess()
                break
            case .failure(_):
                break
            }
        }.disposed(by: self.disposeBag)
        
    }
    
    
    func addAddressSuccess() {
        self.onAddressSuccessed?()
        EXAlert.showSuccess(msg: "common_tip_addSuccess".localized())
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func scanAction() {
        //Set scanning area parameters
        let scanVc = EXScanVc()
        scanVc.onScanResultCallback = {[weak self] address in
            self?.refreshAddress(address)
        }
        self.navigationController?.pushViewController(scanVc, animated: true)
    }
    
    func refreshAddress(_ scanned:String) {
        self.newAddress = scanned
        emptyAddressView.setAddress(scanned)
    }
    
    func largeTitleValueChanged(height: CGFloat) {
        topConstraint.constant = height
    }
   func handleLinkName() {
        for item in self.linkNameBackView.subviews {
            item.removeFromSuperview()
        }
        var followCoinListArr = EXAppMarketManager.sharedInstance.getFollowCoinList(self.mainChainName)
        if followCoinListArr.count > 0 {
            for item in followCoinListArr {
                if item.name != coinSymbol {
                    followCoinListArr.ch_removeObject(item)
                }
            }
            let followCoinListView = EXFollowCoinListView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 0), followCoinListArr:followCoinListArr,symbol: self.coinSymbol)
            followCoinListView.selectCoinBlock = {[weak self] (item) in
                guard let mySelf = self else{return}
                mySelf.coinSymbol = item.name
            }
            followCoinListView.selectedFollowCoinName = coinSymbol
            self.linkNameBackView.addSubview(followCoinListView)
            self.linkNameBackViewHCon.constant = followCoinListView.height
            self.linkNameBackView.isHidden = false
        }else {
            self.linkNameBackView.isHidden = true
            self.linkNameBackViewHCon.constant = 0
        }
        
    }
}

