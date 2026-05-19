//
//  EXPublishAdvertiseMarkVc.swift
//  Chainup
//
//  Created by ljw on 2023/10/9.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit


enum AdvertiseType {
    case publisAdvertise //Advertising
    case advertiseDetail //Ad Details 
    case advertiseClose //Turn off advertising
    
}
typealias callbackBlock = (_ type : AdvertiseType, _ advertiseID : String, _ isSell : Bool) -> ()
class EXPublishAdvertiseMarkVc: BaseVC,NavigationPlugin {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var block : callbackBlock?
    @IBOutlet weak var coinTypeNameStackView: UIStackView!
    @IBOutlet weak var advertiseIDStackView: UIStackView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var adverTypeLab: UILabel!
    @IBOutlet weak var sellBtn: UIButton!
    @IBOutlet weak var buyBtn: UIButton!
    @IBOutlet weak var coinTypeField: EXSelectionField!
    @IBOutlet weak var amountField: EXWithDrawAmountField!
    @IBOutlet weak var referenceLab: UILabel!
    @IBOutlet weak var buyWidth: NSLayoutConstraint!
    @IBOutlet weak var sellWidth: NSLayoutConstraint!
    @IBOutlet weak var referenceMoneyLab: UILabel!
    @IBOutlet weak var priceMethodField: EXSelectionField!
    @IBOutlet weak var YijiaDirectionField: EXSelectionField!
    @IBOutlet weak var YijiaPercentField: EXWithDrawAmountField!
    @IBOutlet weak var singleMoneyLab: UILabel!
    @IBOutlet weak var singleCnyLab: UILabel!
    @IBOutlet weak var allAmountLab: UILabel!
    @IBOutlet weak var allAmountCnyLab: UILabel!
    @IBOutlet weak var minLimitField: EXWithDrawAmountField!
    @IBOutlet weak var maxLimitField: EXWithDrawAmountField!
    @IBOutlet weak var payTimeField: EXWithDrawAmountField!
    @IBOutlet weak var minPayTimesField: EXTextField!
    @IBOutlet weak var validTimeField: EXSelectionField!
    @IBOutlet weak var getMethodLab: UILabel!
    @IBOutlet weak var autoBackField: EXTextField!
    @IBOutlet weak var leaveWordsField: EXTextField!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var shapeImageV: UIImageView!//Question mark on the right side of the reference price
    @IBOutlet weak var yijiaDirectionConTopMargin: NSLayoutConstraint!
    @IBOutlet weak var yijiaDirectionConH: NSLayoutConstraint!
    @IBOutlet weak var singleMoneyStackConTopMargin: NSLayoutConstraint!
    @IBOutlet weak var singleMoneyStackConH: NSLayoutConstraint!
    @IBOutlet weak var baseScr: UIScrollView!
    @IBOutlet weak var nPayLab: UILabel!//There is no payment method available
    @IBOutlet weak var pubulishBtn: EXButton!
    @IBOutlet weak var bottomMarginCon: NSLayoutConstraint!
    @IBOutlet weak var topStackViewConTopMargin: NSLayoutConstraint!
    @IBOutlet weak var chooseStackViewTopMarginCon: NSLayoutConstraint!
    @IBOutlet weak var chooseStackViewConH: NSLayoutConstraint!
    @IBOutlet weak var chooseStackView: UIStackView!
    @IBOutlet weak var creatTimeField: EXSelectionField!
    @IBOutlet weak var advertiseIDTitleLab: UILabel!
    @IBOutlet weak var chooseCoinView: UIView!
    @IBOutlet weak var chooseLab: UILabel!
    @IBOutlet weak var advertiseTypeLab: UILabel!
    @IBOutlet weak var chooseCoinNameLab: UILabel!
    @IBOutlet weak var advertiseIDLab: UILabel!
    @IBOutlet weak var coinTitleLab: UILabel!
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var coinNameLab: UILabel!
    @IBOutlet weak var allAmountFieldConH: NSLayoutConstraint!
    var isMarKet = true//Pricing method (default to market price)
    var isUpReferencePrice = true //Premium direction (default higher than reference price)
    var isFlag = false//Record the first point to sell
    var currentBtn = UIButton()//Record current purchase, sold
    var advertiseType = AdvertiseType.publisAdvertise
    var advertisID = ""//Advertising ID: If you pass it on, you will view the details of the advertisement. If you don't pass it on, you will be publishing the advertisement
    var advertiseDetailModel = EXOTCWantedModel()
    var symbol = ""
    var advance = "0"//Off site balance
    var allMoney = "0"//total
    var referencePrice = "0"//Market reference price
    var coinTypeArr = [EXFilterItem]()
    var currentCoinTypeModel = EXFilterItem()//The currently selected currency type
    var getMethodArr = [EXOTCPaymentListModel]()//payment method 
    var modelsArr = [EXOTCPaymentListModel]()//Real data source used for presentation
    var priceMethodArr = [LanguageTools.getString(key: "otc_market_price"),LanguageTools.getString(key: "otc_custom_price")]
    var jiJiaDirectionArr = [LanguageTools.getString(key: "otc_aboveReference_price"),LanguageTools.getString(key: "otc_belowReference_price")]
    var validTimeArr = ["2","4","7","30"]
    var selectValidDay = "30"//Default selected expiration time
    
    @IBOutlet weak var collectionViewHCon: NSLayoutConstraint!
    
    lazy var navigation : EXNavigation = {
           let nav =  EXNavigation.init(affectScroll: self.baseScr, presenter: self)
           return nav
       }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindCollectionView()
        advertiseType = advertisID.count > 0 ? .advertiseDetail : .publisAdvertise//If the advertisement ID has a value, it means checking the details, otherwise it means publishing the advertisement
        setBasicProperty()
        configNavigation()
        if advertiseType == .publisAdvertise {
            getData()
        }else{
           loadWantedDetail()//Ad Details
        }
        configUI()
    }
}
extension EXPublishAdvertiseMarkVc {
    func bindCollectionView() {
        let layout = UICollectionViewFlowLayout.init()
       layout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 2 * 15)/3, height: 34)
       
       layout.minimumLineSpacing = 5
       layout.minimumInteritemSpacing = 0
       layout.scrollDirection = .vertical
       collectionView.isScrollEnabled = false
       self.collectionView.collectionViewLayout = layout
       collectionView?.register(UINib.init(nibName: "EXPublishAdvertiseCollectionCell", bundle: nil), forCellWithReuseIdentifier: "EXPublishAdvertiseCollectionCell")
    }
    
    
    
    func setBasicProperty() {
        //Ad Details 
       if advertiseType == AdvertiseType.advertiseDetail {
           contentView.isUserInteractionEnabled = false
          _ = contentView.findAllTextFields().map { $0.isUserInteractionEnabled = false }
          _ = contentView.subviews.filter { $0 is EXSelectionField }.map { $0.isUserInteractionEnabled = false }
           selectValidDay = ""
           coinTypeField.triangle.isHidden = true
           priceMethodField.triangle.isHidden = true
           validTimeField.triangle.isHidden = true
           YijiaDirectionField.triangle.isHidden = true
           buyBtn.isHidden = true
           sellBtn.isHidden = true
           allAmountFieldConH.constant = 54
           creatTimeField.enableTitleModel = true
           creatTimeField.triangle.isHidden = true
           creatTimeField.setTitle(title: LanguageTools.getString(key: "otc_create_time"))
           advertiseIDTitleLab.text = LanguageTools.getString(key: "otc_text_advertiseID")
           coinTitleLab.text = LanguageTools.getString(key: "common_text_coinsymbol")
           lineView.isHidden = true
           chooseCoinView.isHidden = true
           chooseStackViewConH.constant = 0
       }else {
           symbol =  OTCPulbicManager.sharedInstance.getDefaultOTCCoinEntity().name
           topStackViewConTopMargin.constant = 0
           advertiseTypeLab.isHidden = true
           advertiseIDStackView.isHidden = true
           coinTypeNameStackView.isHidden = true
           creatTimeField.isHidden = true
           chooseCoinView.backgroundColor = UIColor.ThemeView.bg
           chooseCoinNameLab.text = symbol.aliasName()
           chooseLab.text = LanguageTools.getString(key: "charge_action_selectCoin")
           let tap = UITapGestureRecognizer.init(target: self, action: #selector(chooseCoinAction));
           chooseLab.superview?.addGestureRecognizer(tap)
       }
    }
    func configNavigation(){
        self.navigation.setdefaultType(type:.list)
        if advertiseType == .advertiseDetail {
            self.navigation.setTitle(title:LanguageTools.getString(key: "otc_advertise_detail"))
        }else {
            self.navigation.setTitle(title:LanguageTools.getString(key: "otc_publish_advertise"))
            navigation.customBack = true
            navigation.customBackCallback = {[weak self] in
                self?.handleBack()
            }
        }
    }
    func handleBack() {
        let alert = EXCommonAlert()
        alert.configAlert(title: "otc_confirm_giveupEdit".localized()) { type in
            if type == .sure {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4, execute: {
                    //Click to confirm
                    self.navigationController?.popViewController(animated: true)
                })
            }
        }
        
        //show
        EXAlert.showAlert(alertView: alert)
    }
    func largeTitleValueChanged(height: CGFloat) {
        chooseStackViewTopMarginCon.constant = height
    }
    //MARK: Load ad details
    func loadWantedDetail(){
        otcApi.rx.request(.otcWantedDetail(advertId:advertisID))
            .customObjectMap(EXOTCWantedModel.self)
            .subscribe{[weak self] event in
                switch event {
                case .success(let model):
                    self?.handleWantedDetail(model: model)
                    break
                case .failure(_):
                    break
                }
            }.disposed(by: self.disposeBag)
    }
    //MARK: Processing Advertising Details
    func handleWantedDetail(model : EXOTCWantedModel) {
        self.advertiseDetailModel = model
        getConsiderPrice()//Obtain reference price
        
        let timeStr = DateTools.strToTimeString(model.ctime, dateFormat: "yyyy-MM-dd HH:mm:ss")
        creatTimeField.setText(text:timeStr)
        advertiseIDLab.text = model.advertId
        advertiseTypeLab.text = model.side.lowercased() == "sell" ? LanguageTools.getString(key: "otc_action_sell") : LanguageTools.getString(key: "otc_action_buy")
        coinNameLab.text = model.coin.aliasName()
        coinTypeField.setText(text: OTCPulbicManager.sharedInstance.getPayCurrencyUnit(model.payCoin))
        amountField.setText(text: model.volumeBalance + "/" + model.volume)
        amountField.leftSymbolLabel.text = model.coin.aliasName()
        
      
        if model.priceRateType == "0" {//0 represents custom price
            singleMoneyStackConH.constant = 0
            singleMoneyStackConTopMargin.constant = 0
            yijiaDirectionConH.constant = 0
            yijiaDirectionConTopMargin.constant = 0
            YijiaDirectionField.isHidden = true
            
            priceMethodField.setText(text: priceMethodArr[1])//custom
            YijiaPercentField.setTitle(title: LanguageTools.getString(key: "otc_userSet_singlePrice"))
            YijiaPercentField.setPlaceHolder(placeHolder: LanguageTools.getString(key: "otc_userSet_singlePrice"))
            YijiaPercentField.leftSymbolLabel.text = model.payCoin
            YijiaPercentField.setText(text: model.price.formatCurrencyMoney(model.payCoin))
        }else {
            singleMoneyStackConH.constant = 43
            singleMoneyStackConTopMargin.constant = 25
            yijiaDirectionConH.constant = 54
            yijiaDirectionConTopMargin.constant = 25
            YijiaDirectionField.isHidden = false
            
            priceMethodField.setText(text: priceMethodArr[0])//Market premium
            YijiaDirectionField.setTitle(title: LanguageTools.getString(key: "otc_outPrice_direction"))
            if model.priceRateType == "2" {//Above
                YijiaDirectionField.setText(text: jiJiaDirectionArr[0])
            }else if model.priceRateType == "3" {//under
                 YijiaDirectionField.setText(text: jiJiaDirectionArr[1])
            }
           YijiaPercentField.setTitle(title: LanguageTools.getString(key: "otc_outPrice_percent"))
           YijiaPercentField.setPlaceHolder(placeHolder: LanguageTools.getString(key: "otc_outPrice_percent"))
           YijiaPercentField.leftSymbolLabel.text = "%"
           YijiaPercentField.setText(text: model.priceRate)
           singleCnyLab.text = model.price.formatCurrencyMoney(model.payCoin) + " " + model.payCoin//unit price
        }
        allAmountCnyLab.text = model.totalPrice.formatCurrencyMoney(model.payCoin) + " " + model.payCoin//total
        minLimitField.setText(text:model.minTrade.formatCurrencyMoney(model.payCoin))
        minLimitField.leftSymbolLabel.text = model.payCoin
        maxLimitField.setText(text:model.maxTrade.formatCurrencyMoney(model.payCoin))
        maxLimitField.leftSymbolLabel.text = model.payCoin
        payTimeField.input.text = model.limitTime
        minPayTimesField.input.text = model.dealVolume//Minimum number of transactions by the counterparty
        validTimeField.setText(text: model.days + LanguageTools.getString(key: "otc_advertiseValid_day"))
        if model.autoReply.count > 0 {
            autoBackField.input.text = model.autoReply
        }
        if model.Description.count > 0 {
            leaveWordsField.input.text = model.Description
        }
        if self.advertiseDetailModel.status == "1" || self.advertiseDetailModel.status == "2" {
           pubulishBtn.setTitle(LanguageTools.getString(key: "otc_close_advertise"), for: UIControl.State.normal) //Turn off advertising
        }else {
           pubulishBtn.setTitle(LanguageTools.getString(key: "otc_have_closed"), for: UIControl.State.normal)//Closed
           pubulishBtn.isEnabled = false
        }
        configPayMethod()
    }
    func getData() {
        //Obtain currency type
        if !(OTCPulbicManager.sharedInstance.isPayCoinDisplayAtListView()) {
            let payCoinModel =  OTCPulbicManager.sharedInstance.getFilterPayCoinModel()
            coinTypeArr = payCoinModel.items
            currentCoinTypeModel = coinTypeArr.first ?? EXFilterItem()
            for item in coinTypeArr {
                if item.valueKey == OTCPulbicManager.sharedInstance.getOtcDefaultPaycoin() {
                    currentCoinTypeModel = item;
                    break;
                }
            }
        
        }
        //Obtain reference prices
        getConsiderPrice()
        
        //Request account balance information
        requestOtcAccountBalance()
        
        //Obtain payment method
        paymentFind()
        
    }
   //Obtain reference prices (advertise)
   func getConsiderPrice() {
    var symbol = ""
    var payCoin = ""
    if advertiseType == .publisAdvertise {
        if currentCoinTypeModel.valueKey.isEmpty || self.symbol.isEmpty {
            return
        }
        symbol = self.symbol
        payCoin = currentCoinTypeModel.valueKey
    }else {
        if self.advertiseDetailModel.coin.isEmpty || self.advertiseDetailModel.payCoin.isEmpty {
            return
        }
        symbol = self.advertiseDetailModel.coin
        payCoin = self.advertiseDetailModel.payCoin
    }
       
       otcApi.hideAutoLoading()
       otcApi.rx.request(.considerPrice(currencySymbol:symbol, coinSymbol:payCoin))
           .MJObjectMap(EXOTCConsiderPrice.self,false)
           .subscribe{[weak self] event in
               switch event {
               case .success(let model):
                if self?.advertiseType == .publisAdvertise {
                    self?.referencePrice = model.referencePrice
                    self?.configUI()
                }else {
                    self?.referenceMoneyLab.text = model.referencePrice.formatCurrencyMoney(payCoin) + " " + payCoin
                }
                   break
               case .failure(_):
                   break
               }
           }.disposed(by: self.disposeBag)
   }
    //Request account balance
     func requestOtcAccountBalance() {
        appApi.hideAutoLoading()
        appApi.rx.request(.financeAccountList)
            .MJObjectMap(EXOTCAccountListModel.self)
            .subscribe{[weak self] event in
                switch event {
                case .success(let model):
                    self?.handleOtcAssets(model: model)
                    break
                case .failure(_):
                    break
                }
            }.disposed(by: self.disposeBag)
    }
    
    //payment method 
    func paymentFind() {
           if XUserDefault.isOffLine() {
               return
           }
           otcApi.hideAutoLoading()
           otcApi.rx.request(.paymentFind(isOpen: nil))
               .MJObjectMap(CommonAryModel.self,false)
               .subscribe{[weak self] event in
                   switch event {
                   case .success(let model):
                    if model.dictAry.count > 0 {
                        for item in model.dictAry {
                            if let model = EXOTCPaymentListModel.mj_object(withKeyValues: item) {
                                self?.getMethodArr.append(model)
                            }
                        }
                        self?.configPayMethod()
                    }
                       break
                   case .failure(_):
                       break
                   }
               }.disposed(by: self.disposeBag)
       }
   
}
extension EXPublishAdvertiseMarkVc {
    func configUI() {
        contentView.backgroundColor = UIColor.ThemeView.bg
        adverTypeLab.extSetText(LanguageTools.getString(key: "otc_advertise_type"), textColor: UIColor.ThemeLabel.colorMedium, fontSize: 12)
        buyBtn.extSetTitle(" " + LanguageTools.getString(key: "otc_action_buy"), 12, UIColor.ThemeLabel.colorMedium, UIControl.State.normal)
        buyBtn.setImage(UIImage.themeImageNamed(imageName: "public_unselected"), for: UIControl.State.normal)
        buyBtn.setImage(UIImage.themeImageNamed(imageName: "public_selected"), for: UIControl.State.selected)
        sellBtn.extSetTitle(" " + LanguageTools.getString(key: "otc_action_sell"), 12, UIColor.ThemeLabel.colorMedium, UIControl.State.normal)
        sellBtn.setImage(UIImage.themeImageNamed(imageName: "public_unselected"), for: UIControl.State.normal)
        sellBtn.setImage(UIImage.themeImageNamed(imageName: "public_selected"), for: UIControl.State.selected)
        let w = buyBtn.textWidthFit()
        let w2 = sellBtn.textWidthFit()
        self.buyWidth.constant = w
        self.sellWidth.constant = w2
        if !isFlag {
            isFlag = true
            sellBtn.isSelected = true//Default selection for sale
            currentBtn = sellBtn
        }
        coinTypeField.enableTitleModel = true
        coinTypeField.setTitle(title: LanguageTools.getString(key: "otc_coin_type"))
        coinTypeField.setPlaceHolder(placeHolder: LanguageTools.getString(key: "otc_coin_type"))
        coinTypeField.setText(text: currentCoinTypeModel.text)
        coinTypeField.textfieldDidTapBlock = {[weak self] in
            self?.coinTypeSelection()
        }
        amountField.input.keyboardType = .decimalPad
        amountField.rightSendAllLabel.isHidden = true
        amountField.verticalLine.isHidden = true
        amountField.leftSymbolLabel.text = symbol.aliasName()
        amountField.symbol = symbol
        if advertiseType == .advertiseDetail {
            amountField.setTitle(title: LanguageTools.getString(key: "otc_leaveAndTotal"))
            amountField.amountLabel.text = ""
        }else {
            amountField.setTitle(title: LanguageTools.getString(key: "otc_text_total"))
            amountField.setPlaceHolder(placeHolder: LanguageTools.getString(key: "otc_text_total"))
            amountField.setOTCAmount(amount: advance, title: LanguageTools.getString(key: "otc_out_assetsAvalaible"))
        }
        amountField.changeThemeColor(isRed: false)
        amountField.input.rx.text.orEmpty.changed.asObservable().subscribe {[weak self] (event) in
            if self?.advertiseType == AdvertiseType.advertiseDetail {return}
            //Obtain the precision of fiat currency
            let precion = EXAppMarketManager.sharedInstance.getCurrencyModel(self?.currentCoinTypeModel.valueKey ?? "").coin_precision
                 if var amountStr = event.element{//quantity
                    if amountStr.count > 32{
                        self?.amountField.input.text = amountStr[0...32]
                        amountStr = amountStr[0...32]
                    }
                    //Market price
                    if self?.isMarKet == true {
                         if let percentStr = Double(self?.YijiaPercentField.input.text ?? "") {
                              var percent = ""
                              if self?.isUpReferencePrice == true {
                                  percent = String(1.0 + percentStr / 100.0)
                              } else {
                                  percent = String(1.0 - percentStr / 100.0)
                            }
                             //Total price calculation
                             var allAmount = ((self?.referencePrice ?? "") as NSString).multiplying(by: percent, decimals: Int(precion) ?? 2) ?? ""
                             allAmount = (allAmount as NSString).multiplying(by: amountStr, decimals: Int(precion) ?? 2)
                             self?.allAmountCnyLab.text = allAmount.formatCurrencyMoney(self?.currentCoinTypeModel.valueKey ?? "") + " " + (self?.currentCoinTypeModel.valueKey ?? "")
                        }
                    }else {
                        //Custom Price
                        //Total price=custom price * quantity
                        //At this point, the premium percentage becomes a custom price
                        if let price = self?.YijiaPercentField.input.text{
                            let allAmount = (price as NSString).multiplying(by: amountStr, decimals: Int(precion) ?? 2) ?? ""
                            self?.allAmountCnyLab.text = allAmount.formatCurrencyMoney(self?.currentCoinTypeModel.valueKey ?? "") + " " + (self?.currentCoinTypeModel.valueKey ?? "")
                        }
                    }
                 
                 //Display off market balance when sold
                 if self?.sellBtn.isSelected == true {
                    if (amountStr as NSString).isBig(self?.advance) {
                        self?.amountField.changeThemeColor(isRed: true)
                     }else {
                       self?.amountField.changeThemeColor(isRed: false)
                     }
                 }
            }
        }.disposed(by: self.disposeBag)
        referenceLab.extSetText(LanguageTools.getString(key: "otc_market_ReferencPrice"), textColor: UIColor.ThemeLabel.colorMedium, fontSize: 12)
    referenceMoneyLab.extSetText(referencePrice.formatCurrencyMoney(self.currentCoinTypeModel.valueKey) + " " + self.currentCoinTypeModel.valueKey, textColor: UIColor.ThemeLabel.colorLite, fontSize: 14)
        priceMethodField.enableTitleModel = true
        priceMethodField.setTitle(title: LanguageTools.getString(key: "otc_setPrice_method"))
        priceMethodField.setPlaceHolder(placeHolder: LanguageTools.getString(key: "otc_setPrice_method"))
        if isMarKet {
           priceMethodField.setText(text: priceMethodArr[0])
        }else {
           priceMethodField.setText(text: priceMethodArr[1])
        }
        priceMethodField.textfieldDidTapBlock = {[weak self] in
            self?.priceMethod()
        }
        YijiaDirectionField.enableTitleModel = true
        YijiaDirectionField.setTitle(title: LanguageTools.getString(key: "otc_outPrice_direction"))
        YijiaDirectionField.setPlaceHolder(placeHolder: LanguageTools.getString(key: "otc_outPrice_direction"))
        if isUpReferencePrice {
            YijiaDirectionField.setText(text: jiJiaDirectionArr[0])
        }else {
            YijiaDirectionField.setText(text: referencePrice)
        }
        
        YijiaDirectionField.textfieldDidTapBlock = {[weak self] in
            self?.yiJiaDirection()
        }
       
        if isMarKet {
           YijiaPercentField.setTitle(title: LanguageTools.getString(key: "otc_outPrice_percent"))
           YijiaPercentField.setPlaceHolder(placeHolder: LanguageTools.getString(key: "otc_outPrice_percent"))
           YijiaPercentField.leftSymbolLabel.text = "%"
           YijiaPercentField.setText(text: "0.00")
           YijiaPercentField.decimalType = .coin
           YijiaPercentField.decimal = "2"
        }else {
            YijiaPercentField.setTitle(title: LanguageTools.getString(key: "otc_userSet_singlePrice"))
            YijiaPercentField.setPlaceHolder(placeHolder: LanguageTools.getString(key: "otc_userSet_singlePrice"))
            YijiaPercentField.leftSymbolLabel.text = self.currentCoinTypeModel.valueKey
            YijiaPercentField.setText(text: "")
            YijiaPercentField.decimalType = .cny
            YijiaPercentField.decimal = EXAppMarketManager.sharedInstance.getCurrencyModel(self.currentCoinTypeModel.valueKey).coin_precision
        }
        YijiaPercentField.amountLabel.text = ""
        YijiaPercentField.input.keyboardType = .decimalPad
        YijiaPercentField.rightSendAllLabel.isHidden = true
        YijiaPercentField.verticalLine.isHidden = true
        YijiaPercentField.changeThemeColor(isRed: false)
        YijiaPercentField.input.rx.text.orEmpty.changed.asObservable().subscribe { [weak self](event) in
            if self?.advertiseType == AdvertiseType.advertiseDetail {return}
            guard var str = event.element else {return}
            //Obtain the precision of fiat currency
            let precion = EXAppMarketManager.sharedInstance.getCurrencyModel(self?.currentCoinTypeModel.valueKey ?? "").coin_precision
            
            if self?.isMarKet == true{
                if str.count > 5{
                   self?.YijiaPercentField.input.text = str[0...5]
                   str = str[0...5]
                }
                //Market price
                //Total price=(1 ± 1 * Premium percentage) * Market reference price * Quantity
                //Unit price=(1 ± 1 * Premium percentage) * Market reference price
                var percent = ""
                if (str as NSString).isBig("50") {
                     if self?.isUpReferencePrice == true {
                         percent = String(1.0 + Double(50) / 100.0)
                     } else {
                         percent = String(1.0 - Double(50) / 100.0)
                     }
                  // self?.YijiaPercentField.input.text = "50.00"
                   self?.YijiaPercentField.changeThemeColor(isRed: true)
                   self?.YijiaPercentField.amountLabel.text = LanguageTools.getString(key: "otc_outPrice_percentMax")
                }else {
                      if let percentStr = Double(str) {
                           if self?.isUpReferencePrice == true {
                               percent = String(1.0 + percentStr / 100.0)
                           } else {
                               percent = String(1.0 - percentStr / 100.0)
                           }
                       }
                     self?.YijiaPercentField.amountLabel.text = ""
                     self?.YijiaPercentField.changeThemeColor(isRed: false)
                }
                //Total price calculation
                var allAmount = ((self?.referencePrice ?? "") as NSString).multiplying(by: percent, decimals: Int(precion) ?? 2) ?? ""
                allAmount = (allAmount as NSString).multiplying(by: self?.amountField.input.text ?? "", decimals: Int(precion) ?? 2)
                self?.allAmountCnyLab.text = allAmount.formatCurrencyMoney(self?.currentCoinTypeModel.valueKey ?? "") + " " + (self?.currentCoinTypeModel.valueKey ?? "")
                //Unit price calculation
                self?.singleCnyLab.text = ((self?.referencePrice ?? "") as NSString).multiplying(by: percent, decimals: Int(precion) ?? 2) + " " + (self?.currentCoinTypeModel.valueKey ?? "")
            }else {
                //Custom Price
               //Total price=custom price * quantity
               //At this point, the premium percentage becomes a custom price
                if str.count > 32{
                   self?.YijiaPercentField.input.text = str[0...32]
                   str = str[0...32]
                }
                if let amountStr = self?.amountField.input.text {
                    let allAmount = (str as NSString).multiplying(by: amountStr, decimals: Int(precion) ?? 2) ?? ""
                    self?.allAmountCnyLab.text = allAmount.formatCurrencyMoney(self?.currentCoinTypeModel.valueKey ?? "") + " " + (self?.currentCoinTypeModel.valueKey ?? "")
                }
                self?.YijiaPercentField.amountLabel.text = ""
            }
        }.disposed(by: self.disposeBag)
        
        singleMoneyLab.extSetText(LanguageTools.getString(key: "otc_text_price"), textColor: UIColor.ThemeLabel.colorMedium, fontSize: 12)
        singleCnyLab.extSetText(referencePrice.formatCurrencyMoney(self.currentCoinTypeModel.valueKey) + " " + self.currentCoinTypeModel.valueKey, textColor: UIColor.ThemeLabel.colorLite, fontSize: 14)
        
        allAmountLab.extSetText(LanguageTools.getString(key: "redpacket_send_total"), textColor: UIColor.ThemeLabel.colorMedium, fontSize: 12)
        allAmountCnyLab.extSetText("0".formatCurrencyMoney(self.currentCoinTypeModel.valueKey) + " " + self.currentCoinTypeModel.valueKey, textColor: UIColor.ThemeLabel.colorLite, fontSize: 14)
        
        
        minLimitField.setTitle(title: LanguageTools.getString(key: "otc_min_amount"))
        minLimitField.rightSendAllLabel.isHidden = true
        minLimitField.verticalLine.isHidden = true
        minLimitField.decimalType = .cny
        minLimitField.decimal = EXAppMarketManager.sharedInstance.getCurrencyModel(self.currentCoinTypeModel.valueKey).coin_precision
        minLimitField.input.keyboardType = .decimalPad
        minLimitField.setPlaceHolder(placeHolder: LanguageTools.getString(key: "otc_writeMin_amount"))
        minLimitField.setText(text: "")
        minLimitField.amountLabel.text = ""
        minLimitField.leftSymbolLabel.text = self.currentCoinTypeModel.valueKey
        minLimitField.changeThemeColor(isRed: false)
        minLimitField.input.rx.text.orEmpty.changed.asObservable().subscribe { [weak self](event) in
            if self?.advertiseType == AdvertiseType.advertiseDetail {return}
            guard let str = event.element,!str.isEmpty else {return}
            
            //Total amount
            var allAmoutStr = ((self?.allAmountCnyLab.text ?? "") as NSString).replacingOccurrences(of: " ", with: "")
            allAmoutStr = (allAmoutStr as NSString).replacingOccurrences(of: self?.currentCoinTypeModel.valueKey ?? "", with: "")
            if (str as NSString).isBig(allAmoutStr) {
                self?.minLimitField.changeThemeColor(isRed: true)
                self?.minLimitField.amountLabel.text = LanguageTools.getString(key: "otc_min_smallTotal")
                return
            }else {
                self?.minLimitField.changeThemeColor(isRed: false)
                self?.minLimitField.amountLabel.text = ""
            }
            if str.count != 0 && self?.maxLimitField.input.text?.count != 0 {
                if (str as NSString).isBig(self?.maxLimitField.input.text ?? "") || (str as NSString).isEqual(to: self?.maxLimitField.input.text ?? ""){
                    self?.minLimitField.changeThemeColor(isRed: true)
                    self?.minLimitField.amountLabel.text = LanguageTools.getString(key: "otc_min_smallMaxLimit")
                }else {
                    self?.maxLimitField.changeThemeColor(isRed: false)
                    self?.minLimitField.changeThemeColor(isRed: false)
                    self?.minLimitField.amountLabel.text = ""
                    self?.maxLimitField.amountLabel.text = ""
                }
            }
            
        }.disposed(by: self.disposeBag)
        
        maxLimitField.decimalType = .cny
        maxLimitField.decimal = EXAppMarketManager.sharedInstance.getCurrencyModel(self.currentCoinTypeModel.valueKey).coin_precision
        maxLimitField.leftSymbolLabel.text = self.currentCoinTypeModel.valueKey
        maxLimitField.rightSendAllLabel.isHidden = true
        maxLimitField.verticalLine.isHidden = true
        maxLimitField.setTitle(title: LanguageTools.getString(key: "otc_max_amount"))
        maxLimitField.input.keyboardType = .decimalPad
        maxLimitField.setPlaceHolder(placeHolder: LanguageTools.getString(key: "otc_writeMax_amount"))
        maxLimitField.setText(text: "")
        maxLimitField.amountLabel.text = ""
        maxLimitField.changeThemeColor(isRed: false)
        maxLimitField.input.rx.text.orEmpty.changed.asObservable().subscribe { [weak self](event) in
            if self?.advertiseType == AdvertiseType.advertiseDetail {return}
            guard let str = event.element,!str.isEmpty else {return}
            //Total amount
            var allAmoutStr = ((self?.allAmountCnyLab.text ?? "") as NSString).replacingOccurrences(of: " ", with: "")
            allAmoutStr = (allAmoutStr as NSString).replacingOccurrences(of: self?.currentCoinTypeModel.valueKey ?? "", with: "")
            if (str as NSString).isBig(allAmoutStr) {
                self?.maxLimitField.changeThemeColor(isRed: true)
                self?.maxLimitField.amountLabel.text = LanguageTools.getString(key: "otc_maxLimit_smallTotal")
                return
            }else {
                self?.maxLimitField.changeThemeColor(isRed: false)
                self?.maxLimitField.amountLabel.text = ""
            }
            if str.count != 0 && self?.minLimitField.input.text?.count != 0 {
                if !(str as NSString).isBig(self?.minLimitField.input.text ?? "") || (str as NSString).isEqual(to: self?.minLimitField.input.text ?? ""){
                    self?.maxLimitField.changeThemeColor(isRed: true)
                    self?.maxLimitField.amountLabel.text = LanguageTools.getString(key: "otc_MaxLimit_bigMinLimit")
                }else {
                    self?.maxLimitField.changeThemeColor(isRed: false)
                    self?.minLimitField.changeThemeColor(isRed: false)
                    self?.maxLimitField.amountLabel.text = ""
                    self?.minLimitField.amountLabel.text = ""
                }
            }
            
        }.disposed(by: self.disposeBag)
        
        
        
        payTimeField.setTitle(title: LanguageTools.getString(key: "otc_payMoney_time"))
        payTimeField.input.keyboardType = .numberPad
        payTimeField.rightSendAllLabel.isHidden = true
        payTimeField.verticalLine.isHidden = true
        payTimeField.setPlaceHolder(placeHolder: "5-60")
        payTimeField.setText(text: "5")
        payTimeField.leftSymbolLabel.text = LanguageTools.getString(key: "otc_payMoney_timeMinute")
        payTimeField.decimal = "0"
        payTimeField.amountLabel.text = ""
        payTimeField.changeThemeColor(isRed: false)
        payTimeField.input.rx.text.orEmpty.changed.asObservable().subscribe {[weak self] (event) in
            if self?.advertiseType == AdvertiseType.advertiseDetail {return}
            guard var str = event.element else {return}
            if str.count > 2{
                self?.payTimeField.input.text = str[0...2]
                str = str[0...2]
            }
            if !str.isEmpty {
                if ((str as NSString).isBig("60") || !(str as NSString).isBig("5")) && !(str as NSString).isEqual(to: "5"){
                    //self?.payTimeField.input.text = ""//Emptying
                    self?.payTimeField.changeThemeColor(isRed: true)
                    self?.payTimeField.amountLabel.text = LanguageTools.getString(key: "otc_payMoney_timeLimit")
                }else {
                    self?.payTimeField.amountLabel.text = ""
                    self?.payTimeField.changeThemeColor(isRed: false)
                }
            }

        }.disposed(by: self.disposeBag)
        minPayTimesField.enableTitleModel = true
        minPayTimesField.input.rightView = nil
        minPayTimesField.input.keyboardType = .numberPad
        minPayTimesField.setTitle(title: LanguageTools.getString(key: "otc_other_minTransactionTimes"))
        minPayTimesField.setPlaceHolder(placeHolder: LanguageTools.getString(key: "otc_writeOther_minTransactionTimes"))
        minPayTimesField.setText(text: "0")
        minPayTimesField.setExtraText(LanguageTools.getString(key: "otc_other_times"))
        minPayTimesField.input.rx.text.orEmpty.changed.asObservable().subscribe {[weak self]
            (event) in
            if self?.advertiseType == AdvertiseType.advertiseDetail {return}
            if let str = event.element, str.count > 8{
                self?.minPayTimesField.input.text = str[0...8]
            }
        }.disposed(by: self.disposeBag)
        validTimeField.enableTitleModel = true
        validTimeField.setTitle(title: LanguageTools.getString(key: "otc_text_validTime"))
        validTimeField.setPlaceHolder(placeHolder: LanguageTools.getString(key: "otc_text_validTime"))
        validTimeField.setText(text:selectValidDay + LanguageTools.getString(key: "otc_advertiseValid_day"))
        validTimeField.textfieldDidTapBlock = {[weak self] in
            self?.validTimeSelect()
        }
        getMethodLab.extSetText(LanguageTools.getString(key: "otc_getMoney_Method"), textColor: UIColor.ThemeLabel.colorMedium, fontSize: 12)
        
        
       
        
        configPayMethod()
        
        autoBackField.enableTitleModel = true
        autoBackField.setTitle(title: LanguageTools.getString(key: "otc_text_autoBack"))
        
        
        autoBackField.input.rx.text.orEmpty.changed.asObservable().subscribe {[weak self] (event) in
            if self?.advertiseType == AdvertiseType.advertiseDetail {return}
                   if let str = event.element, str.count > 500{
                       self?.autoBackField.input.text = str[0...500]
                   }
               }.disposed(by: self.disposeBag)
        leaveWordsField.enableTitleModel = true
        leaveWordsField.setTitle(title: LanguageTools.getString(key: "otc_text_advertiseLeaveWords"))
        pubulishBtn.titleLabel?.font = .Ex.medium(16)
        if advertiseType == .publisAdvertise {
            autoBackField.setPlaceHolder(placeHolder:LanguageTools.getString(key: "filter_Input_placeholder"))
            leaveWordsField.setPlaceHolder(placeHolder: LanguageTools.getString(key: "filter_Input_placeholder"))
            pubulishBtn.setTitle(LanguageTools.getString(key: "otc_publish_advertise"), for: UIControl.State.normal)//Advertising
        }
        leaveWordsField.input.rx.text.orEmpty.changed.asObservable().subscribe {[weak self] (event) in
            if self?.advertiseType == AdvertiseType.advertiseDetail {return}
            if let str = event.element, str.count > 500{
                self?.leaveWordsField.input.text = str[0...500]
            }
        }.disposed(by: self.disposeBag)
        
        
        
        if isMarKet {
            singleMoneyStackConH.constant = 43
            singleMoneyStackConTopMargin.constant = 25
            yijiaDirectionConH.constant = 54
            yijiaDirectionConTopMargin.constant = 25
            YijiaDirectionField.isHidden = false
        }else {
            singleMoneyStackConH.constant = 0
            singleMoneyStackConTopMargin.constant = 0
            yijiaDirectionConH.constant = 0
            yijiaDirectionConTopMargin.constant = 0
            YijiaDirectionField.isHidden = true
        }
        bottomMarginCon.constant = TABBAR_BOTTOM + 10
    }
}

extension EXPublishAdvertiseMarkVc {
    
        //MARK: Purchase, sell
       @IBAction func btnClick(_ sender: UIButton) {
            currentBtn.isSelected = false
            sender.isSelected = true
            currentBtn = sender
            resetSubViews()
            configUI()
            allAmountFieldConH.constant = sellBtn.isSelected ? 73 : 54
       }
    
       @IBAction func referenceBtnClick(_ sender: UIButton) {
            //Tooltip
           let alert = EXNormalAlert()
           alert.configSigleAlert(title: LanguageTools.getString(key: "otc_market_ReferencPrice"), message: LanguageTools.getString(key: "otc_market_ReferencPriceDetail"), sigleBtnTitle: "alert_common_iknow".localized())
           //show
           EXAlert.showAlert(alertView: alert)
       }
    
      //MARK: Click to publish
      @IBAction func publishBtnClick(_ sender: UIButton) {
        if advertiseType == .publisAdvertise {
            publishAdvertiseAction()
        }else {
            let alert = EXCommonAlert()
            alert.configAlert(title: "otc_confirm_closeAdvertise".localized()) { type in
                if type == .sure {
                    self.closeAdvertise()
                }
            }
            //show
            EXAlert.showAlert(alertView: alert)
           
        }
        
      }
    func closeAdvertise() {
        //Advertising that can be closed during publication
           otcApi.rx.request(.otcCloseWanted(advertId: advertisID))
               .MJObjectMap(EXVoidModel.self)
               .subscribe{[weak self] event in
                   switch event {
                   case .success(_):
                       if let block = self?.block {
                           block(.advertiseClose,self?.advertisID ?? "",false)
                       }
                       EXAlert.showSuccess(msg: LanguageTools.getString(key: "otc_have_closedAdvertise"))
                       DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                           self?.navigationController?.popViewController(animated: true)
                       }
                       break
                   case .failure(let error):
                       print(error)
                       break
                   }
           }.disposed(by: self.disposeBag)
    }
    @objc func chooseCoinAction() {
//        let searchVc = EXCoinSearchListVc.instanceFromStoryboard(name: StoryBoardNameAsset)
//        searchVc.subsetCoinAccountType =  .otc
//        searchVc.onEntityCallback = {[weak self] model in
//            self?.symbol = model.name
//            self?.chooseCoinNameLab.text = self?.symbol.aliasName()
//            self?.resetSubViews()
//            self?.requestOtcAccountBalance()
//            self?.configUI()
//            self?.getConsiderPrice()
//        }
//
//        self.navigationController?.pushViewController(searchVc, animated: true)
        
        
        let allcoins = EXAppMarketManager.sharedInstance.getAllOTCCoinList()
               var supportOtc:[String] = []
               var selectIdx = 0
               for (idx,item) in allcoins.enumerated() {
                   if symbol == item.name {
                       selectIdx = idx
                   }
                   supportOtc.append(item.name.aliasName())
               }
               let sheet = EXOldActionSheetView()
               sheet.configButtonTitles(buttons: supportOtc,selectedIdx: selectIdx)
               sheet.actionIdxCallback = {[weak self] tag in
                    
                   let model = allcoins[tag]
                   self?.symbol = model.name
                   self?.chooseCoinNameLab.text = self?.symbol.aliasName()
                   self?.resetSubViews()
                   self?.requestOtcAccountBalance()
                   self?.configUI()
                   self?.getConsiderPrice()
               }
               sheet.actionCancelCallback = {[weak self]  in
               }
               EXAlert.showSheet(sheetView:sheet)
        
    }
   
    
    
    func publishAdvertiseAction() {
        //Total amount
        var allAmoutStr = ((self.allAmountCnyLab.text ?? "") as NSString).replacingOccurrences(of: " ", with: "")
        allAmoutStr = (allAmoutStr as NSString).replacingOccurrences(of: self.currentCoinTypeModel.valueKey , with: "")
        let amount = (amountField.input.text ?? "") as NSString//quantity
        let minAmount = (minLimitField.input.text ?? "") as NSString//Minimum amount
        let maxAmount = (maxLimitField.input.text ?? "") as NSString//Maximum amount
        let payTime = (payTimeField.input.text ?? "") as NSString //Payment time
        let times = (minPayTimesField.input.text ?? "") as NSString//Minimum number of transactions by the counterparty
        let alertStr = LanguageTools.getString(key: "otc_mustWrite_tex")
        let desStr = LanguageTools.getString(key: "otc_MustWrite")
        let validStr = LanguageTools.getString(key: "otc_writeContent_nonconformity")
        if amount.length == 0 {
            EXAlert.showFail(msg: alertStr)
            if !sellBtn.isSelected {
                amountField.amountLabel.text = desStr
            }
            amountField.changeThemeColor(isRed: true)
            return
        }
        if isMarKet && YijiaPercentField.input.text?.isEmpty == true {
            EXAlert.showFail(msg: alertStr)
            YijiaPercentField.amountLabel.text = desStr
            YijiaPercentField.changeThemeColor(isRed: true)
            return
        }
        if minAmount.length == 0 {
            EXAlert.showFail(msg: alertStr)
            minLimitField.amountLabel.text = desStr
            minLimitField.changeThemeColor(isRed: true)
            return
        }
        if maxAmount.length == 0 {
            EXAlert.showFail(msg: alertStr)
            maxLimitField.amountLabel.text = desStr
            maxLimitField.changeThemeColor(isRed: true)
            return
        }
        if payTime.length == 0 {
           EXAlert.showFail(msg: alertStr)
           payTimeField.amountLabel.text = desStr
           payTimeField.changeThemeColor(isRed: true)
           return
        }
        if !isMarKet && YijiaPercentField.input.text?.isEmpty == true{
            EXAlert.showFail(msg: alertStr)
            YijiaPercentField.amountLabel.text = desStr
            YijiaPercentField.changeThemeColor(isRed: true)
            return
        }
        if times.length == 0 {
            EXAlert.showFail(msg: alertStr)
            return
        }
        if sellBtn.isSelected && ((amountField.input.text ?? "") as NSString).isBig(self.advance) {
              EXAlert.showFail(msg: validStr)
               return
        }
        if isMarKet && ((YijiaPercentField.input.text ?? "") as NSString).isBig("50") {
             EXAlert.showFail(msg: validStr)
             return
        }

        
        if minAmount.isBig(allAmoutStr) {
           EXAlert.showFail(msg: validStr)
           return
        }
        if minAmount.isBig(maxAmount as String) || minAmount.isEqual(to: maxAmount as String){
           EXAlert.showFail(msg: validStr)
            return
        }
        if maxAmount.isBig(allAmoutStr) {
           EXAlert.showFail(msg: validStr)
             return
         }
        if !maxAmount.isBig(minAmount as String) || maxAmount.isEqual(to:minAmount as String){
           EXAlert.showFail(msg: validStr)
           return
        }
        if (payTime.isBig("60") || !payTime.isBig("5")) && !payTime.isEqual(to: "5"){
            EXAlert.showFail(msg: validStr)
            return
            
        }
        var temp = [EXOTCPaymentListModel]()
        for item in modelsArr {
            if item.isChoose {
                temp.append(item)
            }
        }
        if temp.count == 0 {
            var alertStr = ""
            if sellBtn.isSelected {
                alertStr = LanguageTools.getString(key: "otc_choose_getMoneyMethod")
            }else {
                alertStr = LanguageTools.getString(key: "otc_choose_payMoneyMethod")
            }
            EXAlert.showFail(msg: alertStr)
            return
        }else {
            //Advertising interface for publishing
            var priceRateType = ""
            let priceRate = isMarKet ? YijiaPercentField.input.text ?? "" : "0"//Transfer 0 when customizing prices
            if isMarKet {
                if isUpReferencePrice {
                    priceRateType = "2"
                }else {
                    priceRateType = "3"
                }
            }else {
                priceRateType = "0"
            }
            var payMethod = [[String:String]]()
            for item in modelsArr {
                if item.isChoose {
                    payMethod.append(["payment":item.payment])
                }
            }
            if currentCoinTypeModel.valueKey.isEmpty {
                EXAlert.showFail(msg: "filter_Input_placeholder".localized() + "otc_coin_type".localized())
                return
            }
            //autoBackField
            let payMethodStr = (payMethod as NSArray).mj_JSONString() ?? ""
            otcApi.rx.request(OTCAPIEndPoint.otcWantedSave(coin: symbol, side: sellBtn.isSelected ? "SELL" : "BUY", payCoin: self.currentCoinTypeModel.valueKey, volume: self.amountField.input.text ?? "", price: isMarKet ? self.singleCnyLab.text?.replacingOccurrences(of: " " + self.currentCoinTypeModel.valueKey, with: "") ?? "" : self.YijiaPercentField.input.text ?? "", priceRate: priceRate , priceRateType: priceRateType, minTrade: minAmount as String, maxTrade: maxAmount as String, limitTime: payTime as String, dealVolume: times as String, days: self.selectValidDay, payments: payMethodStr, description: leaveWordsField.input.text ?? "", autoReply: autoBackField.input.text ?? "")).MJObjectMap(EXVoidModel.self)
                           .subscribe{[weak self] event in
                               switch event {
                               case .success(_):
                                EXAlert.showSuccess(msg: LanguageTools.getString(key: "otc_advertisePublish_success"))
                                if let block = self?.block {
                                    block(.publisAdvertise,"",self?.sellBtn.isSelected == true)
                                }
                                   DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                       self?.navigationController?.popViewController(animated: true)
                                   }
                                   break
                               case .failure(let error):
                                print(error)
                                   break
                               }
                       }.disposed(by: self.disposeBag)

        }
    }
    
    //Balance in this currency
    func handleOtcAssets(model:EXOTCAccountListModel) {
           for item in model.allCoinMap {
               if item.coinSymbol == symbol {
                   advance = item.normal.formatAmount(symbol)//currency
                   configUI()
                   break
               }
           }
       }
    //Reset some properties of the subview
    func resetSubViews() {
        //Only display balance when sold
        amountField.amountLabel.isHidden = !sellBtn.isSelected
        autoBackField.input.text = ""
        leaveWordsField.input.text = ""
        amountField.setText(text: "")//Clear when switching
        isMarKet = true//Reset
        isUpReferencePrice = true//Reset
        for item in getMethodArr {
            item.isChoose = false
        }
    }
     //MARK: Currency Type Selection
    func coinTypeSelection() {
        coinTypeField.normalStyle()
       var supportOtc:[String] = []
              var selectIdx = 0
              for (idx,item) in coinTypeArr.enumerated() {
                if currentCoinTypeModel.text == item.text {
                      selectIdx = idx
                  }
                  supportOtc.append(item.text)
              }
        // when the data is empty, the bottomSheet isn't displayed
        if supportOtc.isEmpty {
            return
        }
              let sheet = EXOldActionSheetView()
              sheet.configButtonTitles(buttons: supportOtc,selectedIdx: selectIdx)
              sheet.actionIdxCallback = {[weak self] tag in
                self?.currentCoinTypeModel = self?.coinTypeArr[tag] ?? EXFilterItem()
                self?.resetSubViews()
                self?.configUI()
                self?.getConsiderPrice()
              }
              EXAlert.showSheet(sheetView:sheet)
    }
    //MARK: Pricing method
    func priceMethod() {
        let selectIdx = priceMethodArr.index(of: priceMethodField.input.text ?? "") ?? 0
       
        let sheet = EXOldActionSheetView()
        sheet.configButtonTitles(buttons: priceMethodArr,selectedIdx: selectIdx)
        sheet.actionIdxCallback = {[weak self] tag in
            if tag == 0 {//Premium
                self?.isMarKet = true
                self?.isUpReferencePrice = true
            }else {//custom
                self?.isMarKet = false
            }
           self?.configUI()
           
        }
        EXAlert.showSheet(sheetView:sheet)
    }
    //MARK: Premium direction
    func yiJiaDirection() {
        if isMarKet {
            let selectIdx = jiJiaDirectionArr.index(of: YijiaDirectionField.input.text ?? "") ?? 0
            let sheet = EXOldActionSheetView()
            sheet.configButtonTitles(buttons: jiJiaDirectionArr,selectedIdx: selectIdx)
            sheet.actionIdxCallback = {[weak self] tag in
                self?.isUpReferencePrice = (tag == 0) ? true : false
                self?.YijiaDirectionField.input.text = self?.jiJiaDirectionArr[tag]
                self?.YijiaPercentField.input.sendActions(for: .valueChanged)
            }
            EXAlert.showSheet(sheetView:sheet)
        }
        
    }
    
    //Failure time selection
    func validTimeSelect() {
            
            let selectIdx = validTimeArr.index(of: selectValidDay) ?? 0
            let sheet = EXOldActionSheetView()
            sheet.configButtonTitles(buttons: validTimeArr,selectedIdx: selectIdx)
            sheet.actionIdxCallback = {[weak self] tag in
                self?.selectValidDay = self?.validTimeArr[tag] ?? ""
                self?.validTimeField.input.text = self?.selectValidDay ?? "" + LanguageTools.getString(key: "otc_advertiseValid_day")
            }
            EXAlert.showSheet(sheetView:sheet)
    }
    //Payment method
     func configPayMethod() {
        
         if advertiseType == .publisAdvertise {//Advertising
                  if sellBtn.isSelected {//Selling
                        getMethodLab.text = LanguageTools.getString(key: "otc_getMoney_Method")
                         var tempArr = [EXOTCPaymentListModel]()
                         var hasBank = false//Do you already have a bank card
                         for item in getMethodArr {
                             if item.isOpen == "1"{
                                if item.payment == OTCPayInfoType.UnionPay.rawValue {
                                    if !hasBank {
                                      tempArr.append(item)
                                      hasBank = true
                                    }
                                }else {
                                    tempArr.append(item)
                                }
                                 
                             }
                         }
                         modelsArr = tempArr
                        if tempArr.count == 0 {
                             //Display when there is no payment method
                            nPayLab.isHidden = false
                            collectionView.isHidden = true
                            nPayLab.text = LanguageTools.getString(key: "otc_noSetGetMoney_Method")
                        }else {
                           nPayLab.isHidden = true
                           collectionView.isHidden = false
                        }
                         collectionView.reloadData()
                    }else {//buy
                       getMethodLab.text = LanguageTools.getString(key: "otc_payMoney_Method")
                       nPayLab.isHidden = true//Hide when purchasing
                       var hasBank = false//Do you already have a bank card
                         let payMents = OTCPulbicManager.sharedInstance.getOtcPayments()
                         var tempArr = [EXOTCPaymentListModel]()
                        for item in payMents {
                            if item.key == OTCPayInfoType.UnionPay.rawValue {
                               if !hasBank {
                                   hasBank = true
                                   let model = EXOTCPaymentListModel()
                                   model.payment = item.key
                                   model.title = item.title
                                   model.icon = item.icon
                                   tempArr.append(model)
                               }
                           }else {
                               let model = EXOTCPaymentListModel()
                               model.payment = item.key
                               model.title = item.title
                               model.icon = item.icon
                               tempArr.append(model)
                           }
                         }
                         modelsArr = tempArr
                        if tempArr.count == 0 {
                            collectionView.isHidden = true
                        }else {
                           collectionView.isHidden = false
                        }
                         collectionView.reloadData()
                    }
         }else {//Ad Details 
                 nPayLab.isHidden = true//Hide advertising details
                 getMethodLab.text =  self.advertiseDetailModel.side.lowercased() == "sell" ? LanguageTools.getString(key: "otc_getMoney_Method") :  LanguageTools.getString(key: "otc_payMoney_Method")
                  var tempArr = [EXOTCPaymentListModel]()
                  var hasBank = false//Do you already have a bank card
                  for item in self.advertiseDetailModel.payments {
                        if item.key == OTCPayInfoType.UnionPay.rawValue {
                            if !hasBank {
                                hasBank = true
                                let model = EXOTCPaymentListModel()
                                model.payment = item.key
                                model.title = item.title
                                model.icon = item.icon
                                tempArr.append(model)
                            }
                        }else {
                            let model = EXOTCPaymentListModel()
                            model.payment = item.key
                            model.title = item.title
                            model.icon = item.icon
                            tempArr.append(model)
                        }
                  }
                  modelsArr = tempArr
                 if tempArr.count == 0 {
                    collectionView.isHidden = true
                 }else {
                   collectionView.isHidden = false
                 }
                  collectionView.reloadData()
         }
     }
    
}
extension EXPublishAdvertiseMarkVc:UICollectionViewDataSource,UISearchControllerDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numLines = modelsArr.count / 3
        if  modelsArr.count % 3 != 0 {
            numLines = numLines + 1
        }
        if numLines != 0 {
            collectionViewHCon.constant = CGFloat(34 * numLines + (numLines - 1)*5)
        }
        if modelsArr.count == 0 {
            collectionViewHCon.constant = 34
        }
        return modelsArr.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = modelsArr[indexPath.row]
        let cell:EXPublishAdvertiseCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "EXPublishAdvertiseCollectionCell", for: indexPath) as! EXPublishAdvertiseCollectionCell
        cell.model = model
        cell.modelsArr = modelsArr
        if indexPath.row % 3 == 0 {
            cell.alignMent = .Left
        }else if indexPath.row % 3 == 1 {
            cell.alignMent = .center
        }else {
            cell.alignMent = .right
        }
        cell.chooseBtn.isHidden = advertiseType == .advertiseDetail
        return cell
    }
}
