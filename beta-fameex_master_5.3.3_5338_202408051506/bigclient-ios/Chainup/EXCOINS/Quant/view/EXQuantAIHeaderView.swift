//
//  EXQuantAIHeaderView.swift
//  Chainup
//
//  Created by wangdong on 2023/1/29.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import RxSwift
import EXKit

class EXQuantAIHeaderView: UIView {
    
    var heightCallBack: ((CGFloat) -> Void)?
    
    var contentInsets: UIEdgeInsets = .init(top: 10, left: 16, bottom: 20, right: 16) {
        didSet {
            guard contentView.superview != nil else { return }
            contentView.snp.updateConstraints { $0.edges.equalToSuperview().inset(contentInsets) }
        }
    }
    
    private lazy var contentView: UIView = {
        let v = UIView()
        return v
    }()
    
    lazy var sevenAnnualizedYieldValueLabel: EXQuantLabel = {
        let v = EXQuantLabel(left: "quant_seven_annualized_yield".localized())
        return v
    }()
    
    lazy var priceSectionValueLabel: EXQuantLabel = {
        let v = EXQuantLabel(left: "quant_price_section".localized())
        return v
    }()
    
    lazy var gridAmountValueLabel: EXQuantLabel = {
        let v = EXQuantLabel(left: "quant_grid_amount".localized())
        return v
    }()
    
    lazy var everyProfitValueLabel: EXQuantLabel = {
        let v = EXQuantLabel(left: "quant_every_profit".localized())
        return v
        
    }()
    
    
    ///
    lazy var investmentValueLabel: EXQuantLabel = {
        let v = EXQuantLabel(left: "quant_quote_amount".localized())
        v.rightView = useOwnBaseLabel
        return v
    }()
    
    lazy var useOwnBaseLabel: UILabel = {
        let v = UILabel()
        v.textColor = .Ex.text2
        v.font = .Ex.medium(12)
        return v
    }()
    lazy var useOwnBaseSwitch: EXSwitchV6 = {
        let v = EXSwitchV6()
        v.snp.makeConstraints {$0.size.equalTo(CGSize(width: 34, height: 18))}
        return v
    }()
    
    lazy var quoteAmountInputView: EXQuantAmountInputView = {
        let v = EXQuantAmountInputView()
        v.setPlaceHolder(placeHolder: "otc_text_total".localized(), font: 14)
        return v
    }()
    ///
    ///
    lazy var stopSLTPButton: EXImageButton = {
        let v = EXImageButton(type: .custom)
        v.textLabel.font = .Ex.regular(12)
        v.textLabel.textColor = .Ex.text2
        v.textLabel.text = "quant_stop_hign_and_low".localized() + "common_text_optionalinput".localized()
        v.image = .themeImageNamed(imageName: "public_hint").reSizeImage(reSize: CGSize(width: 12, height: 12))
        v.imagePosition = .right
        v.addTarget(self, action: #selector(tipBtnAction), for: .touchUpInside)
        return v
    }()
    
    lazy var stopLowInputView: EXQuantAmountInputView = {
        let v = EXQuantAmountInputView()
        v.setPlaceHolder(placeHolder: "quant_stop_low_price".localized(), font: 14)
        return v
    }()
    
    lazy var stopHighInputView: EXQuantAmountInputView = {
        let v = EXQuantAmountInputView()
        v.setPlaceHolder(placeHolder: "quant_stop_high_price".localized(), font: 14)
        return v
    }()
    
    
    lazy var stateView: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.distribution = .fill
        v.spacing = 8
        return v
    }()
    
    lazy var assetsAvailableValueLabel: UILabel = {
        let v = UILabel()
        v.font = .Ex.regular(12)
        return v
    }()
    
    lazy var confirmButton: EXButton = {
        let v = EXButton(type: .custom)
        v.setTitle("quant_start_trade".localized(), for: .normal)
        return v
    }()
    
    
    var coinSymbol:String = ""
    var baseSymbol:String = ""
    
    
    var priceRangeL:String = ""
    var priceRangeH:String = ""
    
    var coinMap:CoinMapEntity = CoinMapEntity()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        onCreate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onCreate() {
        addSubview(contentView)
        contentView.snp.makeConstraints { $0.edges.equalToSuperview().inset(contentInsets) }
        contentView.addSubViews([sevenAnnualizedYieldValueLabel, priceSectionValueLabel, gridAmountValueLabel, everyProfitValueLabel,
                                 investmentValueLabel, useOwnBaseSwitch,
                                 quoteAmountInputView,
                                 stopSLTPButton, stopLowInputView, stopHighInputView,
                                 stateView])
        stateView.addArrangedSubviews([assetsAvailableValueLabel, confirmButton])
        
        ///
        sevenAnnualizedYieldValueLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.width.equalToSuperview()
            make.height.equalTo(30)
        }
        
        priceSectionValueLabel.snp.makeConstraints { make in
            make.top.equalTo(sevenAnnualizedYieldValueLabel.snp.bottom)
            make.centerX.width.height.equalTo(sevenAnnualizedYieldValueLabel)
            make.height.equalTo(30)
        }
        gridAmountValueLabel.snp.makeConstraints { make in
            make.top.equalTo(priceSectionValueLabel.snp.bottom)
            make.centerX.width.height.equalTo(priceSectionValueLabel)
        }
        everyProfitValueLabel.snp.makeConstraints { make in
            make.top.equalTo(gridAmountValueLabel.snp.bottom)
            make.centerX.width.height.equalTo(gridAmountValueLabel)
        }
        
        ///
        investmentValueLabel.snp.makeConstraints { make in
            make.top.equalTo(everyProfitValueLabel.snp.bottom).offset(6)
            make.left.equalTo(everyProfitValueLabel)
            make.height.equalTo(28)
        }
        useOwnBaseSwitch.snp.makeConstraints { make in
            make.left.equalTo(investmentValueLabel.snp.right).offset(4)
            make.right.equalTo(everyProfitValueLabel.snp.right)
            make.centerY.equalTo(investmentValueLabel)
        }
        
        quoteAmountInputView.snp.makeConstraints { make in
            make.top.equalTo(investmentValueLabel.snp.bottom).offset(8)
            make.centerX.width.equalToSuperview()
            make.height.equalTo(44)
        }
        
        ///
        stopSLTPButton.snp.makeConstraints { make in
            make.top.equalTo(quoteAmountInputView.snp.bottom).offset(16)
            make.left.equalToSuperview()
            make.right.lessThanOrEqualToSuperview()
            make.height.equalTo(14)
        }
        stopLowInputView.snp.makeConstraints { make in
            make.top.equalTo(stopSLTPButton.snp.bottom).offset(8)
            make.left.equalToSuperview()
            make.height.equalTo(44)
        }
        stopHighInputView.snp.makeConstraints { make in
            make.left.equalTo(stopLowInputView.snp.right).offset(8)
            make.right.equalToSuperview()
            make.height.width.centerY.equalTo(stopLowInputView)
        }
        
        ///
        stateView.snp.makeConstraints { make in
            make.top.equalTo(stopLowInputView.snp.bottom).offset(16)
            make.centerX.width.equalToSuperview()
        }
        assetsAvailableValueLabel.snp.makeConstraints { make in
            make.height.equalTo(14)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        layoutIfNeeded()
        updateLayout()
    }
    
    
    private func updateLayout() {
        var height: CGFloat = 0.0
        height += contentInsets.top
        height += contentInsets.bottom
        height += CGRectGetHeight(sevenAnnualizedYieldValueLabel.frame) * 4
        height += 6
        height += CGRectGetHeight(investmentValueLabel.frame)
        height += 8
        height += CGRectGetHeight(quoteAmountInputView.frame)
        height += 16
        height += CGRectGetHeight(stopSLTPButton.frame)
        height += 8
        height += CGRectGetHeight(stopLowInputView.frame)
        height += 16
        height += CGRectGetHeight(stateView.frame)
        heightCallBack?(height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }
    
    func bindSymbol(coinSym:String,marketSym:String) {
        self.coinSymbol = coinSym
        self.baseSymbol = marketSym
        quoteAmountInputView.bindSymbol(symbol: marketSym)
        stopLowInputView.bindSymbol(symbol: marketSym)
        stopHighInputView.bindSymbol(symbol: marketSym)
        if XUserDefault.isOffLine(){
            bindAccountBalance(coinB: "--", baseB: "--")
        }
    }
    
    
    func clearData(_ clearBalance:Bool = false) {
        if clearBalance {
            bindAccountBalance(coinB: "--", baseB: "--")
        }
        quoteAmountInputView.inputTextField.text = ""
        stopLowInputView.inputTextField.text = ""
        stopHighInputView.inputTextField.text = ""
    }
    
    
    func bindAccountBalance(coinB:String,baseB:String) {
        let asset = "assets_text_available".localized()
        let balance = " \(baseB) \(self.baseSymbol.aliasName()) \(coinB) \(self.coinSymbol.aliasName())"
        let attributedText = NSMutableAttributedString(string: asset + balance)
        attributedText.setAttributes([NSAttributedString.Key.foregroundColor: UIColor.Ex.text2,
                                      NSAttributedString.Key.font: UIFont.Ex.regular(12)],
                                     range: NSRange(location: 0, length: asset.count))
        attributedText.setAttributes([NSAttributedString.Key.foregroundColor: UIColor.Ex.text1,
                                      NSAttributedString.Key.font: UIFont.Ex.regular(12)],
                                     range: NSRange(location: asset.count, length: balance.count))
        assetsAvailableValueLabel.attributedText = attributedText
    }
    
    func bindDatas(model:EXQuantAIStrategyInfoDataModel) {
        self.coinMap = EXAppMarketManager.sharedInstance.getCoinMapEntityByName(model.symbol)
        quoteAmountInputView.decimal = coinMap.price
        stopLowInputView.decimal = coinMap.price
        stopHighInputView.decimal = coinMap.price
        if model.sevenAnnualizedYield.count > 0 {
            if model.sevenAnnualizedYield.contains("-"){
                sevenAnnualizedYieldValueLabel.rightColor = .Ex.kLine.down1
                sevenAnnualizedYieldValueLabel.right = model.sevenAnnualizedYield.decimalString(value: 2) + "%"
            }else if model.sevenAnnualizedYield == "0" {
                sevenAnnualizedYieldValueLabel.rightColor = .Ex.text3
                sevenAnnualizedYieldValueLabel.right = model.sevenAnnualizedYield.decimalString(value: 2) + "%"
            }else {
                sevenAnnualizedYieldValueLabel.rightColor = .Ex.kLine.up1
                sevenAnnualizedYieldValueLabel.right = "+" + model.sevenAnnualizedYield.decimalString(value: 2) + "%"
            }
            
        }else {
            sevenAnnualizedYieldValueLabel.rightColor = .Ex.text3
            sevenAnnualizedYieldValueLabel.right = "0.00%"
        }
        
        everyProfitValueLabel.right = "\(model.everyProfitMin.formatAmountUseDecimal("2"))%~\(model.everyProfitMax.formatAmountUseDecimal("2"))%" + "(\("quant_profitNoFee_tip".localized()))"
        if let mapModel = model.configParamMap {
            self.priceRangeL = mapModel.lowestPrice.decimalString(value: coinMap.priceDecimal())
            self.priceRangeH = mapModel.highestPrice.decimalString(value: coinMap.priceDecimal())
            priceSectionValueLabel.right = "\(mapModel.lowestPrice.decimalString(value: coinMap.priceDecimal()))~\(mapModel.highestPrice.decimalString(value: coinMap.priceDecimal()))"
            gridAmountValueLabel.right = mapModel.gridNumber
            useOwnBaseSwitch.isOn = mapModel.useOwnBase == "1"
            updateCalBlanceTitle(balance: "")
        }
    }
    
    
    func updateAvailableBanlance(balance:String) {
        assetsAvailableValueLabel.text = balance
    }
    
    func updateCalBlanceTitle(balance:String) {
        let blank = LanguageTools.isHan() ? "" : " "
        if balance.count == 0 {
            useOwnBaseLabel.text = "quant_use_own_base".localized() + blank + coinMap.coinName.aliasName()
        }else {
            useOwnBaseLabel.text = "quant_use_own_base".localized() + blank + coinMap.coinName.aliasName() + "(\("grid_need_least_tips".localized())\(blank)\(balance))"
        }
    }
    
    @objc func tipBtnAction() {
        let normalAlert = EXNormalAlert()
        normalAlert.configSigleAlert(title: "coAgent_text_explain".localized(), message: "quant_stopLossProfit_tip".localized())
        EXAlert.showAlert(alertView: normalAlert)
    }
}
