//
//  EXTransactionDetailView.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/3.
//  Copyright © 2023 zewu wang. All rights reserved.
//Trading and deep baseview

import UIKit
import RxSwift
import EXKit
//Currency Trading Toolbar
class EXTransactionToolView: UIView {
    
    typealias ClickBtnBlock = (Bool,Int) -> ()
    var clickBtnBlock : ClickBtnBlock?
    
    typealias ClickPriceBlock = (String) -> ()
    var clickPriceBlock : ClickPriceBlock?
    
    lazy var buyBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.layoutIfNeeded()
        btn.isSelected = true
        btn.titleLabel?.font = UIFont.ThemeFont.HeadBold
        btn.extSetAddTarget(self, #selector(clickBtn))
        btn.contentHorizontalAlignment = .left
        btn.setTitle(LanguageTools.getString(key: "contract_action_buy".localized()), for: .normal)
        btn.setTitleColor(UIColor.ThemeLabel.colorLite, for:.selected)
        btn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
        btn.tag = 1000
        return btn
    }()
    
    lazy var sellBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.layoutIfNeeded()
        btn.titleLabel?.font = UIFont.ThemeFont.HeadBold
        btn.extSetAddTarget(self, #selector(clickBtn))
        btn.contentHorizontalAlignment = .left
        btn.setTitle(LanguageTools.getString(key: "contract_action_sell".localized()), for: .normal)
        btn.setTitleColor(UIColor.ThemeLabel.colorLite, for:.selected)
        btn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
        btn.tag = 1001
        return btn
    }()
    
    lazy var unlockBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.isHidden = true
        btn.layoutIfNeeded()
        btn.titleLabel?.font = UIFont.ThemeFont.HeadBold
        btn.extSetAddTarget(self, #selector(clickBtn))
        btn.contentHorizontalAlignment = .left
        btn.setTitle(LanguageTools.getString(key: "transaction_text_unlockDeal".localized()), for: .normal)
        btn.setTitleColor(UIColor.ThemeLabel.colorLite, for:.selected)
        btn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
        btn.tag = 1002
        return btn
    }()
    
    lazy var lineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemekLine.up
        return view
    }()
    
    var price = "--"
    
    lazy var priceLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.layoutIfNeeded()
        label.text = "--"
        label.font = UIFont.ThemeFont.HeadBold
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.isUserInteractionEnabled = true
        return label
    }()
    
    lazy var aboutLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.layoutIfNeeded()
        label.text = "--"
        label.font = UIFont.ThemeFont.MinimumRegular
        label.textColor = UIColor.ThemeLabel.colorMedium
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeNav.bg
        
        addSubViews([buyBtn,sellBtn,unlockBtn,lineV,priceLabel,aboutLabel])
        buyBtn.snp.makeConstraints { (make) in
            make.height.equalTo(22)
            make.bottom.equalToSuperview().offset(-10)
            make.left.equalToSuperview().offset(13)
        }
        sellBtn.snp.makeConstraints { (make) in
            make.height.equalTo(22)
            make.bottom.equalToSuperview().offset(-10)
            make.left.equalTo(buyBtn.snp.right).offset(20)
        }
        unlockBtn.snp.makeConstraints { (make) in
            make.height.equalTo(22)
            make.bottom.equalToSuperview().offset(-10)
            make.left.equalTo(sellBtn.snp.right).offset(20)
        }
        lineV.snp.makeConstraints { (make) in
            make.height.equalTo(3)
            make.bottom.equalToSuperview()
            make.centerX.equalTo(buyBtn)
            make.width.equalTo(20)
        }
        priceLabel.snp.makeConstraints { (make) in
            make.height.equalTo(16)
            make.bottom.equalTo(aboutLabel.snp.top).offset(-3)
            make.right.equalToSuperview().offset(-15)
        }
        aboutLabel.snp.makeConstraints { (make) in
            make.height.equalTo(12)
            make.bottom.equalToSuperview().offset(-7)
            make.right.equalToSuperview().offset(-15)
        }
        
        let priceTap = UITapGestureRecognizer.init(target: self, action: #selector(clickPrice))
        self.priceLabel.addGestureRecognizer(priceTap)
    }
    
    @objc func clickBtn(_ btn : UIButton){
        if btn.tag == 1002{
            if XUserDefault.getToken() == nil{
                BusinessTools.modalLoginVC()
                return
            }
        }
        buyBtn.isSelected = btn == buyBtn ? true : false
        sellBtn.isSelected = btn == sellBtn ? true : false
        unlockBtn.isSelected = btn == unlockBtn ? true : false
        
        clickBtnBlock?(buyBtn.isSelected,btn.tag)
        
        lineV.backgroundColor = buyBtn.isSelected ? UIColor.ThemekLine.up : UIColor.ThemekLine.down
        lineV.snp.remakeConstraints { (make) in
            make.height.equalTo(3)
            make.bottom.equalToSuperview()
            make.centerX.equalTo(btn)
            make.width.equalTo(20)
        }
    }
    
    @objc func clickPrice(){
        if price != "--"{
            self.clickPriceBlock?(price)
        }
    }
    
    //Update display
    func reloadDatas(){
        priceLabel.text = "--"
        aboutLabel.text = "--"
    }
    
    func setUnlock(_ entity : CoinMapEntity){
        if entity.coinListEntity().isOvercharge == "1"{
            unlockBtn.isHidden = false
        }else{
            unlockBtn.isHidden = true
            clickBtn(buyBtn)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//View of transactions
class EXTransactionTradingV : UIView{
    
    var isLeverage = false
    
    let priceArr = [LanguageTools.getString(key: "contract_action_limitPrice"),LanguageTools.getString(key: "contract_action_marketPrice")]

    typealias ClickTradBlock = ([String : String]) -> ()//Click on transaction callback
    var clickTradBlock : ClickTradBlock?
    
    typealias ClickPriceBlock = (Int) -> ()//Click on the price limit market price
    var clickPriceBlock : ClickPriceBlock?

    typealias ClickLockBtnBlock = () -> ()//Click to unlock and sell
    var clickLockBtnBlock : ClickLockBtnBlock?

    var buy = true//True buy false sell
    {
        didSet{
            self.reloadBuy()
        }
    }
    
    var buyTitle = LanguageTools.getString(key: "contract_action_buy")
    
    var sellTitle = LanguageTools.getString(key: "contract_action_sell")
    
    var price = 0//0 price limit 1 market price
    {
        didSet{
            self.reloadPrice()
        }
    }
    
    func setBtnTitle(_ buy : String , sell : String){
        buyTitle = buy
        sellTitle = sell
        reloadBuy()
    }
    
    //Current user information
    var currentEntity = EXCurrentEntrustArr()
    {
        didSet{
            self.setDownLabel()
            self.setCurrent()
        }
    }
    
    var entity = CoinMapEntity()
    
    var parities : (String , String , Int) = ("$","0",0)//exchange rate

    //Unlock sell button
    lazy var lockSellBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.isHidden = true
        btn.titleLabel?.font = UIFont.ThemeFont.BodyRegular
        btn.setTitle("common_text_unlockSell".localized(), for: .normal)
        btn.setTitleColor(UIColor.ThemeBtn.highlight, for: .normal)
        btn.contentHorizontalAlignment = .right
        btn.extSetAddTarget(self, #selector(clickLockBtn))
        return btn
    }()
    
    //Market price limit button
    lazy var chargeBtn : EXDirectionButton = {
        let btn = EXDirectionButton()
        btn.extUseAutoLayout()
        btn.titleLabel.font = UIFont.ThemeFont.BodyRegular
        btn.text(content: LanguageTools.getString(key: "contract_action_limitPrice"))
        btn.addTarget(self, action: #selector(clickChargeBtn), for: UIControl.Event.touchUpInside)
        return btn
    }()
    
    //Net value display label
    lazy var networthLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.isHidden = true
        label.textAlignment = .right
        label.layoutIfNeeded()
        return label
    }()
    
    //Net value display button
    lazy var networthBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.setImage(UIImage.themeImageNamed(imageName: "assets_doubt"), for: .normal)
        btn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
        btn.addTarget(self, action: #selector(clickNetWorth), for: UIControl.Event.touchUpInside)
        btn.isHidden = true
        return btn
    }()
    
    //Upper Input Box
    lazy var upTextField : EXStepField = {
        let text = EXStepField()
        text.extUseAutoLayout()
        text.input.keyboardType = UIKeyboardType.decimalPad
        text.decimal = "2"//accuracy
        
        text.textfieldValueChangeBlock = {[weak self](str) in
            if XUserDefault.getToken() == nil{
                BusinessTools.modalLoginVC()
                return
            }
            self?.computeLTurnover()
            self?.setDownLabel()
        }
        
        return text
    }()
    
    //Page blocked above
    lazy var upLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.isHidden = true
        label.isUserInteractionEnabled = true
        label.extSetCornerRadius(4)
        label.extSetBorderWidth(1, color: UIColor.ThemeView.seperator)
        label.backgroundColor = UIColor.ThemeNav.bg
        label.font = UIFont.ThemeFont.BodyRegular
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.text = "   " + LanguageTools.getString(key: "common_tip_bestPriceTransaction")
        return label
    }()
    
    //Approximately equal to price
    lazy var priceAboutLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.SecondaryRegular
        return label
    }()
    
    //Input box below
    lazy var downTextField : EXPersentageField = {
        let text = EXPersentageField()
        text.extUseAutoLayout()
        text.input.keyboardType = UIKeyboardType.decimalPad
        text.decimal = "2"//accuracy
        text.maxValue = "0"//Maximum value
        text.textfieldValueChangeBlock = {[weak self](str) in
            if XUserDefault.getToken() == nil{
                BusinessTools.modalLoginVC()
                return
            }
            self?.computeLTurnover()
        }
        return text
    }()
    
    //Available balance
    lazy var availableLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.SecondaryRegular
        return label
    }()
    
    //Transaction volume
    lazy var turnoverLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        return label
    }()
    
    //Transaction button
    lazy var tradingBtn : EXButton = {
        let btn = EXButton()
        btn.extUseAutoLayout()
        btn.color = UIColor.ThemekLine.up
        btn.extSetAddTarget(self, #selector(clickTradingBtn))
        return btn
    }()
    
    var timer : Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.bg
        self.addSubViews([chargeBtn,networthLabel,networthBtn,upTextField,priceAboutLabel,priceAboutLabel,downTextField,availableLabel,turnoverLabel,tradingBtn,upLabel,lockSellBtn])
        chargeBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(14)
            make.top.equalToSuperview().offset(20)
        }
        networthLabel.snp.makeConstraints { (make) in
            make.height.equalTo(12)
            make.right.equalTo(networthBtn.snp.left).offset(-5)
            make.left.equalTo(chargeBtn.snp.right).offset(5)
            make.centerY.equalTo(chargeBtn)
        }
        networthBtn.snp.makeConstraints { (make) in
            make.height.width.equalTo(14)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(chargeBtn)
        }
        
        upTextField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(44)
            make.top.equalTo(chargeBtn.snp.bottom).offset(15)
        }
        upLabel.snp.makeConstraints { (make) in
            make.edges.equalTo(upTextField)
        }
        priceAboutLabel.snp.makeConstraints { (make) in
            make.height.equalTo(12)
            make.top.equalTo(upTextField.snp.bottom).offset(9)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        downTextField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(74)
            make.top.equalTo(priceAboutLabel.snp.bottom).offset(14)
        }
        availableLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(17)
            make.top.equalTo(downTextField.snp.bottom).offset(8)
        }
        turnoverLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(17)
            make.top.equalTo(availableLabel.snp.bottom).offset(25)
        }
        tradingBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(44)
            make.top.equalTo(turnoverLabel.snp.bottom).offset(8)
        }
        lockSellBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.left.equalTo(chargeBtn.snp.right).offset(10)
            make.height.equalTo(14)
            make.centerY.equalTo(chargeBtn)
        }
        
        self.setAvailableLabel("--")
        self.setTurnoverLabel("--")
        self.reloadBuy()
        
        timer = Timer.init(timeInterval: 3, repeats: true, block: {[weak self] (time) in
            if time == self?.timer{
                self?.getNetWorth()
            }
        })
        RunLoop.main.add(timer!, forMode: RunLoop.Mode.common)
        timer?.fireDate = Date.distantFuture
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EXTransactionTradingV{
    
    //Obtain Net Worth
    func getNetWorth(){
        if entity.etfOpen != "1"{
            return
        }
        appApi.hideAutoLoading()
        appApi.rx.request(AppAPIEndPoint.etfNetValue(base: entity.coinName, quote: entity.marketName)).MJObjectMap(EXETFNetValueModel.self,false).subscribe(onSuccess: {[weak self] (model) in
            self?.setNetWorth(model.price)
        }) { (error) in
            
        }.disposed(by: disposeBag)
    }
    
    func isETF(_ b : Bool){
        networthLabel.isHidden = !b
        networthBtn.isHidden = !b
        setNetWorth("--")
    }
    
    //Set net value
    func setNetWorth(_  str : String){
        let attstr = NSMutableAttributedString.init().add(string: "etf_text_networth".localized(), attrDic: [NSAttributedString.Key.font : UIFont.ThemeFont.SecondaryRegular,NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorMedium]).add(string: str, attrDic: [NSAttributedString.Key.font : UIFont.ThemeFont.SecondaryRegular,NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorLite])
        networthLabel.attributedText = attstr
    }
    
    //Click Net Value
    @objc func clickNetWorth(){
        let alert = EXNormalAlert()
        alert.configSigleAlert(title: "", message: "etf_text_networthPrompt".localized())
        //show
        EXAlert.showAlert(alertView: alert)
     }
    
    func reloadPrice(){
        chargeBtn.text(content: priceArr[price])
        priceAboutLabel.isHidden = price != 0
        turnoverLabel.isHidden = price != 0
        upLabel.isHidden = price == 0//Price limit without obstruction
        reloadView()
    }
    
    func reloadBuy(){
        tradingBtn.color = buy ? UIColor.ThemekLine.up : UIColor.ThemekLine.down
        upTextField.input.text = ""
        downTextField.input.text = ""
        if buy == true{//buy
            
            upTextField.setPlaceHolder(placeHolder: LanguageTools.getString(key: "common_text_buyPrice"))
            tradingBtn.setTitle(buyTitle, for: .normal)
        }else{//sell
            upTextField.setPlaceHolder(placeHolder: LanguageTools.getString(key: "common_text_sellPrice"))
            tradingBtn.setTitle(sellTitle, for: .normal)
        }
        downTextField.emptyPersentage()
        downTextField.volumeColor = tradingBtn.color
        reloadView()
    }
    
    func reloadView(){
        if buy == true{//buy
            if price == 0{//Price limit
                downTextField.setPlaceHolder(placeHolder: LanguageTools.getString(key: "transaction_tip_buyVolume".localized()))
//                downTextField.symbolLabel.text = entity.coinName.aliasName()
            }else{
                downTextField.setPlaceHolder(placeHolder: LanguageTools.getString(key: "transaction_text_tradeSum".localized()))
//                downTextField.symbolLabel.text = entity.marketName.aliasName()
            }
        }else{//sell
            if price == 0{//Price limit
                downTextField.setPlaceHolder(placeHolder: LanguageTools.getString(key: "common_text_sellVolume"))
//                downTextField.symbolLabel.text = entity.coinName.aliasName()
            }else{
                downTextField.setPlaceHolder(placeHolder: LanguageTools.getString(key: "common_text_sellVolume"))
//                downTextField.symbolLabel.text = entity.coinName.aliasName()
            }
        }
        upTextField.input.text = ""
        downTextField.input.text = ""
        setPriceAboutLabel(upTextField.input.text ?? "")
        //Setting Precision
        setEntity(self.entity)
        isETF(self.entity.etfOpen == "1")
        setDownLabel()
        setCurrent()
        computeLTurnover()
    }
    
    //Click on the price limit button
    @objc func clickChargeBtn(){
        
        let sheet = EXOldActionSheetView()
        sheet.actionIdxCallback = {[weak self](idx) in
            guard let mySelf = self else{return}
            mySelf.chargeBtn.text(content: mySelf.priceArr[idx])
            mySelf.price = idx
            mySelf.clickPriceBlock?(idx)
            mySelf.chargeBtn.checked(check: false)
        }
        sheet.actionCancelCallback = {[weak self]() in
            guard let mySelf = self else{return}
            mySelf.chargeBtn.checked(check: false)
        }
        var idx = 0
        for i in 0..<priceArr.count{
            if priceArr[i] == chargeBtn.titleLabel.text{
                idx = i
                break
            }
        }
        sheet.configButtonTitles(buttons:  priceArr,selectedIdx: idx)
        EXAlert.showSheet(sheetView: sheet)
    }
    
    //Set Entity
    func setEntity(_ entity : CoinMapEntity){
        self.entity = entity
        upTextField.decimal = entity.price
        if price == 1 && buy == true{//Only when both buying and market prices are present, the accuracy is price
            downTextField.decimal = entity.price
        }else{
            downTextField.decimal = entity.volume
        }
        upTextField.setText(text: "")
        downTextField.setText(text: "")
        downTextField.emptyPersentage()
        
        //If it's 0, hide it. If it's 1, show it
//        lockSellBtn.isHidden = entity.coinListEntity.isOvercharge == "0" || buy == true
    }
    
    //Set current available balance
    func setCurrent(){
        if XUserDefault.getToken() == nil{
            self.setAvailableLabel("--")
            return
        }
        if isLeverage == true{
            guard let baseCoinBalance = (currentEntity.baseCoinBalance.decimalNumberWithDouble() as NSString).decimalString1(8) else{return}
            guard let countCoinBalance = (currentEntity.countCoinBalance.decimalNumberWithDouble() as NSString).decimalString1(8) else{return}
            if buy == false{//sell
                let unit = entity.coinListEntity().name.aliasName()
                self.setAvailableLabel(baseCoinBalance + unit)
            }else{//buy
                let unit = entity.marketName.aliasName()
                self.setAvailableLabel(countCoinBalance + unit)
            }
        }else{
            guard let baseCoinBalance = (currentEntity.baseCoinBalance.decimalNumberWithDouble() as NSString).decimalString(18) else{return}
            guard let countCoinBalance = (currentEntity.countCoinBalance.decimalNumberWithDouble() as NSString).decimalString(18) else{return}
            if buy == false{//sell
                let unit = entity.coinListEntity().name.aliasName()
                self.setAvailableLabel(baseCoinBalance + unit)
            }else{//buy
                let unit = entity.marketName.aliasName()
                self.setAvailableLabel(countCoinBalance + unit)
            }
        }
    }
    
    //Set limit transaction amount
    func setUpText(_ text : String){
        upTextField.setText(text: text)
        setDownLabel()
        computeLTurnover()
    }
    
    //Set to approximately equal to
    func setPriceAboutLabel(_ text : String){
        if price == 0{//If it is a price limit, it will be displayed
            priceAboutLabel.isHidden = text == ""
        }
        let array = self.entity.name.components(separatedBy: "/")
        if array.count > 1{
            if let rmb = NSString.init(string: text).multiplying(by: parities.1, decimals: parities.2){
                priceAboutLabel.text = "≈\(parities.0)" + rmb
            }
        }
    }
    
    //Set Latest Price
    func setPrice(_ price : String , forced : Bool = false){
        if forced == true{
            upTextField.input.text = price
        }else{
            if upTextField.input.text == ""{
                 upTextField.input.text = price
            }
        }
    }
    
    //Set available balance
    func setAvailableLabel(_ text : String){
        availableLabel.text = LanguageTools.getString(key: "assets_text_available") + " " + text
    }
    
    //Set the maximum value and units for the button below
    func setDownLabel(){
        if price == 1{//market price
            if buy == true {//vouchers of sale
                let t0 = self.currentEntity.countCoinBalance
                downTextField.maxValue = t0
            }else{//Pay the bill
                let t0 = self.currentEntity.baseCoinBalance
                downTextField.maxValue = t0
            }
            return
        }
        //Price limit
        if buy == false{//vouchers of sale
            let t0 = self.currentEntity.baseCoinBalance
            downTextField.maxValue = t0
        }else{//Pay the bill
            let countCoinBalance = self.currentEntity.countCoinBalance
            let money = self.upTextField.input.text
            if let t0 = NSString.init(string: countCoinBalance).dividing(by: money, decimals: Int(self.entity.volume) ?? 2){
                downTextField.maxValue = t0
            }
        }
    }
    
    //Calculate transaction volume
    func computeLTurnover(){
        setPriceAboutLabel(upTextField.input.text ?? "0")
        if upTextField.input.text == ""{
            setTurnoverLabel("--")
            return
        }
        if downTextField.input.text == ""{
            setTurnoverLabel("--")
            return
        }
        var decimals = self.entity.price
        if self.entity.marketEntity().name != ""{
            decimals = self.entity.marketEntity().showPrecision
        }
        
        let turnover = (NSString.init(string: upTextField.input.text ?? "0").multiplying(by: downTextField.input.text, decimals: Int(decimals)!) as NSString).decimalString1(Int(decimals)!) + " \(self.entity.marketName.aliasName())"
        setTurnoverLabel(turnover)
    }
    
    //Set transaction amount
    func setTurnoverLabel(_ text : String){
        let att = NSMutableAttributedString.init().add(string: LanguageTools.getString(key: "transaction_text_tradeSum") + " ", attrDic: [NSAttributedString.Key.font : UIFont.ThemeFont.BodyRegular , NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorMedium]).add(string: text, attrDic: [NSAttributedString.Key.font : UIFont.ThemeFont.BodyRegular , NSAttributedString.Key.foregroundColor : UIColor.ThemeLabel.colorLite])
        turnoverLabel.attributedText = att
    }
    
    //Click on the transaction button
    @objc func clickTradingBtn(){
        
        if XUserDefault.getToken() == nil{
            BusinessTools.modalLoginVC()
            return
        }
        
        if isLeverage{//If it's a leveraged transaction
            if EXAppConfigManager.sharedInstance.getKycConfigModel("4"){
                if EXOTCSafetyCheckVm.manager.checkKycRequire(self.yy_viewController ?? UIViewController(), type: "1") == false{
                        return
                }
            }
        }else{
            if EXAppConfigManager.sharedInstance.getKycConfigModel("3"){
                if EXOTCSafetyCheckVm.manager.checkKycRequire(self.yy_viewController ?? UIViewController(), type: "1") == false{
                        return
                }
            }
        }
        
        var param : [String : String] = [:]
        param["side"] = buy == true ? "BUY" : "SELL"
        param["type"] = price == 0 ? "1" : "2"
        param["volume"] = downTextField.input.text
        param["price"] = price == 0 ? upTextField.input.text : "0"
        
        clickTradBlock?(param)
        tradingBtn.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.tradingBtn.isUserInteractionEnabled = true
        }
    }
    
    func appear(){
        timer?.fireDate = Date.init()
    }
    
    func disappear(){
        timer?.fireDate = Date.distantFuture
    }
    
    //Click to unlock and sell
    @objc func clickLockBtn(){
        self.clickLockBtnBlock?()
    }
    
}

//Deep view
class EXTransactionDepthV : UIView{
    
    var depth = "8"
    {
        didSet{
            self.setDepth()
        }
    }
    
    var entity = CoinMapEntity()
    
    typealias ClickDepthBtnBlock = (Int) -> ()//Click deep callback
    var clickDepthBtnBlock : ClickDepthBtnBlock?
    
    typealias ClickDepthBlock = (EXDepthEntity) -> ()//Click on the cell callback
    var clickDepthBlock : ClickDepthBlock?
    
    lazy var depthBtn : EXDirectionButton = {
        let btn = EXDirectionButton()
        btn.extUseAutoLayout()
        btn.addTarget(self, action: #selector(clickDepthBtn), for: UIControl.Event.touchUpInside)
        btn.layoutIfNeeded()
        btn.text(content: depth)
        return btn
    }()
    
    lazy var transactionDepthHeadV : EXTransactionDepthHeadV = {
        let view = EXTransactionDepthHeadV()
        view.extUseAutoLayout()
        return view
    }()
    
    lazy var tableView1 : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.extSetTableView(self, self)
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    lazy var tableView2 : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.extSetTableView(self, self)
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([tableView1,tableView2,depthBtn,transactionDepthHeadV])
    }
    
    //Set Entity
    func setEntity(_ entity : CoinMapEntity){
        self.entity = entity
        if entity.depthArray.count > 0{
            self.depth = "\(entity.depthArray[0])"
        }
    }
    
    //Set Depth
    func setDepth(){
        depthBtn.text(content:"kline_action_depth".localized() + self.depth)
    }
    
    //Click depth
    @objc func clickDepthBtn(){
        var arr : [String] = []
        for i in self.entity.depthArray{
            arr.append("\(i)")
        }
        let sheet = EXOldActionSheetView()
        sheet.actionIdxCallback = {[weak self](idx) in
            guard let mySelf = self else{return}
            mySelf.depthBtn.text(content: arr[idx])
            mySelf.depth = arr[idx]
            mySelf.clickDepthBtnBlock?(idx)
            mySelf.depthBtn.checked(check: false)
        }
        sheet.actionCancelCallback = {[weak self]() in
            guard let mySelf = self else{return}
            mySelf.depthBtn.checked(check: false)
        }
        var idx = 0
        for i in 0..<arr.count{
            if arr[i] == self.depth{
                idx = i
                break
            }
        }
        sheet.configButtonTitles(buttons:  arr,selectedIdx: idx)
        EXAlert.showSheet(sheetView: sheet)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


