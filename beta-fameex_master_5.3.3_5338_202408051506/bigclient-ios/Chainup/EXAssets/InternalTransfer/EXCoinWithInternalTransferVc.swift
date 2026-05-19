//
//  EXCoinWithInternalTransferVc.swift
//  Chainup
//
//  Created by chainup on 2023/7/3.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import EXKit
class EXCoinWithInternalTransferVc: UIViewController,StoryBoardLoadable,NavigationPlugin {

    @IBOutlet var coinSelector: EXCoinSelectorView!

    @IBOutlet var hintTitle: UILabel!
    @IBOutlet var hintContent: UILabel!

    @IBOutlet weak var targetAccountView: EXTargetAccountTextFieldView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var topConstraint: NSLayoutConstraint!
    @IBOutlet var footerView: EXCoinWithdrawFooter!
    @IBOutlet var amountView : EXCoinWithdrawAmountView!
    @IBOutlet var feeView : EXCoinWithdrawFeeView!

   private var followCoinModel : EXFollowCoinModel = EXFollowCoinModel()
   private var hasFollowCoin = false//Is there a sub chain
   private var selectFollowCoinEntity = CoinListEntity()

   var coinModel: EXAccountCoinMapItem = EXAccountCoinMapItem()

   private var amount:String = ""
   private var fee:String = ""
   private var targetAccount = ""
   private var followCoinName = ""
   private var needCheckList = [EXBaseField]()
   private var coinModelRelay :BehaviorRelay<EXAccountCoinMapItem?> = BehaviorRelay(value: nil)

    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: self.scrollView, presenter: self)
        return nav
    }()

    //MARK: lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        scrollView.alwaysBounceVertical = true
        handleNavigation()
        bindCoinModelData()
        handleFooter()
        handleRxBindings()
        handleNeedCheckList()
        configBottomTip()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _ = EXAuthenticManagerTool.kycRightPassed(right:.withdraw)
    }
    //MARK: action
    @objc func confirmBtnAction (){

        if hasEmptyInputs() {
            return
        }

        let nsAmount = self.amount as NSString
        if nsAmount.isBig(followCoinModel.withdraw_max) {

            EXAlert.showFail(msg:"internalTransfer_tip_maxValueError".localized() + followCoinModel.withdraw_max)
            return
        }

        let limit = followCoinModel.withdraw_min as NSString
        if limit.isBig(amount) {

            EXAlert.showFail(msg: "internalTransfer_tip_minValueError".localized() + followCoinModel.withdraw_min)
            return
        }

        if nsAmount.isBig(coinModel.normal_balance) {
            EXAlert.showFail(msg: "common_tip_balanceNotEnough".localized())
            return
        }



        let decimal = EXAppMarketManager.sharedInstance.getCoinPrecision(coinModel.coinName)
        let arriveAmount = nsAmount.subtracting(self.fee, decimals: decimal) as NSString?
        if let rst = arriveAmount {
            if !rst.isBig("0") {

                EXAlert.showFail(msg: "withdraw_tip_withdrawMinArrivalError".localized())
                return
            }
        }

        //Send verification request
        appApi.rx.request(.validateWithInternalTransfer(targetAccount: targetAccount)).MJObjectMap(EXVoidModel.self).subscribe{ [weak self] event in
            guard let `self` = self else { return }
            switch event {
            case .success(_):
                self.newSafeAlert()
                break
            case .failure(_):
                break
            }
        }.disposed(by: self.disposeBag)
    }
    
    func newSafeAlert(){
        let manger = EXComSafeVaildManger()
        manger.safeCheck = .directTransferWithinTheStation
        manger.startSafeAlert()
        manger.resultCallBack = { result in
            self.confirmWithDraw(smsCode: result.phoneCode, googleCode:  result.googleCode,emailAuthCode: result.emailCode,capitalPwd: result.fundPassWord)
        }
    }

    private func confirmWithDraw(smsCode:String?,googleCode:String?,emailAuthCode: String?,capitalPwd: String?) {
        //What the server needs is the received quantity, and verify the received amount+fee<=balance
        let targetAmount = amount as NSString
        let decimal =  EXAppMarketManager.sharedInstance.getCoinPrecision(followCoinName)
        let arriveAmount = targetAmount.subtracting(fee, decimals: decimal)
        if let rst = arriveAmount {

            //Send submission request
            appApi.rx.request(.doWithInternalTransfer(targetAccount: targetAccount, amount: rst, fee: fee, symbol: followCoinName, smsAuthCode: smsCode, googleCode: googleCode,emailAuthCode: emailAuthCode,capitalPwd: capitalPwd)).MJObjectMap(EXVoidModel.self).subscribe{[weak self] event in
                switch event {
                case .success(_):
                    self?.handleWithSuccess()
                    break
                case .failure(_):
                    break
                }
            }.disposed(by: self.disposeBag)
        }

    }
    func handleWithSuccess() {

        EXAlert.showSuccess(msg: "internalTransfer_tip_success".localized())

        handleBack()
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

        feeView.feeInputView.setExtraText(self.coinModel.coinName.aliasName())
        feeView.feeInputView.setText(text: "")
        amountView.amountInputView.setText(text: "")
        if hasFollowCoin {
            feeView.feeInputView.decimal = self.selectFollowCoinEntity.showPrecision
            amountView.amountInputView.decimal = self.selectFollowCoinEntity.showPrecision
        }else {
            if let precision =  EXAppMarketManager.sharedInstance.getCoinEntity(self.followCoinName)?.showPrecision {
                feeView.feeInputView.decimal = precision
                amountView.amountInputView.decimal = precision

            }
        }

        feeView.setFee(self.followCoinModel.innerTransferFee, self.coinModel.coinName.aliasName())

        amountView.setLimit(self.followCoinModel.withdraw_min.formatAmountUseDecimal(amountView.amountInputView.decimal).removeTrailingZeros(),
                            self.coinModel.normal_balance.formatAmount(self.coinModel.coinName),
                            self.coinModel.coinName.aliasName())

        handleHintLabels()
    }

    func changeCoinAction() {
        let searchVc = EXCoinSearchListVc.instanceFromStoryboard(name: StoryBoardNameAsset)
        searchVc.sourceType = .internalTransfer
        searchVc.onEntityCallback = {[weak self] model in

            if let hasModel = EXAccountBalanceManager.manager.getCoinMapItem(model.name) {
                self?.coinModelRelay.accept(hasModel)
            }
        }
        self.navigationController?.pushViewController(searchVc, animated: true)
    }


    func handleLinkName() {
        self.followCoinName = self.coinModel.coinName
        self.hasFollowCoin = false
        self.getFollowCoinInfo()//Request handling fee and address

    }

    func getFollowCoinInfo() {
        EXGetFollowCoinVm.shareInstance.getCost(symbol: self.followCoinName) {[weak self] (item) in
            if let model = item {
                self?.followCoinModel = model
                self?.refresh()
            }
        }
    }

    //MARK:- NavigationPlugin
    func largeTitleValueChanged(height: CGFloat) {
        topConstraint.constant = height
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
        let coinAmout = model.canUseAmount.formatAmountUseDecimal(decimalStr,holdZero: false)
        let currSymbol = String(model.currentSymbolAmount).formatAmountUseDecimal(decimalStr,holdZero: false)
        self.v1.text =  currSymbol + " " + coinModel.coinName.aliasName()
        let can = String(model.canUseAmount)
        let total24 = String(model.withdrawAmount)
        self.v2.text = can + "/" + total24 + " " + "USDT"
    }
    
    
    func configBottomTip(){
        self.scrollView.addSubview(self.v1)
        self.v1.snp.makeConstraints { make in
            make.centerY.equalTo(self.hintContent)
            make.right.equalToSuperview().offset(-16)
        }
        
        self.scrollView.addSubview(self.limitLabel)
        self.scrollView.addSubview(self.v2)
        
        self.limitLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(20)
            make.top.equalTo(self.hintContent.snp.bottom).offset(6)
        }
        
        self.v2.snp.makeConstraints { make in
            make.centerY.equalTo(self.limitLabel)
            make.right.equalToSuperview().offset(-16)
        }
        
        self.scrollView.addSubview(self.withdrawMaxTitleLabel)
        self.scrollView.addSubview(self.withdrawMaxValue)
        
        self.withdrawMaxTitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(20)
            make.top.equalTo(self.limitLabel.snp.bottom).offset(9)
        }
        
        self.withdrawMaxValue.snp.makeConstraints { make in
            make.centerY.equalTo(self.withdrawMaxTitleLabel)
            make.right.equalToSuperview().offset(-16)
        }
    }
    
    lazy var limitLabel: UILabel = {
        let label = UILabel(text:"", font: .Ex.regular(12), textColor: .Ex.text3 , alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var v1: UILabel = {
        let label = UILabel(text:"", font: .Ex.regular(12), textColor: .Ex.text1 , alignment: NSTextAlignment.right)
        label.ext_UseAutoLayout()
        return label
    }()
    lazy var v2: UILabel = {
        let label = UILabel(text:"", font: .Ex.regular(12), textColor: .Ex.text1 , alignment: NSTextAlignment.right)
        label.ext_UseAutoLayout()
        return label
    }()
    
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
}

extension EXCoinWithInternalTransferVc{
    func handleNavigation() {
        self.navigation.setTitle(title: "assets_action_internalTransfer".localized())
        navigation.configRightItems(["internalTransfer_action_History".localized()],isImageName: false)

        navigation.rightItemCallback = {[weak self] tag in
            self?.handleRechargeHistory()
        }

        navigation.customBack = true
        navigation.customBackCallback = {[weak self] in
            self?.handleBack()
        }
    }

    func handleBack() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.navigationController?.popViewController(animated: true)
        }
    }

    func handleRechargeHistory(){

        let chargeHistory = EXChargeHistoryVc.instanceFromStoryboard(name: StoryBoardNameAsset)
        chargeHistory.historyScene = .internalTransfer
        chargeHistory.symbol = self.coinModel.coinName
        self.navigationController?.pushViewController(chargeHistory, animated: true)
    }

    func handleHintLabels() {
        hintTitle.font = UIFont.Ex.regular(14)
        hintTitle.textColor = UIColor.Ex.text2
        hintTitle.text = "transfer_tip_notice".localized()
        

//        let contentA = getFormatHintString(prefix: "transfer_transferAlert_contentA", followCoinModel.withdraw_min)
//        let contentB = getFormatHintString(prefix: "transfer_transferAlert_contentB", followCoinModel.withdraw_max)
//        let contentC = getFormatHintString(prefix: "transfer_transferAlert_contentC", followCoinModel.withdraw_max_day)
//        hintContent.text = contentA + "\n" + contentB + "\n" + contentC
        
        
        self.hintContent.textColor = .Ex.text3
        self.hintContent.font = UIFont.Ex.regular(12)
        self.hintContent.text = "kyc_withdrawal_amount".localized()
        self.limitLabel.text = "kyc_withdrawal_24h".localized()
        
        let contentD = "withdraw_safety_tips".localized()
        let B = "charge_chargeAlert_contentB".localized()
        var contentB = ""
        if followCoinModel.showErr {
             contentB = followCoinModel.withdraw_max.removeTrailingZeros()
        }else {
             contentB =  followCoinModel.withdraw_max.formatAmountUseDecimal(amountView.amountInputView.decimal,holdZero: false) + " " + coinModel.coinName.aliasName()
        }
        self.withdrawMaxTitleLabel.font = UIFont.Ex.regular(12)
        self.withdrawMaxTitleLabel.textColor = .Ex.text3
        self.withdrawMaxTitleLabel.text =  B
        self.withdrawMaxValue.text = contentB
        
        
    }

    func getFormatHintString(prefix:String, _ amountString:String) -> String {
        return prefix.localized() + "：" + amountString.formatAmountUseDecimal(amountView.amountInputView.decimal) + " " + coinModel.coinName.aliasName()
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

        targetAccountView.targetAccountField.input.rx.text.orEmpty.asObservable()
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] account in
                guard let `self` = self else { return }
                self.targetAccount = account
            }).disposed(by: self.disposeBag)
    }

    func handleNeedCheckList() {
        feeView.feeInputView.extraLabel.backgroundColor = UIColor.ThemeView.bg
        needCheckList.append(targetAccountView.targetAccountField)
        needCheckList.append(amountView.amountInputView)
        needCheckList.append(feeView.feeInputView)
    }

    
    func handleFooter() {
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
    }

    func hasEmptyInputs()->Bool {

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

}
