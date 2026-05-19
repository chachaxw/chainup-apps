//
//  EXOTCNewPaymentAddNewVC.swift
//  Chainup
//
//  Created by cwd on 2022/6/7.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import EXKit

enum PaymentType: Int{
    case input
    case uploadImage
}
/*
name
ID number
Bank Name
Account Type
Account
Email
 
Cross bank transfer code
 
 */
enum PaymentSumitKeyType: Int{
    case userRealName = 0//name
    case idNumber //ID number
    case bankName //Bank Name
    case bankBranch //bank branch 
    case acountType //Account Type
    case acount //Account
    case email //Email
    case code //Cross bank transfer code
    case image //Upload images
}

class PayConfigItem {
    var type:PaymentType = .input
    var submitKey: PaymentSumitKeyType = .userRealName
    var title = ""
    var placeHolder = ""
    var value = ""
    var forceInputLenth = false
    var maxLenth = 0
    var canEdit = true
    
    
}
class PayMentItemCell: EXBaseCell{
    var textDidChange: EXComVoidBlock?
    override func prepareForReuse(){
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
    }
    var model = PayConfigItem() {
        didSet{
            inputV.isUserInteractionEnabled = model.canEdit
            inputV.setTitle(model.title)
            inputV.setContent(model.value)
            inputV.setPlaceHolder(model.placeHolder)
            if model.maxLenth > 0 {
                inputV.input.forceInputLenth = true
                inputV.input.maxLenth = model.maxLenth
            }else{
                inputV.input.forceInputLenth = false
            }
        }
        
    }
    

    lazy var inputV: EXCommonInputView = {
        let v = EXCommonInputView()
        return v
    }()
    override func setUpView() {
        self.contentView.addSubview(inputV)
        inputV.snp_makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    override func setData() {
        self.inputV.input.textfieldValueChangeBlock = { [weak self] text in
            self?.model.value = text
            print("type=\(self?.model.submitKey) text = \(text)")
            self?.textDidChange?()
        }
//        v.input.input.rx.text.orEmpty.asObservable()
//            .distinctUntilChanged()
//            .subscribe(onNext: {[weak self] text in
//                self?.model.value = text
//                print("type=\(self?.model.submitKey) text = \(text)")
//            }).disposed(by: self.disposeBag)
//
    }
}
class PayMentUploadImageItemCell: EXBaseCell{
    
    var model = PayConfigItem() {
        didSet{
            upload.setTitle(model.title)
            upload.setUserEnabled(model.canEdit)
        }
    }
    lazy var upload: EXPaymentUploadView = {
        let v = EXPaymentUploadView()
        return v
    }()
    override func setUpView() {
        self.contentView.addSubview(upload)
        upload.snp_makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
}
class EXOTCNewPaymentAddNewVC: BaseVC,NavigationPlugin,EXNavigationPresenter {
    typealias AddSuccessCallback = (String)->()
    var onPaymentSuccess:AddSuccessCallback?
    
    typealias DeleteCallback = (Int) -> ()
    var deleteCallback : DeleteCallback?
    
    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: self.tableView, presenter: self)
        return nav
    }()
    var navTitle: String = ""
    var tag = 1000
    var canEdit = false
    var dataItems = [PayConfigItem]()
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
    var inputItemsAry = [PayMentItemCell]()
    lazy var footer: EXCoinWithdrawFooter = {
        let v = EXCoinWithdrawFooter()
        return v
    }()
    lazy var uploadView: EXPaymentUploadView = {
        let v = EXPaymentUploadView()
        return v
    }()
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = UIColor.ThemeView.bg
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
//        tableView.rowHeight = 100
        tableView.rowHeight = 74
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView.adjustBehaviorDisable()
        tableView.register(cellType: PayMentItemCell.self)
        tableView.register(cellType: PayMentUploadImageItemCell.self)
        
        return tableView
    }()
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configSubView()
        handlePayment()
        configNavigation()
        configPhotoView()
        handleFooterView()
//        handleDataBinding() //Processed in cell
        canEdit(self.canEdit)
    }
    func configSubView(){
        
        self.view.addSubview(tableView)
        self.view.addSubview(footer)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(self.navigation.snp_bottom)
            make.left.right.equalToSuperview()
        }
        footer.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp_bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(112)
            make.bottom.equalToSuperview().offset(-TABBAR_BOTTOM)
        }
    }
    func configPhotoView() {
        
//        uploadView.onImageRemovedCallback = {[weak self] in
//            self?.iconUrl = nil
//        }
//
//        uploadView.photoImg.tapBtn.rx.tap.asObservable()
//            .throttle(1, scheduler: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] _ in
//                guard let `self` = self else { return }
//                self.handleUploadAction()
//            }).disposed(by: self.disposeBag)
        
        uploader.rx_imgUrl.skip(1)
            .subscribe(onNext: { [weak self] imgUrl in
                guard let `self` = self else { return }
                if imgUrl == "" { //Upload failed
                    self.iconUrl = nil
                    self.selectedImg  = nil
                    return
                }
                self.iconUrl = imgUrl
                if let currentimg = self.selectedImg {
                    EXToast.hideProgressHUD()
                    self.uploadView.setImg(icon: currentimg)
                }
                self.uploadView.setImgUrl(iconUrl: imgUrl)
                self.addObserveBtnEnble()
            }).disposed(by: self.disposeBag)
        
    }
    
    func handleFooterView() {
        footer.hideFooterTitle()
        footer.confirmBtn.setTitle("kyc_action_submit".localized(), for: .normal)
        footer.confirmBtn.addTarget(self, action: #selector(confirmBtnAction), for: .touchUpInside)
        self.addObserveBtnEnble()

    }
    func addObserveBtnEnble(){
        var enble = true
        for data in dataItems{
            print("data.submitKey = >\(data.submitKey) value =\(data.value)")
            if data.submitKey == .image {
                if self.iconUrl == nil{ //Simple processing of images
                    enble = false
                    break
                }
            }else{
                if data.value == ""{
                    enble = false
                    break
                }
            }
        }
        footer.confirmBtn.isEnabled = enble
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
//        EXAlert.showSuccess(msg: "b2c_text_deleteSuccess".localized())
        self.navigationController?.popViewController(animated: true)
    }
    
    func beginEditing () {
        if EXOTCSafetyCheckVm.manager.checkOTCBasicRequire(self) {
            self.navigation.hideRightItems()
            self.canEdit(true)
        }
    }
    
    
    func canEdit(_ editable:Bool) {
        if editable == false{
            self.navigation.hideRightItems()
            for item in dataItems{
                if item.submitKey == .userRealName {
                    continue //Name not allowed to be changed
                }
                item.canEdit = canEdit
            }
        }
        footer.isHidden = !editable
    }
    
    
    func handlePayment() {
        var naviTitle =  navTitle
        var items = [PayConfigItem]()
        //name
        let name = PayConfigItem()
        name.title = "otc_5".localized()
        name.value = UserInfoEntity.sharedInstance().realName
        name.submitKey = .userRealName
        
        //Payment code
        let upLoadImg = PayConfigItem()
        upLoadImg.title = "otc_text_paymentQRcode".localized()
        upLoadImg.submitKey = .image
        
        //Account
        let accountItem = PayConfigItem()
        accountItem.title = "otc_6".localized()
        accountItem.placeHolder = "otc_6".localized()
        accountItem.submitKey = .acount
        
        //Bank Name
        let bank = PayConfigItem()
        bank.title = "otc_7".localized()
        bank.placeHolder = "otc_7".localized()
        bank.submitKey = .bankName
        
        //Bank Branch Name
        let bankbranch = PayConfigItem()
        bankbranch.title = "otc_text_bankBranchName".localized()
        bankbranch.placeHolder = "otc_tip_pleaseInputBankbranchName".localized()
        bankbranch.submitKey = .bankBranch
        
        //ID number
        let idnumb = PayConfigItem()
        idnumb.title = "otc_1".localized()
        idnumb.placeHolder = "otc_1".localized()
        idnumb.submitKey = .idNumber
        
        //account type
        let accpuntType = PayConfigItem()
        accpuntType.title = "otc_2".localized()
        accpuntType.placeHolder = "otc_2".localized()
        accpuntType.submitKey = .acountType
        
        //Email
        let email = PayConfigItem()
        email.title = "otc_3".localized()
        email.placeHolder = "otc_3".localized()
        email.submitKey = .email
        
        
        //Cross bank transfer
        let code = PayConfigItem()
        code.title = "otc_4".localized()
        code.placeHolder = "otc_4".localized()
        code.submitKey = .code
        
        
        if !(UserInfoEntity.sharedInstance().canEditOtcRealName()) {
//            nameView.disableTouch()
            name.canEdit = false
        }
        
        
        let key = payTypeKey
        
        if key == OTCPayInfoType.UnionPay.rawValue {
            accountItem.title = "otc_text_bankCardNumber".localized()
            accountItem.placeHolder = "otc_tip_pleaseInputAcount".localized()
            items = [name,accountItem,bank,bankbranch]
            naviTitle = "otc_text_bindBankCard".localized()
        }else if key == OTCPayInfoType.AliPay.rawValue {
            accountItem.title = "alipay_text_account".localized()
            accountItem.placeHolder = "otc_tip_pleaseInputAlipayAccount".localized()
            upLoadImg.title = "alipay_text_qrcode".localized()
            items = [name,accountItem,upLoadImg]
            naviTitle = "alipay_text_qrcode".localized()
        }else if key == OTCPayInfoType.WxPay.rawValue {
            accountItem.title = "otc_text_wxID".localized()
            accountItem.placeHolder = "otc_tip_pleaseInputWxID".localized()
            upLoadImg.title = "wxpay_text_qrcode".localized()
            naviTitle = "wxpay_text_bind".localized()
            items = [name,accountItem,upLoadImg]
        }else if key == OTCPayInfoType.Paypal.rawValue {
            naviTitle = "Paypal".localized()
            accountItem.forceInputLenth = true
            accountItem.maxLenth = 64
            accountItem.title = "otc_text_paypal".localized()
            accountItem.placeHolder = "otc_tip_pleaseInputAcount".localized()
            items = [name,accountItem]
        }else if key == OTCPayInfoType.WestUnio.rawValue {
            naviTitle = "otc_text_westUnion".localized()
            //self.navigation.setTitle(title: "otc_text_westUnion".localized())
            accountItem.title = "otc_tip_pleaseInputWestUnio".localized()
            accountItem.placeHolder = "otc_tip_pleaseInputMoneyAddress".localized()
            items = [name,accountItem]
        }else if key == OTCPayInfoType.SWIFT.rawValue {
            naviTitle = "otc_text_SWIFT".localized()
            accountItem.title = "otc_tip_pleaseInputSWIFT".localized()
            accountItem.placeHolder = "otc_tip_pleaseInputMoneyAddress".localized()
            items = [name,accountItem]
        }else if key == OTCPayInfoType.PayNow.rawValue {
            naviTitle = "PayNow".localized()
            accountItem.title = "otc_text_payNow".localized()
            accountItem.placeHolder = "otc_tip_pleaseInputAcount".localized()
            items = [name,accountItem]
        }else if key == OTCPayInfoType.Paytm.rawValue {
            naviTitle = "Paytm".localized()
            accountItem.title = "otc_text_paytm".localized()
            accountItem.placeHolder = "otc_tip_pleaseInputAcount".localized()
            items = [name,accountItem,upLoadImg]
        }else if key == OTCPayInfoType.QIWI.rawValue {
            naviTitle = "QIWI".localized()
            accountItem.title = "otc_text_QIWI".localized()
            accountItem.placeHolder = "otc_tip_pleaseInputAcount".localized()
            items = [name,accountItem]
        
        }else if key == OTCPayInfoType.Interact.rawValue {
            naviTitle = "Interact".localized()
            accountItem.title = "otc_text_Interact".localized()
            accountItem.placeHolder = "otc_tip_pleaseInputAcount".localized()
            items = [name,accountItem]
            
        }else if key == OTCPayInfoType.IMPS.rawValue {
            naviTitle = "IMPS".localized()
            accountItem.title = "otc_text_bankCardNumber".localized()
            accountItem.placeHolder = "otc_tip_pleaseInputAcount".localized()
            bank.title = "otc_text_IFSC".localized()
            bank.placeHolder = "otc_tip_plieaseInputIFSC".localized()
            bankbranch.title = "otc_text_IFSC".localized()
            bankbranch.placeHolder = "otc_tip_plieaseInputIFSC".localized()
            items = [name,accountItem,bank,bankbranch,upLoadImg]
        }else if key == OTCPayInfoType.UPI.rawValue {
            naviTitle = "UPI".localized()
            accountItem.title = "otc_text_UPI".localized()
            accountItem.placeHolder = "otc_tip_pleaseInputAcount".localized()
            items = [name,accountItem,upLoadImg]
        }else if key == OTCPayInfoType.ZHILI.rawValue {
            items = [name,idnumb,bank,accpuntType,accountItem,email]
        }else if key == OTCPayInfoType.MILU.rawValue {
            items = [name,bank,accountItem,code]
        }else if key == OTCPayInfoType.AGENTING.rawValue {
            items = [name,accountItem,accpuntType,idnumb,bank]
        }else if key == OTCPayInfoType.YAPE.rawValue {
            items = [name,accountItem]
        }else if key == OTCPayInfoType.PlIN.rawValue {
            items = [name,accountItem]
        }else{
            items = [name,accountItem,email]
        }
        for con in items{
            if con.submitKey != .image{
                con.forceInputLenth = true
                con.maxLenth = 100
            }
        }

        self.navigation.setTitle(title: naviTitle)
                    
       
        
        if let oldPayModel = self.oldPaymentModel {
            name.value = oldPayModel.userName
            uploader.imgUrl = oldPayModel.qrcodeImg
            accountItem.value = oldPayModel.account
            bank.value = oldPayModel.bankName
            bankbranch.value = oldPayModel.bankOfDeposit
            idnumb.value = oldPayModel.idNumber
            accpuntType.value = oldPayModel.accountType
            email.value = oldPayModel.email
            code.value = oldPayModel.cci

            if key == OTCPayInfoType.WestUnio.rawValue{
                accountItem.value = oldPayModel.remittanceInformation
            }
            
            
            self.iconUrl = oldPayModel.qrcodeImg
            self.navigation.configRightItems(["address_action_delete".localized()], isImageName:false)
        }
        dataItems = items
        tableView.reloadData()
 
    }
    
}

extension EXOTCNewPaymentAddNewVC {
    
    func isUnionPay() -> Bool{
        return payTypeKey == OTCPayInfoType.UnionPay.rawValue
    }
    
    //No account for Western Union
    func isNotWestUnio() -> Bool {
        return payTypeKey != OTCPayInfoType.WestUnio.rawValue
    }
    
}

extension EXOTCNewPaymentAddNewVC {
    
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

extension EXOTCNewPaymentAddNewVC {
    
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

        var accountType: String? = nil
        var idNumber: String? = nil
        var email: String? = nil
        var code: String? = nil
        for input in dataItems{
            if input.submitKey == .userRealName {
                userRealName  = input.value
            }else if input.submitKey == .acount{
                account = input.value
            }else if input.submitKey == .bankName{
                self.bankOrIFCS = input.value
            }else if input.submitKey == .bankBranch{
                self.subBankOrIFCSB = input.value
            }else if input.submitKey == .acountType {
                accountType = input.value
            }else if input.submitKey == .idNumber{
                idNumber = input.value
            }else if input.submitKey == .email{
                email = input.value
            }else if input.submitKey == .code{
                code = input.value
            }
        }
    
        self.footer.confirmBtn.isUserInteractionEnabled = false
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
                                                googleCode: info["googleCode"],
                                                ifscCode: nil,
                                                accountType: accountType,
                                                email: email,
                                                cci: code,
                                                idNumber:idNumber
                                               ))
                .MJObjectMap(EXVoidModel.self)
                .subscribe{[weak self] event in
                    switch event {
                    case .success(_):
                        EXAlert.showSuccess(msg: "common_tip_editSuccess".localized())
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self?.customPop()
                        }
                      
                        break
                    case .failure(_):
                        self?.footer.confirmBtn.isUserInteractionEnabled = true
                        break
                    }
            }.disposed(by: self.disposeBag)
        }else {//Edit New
            otcApi.rx.request(.otcPaymentAdd(payementKey: payTypeKey,
                                             userName: userRealName,
                                             account: account,
                                             qrcodeImg: self.iconUrl,
                                             bankName: self.bankOrIFCS,
                                             bankOfDeposit: self.subBankOrIFCSB,
                                             smsAuthCode:info["smsAuthCode"],
                                             googleCode: info["googleCode"],
                                             ifscCode: nil,
                                             accountType: accountType,
                                             email: email,
                                             cci: code,
                                             idNumber:idNumber
                                            ))
                .MJObjectMap(EXVoidModel.self)
                .subscribe{[weak self] event in
                    guard let strongSelf = self else {return}
                    switch event {
                    case .success(_):
                        NotificationCenter.default.post(name: NSNotification.Name.init("AddPayMentSuccessNotification"), object: nil)
                        EXAlert.showSuccess(msg: "common_tip_addSuccess".localized())
                        strongSelf.onPaymentSuccess?(strongSelf.payTypeKey)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            strongSelf.customPop()
                        }
                        break
                    case .failure(_):
                        strongSelf.footer.confirmBtn.isUserInteractionEnabled = true
                        break
                    }
            }.disposed(by: self.disposeBag)
        }
    }
}

extension EXOTCNewPaymentAddNewVC : EXOldImagePickerDelegate {
    func customPop(){
        if let vcs = self.navigationController?.viewControllers{
            for item in vcs{
                if item.isKind(of: EXOTCAvailablePaymentVc.self){
                    self.navigationController?.popToViewController(item, animated: true)
                }
            }
        }
    }
    func selectImageFinished(_ image: UIImage) {
        self.selectedImg = image
        self.view.makeLoading()
        uploader.uploadImage(img: image,useBase64: true)
    }
}

extension EXOTCNewPaymentAddNewVC: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item  = dataItems[indexPath.row]
        if item.submitKey == .image {
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: PayMentUploadImageItemCell.self)
            
            cell.upload.onImageRemovedCallback = {[weak self] in
                self?.iconUrl = nil
                self?.addObserveBtnEnble()
            }
         
            cell.upload.photoImg.tapBtn.rx.tap.asObservable()
                .throttle(.seconds(1), scheduler: MainScheduler.instance)
                .subscribe(onNext: { [weak self] _ in
                    guard let `self` = self else { return }
                   // print("tapBtn XXXX")
                    self.handleUploadAction()
                }).disposed(by: self.disposeBag)
            self.uploadView = cell.upload
            if self.iconUrl != nil {
                cell.upload.setImgUrl(iconUrl: self.iconUrl!)
            }
            cell.model = item
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: PayMentItemCell.self)
            cell.model = item
            cell.textDidChange = { [weak self]  in
                                self?.addObserveBtnEnble()
                            }
//            cell.inputV.input.textfieldValueChangeBlock = { [weak self] str in
//                self?.addObserveBtnEnble()
//            }
            return cell
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item  = dataItems[indexPath.row]
        if item.submitKey == .image {
            return 154
        }else{
            return 74
        }
    }
}

