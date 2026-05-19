//
//  EXCoinWithdrawVc.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/5.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import EXKit

class EXCoinWithdrawVc: BaseVC,StoryBoardLoadable,NavigationPlugin {
    
    @IBOutlet weak var linkNameBackViewTopCon: NSLayoutConstraint!
    @IBOutlet weak var linkNameBackViewHCon: NSLayoutConstraint!
    @IBOutlet weak var linkNameBackView: UIView!
    @IBOutlet var coinSelector: EXCoinSelectorView!
    @IBOutlet var withdrawContainer: UIStackView!
    @IBOutlet var hintTitle: UILabel!
    @IBOutlet var hintContent: UILabel!
    @IBOutlet weak var canWithdrawLabel: UILabel!
    @IBOutlet weak var limitLabel: UILabel!
    @IBOutlet weak var tipView: UIView!
    
    @IBOutlet weak var v1: UILabel!
    @IBOutlet weak var v2: UILabel!
    @IBOutlet var withdrawScroll: UIScrollView!
    @IBOutlet var topConstraint: NSLayoutConstraint!
    @IBOutlet var footerView: EXCoinWithdrawFooter!
    var followCoinModel : EXFollowCoinModel = EXFollowCoinModel()
    var hasFollowCoin = false//Is there a sub chain
    var selectFollowCoinEntity = CoinListEntity()
    
    var coinModel: EXAccountCoinMapItem = EXAccountCoinMapItem()
    var allCoins: [EXAccountCoinMapItem]?
    var emptyAddressStyle:Bool = true
    var confirmAddressItem:EXWithDrawConfirmModel = EXWithDrawConfirmModel()
    var totalBalanceSymbol: String?
    var amount:String = ""

    var fee:String = ""
    var followCoinName = ""
//    @IBOutlet var recentlyAddress : EXCoinWithdrawRecentlyAddress!
    @IBOutlet var amountView : EXCoinWithdrawAmountView!
    @IBOutlet var feeView : EXCoinWithdrawFeeView!
    @IBOutlet var emptyAddress: EXCoinWithDrawEmptyAddress!
    @IBOutlet var emptyTagView: EXCoinWithDrawEmptyTagView!
    @IBOutlet var emptyRemarkView: EXCoinWithDrawEmptyRemark!
//    @IBOutlet var recentAddressHeight: NSLayoutConstraint!
    
    
    
    lazy var withdrawMaxTitleLabel: UILabel = {
        let label = UILabel(text:"", font: .Ex.regular(12), textColor: .Ex.text3 , alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    lazy var withdrawMaxValue: UILabel = {
        let label = UILabel(text:"", font: .Ex.regular(12), textColor: .Ex.text1 , alignment: NSTextAlignment.right)
        label.ext_UseAutoLayout()
        return label
    }()
    
    
    
    var needCheckList: [EXBaseField] = []
    
    var coinModelRelay :BehaviorRelay<EXAccountCoinMapItem?> = BehaviorRelay(value: nil)
    
    var rx_addressItem = BehaviorRelay<AddressItem?>(value:nil)
    
    var selectAddress :AddressItem? {
        get {
            return rx_addressItem.value
        }
        set {
            rx_addressItem.accept(newValue)
        }
    }
    
    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: self.withdrawScroll, presenter: self)
        nav.isLastNavigationStyle = true
        return nav
    }()
    
    
    func handleNavigation() {
        self.navigation.setTitle(title: "assets_action_withdraw".localized())
        navigation.configRightItems(["withdraw_action_withdrawHistory".localized()],isImageName: false)
        
        navigation.rightItemCallback = {[weak self] tag in
            self?.handleRechargeHistory()
        }
        
        navigation.customBack = true
        navigation.customBackCallback = {[weak self] in
            self?.handleBack()
        }
    }
    
    func handleBack() {
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
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func handleRechargeHistory(){
        
        let chargeHistory = EXChargeHistoryVc.instanceFromStoryboard(name: StoryBoardNameAsset)
        chargeHistory.historyScene = .withdraw
        chargeHistory.symbol = self.coinModel.coinName
        self.navigationController?.pushViewController(chargeHistory, animated: true)
    }
    
    func hasRecentlyAddress() ->Bool {
        
        if self.followCoinModel.userWithdrawAddrList.count > 0 {
            return true
        }
        return false
    }
    
    func handleContainers() {
        emptyAddress.withdrawAddress.addressListPopBack = {[weak self] in
            self?.chooseAddressList()
        }
        emptyAddress.onQRScanCallback = {[weak self] in
            self?.scanQrCodeAction()
        }
        emptyAddress.onAddressBookCallback = {[weak self] in
            self?.addressBookAction()
        }

    }
    
    func updateRecentAddress(_ atAddressItem:AddressItem) {
        if emptyAddressStyle == true {
            self.showEmptyDataStyle(false)
        }
        self.selectAddress = atAddressItem
        let coinAddress = atAddressItem.address
        if let _ = coinAddress.range(of: "_") {
            let addressAry = coinAddress.components(separatedBy: "_")
            if addressAry.count == 2 {
                emptyAddress.withdrawAddress.setText(text: atAddressItem.addressShow())
                emptyTagView.tagView.setText(text: atAddressItem.tagShow())
            }
        }else {
            emptyAddress.withdrawAddress.setText(text: atAddressItem.addressShow())
        }
        
    }
    
    func checkRecentlyAddressDeleted(_ deletedAddress:AddressItem) {
        guard let addressItem = self.selectAddress else {return}
        if emptyAddressStyle {
            return
        }
        if addressItem.id == deletedAddress.id {
            var rmIdx = -1
            
            for (idx,item) in self.followCoinModel.userWithdrawAddrList.enumerated() {
                if item.id == deletedAddress.id {
                    rmIdx = idx
                    break
                }
            }
            
            if rmIdx >= 0 , self.followCoinModel.userWithdrawAddrList.count > rmIdx {
                self.followCoinModel.userWithdrawAddrList.remove(at: rmIdx)
            }
            self.switchToUseNewAddress()
        }
    }
    
    func configAddressContainer() {
        
        if hasRecentlyAddress() {
//            recentlyAddress.isHidden = false
//            recentAddressHeight.constant = self.tagNeeded() ? 120 : 94
            self.showEmptyDataStyle(false)
        }else {
//            recentlyAddress.isHidden = true
            self.showEmptyDataStyle(true)
        }
    }
    
    func showEmptyDataStyle(_ show:Bool) {
        emptyAddressStyle = show
        if show {
            //FollowcoinName does not have a sub chain followcoinname as the main chain address
            emptyTagView.isHidden = !self.tagNeeded()
        }else {
            emptyTagView.isHidden = true
        }
        emptyTagView.isHidden = !self.tagNeeded()
//        emptyAddress.isHidden = !show
//        emptyRemarkView.isHidden = !show
        emptyAddress.withdrawAddress.input.sendActions(for: .editingChanged)
    }
    
    @objc func switchToUseNewAddress() {
        self.selectAddress = nil
//        self.recentlyAddress.isHidden = true
        self.showEmptyDataStyle(true)
    }
    
    func handleHintLabels() {
        self.canWithdrawLabel.textColor = .Ex.text2
        self.canWithdrawLabel.font = .Ex.regular(12)
        self.canWithdrawLabel.text = "kyc_withdrawal_amount".localized()
        self.v1.textColor = .Ex.text1
        self.v1.font = UIFont.Ex.regular(12)
        self.v1.textAlignment = .right
      
        self.limitLabel.textColor = .Ex.text2
        self.limitLabel.font = .Ex.regular(12)
        self.limitLabel.text = "kyc_withdrawal_24h".localized()
        self.v2.textColor = .Ex.text1
        self.v2.font = UIFont.Ex.regular(12)
        self.v2.textAlignment = .right
        
        hintTitle.font = .Ex.regular(14)
        hintTitle.textColor = .Ex.text2
        hintContent.font = .Ex.regular(12)
        hintContent.textColor = .Ex.text2
        hintTitle.text = "withdraw_tip_notice".localized()
        
        let contentD = "withdraw_safety_tips".localized()
        let B = "charge_chargeAlert_contentB".localized()
        var contentB = ""
        if followCoinModel.showErr {
             contentB = followCoinModel.withdraw_max.removeTrailingZeros()
        }else {
             contentB =  followCoinModel.withdraw_max.formatAmountUseDecimal(amountView.amountInputView.decimal,holdZero: false) + " " + coinModel.coinName.aliasName()
        }
        self.withdrawMaxTitleLabel.font = .Ex.regular(12)
        self.withdrawMaxTitleLabel.textColor = .Ex.text2
        self.withdrawMaxTitleLabel.text =  B
        self.withdrawMaxValue.text = contentB
        
        hintContent.attributedText = contentD.lineSpacingString(font: UIFont.Ex.regular(12), color: UIColor.Ex.text2, lineSpacing: 8, textAligment: .left)
    }
    
    func handleRxBindings() {
        feeView.feeInputView.input.rx.text.orEmpty.asObservable()
        .distinctUntilChanged()
        .subscribe(onNext: { [weak self] fee in
            guard let `self` = self else { return }
            self.fee = fee
        }).disposed(by: self.disposeBag)
        
        amountView.amountInputView.input.rx.text.orEmpty.asObservable()
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] amount in
                guard let `self` = self else { return }
                self.amount = amount
            }).disposed(by: self.disposeBag)
        
        
        let address =  emptyAddress.withdrawAddress.input.rx.text.orEmpty
        let tag =  emptyTagView.tagView.input.rx.text.orEmpty
//        let remark =  emptyRemarkView.remarkField.input.rx.text.orEmpty
        
        Observable.combineLatest(address,tag)
            .subscribe(onNext: {[weak self] tuple in
                guard let `self` = self else {return}
                let (address,tag) = tuple
                if !address.isEmpty/*, !remark.isEmpty */{
                    if self.selectAddress?.address.components(separatedBy: "_").first ?? "" != address {
                        let temp = AddressItem()
                        if !tag.isEmpty {
                            temp.address = "\(address)_\(tag)"
                        }else {
                            temp.address = address
                        }
    //                    temp.label = remark
                        temp.symbol = self.coinModel.coinName
                        self.selectAddress = temp
                    }
                    
                }else {
                    self.selectAddress = nil
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        feeView.isUserInteractionEnabled = false
        feeView.feeInputView.extraLabel.backgroundColor = .Ex.fill2
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        withdrawScroll.alwaysBounceVertical = true 
        handleNavigation()
        bindCoinModelData()
        handleFooter()
        handleRxBindings()
        handleContainers()
        footerView.backgroundColor = .Ex.fill2
        tipView.addSubview(withdrawMaxTitleLabel)
        
        withdrawMaxTitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        self.tipView.addSubview(withdrawMaxValue)
        withdrawMaxValue.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = EXAuthenticManagerTool.kycRightPassed(right: .withdraw)
        refreshAddressList()
    }
    
    
    func tagNeeded() -> Bool {
        let showTag = EXAppMarketManager.sharedInstance.coinNeedTag(self.followCoinName)
        return showTag
    }
    
    func tagForced() -> Bool {
        let forceTag = EXAppMarketManager.sharedInstance.isCoinForceWithdrawTag(self.followCoinName)
        return forceTag
    }
    
    func handleFooter() {
        let addressItem = rx_addressItem.asObservable()
        let amountInput = amountView.amountInputView.input.rx.text.orEmpty.asObservable()
        let feeInput = feeView.feeInputView.input.rx.text.orEmpty.asObservable()
        Observable.combineLatest(amountInput,feeInput)
            .map({[weak self] tuple in
                guard let `self` = self else {return ""}
                let (amount,fee) = tuple
                let decimal = EXAppMarketManager.sharedInstance.getCoinPrecision(self.coinModel.coinName)
                let nsAmount = amount as NSString
                let arriveAmount = nsAmount.subtracting(fee, decimals: decimal) as NSString?
                if let rst = arriveAmount {
                    if rst.isBig("0") {
                        let arrive = rst as String
                        return arrive + " " + self.coinModel.coinName.aliasName()
                    }
                }
                return "0" + " " + self.coinModel.coinName.aliasName()
            })
            .bind(to:footerView.amountLabel.rx.text)
            .disposed(by: self.disposeBag)
        
        footerView.confirmBtn.rx.tap.asObservable()
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
                .subscribe(onNext: { [weak self] _ in
                    guard let `self` = self else { return }
                    self.confirmBtnAction()
                }).disposed(by: disposeBag)
        
//        footerView.confirmBtn.addTarget(self, action: #selector(confirmBtnAction), for: .touchUpInside)
    }
    
    func hasEmptyInputs()->Bool {
        
        needCheckList.removeAll()
        if emptyAddressStyle {
            needCheckList.append(emptyAddress.withdrawAddress)
            if self.tagNeeded() {
                needCheckList.append(emptyTagView.tagView)
            }
//            needCheckList.append(emptyRemarkView.remarkField)
        }
        needCheckList.append(amountView.amountInputView)
        needCheckList.append(feeView.feeInputView)

        for item in needCheckList {
            if let txtfield = item as? EXTextFieldConfigurable {
                if let content = txtfield.baseField.text, content.isEmpty {
                    txtfield.showError()
                    return true
                }
            }
        
        }
        return false
    }
    
    @objc func confirmBtnAction (){
        if hasEmptyInputs() {
            return
        }
        
        guard let addressItem = self.selectAddress else {
            return
        }
        
        var errorDetector:Bool = false
        let nsAmount = self.amount as NSString
        if nsAmount.isBig(followCoinModel.withdraw_max) {
            errorDetector = true
            let msg = String(format:  "withdraw_tip_withdrawMaxValueError".localized(), followCoinModel.withdraw_max)
            EXAlert.showFail(msg:msg)
        }
        let limit = followCoinModel.withdraw_min as NSString
        if limit.isBig(amount) {
            errorDetector = true
            let msg = String(format:  "withdraw_tip_withdrawMinValueError".localized(), followCoinModel.withdraw_min)
            EXAlert.showFail(msg: msg)
        }
        
        if nsAmount.isBig(coinModel.normal_balance) {
            errorDetector = true
            EXAlert.showFail(msg: "common_tip_balanceNotEnough".localized())
        }
        
        let decimal = EXAppMarketManager.sharedInstance.getCoinPrecision(coinModel.coinName)
        let arriveAmount = nsAmount.subtracting(self.fee, decimals: decimal) as NSString?
        if let rst = arriveAmount {
            if !rst.isBig("0") {
                errorDetector = true
                EXAlert.showFail(msg: "withdraw_tip_withdrawMinArrivalError".localized())
            }
        }
        if errorDetector {
            return
        }
        self.validate(address: addressItem.address, symbol: self.followCoinName)
    }
    
    func validate(address: String, symbol: String) {
        appApi.rx.request(.validateWithDrawAddr(address: address, symbol: symbol))
        .MJObjectMap(EXVoidModel.self)
        .autoShowLoadingOnController(context: self)
        .subscribe{[weak self] event in
            switch event {
            case .success(_):
                self?.trustAddressValidate()
            case .failure(_):
                break
            }
        }.disposed(by: self.disposeBag)
    }
    
    func trustAddressValidate() {
        guard let addressItem = self.selectAddress else {
            return
        }
        var message = ""
        if addressItem.isTrust() {
            message = "withdraw_confirm_tips1".localized()
        }
        else {
            message = "withdraw_confirm_tips2".localized()
        }

        precheckSuccessed()
    }
    
    func precheckSuccessed() {
        guard let addressItem = self.selectAddress else {return}
        confirmAddressItem.addreeItem = addressItem
        confirmAddressItem.fee = self.fee
        confirmAddressItem.symbol = self.coinModel.coinName.aliasName()
        confirmAddressItem.amount = self.amount
        confirmSheetAction()
    }
    
    
    func confirmSheetAction() {
        let amount = confirmAddressItem.amount as NSString
        
        let decimal = EXAppMarketManager.sharedInstance.getCoinPrecision(confirmAddressItem.symbol)
        let arriveAmount = amount.subtracting(confirmAddressItem.fee, decimals: decimal)
        
        let drawM = ConfirmWithDrawModel.init()
        drawM.address = confirmAddressItem.addreeItem.address
        drawM.totalAmount = confirmAddressItem.amount.removeTrailingZeros()
        drawM.symbol = confirmAddressItem.symbol //.aliasName()
        drawM.mainNet = self.selectFollowCoinEntity.mainChainName.aliasName()
        drawM.withDrawAmount = (arriveAmount ?? "0").removeTrailingZeros()
        drawM.fee =  confirmAddressItem.fee.removeTrailingZeros()
        drawM.isTrusted = confirmAddressItem.addreeItem.trustType == "1"
        drawM.memo = confirmAddressItem.addreeItem.label
        let confirmSheet = EXConfirmOrderSheet()
        confirmSheet.handleConfirmedInfo(drawM)
        confirmSheet.confirmCallback = {[weak self] in
            EXAlert.dismissEnd {
                self?.confirmOrder()
            }
        }
        EXAlert.showSheet(sheetView: confirmSheet)
    }
    
    @objc func confirmOrder() {
        guard let addressItem = self.selectAddress else {
            return
        }
        if addressItem.trustType == "1" {
            self.confirmWithDraw(confirmAddressItem, smsCode: nil, googleCode: nil, emailCode: nil,trustType: nil, capitalPwd: nil)
        }else {
            
            let manger = EXComSafeVaildManger()
            manger.safeCheck = .withdrawal
            manger.startSafeAlert()
            manger.resultCallBack = { result in
                self.confirmWithDraw(self.confirmAddressItem, smsCode: result.phoneCode, googleCode:  result.googleCode, emailCode:result.emailCode, trustType: 0,capitalPwd: result.fundPassWord)
            }
        }
    }
    
    private func confirmWithDraw(_ item:EXWithDrawConfirmModel,smsCode:String?,googleCode:String?,emailCode:String?,trustType:Int?,capitalPwd: String?) {
        //What the server needs is the received quantity, and verify the received amount+fee<=balance
        let amount = item.amount as NSString
        let decimal = EXAppMarketManager.sharedInstance.getCoinPrecision(item.symbol)
        let arriveAmount = amount.subtracting(item.fee, decimals: decimal)
        let symbol =  self.hasFollowCoin ? self.followCoinName : item.symbol
//        print("cwd=提交\(symbol)")
        if let rst = arriveAmount {
//            if isLoading {
//                return
//            }
//            self.isLoading = true
            appApi.rx.request(.doWithDraw(address: item.addreeItem.address,
                                          trustType: trustType,
                                          remark: item.addreeItem.label,
                                          symbol: symbol,
                                          fee: item.fee,
                                          amount: rst,
                                          smsVaildCode: smsCode,
                                          googleValidCode: googleCode,
                                          emailValidCode: emailCode,
                                          addressID: item.addreeItem.id,
                                          capitalPwd: capitalPwd
                                         ))
                .MJObjectMap(EXWithdrawSuccessModel.self)
                .autoShowLoadingOnController(context: self)
                .subscribe{[weak self] event in
//                    self?.resetLoading()
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
    
    //Manual filling
    func onHandWriteVerify(withdrawId:String) {
        let verifyVc = EXCoinWithdrawVerifyVc.instanceFromStoryboard(name: StoryBoardNameAsset)
        verifyVc.withdrawID = withdrawId
        self.navigationController?.pushViewController(verifyVc, animated: true)
    }
    
    func onBackToAssets() {
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
    
    func handleWithDrawSuccess(_ model:EXWithdrawSuccessModel) {
        
        if model.isOpenUserCheck == "1" {
            if model.isOpenCompanyCheck == "1" {
                //face++
                if let authUrl = URL.init(string: model.faceAuthUrl),model.faceToken.count > 0 {
                    var handleUrl = model.faceAuthUrl
                    if let _ = authUrl.query {
                        handleUrl = handleUrl + "&token=\(model.faceToken)"
                    }else {
                        handleUrl = handleUrl + "?token=\(model.faceToken)"
                    }
                    let vc = WebVC()
                    vc.closeBlock = {
                        self.onBackToAssets()
                    }
                    vc.loadUrl(handleUrl)
                    self.navigationController?.pushViewController(vc, animated: true)
                }else {
                    onHandWriteVerify(withdrawId: model.withdrawId)
                }
            }else {
                onHandWriteVerify(withdrawId: model.withdrawId)
            }
        }else {
            //
            self.successAlert()
        }
    }
    //Prompt for successful withdrawal of currency
    func successAlert(){
        let alert = EXCommonAlert()
        alert.configAlert(title:  "withdraw_tip_withdrawSuccess".localized(), message: nil,bottomOnlyOneBtn: true) { [weak self] _ in
            guard let newSelf = self else{
                return
            }
            EXAlert.dismiss()
            newSelf.onBackToAssets()
        }
        EXAlert.showAlert(alertView: alert)
    }
    
    func handleWithdrawSuccess() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func bindCoinModelData() {
        self.coinModelRelay.accept(self.coinModel)
        self.coinModelRelay.asObservable()
        .subscribe(onNext: {[weak self] model in
            self?.refreshpage()
        }).disposed(by: self.disposeBag)
    }
   
    func refreshpage(){
        guard let model = coinModelRelay.value else {return}
        self.coinModel = model
        handleLinkName()
        getUserWidthInfo()
    }
    
    func refresh() {
        coinSelector.coinName.text = self.coinModel.coinName.aliasName()
        coinSelector.tapCallback = { [weak self] in
            self?.changeCoinAction()
        }
        configAddressContainer()
        emptyAddress.setEmpty()
        emptyTagView.setEmpty()
//        emptyRemarkView.setEmpty()

        feeView.feeInputView.setExtraText(self.coinModel.coinName.aliasName())
        feeView.feeInputView.setText(text: "")
        amountView.amountInputView.setText(text: "")
        if hasFollowCoin {
            feeView.feeInputView.decimal = self.selectFollowCoinEntity.showPrecision
            amountView.amountInputView.decimal = self.selectFollowCoinEntity.showPrecision
        }else {
            if let precision = EXAppMarketManager.sharedInstance.getCoinEntity(self.followCoinName)?.showPrecision {
               feeView.feeInputView.decimal = precision
               amountView.amountInputView.decimal = precision
                
            }
        }
        
        if followCoinModel.showErr {
            feeView.setFee(followCoinModel.defaultFee, self.coinModel.coinName.aliasName())
        }else {
            feeView.setFee(self.followCoinModel.defaultFee.formatAmountUseDecimal(feeView.feeInputView.decimal,holdZero: false), self.coinModel.coinName.aliasName())
        }
       
        amountView.setLimit(self.followCoinModel.withdraw_min.formatAmountUseDecimal(amountView.amountInputView.decimal,holdZero: false),
                            self.coinModel.normal_balance.formatAmount(self.coinModel.coinName,holdZero: false),
        self.coinModel.coinName.aliasName(),holdzero: false)


//        if hasRecentlyAddress() {
//            updateRecentAddress(self.followCoinModel.userWithdrawAddrList[0])
//            
//        }
        ///Bottom copy
        handleHintLabels()
    }
    
    
    func changeCoinAction() {
//        let searchVc = EXCoinSearchListVc.instanceFromStoryboard(name: StoryBoardNameAsset)
//        searchVc.sourceType = .sourceForWithdraw
//        searchVc.onEntityCallback = {[weak self] model in
//            self?.updateCoinEntity(model)
//        }
//        self.navigationController?.pushViewController(searchVc, animated: true)
        
        let target = EXAssetsPickerVc.init(source: allCoins ?? [])
        target.totalBalanceSymbol = totalBalanceSymbol
        target.didSelectedCoin = { [weak self] coin in
            guard let self = `self` else { return }
            self.coinModelRelay.accept(coin)
        }
        navigationController?.pushViewController(target, animated: true)
    }
    
    func updateCoinEntity(_ model:CoinListEntity) {
        if let hasModel = EXAccountBalanceManager.manager.getCoinMapItem(model.name) {
            self.coinModelRelay.accept(hasModel)
        }
    }
    
    func largeTitleValueChanged(height: CGFloat) {
        topConstraint.constant = height
    }
    
    func scanQrCodeAction() {
        
        //Set scanning area parameters
        let scanVc = EXScanVc()
        scanVc.onScanResultCallback = {[weak self] address in
            guard let self = `self` else { return }
            let addressTags = address.components(separatedBy: "_")
            if self.tagNeeded() && addressTags.count == 2 {
                self.emptyAddress.withdrawAddress.setText(text: addressTags[0])
                self.emptyTagView.tagView.setText(text: addressTags[1])
            }
            else {
                self.emptyAddress.withdrawAddress.setText(text: address)
                self.emptyTagView.tagView.setText(text: "")
            }
            
        }
        self.navigationController?.pushViewController(scanVc, animated: true)
    }
    
    func addressBookAction() {
        let address = EXCoinAddressListVc.instanceFromStoryboard(name: StoryBoardNameAsset)
        address.selectAddressItem = self.selectAddress
        address.coinSymbol = self.followCoinName
        address.mainChainName = self.coinModel.coinName
        address.coinModel = self.coinModel
        address.onAddressItemCallback = {[weak self] item in
            self?.updateRecentAddress(item)
        }
        address.onAddressDeleteCallback = {[weak self] item in
            self?.checkRecentlyAddressDeleted(item)
        }
        self.navigationController?.pushViewController(address, animated: true)
    }
   func handleLinkName() {
        for item in self.linkNameBackView.subviews {
            item.removeFromSuperview()
        }
       let followCoinListArr = EXAppMarketManager.sharedInstance.getFollowCoinList(self.coinModel.coinName,type: .withdraw)
        if followCoinListArr.count > 0 {
            let followCoinListView = EXFollowCoinListView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 0), followCoinListArr:followCoinListArr,symbol:self.coinModel.coinName)
            followCoinListView.selectCoinBlock = {[weak self] (item) in
                guard let mySelf = self else{return}
                mySelf.followCoinName = item.name
//                print("cwd followCoinName = \(item.name)")
                mySelf.selectFollowCoinEntity = item
                mySelf.getFollowCoinInfo()//Request handling fee and address
//                mySelf.configAddressContainer()
            }
            self.hasFollowCoin = true
            self.followCoinName = followCoinListView.selectFollowCoinEntity.name
//            print("cwd defalut = followCoinName = \(self.followCoinName)")
            self.selectFollowCoinEntity = followCoinListView.selectFollowCoinEntity
            self.getFollowCoinInfo()//Request handling fee and address
            self.linkNameBackView.addSubview(followCoinListView)
            self.linkNameBackViewHCon.constant = followCoinListView.height
            self.linkNameBackViewTopCon.constant = 13
        }else {
            self.linkNameBackViewTopCon.constant = 0
            self.linkNameBackViewHCon.constant = 0
            self.followCoinName = self.coinModel.coinName
            self.hasFollowCoin = false
            self.getFollowCoinInfo()//Request handling fee and address
        }
    }
   
    func getFollowCoinInfo() {
        EXGetFollowCoinVm.shareInstance.getCost(symbol: self.followCoinName) {[weak self] (item) in
            if let model = item {
                self?.followCoinModel = model
                if model.withdrawWhitelistFlag == "1"{
                    self?.emptyAddress.withdrawAddress.switchWhiteAddressListMode()
                }
                self?.footerView.confirmBtn.isEnabled = true
                self?.refresh()
            }else {
                self?.followCoinModel = EXFollowCoinModel.errorFollowCoinModel()
                self?.footerView.confirmBtn.isEnabled = false
                self?.refresh()
            }
        }
    }
    
    func refreshAddressList() {
        EXGetFollowCoinVm.shareInstance.getCost(symbol: self.followCoinName) {[weak self] (item) in
            if let model = item {
                self?.followCoinModel = model
            }
        }
    }
    
    func getUserWidthInfo(){
        let symbol = coinModel.coinName.aliasName()
        EXAuthenticManagerTool.getUserKysRight(symbol: symbol) { model in
            self.updateUserWithdrawInfo(model: model)
        }
    }
    
    func updateUserWithdrawInfo(model: EXKycUserWithdrawAmountInfo){
        let decimal = EXAppMarketManager.sharedInstance.getCoinPrecision(self.coinModel.coinName)
        let decimalStr = String(decimal) 
        _ = model.canUseAmount.formatAmountUseDecimal(decimalStr,holdZero: false)
        let currSymbol = String(model.currentSymbolAmount).formatAmountUseDecimal(decimalStr,holdZero: false)
        self.v1.text =  currSymbol + " " + coinModel.coinName.aliasName()
        let can = String(model.canUseAmount)
        let total24 = String(model.withdrawAmount)
        self.v2.text = can + "/" + total24 + " " + "USDT"
    }
    
}


extension EXCoinWithdrawVc{
    func chooseAddressList(){
        let v = EXAddressListView()
        v.addressList = self.followCoinModel.userWithdrawAddrList
        v.selectAddressCallBack = { [weak self] address in
            guard let `self` = self else { return }
            self.updateRecentAddress(address)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                EXAlert.dismiss()
            }
            
        }
        EXAlert.showSheet(sheetView: v)
    }
}
