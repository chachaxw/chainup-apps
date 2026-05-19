//
//  EXLeverageReturnVc.swift
//  Chainup
//
//  Created by ljw on 2023/11/6.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
enum EXLeverageType {
    case none
    case leverageReturn//return
    case leverageBorrow//Lending
}
class EXLeverageReturnVc: BaseVC,NavigationPlugin{
    
    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: self.scrollView, presenter: self)
        nav.isLastNavigationStyle = false
        return nav
    }()
    
    @IBOutlet weak var returnBtn: EXButton!
    @IBOutlet weak var contentView: UIView!
    var selectIdx = 0
    var isBase = true
    var isfromAsset: Bool = false
    var borrowModel = EXLeverCoinBorrowRecord()
    typealias returnSuccessBlock = () -> ()
    var successBlock : returnSuccessBlock?
    var currentCoinName = ""//Loan currency pair
    var model = EXCurrentBorrowListModel()//For return
    @IBOutlet var shortBtn: EXIndicatorBtn!
    @IBOutlet var longBtn: EXIndicatorBtn!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var leverageTitleLab: UILabel!
    @IBOutlet weak var leverageLab: UILabel!
    @IBOutlet weak var returnSymbolTitleLab: UILabel!
    @IBOutlet weak var returnSymbolLab: UILabel!
    @IBOutlet weak var shouldReturnLab: UILabel!
    @IBOutlet weak var shouldReturnTitleLab: UILabel!
    @IBOutlet weak var rateTitleLab: UILabel!
    @IBOutlet weak var rateLab: UILabel!
    @IBOutlet weak var allAmountLab: UILabel!
    @IBOutlet weak var allAmountTitleLab: UILabel!
    @IBOutlet weak var amountField: EXWithDrawAmountField!
    @IBOutlet weak var topCon: NSLayoutConstraint!
    @IBOutlet weak var bottomCon: NSLayoutConstraint!
//    @IBOutlet weak var bottomBtn: EXIndicatorBtn!
    @IBOutlet weak var topLab: UILabel!
    @IBOutlet weak var topBackView: UIView!//Hide when returning
    @IBOutlet weak var bottomBackView: UIView!//Hide when returning
    @IBOutlet weak var returnStackView: UIStackView!//Hide when borrowing
    var type : EXLeverageType = .none
    var inputlevelPersion = "8"
    let showlevelPersion = "8"
    @IBOutlet weak var arrowbtn: UIButton!
    var titlesArr = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shortBtn.isSelected = true
        returnBtn.isEnabled = false
        returnBtn.setBackgroundColor(color: .Ex.main1, forState: .normal)
        returnBtn.setBackgroundColor(color: .Ex.fill5, forState: .disabled)
        returnBtn.extSetCornerRadius(4)
        shortBtn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
        shortBtn.setTitleColor(UIColor.ThemeLabel.colorLite, for: .selected)
        longBtn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
        longBtn.setTitleColor(UIColor.ThemeLabel.colorLite, for: .selected)
        self.view.backgroundColor = UIColor.ThemeView.bg
        arrowbtn.imageView?.contentMode = .scaleAspectFit
        arrowbtn.setImage(EXKitBundle.image(named: "public_positions_arrow_right"), for: .normal)
        handNavigationBar()
        if type == .leverageReturn {
            currentCoinName = model.symbol
            inputlevelPersion = "8"
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    
    func configUI(_ showAlert:Bool = true){

        amountField.titleLabel.text = "charge_text_volume".localized()
        amountField.rightSendAllLabel.text = "common_action_sendall".localized()
        if type == .leverageReturn{
            leverageTitleLab.text = "leverage_asset".localized()
            leverageLab.text = borrowModel.name.aliasCoinMapName().uppercased()
            returnSymbolTitleLab.text = "leverage_returnCoin".localized()
            returnSymbolLab.text = model.coin.aliasName()
            shouldReturnTitleLab.text = "leverage_shouldReturn_amount".localized()
            shouldReturnLab.text = (model.oweAmount as NSString).adding(model.oweInterest, decimals: Int(showlevelPersion) ?? 8 ).formatAmount(model.coin,isLeverage: true) + model.coin.aliasName()
            
            allAmountTitleLab.text = "leverage_totalBorrow_amount".localized()
            allAmountLab.text = model.borrowMoney.formatAmount(model.coin,isLeverage: true) + model.coin.aliasName()
            rateTitleLab.text = "leverage_interest".localized()
            rateLab.text = model.oweInterest.formatAmount(model.coin,isLeverage: true) + model.coin.aliasName()
            self.navigation.setTitle(title:"leverage_return".localized())
            returnBtn.setTitle("leverage_return".localized(), for: UIControl.State.normal)//return
            topBackView.isHidden = true
            bottomBackView.isHidden = true
            if model.coin.uppercased() == borrowModel.baseCoin.uppercased() {
                self.basicSet(isBase: true)
            }else {
                self.basicSet(isBase: false)
            }
            
        }else {
            let totalMoney = borrowModel.symbolBalance as NSString
            if totalMoney.isEqualValue("0"),showAlert {
                alertShow()
            }
            if currentCoinName.count > 0 && currentCoinName.contains("/"){
                titlesArr = (currentCoinName.aliasCoinMapName() as NSString).components(separatedBy: "/")
                var tempArr = [String]()
                for (idx,item) in titlesArr.enumerated() {
                    if idx == 0 {
                        tempArr.append(String(format: "leverage_short".localized(), item))
                    }else {
                        tempArr.append(String(format: "leverage_more".localized(), item))
                    }
                }
                titlesArr = tempArr
                if titlesArr.count == 2 {
                    amountField.input.text = ""
                    shortBtn.setTitle(titlesArr[0], for: .normal)
                    longBtn.setTitle(titlesArr[1], for: .normal)
                }
            }
            leverageTitleLab.text = "leverage_asset".localized()
            leverageLab.text = currentCoinName.aliasCoinMapName()
            shouldReturnTitleLab.text = "leverage_have_borrowed".localized()
            allAmountTitleLab.text = "leverage_text_biggestLimit".localized()
            self.basicSet(isBase: isBase)
            rateTitleLab.text = "leverage_rate".localized()
            
            rateLab.text = borrowModel.rate
            returnStackView.isHidden = true
            self.navigation.setTitle(title:"leverage_borrow".localized())
            self.getTopTitle(coin: currentCoinName.aliasCoinMapName())
            returnBtn.setTitle("leverage_borrow".localized(), for: UIControl.State.normal)
            navigation.configRightItems(["leverage_borrowRecord".localized()], isImageName: false)
            navigation.rightItemCallback = {[weak self] tag in
                if var currentCoinName = self?.currentCoinName {
                    currentCoinName = (currentCoinName as NSString).replacingOccurrences(of: "/", with: "")
                    let vc = EXLeverLoanListVC.init()
                    vc.coinMapName = currentCoinName.uppercased()
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        
        if isiPhoneX {
            bottomCon.constant = TABBAR_BOTTOM + 10;
        }else {
            bottomCon.constant = 30;
        }
    }
    func basicSet(isBase : Bool) {
        
        let precision = EXAppMarketManager.sharedInstance.getCoinPrecision(borrowModel.baseCoin)
        inputlevelPersion = String(precision)
        
        let baseNormalBalance = borrowModel.baseNormalBalance.formatAmountUseDecimal(inputlevelPersion)
        let quoteNormalBalance = borrowModel.quoteNormalBalance.formatAmountUseDecimal(inputlevelPersion)
        let baseMinPayment = borrowModel.baseMinPayment.formatAmountUseDecimal(inputlevelPersion)
        let baseMinBorrow = borrowModel.baseMinBorrow.formatAmountUseDecimal(inputlevelPersion)
        let baseCanBorrow = borrowModel.baseCanBorrow.formatAmountUseDecimal(inputlevelPersion)
        let quoteMinBorrow = borrowModel.quoteMinBorrow.formatAmountUseDecimal(inputlevelPersion)
        let quoteCanBorrow = borrowModel.quoteCanBorrow.formatAmountUseDecimal(inputlevelPersion)
        if type == .leverageReturn {//return need 8
            amountField.decimal = inputlevelPersion
            if isBase {
                amountField.setPlaceHolder(placeHolder: "withdraw_text_minimumVolume".localized() + baseMinPayment)
                amountField.leftSymbolLabel.text = model.coin.aliasName()
                amountField.symbol = model.coin
                amountField.setAmount(amount:baseNormalBalance, title: "redpacket_send_availableBalance".localized(),isLeverage: true)
            }else {
                amountField.setPlaceHolder(placeHolder: "withdraw_text_minimumVolume".localized() + borrowModel.quoteMinPayment.formatAmount(model.coin,isLeverage: true,deci: 8))
                amountField.leftSymbolLabel.text = model.coin.aliasName()
                amountField.symbol = model.coin
                amountField.setAmount(amount:quoteNormalBalance, title: "redpacket_send_availableBalance".localized(),isLeverage: true)
            }
            amountField.input.rx.text.orEmpty.changed.asObservable().subscribe {[weak self] (event) in
                guard let mySelf = self else {return}
                let inputMoney = (mySelf.amountField.input.text ?? "") as NSString
                mySelf.returnBtn.isEnabled = inputMoney.length > 0
                let total = (mySelf.model.oweAmount as NSString).adding(mySelf.model.oweInterest, decimals: Int(mySelf.inputlevelPersion) ?? 8).formatAmountUseDecimal("8",holdZero: true)
                if isBase {
                    let normalBalnance = baseNormalBalance
                    
                    if inputMoney.isEqualValue(normalBalnance) && (normalBalnance as NSString).isBig(total)  {
                        mySelf.amountField.input.text = total
                    }
                }else {
                    let normalBalnance = quoteNormalBalance
                    if inputMoney.isEqualValue(normalBalnance) && (normalBalnance as NSString).isBig(total)  {
                        mySelf.amountField.input.text = total
                    }
                }
            }.disposed(by: self.disposeBag)
        }else { ////borrow need 3
            amountField.decimal = inputlevelPersion
            amountField.input.text = ""
            amountField.changeThemeColor(isRed: false)
            if isBase {
                shouldReturnLab.text = borrowModel.baseBorrowBalance.formatAmount(borrowModel.baseCoin,isLeverage: true) + borrowModel.baseCoin.aliasName()
                allAmountLab.text = (borrowModel.baseCanBorrow as NSString).adding(borrowModel.baseBorrowBalance, decimals: Int(self.showlevelPersion) ?? 8).formatAmount(borrowModel.baseCoin,isLeverage: true) + borrowModel.baseCoin.aliasName()
                amountField.setPlaceHolder(placeHolder: "withdraw_text_minimumVolume".localized() + baseMinBorrow)
                amountField.leftSymbolLabel.text = borrowModel.baseCoin.aliasName()
                amountField.symbol = borrowModel.baseCoin
                amountField.setLeverageAmount(amount: baseCanBorrow, title:"leverage_text_canborrow".localized())
            }else {
                shouldReturnLab.text = borrowModel.quoteBorrowBalance.formatAmount(borrowModel.quoteCoin,isLeverage: true) + borrowModel.quoteCoin.aliasName()
                allAmountLab.text = (borrowModel.quoteCanBorrow as NSString).adding(borrowModel.quoteBorrowBalance, decimals: Int(self.showlevelPersion) ?? 8) .formatAmount(borrowModel.quoteCoin,isLeverage: true) + borrowModel.quoteCoin.aliasName()
                amountField.setPlaceHolder(placeHolder: "withdraw_text_minimumVolume".localized() + quoteMinBorrow)
                amountField.leftSymbolLabel.text = borrowModel.quoteCoin.aliasName()
                amountField.symbol = borrowModel.quoteCoin
                amountField.setLeverageAmount(amount: quoteCanBorrow, title: "leverage_text_canborrow".localized())
            }
            amountField.input.rx.text.orEmpty.changed.asObservable().subscribe {[weak self] (event) in
                guard let mySelf = self else {return}
                let inputMoney = (mySelf.amountField.input.text ?? "") as NSString
                mySelf.returnBtn.isEnabled = inputMoney.length > 0
                var coin = ""
                if isBase {
                    coin = mySelf.borrowModel.baseCoin
                    if inputMoney.isBig(baseCanBorrow) || inputMoney.isSmall(baseMinBorrow) {
                    }else {
//                        mySelf.amountField.setLeverageAmount(amount: baseCanBorrow, title:"leverage_text_canborrow".localized())
//                        mySelf.amountField.changeThemeColor(isRed: false)
                    }
                }else {
                    coin = mySelf.borrowModel.quoteCoin
                    if inputMoney.isBig(quoteCanBorrow) || inputMoney.isSmall(quoteMinBorrow) {
                    }else {
//                        mySelf.amountField.changeThemeColor(isRed: false)
//                        mySelf.amountField.setLeverageAmount(amount: quoteCanBorrow, title: "leverage_text_canborrow".localized())
                        
                        
                    }
                }
            }.disposed(by: self.disposeBag)
        }
    }
    func handNavigationBar() {
        self.navigation.isLastNavigationStyle = true 
        self.navigation.setdefaultType(type: .list)
    }
    func largeTitleValueChanged(height: CGFloat) {
        topCon.constant = height
    }
    
    @IBAction func returnBtnClick(_ sender: Any) {
        
        let baseNormalBalance = borrowModel.baseNormalBalance.formatAmountUseDecimal(inputlevelPersion)
        let quoteNormalBalance = borrowModel.quoteNormalBalance.formatAmountUseDecimal(inputlevelPersion)
        let baseMinPayment = borrowModel.baseMinPayment.formatAmountUseDecimal(inputlevelPersion)
        let baseMinBorrow = borrowModel.baseMinBorrow.formatAmountUseDecimal(inputlevelPersion)
        let baseCanBorrow = borrowModel.baseCanBorrow.formatAmountUseDecimal(inputlevelPersion)
        let quoteMinBorrow = borrowModel.quoteMinBorrow.formatAmountUseDecimal(inputlevelPersion)
        let quoteCanBorrow = borrowModel.quoteCanBorrow.formatAmountUseDecimal(inputlevelPersion)
        
        if type == .leverageReturn {//return
            let inputMoney = (amountField.input.text ?? "")
            if inputMoney.count == 0{
                return
            }
            if inputMoney.lessThanOrEqual("0"){
                EXAlert.showFail(msg: "leverage_return_quantity_check".localized())
                return
            }
            appApi.rx.request(.leverFinanceReturn(id: model.id, amount: amountField.input.text ?? ""))
                .MJObjectMap(EXVoidModel.self)
                .subscribe{[weak self] event in
                    switch event {
                    case .success(_):
                        self?.successBlock?()
                        EXAlert.showSuccess(msg: "leverage_return_success".localized())
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            self?.navigationController?.popViewController(animated: true)
                        }
                        break
                    case .failure(_):
                        break
                    }
                }.disposed(by: self.disposeBag)
        }else {//Lending
            
            let inputMoney = (amountField.input.text ?? "")
            if inputMoney.count == 0 {
                return
            }
//            if inputMoney.lessThanOrEqual("0"){
//                EXAlert.showFail(msg: "leverage_loan_quantity_check".localized())
//                return
//            }
            var coin = ""
            if isBase {
                coin = borrowModel.baseCoin
                if inputMoney.isBig(baseCanBorrow) {
//                    amountField.amountLabel.text = "leverage_text_lessThanCanuse".localized()
                    
                    EXAlert.showFail(msg: "leverage_text_lessThanCanuse".localized())
//                    amountField.changeThemeColor(isRed: true)
                    return
                }
                if inputMoney.isSmall(baseMinBorrow) {
                    let error = "leverage_text_noLess".localized().formatWithArguments(arguments: [baseMinBorrow,coin.aliasName()])
                    EXAlert.showFail(msg:error)
                    
                    return
                }
                
            }else {
                coin = borrowModel.quoteCoin
                
                if inputMoney.isBig(quoteCanBorrow) {
//                    amountField.amountLabel.text = "leverage_text_lessThanCanuse".localized()
//                    amountField.changeThemeColor(isRed: true)
                    EXAlert.showFail(msg: "leverage_text_lessThanCanuse".localized())
                    return
                }
                if inputMoney.isSmall(quoteMinBorrow) {
                    let error = "leverage_text_noLess".localized().formatWithArguments(arguments: [quoteMinBorrow,coin.aliasName()])
                    EXAlert.showFail(msg:error)
//                    amountField.changeThemeColor(isRed: true)
                    return
                }
                
            }
            appApi.rx.request(.leverFinanceBorrow(symbol:(currentCoinName as NSString).replacingOccurrences(of: "/", with: "").uppercased(), coin: coin, amount: amountField.input.text ?? ""))
                .MJObjectMap(EXVoidModel.self)
                .subscribe{[weak self] event in
                    guard let `self` = self else { return }
                    switch event {
                    case .success(_):
                        EXAlert.showSuccess(msg: "leverage_loan_success".localized())
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            if self.isfromAsset {
                                if let arr =  self.navigationController?.children{
                                    if arr.count - 3 >= 0 {
                                        if let v = self.navigationController?.children[arr.count - 3]{
                                            self.navigationController?.popToViewController(v, animated: true)
                                        }
                                    }
                                }
                                return
                            }
                            self.navigationController?.popViewController(animated: true)
                        }
                        break
                    case .failure(_):
                        break
                    }
                }.disposed(by: self.disposeBag)
        }
    }
    
    @objc func alertShow() {
        let normalAlert = EXCommonAlert()
        let coin = currentCoinName.aliasCoinMapName()
        let title = String(format: "leverage_notEnught_prompt".localized(), arguments: [coin])
        normalAlert.configAlert(tipImage: nil, title: title, message: nil, cancelBtnTitle: "common_text_btnCancel".localized(), sureBtnTitle: "assets_action_transfer".localized(), btnLayoutStyle: .horizontal) { [weak self] type in
            guard let weakSelf = self else { return }
            if type == .sure{
                
                let transfer = EXAccountTransferVc.instanceFromStoryboard(name: StoryBoardNameAsset)
                transfer.coinName = weakSelf.isBase ? weakSelf.borrowModel.baseCoin : weakSelf.borrowModel.quoteCoin
                transfer.coinMapName =  weakSelf.borrowModel.name.uppercased()
                transfer.transferFlow = .leverageToExchagne
                transfer.onTrasferSuccessCallback = { [weak self] (ftype,ttype) in
                    
                }
                weakSelf.navigationController?.pushViewController(transfer, animated: true)
                
            }
        }
        EXKitAlert.showAlert(alertView: normalAlert)
        
//
//        let normalAlert = EXNormalAlert()
//        let att = NSMutableAttributedString.init(string:String.init(format: "leverage_notEnught_prompt".localized(), currentCoinName.aliasCoinMapName()))
//        att.addAttributes([NSAttributedString.Key.font: UIFont.ThemeFont.HeadRegular,NSAttributedString.Key.foregroundColor:UIColor.ThemeLabel.colorLite], range: att.yy_rangeOfAll())
//        att.addAttributes([NSAttributedString.Key.font: UIFont.ThemeFont.HeadRegular,NSAttributedString.Key.foregroundColor:UIColor.ThemeState.warning], range: (att.string as NSString) .range(of: currentCoinName.aliasCoinMapName()))
//        normalAlert.configAttributeAlert(title:nil, message: att, passiveBtnTitle: "common_text_btnCancel".localized(), positiveBtnTitle: "assets_action_transfer".localized())
//        normalAlert.alertCallback = {[weak self] tag in
//            guard let mySelf = self else {
//                return
//            }
//            if tag == 0 {
//                let transfer = EXAccountTransferVc.instanceFromStoryboard(name: StoryBoardNameAsset)
//                transfer.coinName = mySelf.isBase ? mySelf.borrowModel.baseCoin : mySelf.borrowModel.quoteCoin
//                transfer.coinMapName =  mySelf.borrowModel.name.uppercased()
//                transfer.transferFlow = .leverageToExchagne
//                transfer.onTrasferSuccessCallback = { [weak self] (ftype,ttype) in
//
//                }
//                self?.navigationController?.pushViewController(transfer, animated: true)
//            }
//        }
//        EXAlert.showAlert(alertView: normalAlert)
        
    }
    
//    @IBAction func bottomBtnClick() {
//        for (idx,item) in titlesArr.enumerated() {
//            if self.typeLab.text == item {
//                selectIdx = idx
//                break
//            }
//        }
//        let sheet = EXActionSheetView()
//        sheet.configButtonTitles(buttons: titlesArr,selectedIdx: selectIdx)
//        sheet.actionIdxCallback = {[weak self] tag in
//            guard let mySelf = self else {
//                return
//            }
//            mySelf.isBase = (tag == 0)
//            mySelf.configUI()
//        }
//        EXAlert.showSheet(sheetView:sheet)
//        //self.bottomBtn.isSelected = false
//    }
//
    @IBAction func onShortLongAction(_ sender:EXIndicatorBtn) {
        if sender == shortBtn {
            selectIdx = 0
            self.isBase = true
            longBtn.isSelected = false
            shortBtn.isSelected = true
        }else if sender == longBtn {
            selectIdx = 1
            self.isBase = false
            shortBtn.isSelected = false
            longBtn.isSelected = true
        }
        
        configUI(false)
    }
    
    
    @IBAction func topBackViewClick(_ sender: UITapGestureRecognizer) {
        let vc = EXLeverageCoinSearchVc.init(nibName: "EXLeverageCoinSearchVc", bundle: nil)
        vc.backCoinNameBlock = {[weak self] str in
            self?.currentCoinName = str
            self?.getTopTitle(coin: str)
            self?.isBase = true
            //self?.loadData()
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getTopTitle(coin : String) {
        self.topLab.text = coin + " " + "leverage_asset".localized()
    }
}
extension EXLeverageReturnVc {
    func loadData() {
        let str = (currentCoinName as NSString).replacingOccurrences(of: "/", with: "").uppercased()
        appApi.rx.request(.leverFinanceSymbolInfo(symbol: str))
            .MJObjectMap(EXLeverCoinBorrowRecord.self)
            .subscribe{[weak self] event in
                switch event {
                case .success(let model):
                    self?.borrowModel = model
                    self?.returnBtn.isHidden = false
                    self?.contentView.isHidden = false
                    self?.configUI()
                    break
                case .failure(_):
                    break
                }
            }.disposed(by: self.disposeBag)
    }
}




