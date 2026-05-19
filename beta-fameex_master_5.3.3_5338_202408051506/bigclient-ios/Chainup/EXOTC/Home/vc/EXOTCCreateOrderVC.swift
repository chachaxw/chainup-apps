//
//  EXOTCCreateOrderVC.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/27.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import EXKit
import JXSegmentedView


class EXOTCCreateOrderVC: BaseVC,NavigationPlugin {
    
    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: baseScroll, presenter: self)
        return nav
    }()
    
    lazy var baseScroll: UIScrollView = {
        let v = UIScrollView()
        v.contentInsetAdjustmentBehavior = .never
        v.alwaysBounceVertical = true
        return v
    }()
    
    lazy var footerBtn: EXCountDownBtnFooter = {
        let v = EXCountDownBtnFooter()
        return v
    }()
    
    lazy var priceUnitTxtField: EXTextField = {
        let v = EXTextField()
        return v
    }()
    
    lazy var tradingInfoView: EXTradingWithInfoView = {
        let v = EXTradingWithInfoView()
        v.contentInset = .init(top: 16, left: 0, bottom: 16, right: 0)
        return v
    }()
    
    lazy var userInputField: EXOTCTradeTextField = {
        let v = EXOTCTradeTextField()
        return v
    }()
    
    lazy var bottomStack: EXStackView = {
        let v = EXStackView()
        v.separatorConfiguration = nil
        v.axis = .vertical
        v.spacing = 10
        v.distribution = .fill
        return v
    }()
    
    
    lazy var advanceLab: UILabel = {
        let v = UILabel(font: .Ex.regular(12), textColor: .Ex.text2)
        return v
    }()
    
    lazy var withdrawTipLabel: EXInsetLabel = {
        let v = EXInsetLabel(font: .Ex.regular(12), textColor: .Ex.warning1)
        v.edgeInset = .init(top: 15, left: 0, bottom: 15, right: 0)
        v.numberOfLines = 0
        return v
    }()
    
    lazy var tipTitle: UILabel = {
        let v = UILabel(font: .Ex.regular(14), textColor: .Ex.text2)
        v.text = "common_text_tip".localized()
        return v
    }()
    
    lazy var tipContent: UILabel = {
        let v = UILabel(font: .Ex.regular(12), textColor: .Ex.text2)
        v.numberOfLines = 0
        return v
    }()
    
    
    
    
    var selectionTitleBar: EXSelectionTitleBar!
    
    typealias OrderSaveErrorCallback = () -> ()
    var errorCallback:OrderSaveErrorCallback?
    
    var caculateResult:String = ""//Calculated total amount or total currency
    
    var wantedModel:EXOTCWantedModel?
    
    var tradeType:OTCTradeType = .none
    var advertId:String = ""
    
    lazy var dataSource: JXSegmentedTitleDataSource = {
        let d = JXSegmentedTitleDataSource()
        d.titleNormalFont = .Ex.medium(16)
        d.titleSelectedFont = .Ex.medium(16)
        d.titleNormalColor = .Ex.text2
        d.titleSelectedColor = .Ex.text1
        d.isItemSpacingAverageEnabled = false
        return d
    }()
    
    lazy var segementView: JXSegmentedView = {
        let v = JXSegmentedView()
        v.contentEdgeInsetLeft = 16
        v.delegate = self
        v.dataSource = dataSource
        v.indicators = [EKIndicatorSegmentIndicator()]
        return v
    }()
    
    
    private var userInputValue: String = ""
    
    var rx_paymentType = BehaviorRelay<OTCPaymentType>(value:.paymentMoney)
    
    var paymentType :OTCPaymentType {
        get {
            return rx_paymentType.value
        }
        set {
            rx_paymentType.accept(newValue)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubViews([baseScroll,footerBtn])
        bottomStack.addArrangedSubviews([advanceLab, withdrawTipLabel, tipTitle, tipContent])
        baseScroll.addSubViews([tradingInfoView,
                                segementView, priceUnitTxtField, userInputField,
                                bottomStack
                               ])
        ///
        baseScroll.snp.makeConstraints { make in
            make.top.equalTo(self.navigation.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
        }
        footerBtn.snp.makeConstraints { make in
            make.top.equalTo(baseScroll.snp.bottom).offset(16)
            make.bottom.equalToSuperview().offset(-(max(getSafeAreaBottom(), 0) + 10))
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(40)
        }
        ///
        tradingInfoView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
        }
        segementView.snp.makeConstraints { make in
            make.top.equalTo(tradingInfoView.snp.bottom).offset(10)
            make.centerX.width.equalToSuperview()
            make.height.equalTo(44)
        }
        ///
        priceUnitTxtField.snp.makeConstraints { make in
            make.top.equalTo(segementView.snp.bottom).offset(20)
            make.centerX.equalTo(segementView)
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(54)
        }
        userInputField.snp.makeConstraints { make in
            make.top.equalTo(priceUnitTxtField.snp.bottom).offset(20)
            make.centerX.width.equalTo(priceUnitTxtField)
            make.height.equalTo(88)
        }
        
        bottomStack.snp.makeConstraints { make in
            make.top.equalTo(userInputField.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
        }
        
        
        self.handleUI()
        
        self.paymentType = .paymentMoney
        
        self.loadWantedDetail()
        self.configFooterToolBar()
        self.observeTab()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Compatible with ios10, re layout
        self.baseScroll.layoutIfNeeded()
        //        selectionTitleBar.setSelected(atIdx: 0)
    }
    
    func largeTitleValueChanged(height: CGFloat) {
        
    }
}

//MARK:  UI
extension EXOTCCreateOrderVC{
    func handleUI() {
        
        self.navigation.setdefaultType(type: .list)
        var attributes: [NSAttributedString.Key: Any] = [:]
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        paragraphStyle.alignment = .left
        attributes.updateValue(paragraphStyle, forKey: .paragraphStyle)
        let tip = String(format: "otc_tip_tradeHintContent".localized(), OTCPulbicManager.sharedInstance.getCancelMaxNum())
        let att = NSAttributedString(string:tip , attributes: attributes)
        tipContent.attributedText = att
        
        priceUnitTxtField.isUserInteractionEnabled = false
        priceUnitTxtField.titleMode(enabled: true)
        priceUnitTxtField.setTitle(title: "otc_text_price".localized())
        userInputField.setTitle(title: "noun_order_GMV".localized())
        userInputField.actionBtn.setTitle("common_action_sendall".localized(), for: UIControl.State.normal)
        userInputField.textfieldValueChangeBlock = { [weak self] value in
            guard let self else { return }
            self.userInputValue = value
            self.updateCaculation(value: value)
        }
        userInputField.sendAllCallback  = {[weak self] in
            guard let self else { return }
            self.allInAction()
        }
        if tradeType == .otcbuy {
            dataSource.titles = ["otc_action_buyByPrice".localized(),"otc_action_buyByVolume".localized()]
            withdrawTipLabel.isHidden = !OTCPulbicManager.sharedInstance.isShowWithdrawLimitTip()
            withdrawTipLabel.text = "otc_tip_withdrawLimitTime".localized()
        }else if tradeType == .otcsell {
            dataSource.titles = ["otc_action_sellByPrice".localized(),"otc_action_sellByVolume".localized()]
        }
        
        self.segementView.reloadData()

    }
    func observeTab() {
        rx_paymentType.subscribe(onNext:{[weak self] type in
            self?.updateUserInputUI(type:type)
        }).disposed(by: self.disposeBag)
    }
    
    func updatePriceInputUI() {
        let priceUnit = "otc_text_price".localized()
        let title = priceUnit + "(\(self.wantedModel?.payCoin ?? ""))"
        let price  =  "\(self.wantedModel?.fmtPrice() ?? "") \(self.wantedModel?.payCoin ?? "")"
        priceUnitTxtField.setTitle(title: title)
        priceUnitTxtField.setText(text:price)
    }
    
    func updateUserInputUI(type:OTCPaymentType) {
        if type == .paymentMoney {
            userInputField.decimalType = .cny
            userInputField.decimal = EXAppMarketManager.sharedInstance.getCurrencyModel(self.wantedModel?.payCoin ?? "").coin_fiat_precision
#if DEBUG
            
            print("userInputField.decimal = \(userInputField.decimal)")
            
#endif
            let titleUnit = "otc_text_orderTotal".localized()
            let title = titleUnit + "(\(self.wantedModel?.payCoin ?? ""))"
            userInputField.setTitle(title:title)
            if self.tradeType == .otcbuy {
                userInputField.setPlaceHolder(placeHolder:"otc_tip_inputWishPrice".localized())
            }else {
                userInputField.setPlaceHolder(placeHolder:"otc_tip_inputWishSellPrice".localized())
            }
        }else if type == .paymentVolume {
            userInputField.decimalType = .coin
            let precion = EXAppMarketManager.sharedInstance.getCoinPrecision(self.wantedModel?.coin ?? "")
            userInputField.decimal =  "\(precion)"  //Regression to default value, taken from coin symbol
            let title = "charge_text_volume".localized() +  "\(self.wantedModel?.coin.aliasName() ?? "")"
            userInputField.setTitle(title:title)
            if self.tradeType == .otcbuy {
                userInputField.setPlaceHolder(placeHolder:"otc_tip_inputWishVolume".localized())
            }else {
                userInputField.setPlaceHolder(placeHolder:"otc_tip_inputWishSellVolume".localized())
            }
        }
        self.updateCaculation(value:userInputValue)
    }
    
    func configFooterToolBar() {
        footerBtn.setTitle(left: "common_text_btnCancel".localized(),
                           right: "otc_action_placeOrder".localized())
        footerBtn.startFire()
        footerBtn.rightBtnCallback = {[weak self] in
            guard let `self` = self else { return }
            self.createOrderAction()
        }
        footerBtn.leftBtnCallback = {[weak self] in
            guard let `self` = self else { return }
            self.navigationController?.popViewController(animated: true)
        }
        footerBtn.countDownStopped.asObservable()
            .subscribe(onNext:{[weak self] stopped in
                guard let self else { return }
                if stopped {
                    self.loadWantedDetail()
                    self.footerBtn.resetCountSeconds()
                    self.footerBtn.startFire()
                }
            }).disposed(by: self.disposeBag)
    }
    
    
}

extension EXOTCCreateOrderVC: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        if index == 0 {
            moneyTabAction()
        } else {
            volumeTabAction()
        }
    }
}





//MARK:  action
extension EXOTCCreateOrderVC{
    
    func moneyTabAction() {
        self.paymentType = .paymentMoney
    }
    
    func volumeTabAction() {
        self.paymentType = .paymentVolume
    }
    
    func allInAction() {
        if self.tradeType == .otcbuy {
            if self.paymentType == .paymentMoney {
                if let model = self.wantedModel {
                    let text = model.maxTrade.formatCurrencyMoney(model.payCoin,format: .fiatFormat)
                    print("orgin =\( model.maxTrade) deal after = \(text)")
                    self.userInputField.setText(text: text)
                }
            }else {
                if let model = self.wantedModel {
                    let nsInput = model.maxTrade as NSString
                    let precion = EXAppMarketManager.sharedInstance.getCoinPrecision(model.coin)
                    let maxVolume = nsInput.dividing(by: model.price, decimals: precion)
                    userInputField.setText(text: maxVolume ?? "")
                }
            }
            userInputField.input.sendActions(for: .valueChanged)
        }else if self.tradeType == .otcsell {
            if self.paymentType == .paymentMoney {
                if let model = self.wantedModel {
                    let precion = EXAppMarketManager.sharedInstance.getCoinPrecision(model.coin)
                    let totalBalance = (model.currentUserBanlance as NSString).multiplying(by: model.price, decimals: precion) //Currency balance * unit price
                    if let totalBalance = totalBalance{
                        if (totalBalance as NSString).isBig(model.maxTrade){
                            self.userInputField.setText(text: model.maxTrade)
                        }else {
                            self.userInputField.setText(text: totalBalance.formatCurrencyMoney(model.payCoin))
                        }
                    }
                    
                }
            }else {
                if let model = self.wantedModel {
                    let nsInput = model.maxTrade as NSString
                    let precion = EXAppMarketManager.sharedInstance.getCoinPrecision(model.coin)
                    let maxVolume = nsInput.dividing(by: model.price, decimals: precion)
                    if let maxVolume = maxVolume {
                        if (model.currentUserBanlance as NSString).isBig(maxVolume){
                            userInputField.setText(text: maxVolume)
                        }else {
                            userInputField.setText(text: model.currentUserBanlance.formatAmount(model.coin))
                        }
                    }
                    
                    
                }
            }
            userInputField.input.sendActions(for: .valueChanged)
        }
    }
}


//MARK:  businss
extension EXOTCCreateOrderVC{
    
    
    func createOrderAction() {
        if tradeType == .otcbuy {
            orderBuy()
        }else if tradeType == .otcsell {
            let manger = EXComSafeVaildManger()
            manger.safeCheck = .c2csales
            manger.startSafeAlert()
            manger.resultCallBack = { result in
                self.submitSellOrder(result: result)
            }
        }
    }
    
    func updateCaculation(value:String) {
        if self.paymentType == OTCPaymentType.paymentMoney {
            print("paymentType = \(self.paymentType)")
            if let model = self.wantedModel {
                let nsInput = value as NSString
                let precion = EXAppMarketManager.sharedInstance.getCoinPrecision(model.coin)
                let result = nsInput.dividing(by: model.price, decimals: precion)
                if let rst = result {
                    let fmtRst = rst.formatAmount(model.coin)
                    print(" fmtRst => = \(fmtRst)")
                    checkPriceAvailable(value)
                    caculateResult = fmtRst
                    //tip = % usdt use usdt presion
                    self.userInputField.bottomLeftLabel.text = "≈" + fmtRst + " " + model.coin.aliasName()
                }
            }else {
                self.userInputField.bottomLeftLabel.text = "≈ 0"
            }
        }else {
            print("paymentType = \(self.paymentType)")
            if let model = self.wantedModel {
                let nsPrice = model.price as NSString
                let precion = EXAppMarketManager.sharedInstance.getCoinPrecision(model.coin)
                print(" model.coin =>precion = \(precion)")
                let result = nsPrice.multiplying(by: value, decimals: precion)
                if let rst = result {
                    let fmtRst = rst.formatCurrencyMoney(model.payCoin,format: .fiatFormat)
                    print(" fmtRst => = \(fmtRst)")
                    checkPriceAvailable(fmtRst)
                    caculateResult = fmtRst
                    self.userInputField.bottomLeftLabel.text = "≈" + fmtRst + " " + model.payCoin
                }
            }else {
                self.userInputField.bottomLeftLabel.text = "≈ 0"
            }
        }
    }
    
    func checkPriceAvailable(_ price:String) {
        //Do not process red when not entered
        let text = userInputField.input.text
        if let value = text, value.isEmpty {
            footerBtn.rightBtn.isEnabled = false
            userInputField.setBottomRightTextColor(UIColor.ThemeLabel.colorMedium)
            return
        }
        let min = self.wantedModel?.minTrade
        let max = self.wantedModel?.maxTrade
        if let lmin = min, let lmax = max {
            let nsPrice = price as NSString
            let nsMin = lmin as NSString
            if nsPrice.isBig(lmax) || nsMin.isBig(price) {
                userInputField.setBottomRightTextColor(UIColor.ThemeState.fail)
                footerBtn.rightBtn.isEnabled = false
            }else {
                userInputField.setBottomRightTextColor(UIColor.ThemeLabel.colorMedium)
                footerBtn.rightBtn.isEnabled = true
            }
        }
    }
}
extension EXOTCCreateOrderVC{
    
    func submitSellOrder(result: EXCodeResult){
        guard let model = self.wantedModel else {return}
        
        let type = (self.paymentType == .paymentMoney) ? OTCPaymentTypeKey.payByMoney.rawValue : OTCPaymentTypeKey.payByVolume.rawValue
        var totalPrice = ""
        var totalVolume = ""
        if self.paymentType == .paymentMoney {
            totalPrice = userInputField.input.text ?? ""
            totalVolume = caculateResult
        }else {
            totalVolume = userInputField.input.text ?? ""
            totalPrice = caculateResult
        }
        print("totalPrice \(totalPrice)  totalVolume = \(totalVolume)")
        otcApi.rx.request(.otcSellOrderSave(totalPrice:totalPrice,
                                            price: model.price,
                                            volume: totalVolume,
                                            advertId:advertId,
                                            remark: nil,
                                            type: type,
                                            capitalPword:result.fundPassWord,
                                            smsAuthCode: result.phoneCode,
                                            googleCode: result.googleCode
                                           ))
        .MJObjectMap(EXOTCOrderSaveModel.self,false)
        .subscribe{[weak self] event in
            switch event {
            case .success(let model):
                self?.showOrderDetail(model.sequence)
                break
            case .failure(let error):
                self?.handleError(error)
                break
            }
        }.disposed(by: self.disposeBag)
        
    }
    
    func orderBuy() {
        guard let model = self.wantedModel else {return}
        let type = (self.paymentType == .paymentMoney) ? OTCPaymentTypeKey.payByMoney.rawValue : OTCPaymentTypeKey.payByVolume.rawValue
        var totalPrice = ""
        var totalVolume = ""
        if self.paymentType == .paymentMoney {
            totalPrice = userInputField.input.text ?? ""
            totalVolume = caculateResult
        }else {
            totalVolume = userInputField.input.text ?? ""
            totalPrice = caculateResult
        }
        print("self.paymentType = \(self.paymentType)  totalPrice \(totalPrice)  totalVolume = \(totalVolume)")
        otcApi.rx.request(.otcBuyOrderSave(totalPrice: totalPrice,
                                           price: model.price,
                                           volume: totalVolume,
                                           advertId:advertId,
                                           remark: "",
                                           type: type))
        .MJObjectMap(EXOTCOrderSaveModel.self,false)
        .subscribe{[weak self] event in
            switch event {
            case .success(let model):
                self?.showOrderDetail(model.sequence)
                break
            case .failure(let error):
                self?.handleError(error)
                break
            }
        }.disposed(by: self.disposeBag)
    }
    
    func handleError(_ err:Error) {
        let nsErr = err as NSError
        let code = nsErr.code
        if code == OTCOrderSaveErrors.orderOffline.rawValue ||
            code == OTCOrderSaveErrors.orderNeedRefresh.rawValue {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
                EXAlert.showFail(msg: err.localizedDescription)
                self.navigationController?.popViewController(animated: true)
            }
            errorCallback?()
        }else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
                EXAlert.showFail(msg: err.localizedDescription)
            }
        }
    }
    
    func showOrderDetail(_ orderId:String) {
        footerBtn.stopCounting()
        let detail = EXOTCOrderDetailVC.instanceFromStoryboard(name: StoryBoardNameOTC)
        detail.sequenceId = orderId
        detail.tradeType = self.tradeType
        self.navigationController?.pushViewController(detail, animated: true)
    }
    
    func loadWantedDetail(){
        otcApi.rx.request(.otcWantedDetail(advertId:advertId))
            .customObjectMap(EXOTCWantedModel.self)
            .subscribe{[weak self] event in
                switch event {
                case .success(let model):
                    self?.handleWanted(model: model)
                    break
                case .failure(_):
                    break
                }
            }.disposed(by: self.disposeBag)
    }
    
    func getTradeTypeDesc()->String {
        if self.tradeType == .otcbuy {
            return "otc_action_buy".localized()
        }else if self.tradeType == .otcsell {
            return "otc_action_sell".localized()
        }else {
            return ""
        }
    }
    
    func handleWanted(model:EXOTCWantedModel) {
        self.wantedModel = model
        let desc = self.getTradeTypeDesc()
        self.navigation.setTitle(title:desc + " " + model.coin.aliasName())
        self.userInputField.symbol = model.coin
        self.updateUserInputUI(type: self.paymentType)
        self.updatePriceInputUI()
        tradingInfoView.bindTradingWithData(item: model)
        userInputField.setBottomRightText(value: "otc_text_priceLimit".localized() + " " + model.fmtMin() + model.payCoin + "-" + model.fmtMax() + model.payCoin)
        if tradeType == .otcsell {
            var str = LanguageTools.getString(key: "otc_asset_availableBalance")
            if EXAppConfigManager.sharedInstance.didOpenB2C(){
                str = LanguageTools.getString(key: "otc_asset_availableBalance_forotc")
            }
            advanceLab.text = String(format: "\(str):%@%@", model.currentUserBanlance.formatAmount(model.coin),model.coin.aliasName())
        }
    }
    
}
