//
//  EXQuantCustomHeaderView.swift
//  Chainup
//
//  Created by wangdong on 2023/1/29.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
class EXQuantCustomHeaderView: UIView {
    typealias GridLineTypeChanged = (String) -> ()
    var gridLineChangeBlock:GridLineTypeChanged?
    var fee:String = ""
    var high:String = ""
    var low:String = ""
    var gridNumber:String = ""
    
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
    
    
    ///
    lazy var priceSectionLabel: UILabel = {
        let v = UILabel(text:"quant_price_section".localized(),font: .Ex.medium(12), textColor: .Ex.text2)
        return v
    }()
    
    lazy var lowPriceInputView: EXQuantAmountInputView = {
        let v = EXQuantAmountInputView()
        v.setPlaceHolder(placeHolder: "quant_low_price".localized(), font: 14)
        return v
    }()
    lazy var highPriceInputView: EXQuantAmountInputView = {
        let v = EXQuantAmountInputView()
        v.setPlaceHolder(placeHolder: "quant_high_price".localized(), font: 14)
        return v
    }()
    
    
    ///
    lazy var gridNumberLabel: UILabel = {
        let v = UILabel(text:"quant_grid_amount".localized(),font: .Ex.medium(12), textColor: .Ex.text2)
        return v
    }()
    lazy var gridAmountTextField: EXQuantAmountInputView = {
        let v = EXQuantAmountInputView()
        v.inputTextField.keyboardType = .numberPad
        v.setPlaceHolder(placeHolder: "2-100".localized(), font: 14)
        return v
    }()
    lazy var gridTypeOneButton: UIButton = {
        let v = UIButton(type: .custom)
        v.extSetCornerRadius(4)
        v.setTitle("quant_grid_line_type1".localized(), for: .normal)
        v.setTitleColor(.Ex.text1, for: .normal)
        v.setTitleColor(.white, for: .selected)
        v.titleLabel?.font = .Ex.medium(14)
        v.setBackgroundColor(color: .Ex.fill3, forState: .normal)
        v.setBackgroundColor(color: .Ex.main1, forState: .selected)
        v.addTarget(self, action: #selector(updateSelectedType(btn:)), for: .touchUpInside)
        return v
    }()
    lazy var gridTypeTwoButton: UIButton = {
        let v = UIButton(type: .custom)
        v.extSetCornerRadius(4)
        v.setTitle("quant_grid_line_type2".localized(), for: .normal)
        v.setTitleColor(.Ex.text1, for: .normal)
        v.setTitleColor(.white, for: .selected)
        v.titleLabel?.font = .Ex.medium(14)
        v.setBackgroundColor(color: .Ex.fill3, forState: .normal)
        v.setBackgroundColor(color: .Ex.main1, forState: .selected)
        v.addTarget(self, action: #selector(updateSelectedType(btn:)), for: .touchUpInside)
        return v
    }()
    
    
    ///
    lazy var profitsLabel: EXQuantLabel = {
        let v = EXQuantLabel(left: "quant_every_profit".localized(), leftFont: .Ex.regular(12), rightFont: .Ex.medium(12))
        return v
    }()
    
    
    ///
    lazy var investmentValueLabel: EXQuantLabel = {
        let v = EXQuantLabel(left:"quant_quote_amount".localized())
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
    
    ///
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
    
    let minProfitPublish: PublishSubject<String> = PublishSubject.init()
    var coinSymbol:String = ""
    var marketSymbol:String = ""
    var coinMap:CoinMapEntity = CoinMapEntity()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        onCreate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func onCreate() {
        addSubview(contentView)
        contentView.snp.makeConstraints { $0.edges.equalToSuperview().inset(contentInsets) }
        
        contentView.addSubViews([priceSectionLabel, lowPriceInputView, highPriceInputView,
                                 gridNumberLabel, gridAmountTextField, gridTypeOneButton, gridTypeTwoButton,
                                 profitsLabel,
                                 investmentValueLabel, useOwnBaseSwitch, quoteAmountInputView,
                                 stopSLTPButton, stopLowInputView, stopHighInputView,
                                 stateView])
        stateView.addArrangedSubviews([assetsAvailableValueLabel, confirmButton])
        
        ///
        priceSectionLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.lessThanOrEqualToSuperview()
            make.height.equalTo(30)
        }
        lowPriceInputView.snp.makeConstraints { make in
            make.top.equalTo(priceSectionLabel.snp.bottom)
            make.left.equalToSuperview()
            make.height.equalTo(44)
        }
        highPriceInputView.snp.makeConstraints { make in
            make.left.equalTo(lowPriceInputView.snp.right).offset(8)
            make.right.equalToSuperview()
            make.centerY.height.width.equalTo(lowPriceInputView)
        }
        
        ///
        gridNumberLabel.snp.makeConstraints { make in
            make.top.equalTo(lowPriceInputView.snp.bottom).offset(8)
            make.left.equalToSuperview()
            make.right.lessThanOrEqualToSuperview()
            make.height.equalTo(30)
        }
        gridAmountTextField.snp.makeConstraints { make in
            make.top.equalTo(gridNumberLabel.snp.bottom)
            make.left.equalToSuperview()
            make.height.equalTo(44)
        }
        gridTypeOneButton.snp.makeConstraints { make in
            make.centerY.height.equalTo(gridAmountTextField)
            make.left.equalTo(gridAmountTextField.snp.right).offset(8)
            make.width.equalTo(85)
        }
        gridTypeTwoButton.snp.makeConstraints { make in
            make.centerY.height.equalTo(gridTypeOneButton)
            make.left.equalTo(gridTypeOneButton.snp.right).offset(4)
            make.right.equalToSuperview()
            make.width.equalTo(85)
        }
        gridAmountTextField.setContentHuggingPriority(.required, for: .horizontal)
        gridTypeOneButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        gridTypeTwoButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        ///
        profitsLabel.snp.makeConstraints { make in
            make.top.equalTo(gridAmountTextField.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.height.equalTo(30)
        }
        
        ///
        investmentValueLabel.snp.makeConstraints { make in
            make.top.equalTo(profitsLabel.snp.bottom)
            make.left.equalToSuperview()
            make.height.equalTo(28)
        }
        
        useOwnBaseSwitch.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.left.equalTo(investmentValueLabel.snp.right).offset(4)
            make.centerY.equalTo(investmentValueLabel)
        }
        
        ///
        quoteAmountInputView.snp.makeConstraints { make in
            make.top.equalTo(investmentValueLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        ///
        stopSLTPButton.snp.makeConstraints { make in
            make.top.equalTo(quoteAmountInputView.snp.bottom).offset(16)
            make.left.equalToSuperview()
            make.height.equalTo(16)
            make.right.lessThanOrEqualToSuperview()
        }
        stopLowInputView.snp.makeConstraints { make in
            make.top.equalTo(stopSLTPButton.snp.bottom).offset(8)
            make.left.equalToSuperview()
            make.height.equalTo(44)
        }
        stopHighInputView.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.left.equalTo(stopLowInputView.snp.right).offset(8)
            make.centerY.height.width.equalTo(stopLowInputView)
        }
        
        ///
        stateView.snp.makeConstraints { make in
            make.top.equalTo(stopLowInputView.snp.bottom).offset(16)
            make.centerX.width.equalToSuperview()
        }
        assetsAvailableValueLabel.snp.makeConstraints { $0.height.equalTo(14)}
        confirmButton.snp.makeConstraints { $0.height.equalTo(40) }
        
        layoutIfNeeded()
        
        updateSelectedType(btn: gridTypeOneButton)
        gridTypeOneButton.sendActions(for: .touchUpInside)
        configProfits()
    }
    
    private func updateLayout() {
        var height: CGFloat = 0.0
        height += contentInsets.top
        height += contentInsets.bottom
        height += CGRectGetHeight(priceSectionLabel.frame)
        height += CGRectGetHeight(lowPriceInputView.frame)
        height += 8
        height += CGRectGetHeight(gridNumberLabel.frame)
        height += CGRectGetHeight(gridAmountTextField.frame)
        height += 8
        height += CGRectGetHeight(profitsLabel.frame)
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
    
    
    @objc func updateSelectedType(btn:UIButton) {
        if btn == gridTypeOneButton {
            self.gridLineChangeBlock?("1")
            gridTypeOneButton.isSelected = true
            gridTypeTwoButton.isSelected = false
            gridTypeOneButton.layer.borderColor = UIColor.ThemeView.highlight.cgColor
            gridTypeOneButton.setTitleColor(UIColor.Ex.main4, for: .normal)
            
            gridTypeTwoButton.layer.borderColor = UIColor.ThemeLabel.colorMedium.cgColor
            gridTypeTwoButton.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
            
            
        }else {
            self.gridLineChangeBlock?("2")
            gridTypeOneButton.isSelected = false
            gridTypeTwoButton.isSelected = true
            gridTypeTwoButton.layer.borderColor = UIColor.ThemeView.highlight.cgColor
            gridTypeTwoButton.setTitleColor(UIColor.Ex.main4, for: .normal)
            
            gridTypeOneButton.layer.borderColor = UIColor.ThemeLabel.colorMedium.cgColor
            gridTypeOneButton.setTitleColor(UIColor.Ex.text2, for: .normal)
        }
        
        if high.count > 0,low.count > 0, gridNumber.count > 0 {
            self.configProfitLabelRst(max: high, min: low, gridNumber: gridNumber)
        }
    }
    
    func bindSymbol(_ symbol:String) {
        self.coinMap = EXAppMarketManager.sharedInstance.getCoinMapEntityByName(symbol)
        
        self.coinSymbol = coinMap.coinName
        self.marketSymbol = coinMap.marketName
        lowPriceInputView.decimal = coinMap.price
        highPriceInputView.decimal = coinMap.price
        stopLowInputView.decimal = coinMap.price
        stopHighInputView.decimal = coinMap.price
        quoteAmountInputView.decimal = coinMap.price
        quoteAmountInputView.bindSymbol(symbol: marketSymbol)
        stopLowInputView.bindSymbol(symbol: marketSymbol)
        stopHighInputView.bindSymbol(symbol: marketSymbol)
        lowPriceInputView.bindSymbol(symbol: marketSymbol)
        highPriceInputView.bindSymbol(symbol: marketSymbol)
        updateCalBlanceTitle(balance: "")
    }
    
    func bindAccountBalance(coinB:String,baseB:String) {
        let asset = "assets_text_available".localized()
        let balance = " \(baseB) \(self.marketSymbol.aliasName()) \(coinB) \(self.coinSymbol.aliasName())"
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
        self.fee = model.makerFee
    }
    
    func clearData(_ clearBalance:Bool = false) {
        if clearBalance {
            bindAccountBalance(coinB: "--", baseB: "--")
        }
        lowPriceInputView.inputTextField.text = ""
        highPriceInputView.inputTextField.text = ""
        gridAmountTextField.inputTextField.text = ""
        stopLowInputView.inputTextField.text = ""
        stopHighInputView.inputTextField.text = ""
        quoteAmountInputView.inputTextField.text = ""
        profitsLabel.right = defaultProfit()
    }
    
    func defaultProfit() -> String {
        return "--%～--%" + "(\("quant_profitNoFee_tip".localized()))"
    }
    
    func configProfits() {
        let low =  lowPriceInputView.inputTextField.rx.text.orEmpty.distinctUntilChanged()
        let high =  highPriceInputView.inputTextField.rx.text.orEmpty.distinctUntilChanged()
        let grid =  gridAmountTextField.inputTextField.rx.text.orEmpty.distinctUntilChanged()
        
        Observable.combineLatest(low,high,grid)
            .subscribe(onNext: {[weak self] tuple in
                guard let `self` = self else {return}
                let (low,high,grid) = tuple
                
                self.high = high
                self.low = low
                self.gridNumber = grid
                
                if low.count > 0 ,high.count > 0,grid.count > 0 {
                    self.configProfitLabelRst(max: high, min: low, gridNumber: grid)
                }else {
                    self.profitsLabel.right = self.defaultProfit()
                }
            })
            .disposed(by: disposeBag)
    }
    
    func configProfitLabelRst(max:String,min:String,gridNumber:String) {
        if gridTypeOneButton.isSelected {
            profitsLabel.right = caculateProfitIsotropic(max: max, min: min, gridNumber: gridNumber) + "(\("trading_fee_deducted".localized()))"
        }else {
            profitsLabel.right = caculateProfitEquiproportional(max: max, min: min, gridNumber: gridNumber) + "(\("trading_fee_deducted".localized()))"
            
        }
    }
    
    //Equidistant grid
    func caculateProfitIsotropic(max:String,min:String,gridNumber:String) -> String {
        /*
         Differential grid (dynamic profit): min~max
         Max=((highest lowest price)/(grid quantity -1)/lowest price) - handling rate * 2
         Min=((highest price lowest price)/(grid quantity 1))/highest price (highest price lowest price)/(grid quantity 1)) - handling rate * 2
         */
        if min.isEquals("0") {
            return self.defaultProfit()
        }
        
        let maxPrice:String = max
        let minPrice:String = min
        let gridNumber:String = gridNumber
        let fee:String = self.fee
        let decimal:Int = 2
        
        //Seeking the highest interest rate
        //Highest - lowest price
        let numberA = maxPrice.stringBySubtracting(sub: minPrice, decimal: -1)
        //Number of Grids -1
        let numberB = gridNumber.stringBySubtracting(sub: "1", decimal: -1)
        //divde = a/b/
        let divde = numberA.stringByDividing(divide: numberB, decimal:-1)
        // maxrsta = divide/min
        let maxrstA = divde.stringByDividing(divide: minPrice, decimal: -1)
        // fee*2
        let feeRst = fee.stringByMultiplying(multiple: "2", decimal: -1)
        //max
        let maxRst = maxrstA.stringBySubtracting(sub: feeRst, decimal: -1)
        
        //Seeking the lowest interest rate
        //((numberA/numberB)/(maxPrice-(numberA/numberB))- feeRst
        let minA = maxPrice.stringBySubtracting(sub: divde, decimal: -1)
        let minB = divde.stringByDividing(divide: minA, decimal: -1)
        //min
        let minRst = minB.stringBySubtracting(sub: feeRst, decimal: -1)
        
        let persentMin = minRst.stringByMultiplying(multiple: "100", decimal: decimal,holdZero: true)
        let persentMax = maxRst.stringByMultiplying(multiple: "100", decimal: decimal,holdZero: true)
        self.minProfitPublish.onNext(persentMin)
        return "\(persentMin)%～\(persentMax)%"
    }
    
    func caculateProfitEquiproportional(max:String,min:String,gridNumber:String) -> String {
        /*
         Equal ratio grid (fixed profit): ((highest/lowest price) to the power of grid quantity -1) - handling rate * 2-1
         */
        if min.isEquals("0") {
            return self.defaultProfit()
        }
        
        let maxPrice:String = max
        let minPrice:String = min
        let gridNumber:String = gridNumber
        let fee:String = self.fee
        let decimal:Int = 2
        
        let feeRst = fee.stringByMultiplying(multiple: "2", decimal: -1)
        
        if let divde = Double(maxPrice.stringByDividing(divide: minPrice, decimal:-1)),
           let numberB = Double(gridNumber.stringBySubtracting(sub: "1", decimal: -1)) {
            if numberB > 0 {
                let rstDouble = "\(pow(divde,1/numberB))"
                let minRst = rstDouble.stringBySubtracting(sub: feeRst, decimal: -1)
                let rst = minRst.stringBySubtracting(sub: "1", decimal: -1)
                let persent = rst.stringByMultiplying(multiple: "100", decimal: decimal,holdZero: true)
                self.minProfitPublish.onNext(persent)
                return "\(persent)%"
            }
            return ""
        }else {
            return ""
        }
    }
    
    
    @objc func tipBtnAction() {
        let normalAlert = EXNormalAlert.init()
        normalAlert.configSigleAlert(title: "coAgent_text_explain".localized(), message: "quant_stopLossProfit_tip".localized())
        EXAlert.showAlert(alertView: normalAlert)
    }
    
    func updateCalBlanceTitle(balance:String) {
        let blank = LanguageTools.isHan() ? "" : " "
        if balance.count == 0 {
            useOwnBaseLabel.text = "quant_use_own_base".localized() + blank + coinMap.coinName.aliasName()
        }else {
            useOwnBaseLabel.text = "quant_use_own_base".localized() + blank + coinMap.coinName.aliasName() + "(\("grid_need_least_tips".localized())\(blank)\(balance))"
        }
    }
}

