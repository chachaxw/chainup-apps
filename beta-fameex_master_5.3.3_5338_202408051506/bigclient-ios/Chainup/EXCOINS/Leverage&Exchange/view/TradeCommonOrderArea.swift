//
//  TradeCommonOrderArea.swift
//  Chainup
//
//  Created by liuxuan on 2023/11/3.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
class TradeCommonOrderArea:EXTradeAreaBase {
    
    let volumeHeight = 70
    let limitPriceHeight = 40
    let rmbPriceHeight = 14
    
    weak var editingTextFiledView:UITextField?
    
    var transferBlock: EXComVoidBlock?
    
    var heighCallBack: ((CGFloat) -> Void)?
    
    var entrustEntity:EXCurrentEntrustArr = EXCurrentEntrustArr() {
        didSet {
            caculateMaxVolume()
            caculateAvailableValue()
        }
    }
    
    //Current delegation
    //Price limit input box
    lazy var priceField : EXStepField = {
        let v = EXStepField()
        v.updateBackgroundColor(with: .Ex.special2)
        v.highLightColor = orderAction == .buy ? .ThemekLine.up : .ThemekLine.down
        v.extUseAutoLayout()
        v.configLayouts(type: .horizon)
        v.input.font = .Ex.medium(14)
        v.input.keyboardType = .decimalPad
        v.decimal = "2"//accuracy
        v.textfieldValueChangeBlock = {[weak self](str) in
            if XUserDefault.getToken() == nil{
                BusinessTools.modalLoginVC()
                return
            }
            self?.caculateTradeVolume()
            self?.caculateMaxVolume()
            self?.checkBalance()
        }
        return v
    }()
    
    //Market price limit button
    lazy var priceMask : EXDirectionSelector = {
        let v = EXDirectionSelector()
        v.extSetCornerRadius(4)
        v.backgroundColor = .Ex.fill5
        v.isHidden = true
        v.titleLabel.text = "common_tip_bestPriceTransaction".localized()
        v.titleLabel.textColor = .Ex.text2
        v.icon.isHidden = true
        v.textAlignment = .center
        return v
    }()
    
    //Quantity input box
    lazy var volumeField : EXPersentageField = {
        let v = EXPersentageField()
        v.highLightColor = orderAction == .buy ? .ThemekLine.up : .ThemekLine.down
        v.extUseAutoLayout()
        v.input.keyboardType = .decimalPad
        v.input.font = .Ex.medium(14)
        v.decimal = "2"//accuracy
        v.maxValue = "0"//Maximum value
        v.setTitle(title: entity.coinName)
        v.stepField.textfieldValueChangeBlock = {[weak self](str) in
            if XUserDefault.getToken() == nil{
                BusinessTools.modalLoginVC()
                return
            }
            self?.volumeField.emptyPersentage()
            self?.caculateSellVolume()
            self?.checkBalance()
        }
        return v
    }()
    
    lazy var rmbLabel:UILabel = {
        let v = UILabel()
        v.font = .Ex.medium(12)
        v.textColor = .Ex.text3
        v.isHidden = false
        return v
    }()
    
    /// total
    lazy var amountField: EXBorderField = {
        let v = EXBorderField()
        v.corneradius = 4
        v.input.isEnabled = false
        v.input.keyboardType = .decimalPad
        v.input.font = .Ex.regular(14)
        v.highlightColor = orderAction == .buy ? .Ex.up1 : .Ex.down1
        v.decimal = "18"//精度
        v.shouldBeginEditingBlock = { _ in !BusinessTools.loginIfNeeded()}
        v.textfieldValueChangeBlock = {[weak self](str) in
            if XUserDefault.getToken() == nil{
                BusinessTools.modalLoginVC()
                return
            }
            self?.volumeField.emptyPersentage()
            print("订单金额:\(str)")
            self?.caculateBuyVolume()
            self?.caculateMaxVolume()
        }
        self.recordFirstResponder(textField: v.input)
        return v
    }()
    
    
    lazy var totalTitle:UILabel = {
        let v = UILabel()
        v.font = .Ex.medium(14)
        v.textColor = .Ex.text2
        v.text = "transaction_text_tradeSum".localized()
        return v
    }()
    
    lazy var totalValue:UILabel = {
        let v = UILabel()
        v.font = .Ex.medium(14)
        v.textColor = .Ex.text1
        v.text = "--"
        v.textAlignment = .right
        v.adjustsFontSizeToFitWidth  = true
        return v
    }()
    
    lazy var availableView: EXTradeAvailableView = {
        let v = EXTradeAvailableView()
        v.transferBlock = {[weak self] in
            guard let self else { return }
            self.transferBlock?()
        }
        return v
    }()
    
    lazy var bottomV1Spacing: UIView = {
        let v = UIView()
        return v
    }()
    
    lazy var bottomV2Spacing: UIView = {
        let v = UIView()
        return v
    }()
    
    lazy var orderCreateBtn:RepeatButton = {
        let v = RepeatButton(type: .custom)
        v.backgroundColor = .Ex.kLine.up1
        v.titleLabel?.font = .Ex.medium(16)
        v.setTitleColor(UIColor.white, for: .normal)
        v.extSetCornerRadius(4)
        return v
    }()
    
    lazy var contentView: UIView = {
        let v = UIView()
        return v
    }()
    
    lazy var topView: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.distribution = .fill
        v.spacing = 8
        return v
    }()
    
    lazy var bottomView: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.distribution = .fill
        v.spacing = 0
        return v
    }()
    
    private var topBottomSpacing: CGFloat = 12.0
    
    func recordFirstResponder(textField:UITextField) {
        NotificationCenter.default.rx
            .notification(UITextField.textDidBeginEditingNotification, object: textField)
            .subscribe(onNext: {[weak self] noti in
                guard let `self` = self else { return }
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(TradeCommonOrderArea.textFieldDidEndEditing), object: nil)
                self.editingTextFiledView = textField
            }).disposed(by: self.disposeBag)
        NotificationCenter.default.rx
            .notification(UITextField.textDidEndEditingNotification, object: textField)
            .subscribe(onNext: {[weak self] noti in
                guard let `self` = self else { return }
                self.perform(#selector(TradeCommonOrderArea.textFieldDidEndEditing), with: nil, afterDelay: 0.001)
            }).disposed(by: self.disposeBag)
    }
    
    @objc func textFieldDidEndEditing() {
        self.editingTextFiledView = nil
    }
    
    override func onCreate() {
        addSubview(contentView)
        configBtnTitle()
        
        if layoutType == .horizontal {
            availableView.isCanTransfer = true
            topBottomSpacing = 12
        } else {
            availableView.isCanTransfer = EXAppConfigManager.sharedInstance.getSupportAccounts().count > 1
            topBottomSpacing = 24
        }
        
        contentView.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView.addSubViews([topView, bottomView])
        
        /// layout: vertical
        topView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        bottomView.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(topView.snp.bottom).offset(topBottomSpacing)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        /// price: limit market
        priceField.addSubview(priceMask)
        priceMask.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        ///
        topView.addArrangedSubviews([priceField, volumeField, amountField])
        bottomView.addArrangedSubviews([availableView, bottomV2Spacing, orderCreateBtn])
        priceField.snp.makeConstraints { $0.height.equalTo(limitPriceHeight)}
        // 隐藏rmb折算
//        rmbLabel.snp.makeConstraints { $0.height.equalTo(rmbPriceHeight)}
        amountField.snp.makeConstraints { $0.height.equalTo(limitPriceHeight) }
        bottomV1Spacing.snp.makeConstraints { $0.height.equalTo(12) }
        
        
        availableView.snp.makeConstraints { $0.height.equalTo(rmbPriceHeight) }
        bottomV2Spacing.snp.makeConstraints { $0.height.equalTo(8) }
        orderCreateBtn.snp.makeConstraints { $0.height.equalTo(limitPriceHeight) }
    }
    
    
    override func onUpdateLayout(with orderWay: EXTradeOrderWay) {
        super.onUpdateLayout(with: orderWay)
//        var height: CGFloat = 0
//        height += CGRectGetHeight(topView.frame)
//        height += topBottomSpacing
//        height += CGRectGetHeight(bottomView.frame)
//        heighCallBack?(height)
    }
    
}

//MARK: Update reload
extension TradeCommonOrderArea {
    
    func configBtnTitle() {
        if XUserDefault.isOffLine() {
            orderCreateBtn.setTitle("login_action_login".localized(), for: .normal)
            orderCreateBtn.backgroundColor = self.orderAction == .buy ? UIColor.ThemekLine.up : UIColor.ThemekLine.down
        }else {
            if self.orderAction == .buy {
                orderCreateBtn.setTitle("contract_action_buy".localized() + " " + self.entity.coinName.aliasName(), for: .normal)
                orderCreateBtn.backgroundColor = UIColor.ThemekLine.up
            }else {
                orderCreateBtn.setTitle("contract_action_sell".localized() + " " + self.entity.coinName.aliasName(), for: .normal)
                orderCreateBtn.backgroundColor = UIColor.ThemekLine.down
            }
        }
    }
    
    func updateEntity(entity:CoinMapEntity) {
        self.entity = entity
        self.suggestBuyStr = ""
        self.suggestSellStr = ""
        self.rmbLabel.text = ""
        if self.layoutType == .vertical {
            let offset = self.entity.etfOpen == "1" ? 88 : 72
// 111           orderCreateBtn.snp.remakeConstraints { (make) in
//                make.top.equalTo(volumeField.snp.bottom).offset(offset)
//                make.left.equalToSuperview()
//                make.right.equalToSuperview()
//                make.height.equalTo(40)
//            }
        }
        configBtnTitle()
        reloadFiedls()
    }
    
    func updatePrice(price:String) {
        priceField.setText(text: price)
        self.setEstimateValue(price)
        
        if self.volumeField.maxValue == "0" {
            self.caculateMaxVolume()
        }
        caculateSellVolume()
    }
    
    func setDefaultTradingVolume() {
        if orderAction == .buy {
            amountField.highlightColor = .Ex.up1
        }else {
            amountField.highlightColor = .Ex.down1
        }
        amountField.setText(text: "")
        updatePlaceholder(for: amountField, with: "trade_total_money".localized(), unit: entity.marketName.aliasName())
    }
    
    func updatePlaceholder(for textField:EXTextFieldProtocol, with placeholder:String, unit:String) {
//        if layoutType == .top {
//            textField.attributedPlaceholder = placeholder.ex_toNSAttributedString(font: textField.font, textColor: .Ex.text3)
//        }else{
            textField.attributedPlaceholder = "\(placeholder)(\(unit.aliasName()))".ex_toNSAttributedString(font: textField.font, textColor: .Ex.text3)
//        }
    }
    
    func reloadFiedls(){
        reloadLimitTxtField()
        reloadVolumeTxtField()
        setDefaultTradingVolume()
        setTradingVolume("")
        caculateMaxVolume()
    }
    
    func reloadLimitTxtField() {
        priceField.decimal = entity.price
        if orderAction == .buy {//buy
            priceField.setText(text: suggestBuyStr)
            priceField.highLightColor = UIColor.ThemekLine.up
            priceField.setPlaceHolder(placeHolder:"common_text_buyPrice".localized())
        }else{//sell
            priceField.setText(text: suggestSellStr)
            priceField.highLightColor = UIColor.ThemekLine.down
            priceField.setPlaceHolder(placeHolder:"common_text_sellPrice".localized())
        }
    }
    
    func reloadVolumeTxtField() {
        volumeField.reset()
   
        if orderWay == .market && orderAction == .buy {//Only when both buying and market prices are present, the accuracy is price
            print("Market price purchase order, precision  (entity. price)")
            volumeField.decimal = entity.price
        }else {
//            volumeField.decimal = String(EXAppMarketManager.sharedInstance.getCoinPrecision(entity.coinName))
            volumeField.decimal = entity.volume
        }
        if orderAction == .buy {//buy
            volumeField.highLightColor = UIColor.ThemekLine.up
            if orderWay == .limit {//Price limit
                updatePlaceholder(for: volumeField, with: "transaction_tip_buyVolume".localized(), unit: entity.coinName.aliasName())
            }else{
                updatePlaceholder(for: volumeField, with: "transaction_text_tradeSum".localized(), unit: entity.marketName.aliasName())
            }
        }else{//sell
            volumeField.highLightColor = UIColor.ThemekLine.down
            if orderWay == .limit {//Price limit
                updatePlaceholder(for: volumeField, with: "common_text_sellVolume".localized(), unit: entity.coinName.aliasName())
            }else{
                updatePlaceholder(for: volumeField, with: "common_text_sellVolume".localized(), unit: entity.coinName.aliasName())
            }
        }
    }
}

//MARK: Calculation
extension TradeCommonOrderArea {
    //Update available balance to obtain orderlistnew updates
    //Switching between buying and selling updates
    func caculateAvailableValue() {
        if XUserDefault.isOffLine(){
            self.setAvailableLabel("--")
            return
        }
        if orderAction == .sell {
            var baseCoinBalance:String?
            var unit = entity.coinListEntity().name.aliasName()
            if unit.isEmpty {
                unit = entity.coinName
            }
            ///sell 币对数量精度
            // baseCoinBalance = entrustEntity.baseCoinBalance.decimalString1(entity.volDecimal())
            //sell 币种数量精度
            baseCoinBalance = entrustEntity.baseCoinBalance.formatAmount(unit)
            guard let balance = baseCoinBalance else {
                return
            }
            self.setAvailableLabel(balance + " " + unit)
        }else {
            var countCoinBalance:String?
            var unit = entity.marketName.aliasName()
            if unit.isEmpty {
                unit = entity.coinName
            }
            //buy 币对价格精度
            // countCoinBalance = entrustEntity.countCoinBalance.decimalString1(entity.priceDecimal())
            //buy 币种价格精度
            countCoinBalance = entrustEntity.countCoinBalance.formatAmount(unit)
            guard let balance = countCoinBalance else {
                return
            }
            self.setAvailableLabel(balance + " " + unit)
        }
    }
    
    func checkBalance() {
        if !isBalanceEnough() {
            EXAlert.showFail(msg: "common_tip_balanceNotEnough".localized(), holdResponder: true)
        }
    }
    
    func isBalanceEnough() -> Bool {
        guard let balanceValue = availableView.balanceLabel.text else { return true }
        var quantity:String? = ""
        if orderAction == .buy {
            if orderWay == .market {
                quantity = volumeField.text
            }else{
                quantity = amountField.text
            }
        }else{
            quantity = volumeField.text
        }
        guard let quantity = quantity, !quantity.isEmpty else {
            return true
        }
        let enough = quantity.lessThanOrEqual(balanceValue)
        return enough
    }
    
    //Calculate transaction volume
    //Recalculate when the price limit input box is changed
    //Recalculate when the quantity input box is changed

    func caculateTradeVolume(){
        let limitPrice:String = priceField.input.text ?? "0"
        let volume:String = volumeField.input.text ?? "0"
        setEstimateValue(limitPrice)
        
        if priceField.input.text == ""{
            setTradingVolume("")
            return
        }
        if volumeField.input.text == ""{
            setTradingVolume("")
            return
        }
        var decimals = self.entity.price
        if self.entity.marketEntity().name != ""{
            decimals = self.entity.marketEntity().showPrecision
        }
        if let precision = Int(decimals) {
            let tradingVolume = (NSString.init(string: limitPrice).multiplying(by: volume, decimals:precision) as NSString).decimalString1(precision) as String
            setTradingVolume(tradingVolume)
        }
    }
    
    //计算交易额
    //限价输入框更改时,重新计算
    //量输入框更改时,重新计算
    
    func caculateBuyVolume(){
        let limitPrice:String = priceField.input.text ?? "0"
        let amount:String = amountField.input.text ?? "0"
        
        var decimals = ""
        if orderWay == .market && orderAction == .buy {//只有买入和市价的同时，精度为price
            decimals = entity.price
        }else {
            decimals = entity.volume
        }
        if let precision = Int(decimals) {
            let tradingVolume = amount.stringByDividing(divide: limitPrice, decimal: precision)
            self.volumeField.setText(text: tradingVolume)
        }
    }
    
    //计算消费多少,btc/usdt,消费多少usdt
    func caculateSellVolume(){
        let limitPrice:String = priceField.input.text ?? "0"
        let volume:String = volumeField.input.text ?? "0"
        
        if priceField.input.text == ""{
            setDefaultTradingVolume()
            return
        }
        if volumeField.input.text == ""{
            setDefaultTradingVolume()
            return
        }
        var decimals = self.entity.price
        if self.entity.marketEntity().name != ""{
            decimals = self.entity.marketEntity().showPrecision
        }
        if let precision = Int(decimals) {
            let tradingVolume = limitPrice.stringByMultiplying(multiple: volume, decimal: precision,holdZero: false).decimalString1(precision) as String
            setTradingVolume(tradingVolume)
        }
    }
    
    
    //Set the maximum value of the percentage control
    //Recalculate when updating the current delegate model
    //Recalculate when the price limit input box is changed
    //Change limit/market price, recalculate
    //Change buying and selling, recalculate
    func caculateMaxVolume(){
        if orderWay == .market {//market price
            if orderAction == .buy {//buy
                let t0 = self.entrustEntity.countCoinBalance
                volumeField.maxValue = t0
            }else{//Pay the bill
                let t0 = self.entrustEntity.baseCoinBalance
                volumeField.maxValue = t0
            }
            return
        }else {
            //Price limit
            if orderAction == .sell {//vouchers of sale
                let t0 = self.entrustEntity.baseCoinBalance
                volumeField.maxValue = t0
            }else{//Pay the bill
                let countCoinBalance = self.entrustEntity.countCoinBalance
                if let money = self.priceField.input.text {
                    let rst = countCoinBalance.stringByDividing(divide: money, decimal: entity.volDecimal(),roundDown: true)
                    volumeField.maxValue = rst
                }
            }
        }
    }
    
    //Set transaction amount
    func setTradingVolume(_ result:String) {
        totalValue.text = result
        if Float(result) == 0.0 {
            amountField.setText(text: "0")
        } else {
            amountField.setText(text: result)
        }
    }
    
    //Set to approximately equal to
    func setEstimateValue(_ value : String){
        if orderWay == .limit {
            //If it is a price limit, it will be displayed
            rmbLabel.isHidden = value.isEmpty
        }
        let rates = EXAppMarketManager.sharedInstance.getCoinExchangeRate(entity.marketName)
        if let rmb = NSString.init(string: value).multiplying(by: rates.1, decimals: rates.2){
            rmbLabel.text = "≈\(rates.0)" + rmb
        }
        
    }
    
    //Set available balance
    func setAvailableLabel(_ text : String){
        availableView.balanceLabel.text = text
    }
}

