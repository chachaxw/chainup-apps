
//
//  EXOTCPaymentAddNewVc.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/6.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import EXKit

class EXOTCPaymentAddNewVc: BaseVC,StoryBoardLoadable,NavigationPlugin,EXNavigationPresenter {
    typealias AddSuccessCallback = (String)->()
    var onPaymentSuccess:AddSuccessCallback?
    
    typealias DeleteCallback = (Int) -> ()
    var deleteCallback : DeleteCallback?
    
    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: self.baseScroll, presenter: self)
        return nav
    }()
    
    var tag = 1000
    var canEdit = false
    
    @IBOutlet var baseScroll: UIScrollView!
    @IBOutlet var topConstraint: NSLayoutConstraint!
    @IBOutlet var containers: UIStackView!
    
    @IBOutlet var nameView: EXCommonInputView!
    @IBOutlet var accountView: EXCommonInputView!
    @IBOutlet var ifscCodeA: EXCommonInputView!
    @IBOutlet var ifscCodeB: EXCommonInputView!
    @IBOutlet var uploadView: EXPaymentUploadView!
    
    @IBOutlet var footer: EXCoinWithdrawFooter!
    var paymentMethod:OTCPayInfoType?
    
    let pickerController:EXOldImagePicker = EXOldImagePicker.init()
    let uploader:EXImageUploader = EXImageUploader.init()
    let smsService:EXSmsService = EXSmsService()
    
    
    var oldPaymentModel:EXOTCPaymentListModel?
    var payTypeKey = ""
    var selectedImg:UIImage?
    var account:String = ""
    var bankOrIFCS:String?
    var subBankOrIFCSB:String?
    var iconUrl:String?
    
    var userRealName:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handlePayment()
        configNavigation()
        configPhotoView()
        handleFooterView()
        handleDataBinding()
        canEdit(self.canEdit)
    }
    
    func configPhotoView() {
        
        uploadView.onImageRemovedCallback = {[weak self] in
            self?.iconUrl = nil
        }
        
        uploadView.photoImg.tapBtn.rx.tap.asObservable()
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.handleUploadAction()
            }).disposed(by: self.disposeBag)
        
        uploader.rx_imgUrl.skip(1)
            .subscribe(onNext: { [weak self] imgUrl in
                guard let `self` = self else { return }
                self.iconUrl = imgUrl
                if let currentimg = self.selectedImg {
                    self.uploadView.setImg(icon: currentimg)
                }
                self.uploadView.setImgUrl(iconUrl: imgUrl)
            }).disposed(by: self.disposeBag)
        
    }
    
    func handleDataBinding() {
        accountView.input.input.rx.text.orEmpty.asObservable()
            .distinctUntilChanged()
            .subscribe(onNext: {[weak self] text in
                self?.account = text
            }).disposed(by: self.disposeBag)
        
        nameView.input.input.rx.text.orEmpty.asObservable()
            .distinctUntilChanged()
            .subscribe(onNext: {[weak self] text in
                self?.userRealName = text
            }).disposed(by: self.disposeBag)
        
        
        ifscCodeA.input.input.rx.text.orEmpty.asObservable()
            .distinctUntilChanged()
            .subscribe(onNext: {[weak self] text in
                self?.bankOrIFCS = text
            }).disposed(by: self.disposeBag)
        
        ifscCodeB.input.input.rx.text.orEmpty.asObservable()
            .distinctUntilChanged()
            .subscribe(onNext: {[weak self] text in
                self?.subBankOrIFCSB = text
            }).disposed(by: self.disposeBag)
    }
    
    func handleFooterView() {
        footer.hideFooterTitle()
        footer.confirmBtn.setTitle("otc_action_bindpayment".localized(), for: .normal)
        footer.confirmBtn.addTarget(self, action: #selector(confirmBtnAction), for: .touchUpInside)
        var inputsAry:[Observable<String>] = []
        let rxName = nameView.input.input.rx.text.orEmpty.asObservable()
        inputsAry.append(rxName)
        let account = accountView.input.input.rx.text.orEmpty.asObservable()
        inputsAry.append(account)
        if isUnionPay() {
            let bankname = ifscCodeA.input.input.rx.text.orEmpty.asObservable()
            inputsAry.append(bankname)
            let codeb = ifscCodeB.input.input.rx.text.orEmpty.asObservable()
            inputsAry.append(codeb)
        }
        if isQRSupport() {
            let qrcode = uploader.rx_imgUrl.asObservable()
            inputsAry.append(qrcode)
        }
        if isIMPS() {
            let codea = ifscCodeA.input.input.rx.text.orEmpty.asObservable()
            inputsAry.append(codea)
            let codeb = ifscCodeB.input.input.rx.text.orEmpty.asObservable()
            inputsAry.append(codeb)
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
            .bind(to:footer.confirmBtn.rx.isEnabled)
            .disposed(by: self.disposeBag)
    }
    
    func configNavigation() {
        self.navigation.setdefaultType(type: .list)
        self.navigation.isLastNavigationStyle = true
        self.navigation.rightItemCallback =  {[weak self] tag in
            //            self?.beginEditing()
            self?.beginDelete()
        }
    }
    
    func beginDelete(){
        deleteCallback?(self.tag - 1000)
    }
    
    func endDelete(){
        EXAlert.showSuccess(msg: "b2c_text_deleteSuccess".localized())
        self.navigationController?.popViewController(animated: true)
    }
    
    func beginEditing () {
        if EXOTCSafetyCheckVm.manager.checkOTCBasicRequire(self) {
            self.navigation.hideRightItems()
            self.canEdit(true)
        }
    }
    
    func hideIFCS(_ hide:Bool ) {
        ifscCodeA.isHidden = hide
        ifscCodeB.isHidden = hide
    }
    
    func hideUpload(_ hide:Bool ) {
        uploadView.isHidden = hide
    }
    
    func canEdit(_ editable:Bool) {
        footer.confirmBtn.setTitle("common_text_btnConfirm".localized(), for: .normal)
        accountView.input.isUserInteractionEnabled = editable
        ifscCodeA.input.isUserInteractionEnabled = editable
        ifscCodeB.input.isUserInteractionEnabled = editable
        footer.isHidden = !editable
        uploadView.setUserEnabled(editable)
        if editable == false{
            self.navigation.hideRightItems()
        }
    }
    
    func bindOldData(_ model:EXOTCPaymentListModel){
        uploader.imgUrl = model.qrcodeImg
        accountView.input.setText(text: model.account)
        uploadView.setImgUrl(iconUrl:model.qrcodeImg)
        if isUnionPay() || isIMPS() {
            ifscCodeA.input.setText(text: model.bankName)
            ifscCodeB.input.setText(text: model.bankOfDeposit)
        }
    }
    
    func handlePayment() {
        
        if let oldPayModel = self.oldPaymentModel {
            self.canEdit(false)
            self.bindOldData(oldPayModel)
            self.iconUrl = oldPayModel.qrcodeImg
            self.navigation.configRightItems(["address_action_delete".localized()], isImageName:false)
        }
        
        nameView.setTitle("otc_text_payee".localized())
        
        if !(UserInfoEntity.sharedInstance().canEditOtcRealName()) {
            nameView.disableTouch()
        }
        let userName = UserInfoEntity.sharedInstance().realName
        self.userRealName = userName
        nameView.setContent(userName)
        
        uploadView.setTitle("otc_text_paymentQRcode".localized())
        let key = payTypeKey
        hideIFCS(true)
        hideUpload(true)
        if key == OTCPayInfoType.UnionPay.rawValue {
            hideIFCS(false)
            nameView.setTitle("otc_text_bankCardOwnerName".localized())
            accountView.setTitle("otc_text_bankCardNumber".localized())
            accountView.setPlaceHolder("otc_tip_bankcardBelong".localized())
            ifscCodeA.setTitle("otc_text_bankName".localized())
            ifscCodeA.setPlaceHolder("otc_tip_pleaseInputBankName".localized())
            ifscCodeB.setTitle("otc_text_bankBranchName".localized())
            ifscCodeB.setPlaceHolder("otc_tip_pleaseInputBankbranchName".localized())
            self.navigation.setTitle(title: "otc_text_bindBankCard".localized())
        }else if key == OTCPayInfoType.AliPay.rawValue {
            hideUpload(false)
            accountView.setTitle("alipay_text_account".localized())
            accountView.setPlaceHolder("otc_tip_pleaseInputAlipayAccount".localized())
            self.navigation.setTitle(title: "alipay_text_bind".localized())
            uploadView.setTitle("alipay_text_qrcode".localized())
        }else if key == OTCPayInfoType.WxPay.rawValue {
            hideUpload(false)
            accountView.setTitle("otc_text_wxID".localized())
            accountView.setPlaceHolder("otc_tip_pleaseInputWxID".localized())
            uploadView.setTitle("wxpay_text_qrcode".localized())
            self.navigation.setTitle(title: "wxpay_text_bind".localized())
        }else if key == OTCPayInfoType.Paypal.rawValue {
            self.navigation.setTitle(title:"Paypal".localized())
            accountView.input.forceInputLenth = true
            accountView.input.maxLenth = 64
            accountView.setTitle("otc_text_paypal".localized())
            accountView.setPlaceHolder("otc_tip_pleaseInputAcount".localized())
        }else if key == OTCPayInfoType.WestUnio.rawValue {
            self.navigation.setTitle(title: "otc_text_westUnion".localized())
            accountView.setTitle("otc_tip_pleaseInputWestUnio".localized())
            accountView.setPlaceHolder("otc_tip_pleaseInputMoneyAddress".localized())
        }else if key == OTCPayInfoType.SWIFT.rawValue {
            self.navigation.setTitle(title: "otc_text_SWIFT".localized())
            accountView.setTitle("otc_tip_pleaseInputSWIFT".localized())
            accountView.setPlaceHolder("otc_tip_pleaseInputMoneyAddress".localized())
        }else if key == OTCPayInfoType.PayNow.rawValue {
            self.navigation.setTitle(title: "PayNow".localized())
            accountView.setTitle("otc_text_payNow".localized())
            accountView.setPlaceHolder("otc_tip_pleaseInputAcount".localized())
        }else if key == OTCPayInfoType.Paytm.rawValue {
            hideUpload(false)
            self.navigation.setTitle(title: "Paytm".localized())
            accountView.setTitle("otc_text_paytm".localized())
            accountView.setPlaceHolder("otc_tip_pleaseInputAcount".localized())
        }else if key == OTCPayInfoType.QIWI.rawValue {
            self.navigation.setTitle(title: "QIWI".localized())
            accountView.setTitle("otc_text_QIWI".localized())
            accountView.setPlaceHolder("otc_tip_pleaseInputAcount".localized())
        }else if key == OTCPayInfoType.Interact.rawValue {
            self.navigation.setTitle(title: "Interact".localized())
            accountView.setTitle("otc_text_Interact".localized())
            accountView.setPlaceHolder("otc_tip_pleaseInputAcount".localized())
        }else if key == OTCPayInfoType.IMPS.rawValue {
            self.navigation.setTitle(title: "IMPS".localized())
            accountView.setTitle("otc_text_bankCardNumber".localized())
            accountView.setPlaceHolder("otc_tip_pleaseInputAcount".localized())
            ifscCodeA.setTitle("otc_text_IFSC".localized())
            ifscCodeA.setPlaceHolder("otc_tip_plieaseInputIFSC".localized())
            ifscCodeB.setTitle("otc_text_IFSC".localized())
            ifscCodeB.setPlaceHolder("otc_tip_plieaseInputIFSC".localized())
            hideIFCS(false)
            hideUpload(false)
        }else if key == OTCPayInfoType.UPI.rawValue {
            accountView.setTitle("otc_text_UPI".localized())
            accountView.setPlaceHolder("otc_tip_pleaseInputAcount".localized())
            self.navigation.setTitle(title: "UPI".localized())
            hideUpload(false)
        }
        hideIFCS(false)
    }
    
    func largeTitleValueChanged(height: CGFloat) {
        topConstraint.constant = height
    }
    
}

extension EXOTCPaymentAddNewVc {
    
    func isUnionPay() -> Bool{
        return payTypeKey == OTCPayInfoType.UnionPay.rawValue
    }
    
    //No account for Western Union
    func isNotWestUnio() -> Bool {
        return payTypeKey != OTCPayInfoType.WestUnio.rawValue
    }
    
    func isQRSupport() -> Bool {
        let key = payTypeKey
        
        if key == OTCPayInfoType.AliPay.rawValue ||
            key == OTCPayInfoType.WxPay.rawValue ||
            key == OTCPayInfoType.Paytm.rawValue ||
            key == OTCPayInfoType.IMPS.rawValue ||
            key == OTCPayInfoType.UPI.rawValue {
            return true
        }
        return false
    }
    
    func isIMPS() -> Bool {
        return payTypeKey == OTCPayInfoType.IMPS.rawValue
    }
}

extension EXOTCPaymentAddNewVc {
    
    func handleUploadAction() {
        if let icon = self.iconUrl {
            EXAlert.showPhotoBrowser(urls: [icon])
        }else {
            let sheet = EXOldActionSheetView()
            sheet.configButtonTitles(buttons: ["noun_camera_takephoto".localized(),"noun_camera_takeAlbum".localized()])
            sheet.actionIdxCallback = {[weak self] tag in
                self?.handlePhoto(tag)
            }
            EXAlert.showSheet(sheetView:sheet)
        }
    }
    
    func handlePhoto(_ sheetIdx:Int) {
        pickerController.delegate = self
        if sheetIdx == 0 {
            pickerController.selectImageFromCameraSuccess({[weak self] (picker) in
                guard let `self` = self else {return}
                self.presentF(picker, animated: true, completion: nil)
                },Fail: {
                    
            })
        }else if sheetIdx == 1 {
            pickerController.selectImageFromAlbumSuccess({[weak self] (picker) in
                guard let `self` = self else {return}
                self.presentF(picker, animated: true, completion: nil)
                },Fail: {
                    
            })
        }
    }
}

extension EXOTCPaymentAddNewVc {
    
    @objc func confirmBtnAction() {
        if payTypeKey.isEmpty {
            return
        }
        submitAddNewPayment()
    }
    
    func submitAddNewPayment() {
        smsService.getOTCAddPaymentService()
        smsService.onServiceFinishCallback = {[weak self] dict in
            self?.verifiedSafety(dict)
        }
    }
    
    func verifiedSafety(_ info:[String:String]) {
        if self.userRealName.count == 0 {
            EXAlert.showWarning(msg: "common_tip_inputRealName".localized())
            return
        }

        if let oldModel = self.oldPaymentModel { //edit
//            let userName = UserInfoEntity.sharedInstance().realName
            otcApi.rx.request(.otcPaymentUpdate(paymentID: oldModel.id,
                                                userName: userRealName,
                                                paymentKey:oldModel.payment,
                                                account: account,
                                                qrcodeImg: self.iconUrl,
                                                bankName: self.bankOrIFCS,
                                                bankOfDeposit: self.subBankOrIFCSB,
                                                smsAuthCode: info["smsAuthCode"],
                                                googleCode: info["googleCode"]))
                .MJObjectMap(EXVoidModel.self)
                .subscribe{[weak self] event in
                    switch event {
                    case .success(_):
                        EXAlert.showSuccess(msg: "common_tip_editSuccess".localized())
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            self?.navigationController?.popViewController(animated: true)
                        }
                        break
                    case .failure(_):
                        break
                    }
            }.disposed(by: self.disposeBag)
        }else {//Add
            otcApi.rx.request(.otcPaymentAdd(payementKey: payTypeKey,
                                             userName: userRealName,
                                             account: account,
                                             qrcodeImg: self.iconUrl,
                                             bankName: self.bankOrIFCS,
                                             bankOfDeposit: self.subBankOrIFCSB,
                                             smsAuthCode:info["smsAuthCode"],
                                             googleCode: info["googleCode"],
                                             ifscCode:"ifscCode",
                                             accountType: "accountType",
                                             email: "email",
                                             cci: "cci"
                                            ))
                .MJObjectMap(EXVoidModel.self)
                .subscribe{[weak self] event in
                    guard let strongSelf = self else {return}
                    switch event {
                    case .success(_):
                        NotificationCenter.default.post(name: NSNotification.Name.init("AddPayMentSuccessNotification"), object: nil)
                        EXAlert.showSuccess(msg: "common_tip_addSuccess".localized())
                        strongSelf.onPaymentSuccess?(strongSelf.payTypeKey)
                        strongSelf.navigationController?.popViewController(animated: true)
                        break
                    case .failure(_):
                        break
                    }
            }.disposed(by: self.disposeBag)
        }
    }
}

extension EXOTCPaymentAddNewVc : EXOldImagePickerDelegate {
    
    func selectImageFinished(_ image: UIImage) {
        self.selectedImg = image
        uploader.uploadImage(img: image,useBase64: true)
    }
}


