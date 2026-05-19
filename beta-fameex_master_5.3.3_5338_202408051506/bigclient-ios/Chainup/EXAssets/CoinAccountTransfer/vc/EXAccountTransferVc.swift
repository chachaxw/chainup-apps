//
//  EXAccountTransferVc.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/6.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import EXKit
import Swap
class EXAccountTransferVc: BaseVC,StoryBoardLoadable,NavigationPlugin {
    
    typealias TransferSuccessCallback = (EXAccountType,EXAccountType) -> ()
    var onTrasferSuccessCallback:TransferSuccessCallback?
    var isPopRoot = false
    var isfromAsset: Bool = false
    @IBOutlet var transferScroll: UIScrollView!
    @IBOutlet var accountTransferHeader: EXAccountTransferHeaderView!
    @IBOutlet var footerBar: EXCoinWithdrawFooter!
    @IBOutlet var topConstraint: NSLayoutConstraint!
    @IBOutlet var coinSelector: EXSelectionField!
    @IBOutlet var grantsTipView: UIView!
    @IBOutlet var grantsTipBtn: UIButton!
    
    @IBOutlet weak var transferNoticeTitleLabel: CMLocalizedLabel!
    @IBOutlet weak var transferNoticeContentLabel: UILabel!
    
    @IBOutlet weak var coinDoubleView: UIView!//Display only when lever is used
    @IBOutlet weak var coinDoubleSelector: EXSelectionField!//When using leverage
    @IBOutlet var amountView: EXWithDrawAmountField!
    var transferVm:EXTransferVm = EXTransferVm()
    var coinListVm:EXCoinSearchVm = EXCoinSearchVm()
    var transferFlow:EXTransferFlow = .exchangeToOther
    
    //Entering from a certain account can bring in one. The rest will be automatically obtained
    var coinModel:EXAccountCoinMapItem?
    var otcModel:CoinMapItem?
    var contractModel:EXContractAccountModel?
    var contractModels:[EXContractAccountModel] = []

    var fromModel:EXTransferCommonModel = EXTransferCommonModel()
    var toModel  :EXTransferCommonModel = EXTransferCommonModel()
    var canTransferType:EXAccountType = .coin //The option to swap accounts, if equal to a currency account, is incorrect. Only OTC/contract can be swapped
    
    var symbol:String = ""
    var amount:String = ""
    
    var coinMapName = ""//Name of currency pair, used for leverage
    var coinName = ""//币种名字//When using leverage
    var leverModel = EXLeverCoinBorrowRecord()
    
    var coinTitleArr = [String]()
    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: nil, presenter: self)
        nav.isLastNavigationStyle = true
        return nav
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        accountTransferHeader.backgroundColor = .Ex.fill3
        accountTransferHeader.nibView.backgroundColor = .clear
        configNavigation()
        if isPopRoot { //Return to the root asset master controller
            navigation.customBack = true
            navigation.customBackCallback = { [weak self] in
                guard let newSelf = self else{
                    return
                }
                newSelf.navigationController?.popToRootViewController(animated: true)
            }
        }
        configVm()
        configHeaderFlow()
        configInputs()
        configFooter()
        configAccountsBalance()
        transferNoticeTitleLabel.font = .Ex.regular(14)
        transferNoticeTitleLabel.textColor = .Ex.text2
        transferNoticeContentLabel.attributedText = "content_transfer_notice".localized().lineSpacingString(font: UIFont.Ex.regular(12), color: UIColor.Ex.text2, lineSpacing: 8, textAligment: .left)
    }
    
    
    
    func largeTitleValueChanged(height: CGFloat) {
        topConstraint.constant = height
    }
    
   
}


//MARK: lazy - Update balance
extension EXAccountTransferVc  {
    
    func updateBlanceAmount(){
        
/*
Spot to fiat currency
 self.transferFlow = exchangeToOther
 self.canTransferType = otc
 self.symol = USDT
 self.fromModel.key = 1

Spot contract
 self.transferFlow = exchangeToOther
 self.canTransferType = contract
 self.symol = USDT
 self.fromModel.key = 1

Spot - Leveraged
 self.transferFlow = exchangeToOther
 self.canTransferType = leverage
 self.symol = USDT
 self.fromModel.key = 1




Legal Currency - Spot
 self.transferFlow = exchangeToOther
 self.canTransferType = otc
 self.symol = USDT
 self.fromModel.key = 2

Contract to Spot
 self.transferFlow = exchangeToOther
 self.canTransferType = contract
 self.symol = USDT
 self.fromModel.key = 2

Leverage - Spot
 self.transferFlow = exchangeToOther
 self.canTransferType = leverage
 self.symol = USDT
 self.fromModel.key = 2
 
 */
        if self.fromModel.key == "1" {
            EXAccountBalanceManager.manager.updateExchangeAccountBalance()
        }else{
            if self.canTransferType == .otc {
                EXAccountBalanceManager.manager.updateOTCAccountBalance()
            }else if self.canTransferType == .contract {
                EXAccountBalanceManager.manager.updateContractAccountBalance()
            }else if self.canTransferType == .leverage {
                loadData()
            }
        }
    }
}
extension EXAccountTransferVc  {
    
    func handleFromModel(_ withType:EXAccountType) {
        if withType == .coin {
            if canTransferType == .contract {
                fromModel.key = self.contractModel?.walletAccountType ?? ""
            }else {
                fromModel.key = EXTransferAccountKey.accountKeyExchange.rawValue
            }
            if canTransferType == .leverage {
                if self.coinName.uppercased() == leverModel.baseCoin.uppercased(){
                    fromModel.balance = leverModel.baseExNormalBalance
                }else {
                    fromModel.balance = leverModel.quoteEXNormalBalance
                }
            }else {
               fromModel.balance = self.coinModel?.normal_balance ?? "--"
            }
        }else if withType == .otc {
            fromModel.key = EXTransferAccountKey.accountKeyOTC.rawValue
            fromModel.balance = self.otcModel?.normal ?? "--"
        }else if withType == .leverage {
            fromModel.key = EXTransferAccountKey.accountKeyOTC.rawValue
            if self.coinName.uppercased() == leverModel.baseCoin.uppercased(){
                fromModel.balance = leverModel.baseCanTransfer.formatAmountUseDecimal("8")
            }else {
                fromModel.balance = leverModel.quoteCanTransfer.formatAmountUseDecimal("8")
            }
            
        }else {
            fromModel.key = self.contractModel?.contractAccountType ?? ""
            fromModel.balance = self.contractModel?.canUseBalance ?? ""
        }
    }
    
    func handleToModel(_ withType: EXAccountType) {
        if withType == .coin {
            if canTransferType == .contract {
                toModel.key = self.contractModel?.walletAccountType ?? ""
            }else {
                toModel.key = EXTransferAccountKey.accountKeyExchange.rawValue
            }
            toModel.balance = self.coinModel?.normal_balance ?? "--"
        }else if withType == .otc {
            toModel.key = EXTransferAccountKey.accountKeyOTC.rawValue
            toModel.balance = self.otcModel?.normal ?? "--"
        }else if withType == .leverage {
            toModel.key = EXTransferAccountKey.accountKeyOTC.rawValue
            if self.coinName.uppercased() == leverModel.baseCoin.uppercased(){
                toModel.balance = leverModel.baseNormalBalance
            }else {
                toModel.balance = leverModel.quoteNormalBalance
            }
            
        }else {
            toModel.key = self.contractModel?.contractAccountType ?? ""
            toModel.balance = self.contractModel?.canUseBalance ?? ""
        }
    }
}

//MARK: Lazy transfer successfully processed
extension EXAccountTransferVc {
    
    func onSuccessAlert(_ account:EXAccountType) {
        let normalAlert = EXNormalAlert()
        normalAlert.configAlert(title:"transfer_text_guideTransaction".localized(), message: "", passiveBtnTitle: "common_text_close".localized(), positiveBtnTitle: "transfer_action_goTransaction".localized())
        normalAlert.alertCallback = {[weak self] tag in
            self?.handleAlert(tag,account)
        }
        EXAlert.showAlert(alertView: normalAlert)
    }
    
    func handleAlert(_ alertTag:Int, _ account:EXAccountType ) {
        if alertTag == 0 {
            self.handlePositiveBtnAction(account)
        }
        updateBlanceAmount()
//        amountView.input.text = ""
        self.amount = ""
        self.amountView.setText(text: "")
        
        
        

    }
    
    //route
    func handlePositiveBtnAction(_ account:EXAccountType) {
        //Go to the trading page/OTC page/contract page/leverage page
        self.navigationController?.popToRootViewController(animated: false)
        if account == .coin {
            var coinEntity = CoinMapEntity()
            if canTransferType == .leverage {
                self.symbol = (self.coinMapName as NSString).replacingOccurrences(of: "/", with: "").lowercased()
                coinEntity = EXAppMarketManager.sharedInstance.getCoinMapEntityBySymbol(self.symbol)
            }else{
                coinEntity = EXAppMarketManager.sharedInstance.getDealEntity(self.symbol)
            }
            if coinEntity.name.isEmpty {
                EXAlert.showFail(msg: "common_tip_coinTradeNotOpen".localized())
            }else {
                EXNavigationHandler.sharedHandler.commandTradingCoin(coinEntity.symbol, "buy")
            }
        }else if account == .otc {
            EXNavigationHandler.sharedHandler.commandToOTC(self.symbol, "")
        }else if account == .leverage {
            EXNavigationHandler.sharedHandler.commandTradingCoin((self.coinMapName as NSString).replacingOccurrences(of: "/", with: "").lowercased(), "leverBuy")
        }else  {
            EXNavigationHandler.sharedHandler.commandToContract(self.symbol, "")
        }
    }
}
extension EXAccountTransferVc {//Levers
    func loadData() {
        if coinMapName.count == 0 {
            return
        }
        let str = (coinMapName as NSString).replacingOccurrences(of: "/", with: "").uppercased()
        appApi.rx.request(.leverFinanceSymbolInfo(symbol: str))
            .MJObjectMap(EXLeverCoinBorrowRecord.self)
            .subscribe{[weak self] event in
                switch event {
                case .success(let model):
                    self?.leverModel = model
//                    self?.updateCoinDatas()
                    self?.updateExchangeBalance()
                    break
                case .failure(_):
                    break
                }
        }.disposed(by: self.disposeBag)
    }
}

//MARK: UI
extension EXAccountTransferVc{
    func configRightItem() {
        self.navigation.configRightItems(["transfer_text_record".localized()],isImageName: false)
        self.navigation.rightItemCallback = {[weak self] tag in
            self?.handleHistory()
        }
    }
    
    func configNavigation(){
        self.navigation.setdefaultType(type:.list)
        self.navigation.setTitle(title: "assets_action_transfer".localized())
        configRightItem()
    }
    
    func handleHistory() {
        if canTransferType == .leverage {
           let vc = EXLeverageTransferRecordVc.init(nibName: "EXLeverageTransferRecordVc", bundle: nil)
            vc.symbol = coinMapName
            vc.coinName = coinName
           self.navigationController?.pushViewController(vc, animated: true)
        }
        else if canTransferType == .contract {
            
            if EXAppConfigManager.sharedInstance.getContractVersion() == .new {
                let vc = EXSwapTransferRecordVc()
                vc.symbol = symbol
                self.navigationController?.pushViewController(vc, animated: true)
            }else {
                
//                let vc = SLSwapTransferRecordVc()
//                vc.symbol = symbol
//                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }
        else {
            let history = EXChargeHistoryVc.instanceFromStoryboard(name: StoryBoardNameAsset)
            history.historyScene = .otctransfer
            history.symbol = self.symbol
            self.navigationController?.pushViewController(history, animated: true)
        }
    }
    
    func configInputs() {
        coinSelector.setTitle(title: "common_text_coinsymbol".localized())
        coinSelector.arrowModel(enabled: true)
        coinSelector.titleMode(enabled: true)
        coinSelector.textfieldDidTapBlock = {[weak self] in
            self?.handleCoinSelection()
        }
        if canTransferType == .leverage && coinMapName.count > 0 &&  coinMapName.contains("/") {
              coinTitleArr = (coinMapName as NSString).components(separatedBy: "/")
            if coinName.count ==  0  && coinTitleArr.count > 0{
                coinName = coinTitleArr[0]
            }
            loadData()
        }
        coinDoubleSelector.setTitle(title: "leverage_coinMap".localized())
        coinDoubleSelector.arrowModel(enabled: true)
        coinDoubleSelector.titleMode(enabled: true)
        coinDoubleSelector.textfieldDidTapBlock = {[weak self] in
            self?.handleCoinDoubleSelection()
        }
        updateCoinDatas()
        amountView.rightSendAllLabel.text = "common_action_sendall".localized()
        amountView.setTitle(title: "charge_text_volume".localized())
        amountView.setPlaceHolder(placeHolder: "transfer_tip_emptyVolume".localized())
        amountView.input.rx.text.orEmpty.asObservable()
        .distinctUntilChanged()
            .subscribe(onNext: { [weak self] text in
                self?.amount = text
            }).disposed(by: self.disposeBag)
    }
    
    ///Update currency pairs
    func handleCoinSelection() {
        coinSelector.normalStyle()
        if canTransferType == .leverage {
            leveSelect()
        }else{
            let vc = EXSimplePickerVc.init()
            vc.setTitle("charge_action_selectCoin".localized())
            if EXAppConfigManager.sharedInstance.getContractVersion() == .new,
               canTransferType == .contract {
                let source = contractModels
                vc.cellForTitle = { index -> String in
                    return source[index].quoteSymbol.aliasName()
                }
                
                vc.didSelected = { [weak self] index in
                    let model = CoinListEntity()
                    model.name = source[index].quoteSymbol //alias
                    model.originCoin = source[index].originalCoin //Real name
                    self?.updateCoinEntity(model,swap: true)
                }
                vc.source = source as Array<AnyObject>
                navigationController?.pushViewController(vc, animated: true)
                return
            }
            let source = EXAppMarketManager.sharedInstance.getAllOTCCoinList()

            vc.cellForTitle = { index -> String in
                let item = source[index]
                return item.name
            }
            
            vc.didSelected = { [weak self] index in
                self?.updateCoinEntity(source[index])
            }

            vc.source = source

            navigationController?.pushViewController(vc, animated: true)
        }
    }
    func leveSelect() {
       var selectIdx = 0
       var titlesArr = [String]()
       for (idx,item) in coinTitleArr.enumerated() {
        if self.coinSelector.input.text == item.aliasName() {
               selectIdx = idx
               break
           }
       }
        for item in coinTitleArr {
            titlesArr.append(item.aliasName())
        }
       let sheet = EXOldActionSheetView()
        sheet.configButtonTitles(buttons: titlesArr,selectedIdx: selectIdx)
        sheet.actionIdxCallback = {[weak self] tag in
            self?.coinSelector.input.text = self?.coinTitleArr[tag].aliasName()
            self?.coinName = self?.coinTitleArr[tag] ?? ""
//            self?.updateCoinDatas()
            self?.updateExchangeBalance()
            
            self?.amountView.setText(text: "")
        }
        EXAlert.showSheet(sheetView:sheet)
    }
    func handleCoinDoubleSelection() {//Leveraged currency pair selection
        coinDoubleSelector.normalStyle()
        let vc = EXSimplePickerVc.init()
        vc.setTitle("title_choose_symbol".localized())
        let source = EXAppMarketManager.sharedInstance.getAllLeverArray()
        vc.cellForTitle = { index -> String in
            let item = source[index]
            return item.name.aliasCoinMapName()
        }
        vc.didSelected = { [weak self] index in
            let item = source[index]
            guard let mySelf = self else {return}
            mySelf.amountView.setText(text: "")
            mySelf.coinMapName = item.name
            if mySelf.coinMapName.count > 0 &&  mySelf.coinMapName.contains("/") {
                mySelf.coinTitleArr = (mySelf.coinMapName as NSString).components(separatedBy: "/")
                if mySelf.coinTitleArr.count > 0{
                   mySelf.coinName = mySelf.coinTitleArr[0]
                }
            }
            mySelf.loadData()
        }

        vc.source = source

        navigationController?.pushViewController(vc, animated: true)
    }
    
    func updateCoinEntity(_ model:CoinListEntity,swap: Bool = false) {
        if swap { //Currently not used
            self.symbol = model.originCoin
        }else{
            self.symbol = model.name
        }
        if let hasModel = EXAccountBalanceManager.manager.getCoinMapItem(self.symbol) {
            self.coinModel = hasModel
        }
        if let otcModel = EXAccountBalanceManager.manager.getOtcAccountItem(self.symbol) {
            self.otcModel = otcModel
        }
        if let swapModel =  EXAccountBalanceManager.manager.getSwapAccountItem(self.symbol) {
            self.contractModel = swapModel
        }
        amountView.setText(text: "")
        updateCoinDatas()
    }
    
   

    func updateCoinDatas() {
        guard let fromAccountType = accountTransferHeader.fromAccountView.accountType else {return}
        guard let toAccountType = accountTransferHeader.toAccountView.accountType else {return}
        
        if self.accountTransferHeader.upsideDown {
            self.contractModel?.walletAccountType = "2"
            self.handleFromModel(toAccountType)
            self.handleToModel(fromAccountType)
        }else {
            self.contractModel?.walletAccountType = "1"
            self.handleFromModel(fromAccountType)
            self.handleToModel(toAccountType)
        }
        
        configRightItem()
        
        if canTransferType != .leverage {//other
            amountView.symbol = self.symbol
            amountView.leftSymbolLabel.text = self.symbol.aliasName()
            coinSelector.setText(text: self.symbol.aliasName())
            let qty = self.getGrantsBounsValue(toAccountType: toAccountType)
            
            if qty.count > 0 {
                grantsTipView.isHidden = false
                grantsTipBtn.addTarget(self, action: #selector(clickBounsTips), for: .touchUpInside)
                if EXAppConfigManager.sharedInstance.getContractVersion() == .old {
                    grantsTipBtn.extSetTitle(String(format: "(%@%@%@)", "contract_tips_noExperience".localized(),qty.formatAmount(self.symbol),contractModel?.quoteSymbol ?? ""), titleColor: UIColor.ThemeLabel.colorMedium)
                    grantsTipBtn.titleLabel?.font = UIFont.ThemeFont.SecondaryRegular
                }else {
                    grantsTipBtn.extSetTitle(String(format: "(%@%@%@)", "contract_tips_noExperience".localized(),qty.formatAmount(self.symbol),contractModel?.quoteSymbol ?? ""), titleColor: UIColor.ThemeLabel.colorMedium)
                    grantsTipBtn.titleLabel?.font = UIFont.ThemeFont.SecondaryRegular
                }
                let balance = fromModel.balance as NSString

                if balance.isBig(qty),let rst = balance.subtracting(qty, decimals: 2) {
                    amountView.setAmount(amount:rst,title:"transfer_tip_maxTransfer".localized())
                }else {
                    amountView.setAmount(amount: "0.00",title:"transfer_tip_maxTransfer".localized())
                }
            }else {
                amountView.setAmount(amount: fromModel.balance,title:"transfer_tip_maxTransfer".localized())
                grantsTipView.isHidden = true
            }
            
        }else {//lever
            grantsTipView.isHidden = true
            coinDoubleSelector.setText(text: coinMapName.aliasCoinMapName())
            coinSelector.setText(text: self.coinName.aliasName())
            amountView.symbol = self.coinName
            amountView.leftSymbolLabel.text = self.coinName.aliasName()
            amountView.setAmount(amount: fromModel.balance,title:"transfer_tip_maxTransfer".localized())
            amountView.decimal = ""
            amountView.setText(text: "")
            if self.accountTransferHeader.upsideDown {//Only when the lever is transferred to the currency, the quantity and available assets use an 8-digit precision, while others remain unchanged
                if toAccountType == .leverage {
                    amountView.decimal = "8"
                    amountView.setAmount(amount: fromModel.balance,title:"transfer_tip_maxTransfer".localized(),isLeverage: true)
                }
            }else {
                if fromAccountType == .leverage {
                    amountView.decimal = "8"
                    amountView.setAmount(amount: fromModel.balance,title:"transfer_tip_maxTransfer".localized(),isLeverage: true)
                }
            }
        }
       
    }
    
    func configFooter() {
        footerBar.hideFooterTitle()
        footerBar.confirmBtn.addTarget(self, action:#selector(doTransferAction), for: .touchUpInside)
        let amount = amountView.input.rx.text.orEmpty.asObservable()
        let coinsymbol = coinSelector.input.rx.text.orEmpty.asObservable()
        let coinMap = coinDoubleSelector.input.rx.text.orEmpty.asObservable()
        if canTransferType == .leverage{//lever
            Observable.combineLatest(amount,coinsymbol,coinMap)
                .map( { tuple in
                    let (amount,symbol,coinMap) = tuple
                    guard let a = Double(amount) else{return false}
                    return (amount.count > 0 && symbol.count > 0 && a > 0 && coinMap.count > 0)
                })
            .bind(to: footerBar.confirmBtn.rx.isEnabled)
            .disposed(by: disposeBag)
        }else {
            Observable.combineLatest(amount,coinsymbol)
                .map( { tuple in
                    let (amount,symbol) = tuple
                    guard let a = Double(amount) else{return false}
                    return (amount.count > 0 && symbol.count > 0 && a > 0)
                })
            .bind(to: footerBar.confirmBtn.rx.isEnabled)
            .disposed(by: disposeBag)
        }
    }
    
    
    func configHeaderFlow() {
        //Switch Currency
        accountTransferHeader.onTransferTapCallback = {[weak self] in
            self?.handleAccountChangeAction()
        }
        //Transfer account up and down switching
        accountTransferHeader.onTransferUpsidedownCallback = { [weak self] upsideDown in
            self?.handleViewTransition(upsideDown)
            self?.updateBlanceAmount()
        }
        
        switch transferFlow {
        case .exchangeToOther:
            canTransferType = self.transferVm.getToAccountType()
            if self.symbol.isEmpty {
                self.symbol = self.coinModel?.coinName ?? ""
            }else {
                //The coin transaction page will directly bring in the symbol without a model. If the symbol is in the otc list
                if canTransferType == .otc {
                    var coinNames:[String] = []
                    let otccoins = EXAppMarketManager.sharedInstance.getAllOTCCoinList()
                    for otcItem in otccoins {
                        coinNames.append(otcItem.name)
                    }
                    if coinNames.count > 0, !coinNames.contains(self.symbol) {
                        let firstModel = self.coinListVm.getFirstCoinModel(.otc)
                        self.symbol = firstModel.name
                    }
                }
            }
            accountTransferHeader.setFromAccountType(.coin)
            accountTransferHeader.setToAccountType(canTransferType)
            if EXHomeViewModel.isContractStatus() {
                accountTransferHeader.setFromAccountTitle("onlyCo_assets_text_exchange".localized())
            }else {
                accountTransferHeader.setFromAccountTitle("assets_text_exchange".localized())
            }
            accountTransferHeader.setToAccountTitle(self.transferVm.getToAccountName())
            accountTransferHeader.setMultiAccountStyle(isfromAccountMulti: false)
        case .otcToExchange:
            self.symbol = self.otcModel?.coinSymbol ?? ""
            accountTransferHeader.setFromAccountType(.coin)
            accountTransferHeader.setToAccountType(.otc)
            if EXHomeViewModel.isContractStatus() {
                accountTransferHeader.setFromAccountTitle("onlyCo_assets_text_exchange".localized())
            }else {
                accountTransferHeader.setFromAccountTitle("assets_text_exchange".localized())
            }

            if EXAppConfigManager.sharedInstance.didOpenB2C(){
                accountTransferHeader.setToAccountTitle("assets_text_otc_forotc".localized())
            }else{
                accountTransferHeader.setToAccountTitle("assets_text_otc".localized())
            }
            accountTransferHeader.setMultiAccountStyle(isfromAccountMulti: false)
            canTransferType = .otc
        case .contractToExchagne:
            if let model = self.contractModel {
                self.symbol = model.quoteSymbol
            }
            
            accountTransferHeader.setFromAccountType(.coin)
            accountTransferHeader.setToAccountType(.contract)
            if EXHomeViewModel.isContractStatus() {
                accountTransferHeader.setFromAccountTitle("onlyCo_assets_text_exchange".localized())
            }else {
                accountTransferHeader.setFromAccountTitle("assets_text_exchange".localized())
            }
            accountTransferHeader.setToAccountTitle("assets_text_contract".localized())
            accountTransferHeader.setMultiAccountStyle(isfromAccountMulti: false)
            canTransferType = .contract
        case .leverageToExchagne:
            accountTransferHeader.setFromAccountType(.coin)
            accountTransferHeader.setToAccountType(.leverage)
            if EXHomeViewModel.isContractStatus() {
                accountTransferHeader.setFromAccountTitle("onlyCo_assets_text_exchange".localized())
            }else {
                accountTransferHeader.setFromAccountTitle("assets_text_exchange".localized())
            }
            accountTransferHeader.setToAccountTitle("leverage_asset".localized())
            accountTransferHeader.setMultiAccountStyle(isfromAccountMulti: false)
            canTransferType = .leverage
            coinDoubleView.isHidden = false
            if !UserDefaults.standard.bool(forKey: "EXLeverageAlertView") && EXAppConfigManager.sharedInstance.getLeverProtocolURL().count > 0{
                let alertView = EXLeverageAlertView.show()
                if let alertView = alertView {
                    alertView.isTransfer = true
                    alertView.cancleBlock = {
                        let accounts = EXAppConfigManager.sharedInstance.getSupportAccounts()
                        if accounts.count == 2 && accounts.contains(.leverage) {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
    }
    
    
}

//MARK: Data Processing - Account Balance Update Callback
extension EXAccountTransferVc{
    func configVm() {
        if self.transferFlow == .contractToExchagne {
            EXAccountBalanceManager.manager.updateContractAccountBalance()
        }else if self.transferFlow == .exchangeToOther {
//            let accounts = EXAppConfigManager.sharedInstance.getSupportAccounts()
//            if accounts.contains(.contract) {
//                EXAccountBalanceManager.manager.updateContractAccountBalance()
//            }
//            if accounts.contains(.otc) {
//                EXAccountBalanceManager.manager.updateOTCAccountBalance()
//            }
        }else {
            EXAccountBalanceManager.manager.updateExchangeAccountBalance()
        }
        //MARK: Transfer interface
        transferVm.onTransferSuccessCallback = {[weak self] toAccount in
            self?.onSuccessAlert(toAccount)
        }
    }
    
    func configAccountsBalance() {
//        EXAccountBalanceManager.manager.updateExchangeAccountBalance()

        let accounts = EXAppConfigManager.sharedInstance.getSupportAccounts()
        if accounts.contains(.otc) {
            if self.otcModel == nil {
                EXAccountBalanceManager.manager.updateOTCAccountBalance()
            }
        }

        if accounts.contains(.contract) {
          //  EXAccountBalanceManager.manager.updateContractAccountBalance()
        }

        if self.coinModel == nil {
            EXAccountBalanceManager.manager.updateExchangeAccountBalance()
        }
        
        EXAccountBalanceManager.manager.accountCallback = { [weak self] _ in
            guard let `self` = self else { return }
            self.updateExchangeBalance()
        }
        
        EXAccountBalanceManager.manager.otcAccountCallback = {[weak self] _ in
            guard let `self` = self else { return }
            self.updateOTCBalance()
        }
        
        EXAccountBalanceManager.manager.swapAccountCallback = {[weak self] _ in
                guard let `self` = self else { return }
            self.updateContractBalance()
        }
    }
    
    func updateContractBalance(){
        self.contractModels = EXAccountBalanceManager.manager.swapAccountModels
        if self.contractModels.count > 0 {
            //Default First
            self.contractModel = self.contractModels.first
            if self.symbol.count > 0 { //If it's transmitted externally. Use an external one
                for itemModel in self.contractModels {
                    if itemModel.quoteSymbol == self.symbol {
                        self.contractModel = itemModel
                    }
                }
            }
          
            if canTransferType == .contract { //If the currency transfer contract is completed, obtain the combined balance, take the first currency pair that intersects with the currency, and use this currency pair balance information to refresh the interface
                self.symbol = self.contractModel!.quoteSymbol
                let realName = EXSwapPublicInfo.shared.maiginOrignPair[self.symbol] ?? ""
                self.coinModel = EXAccountBalanceManager.manager.getCoinMapItem(realName)
                self.updateCoinDatas()
            }
        }
    }
    
    
    func updateOTCBalance() {
        self.otcModel = EXAccountBalanceManager.manager.getOtcAccountItem(self.symbol)
        self.updateCoinDatas()
    }
    
    func updateExchangeBalance() {
        self.coinModel = EXAccountBalanceManager.manager.getCoinMapItem(self.symbol)
        if !self.coinName.isEmpty && canTransferType == .leverage{
            let coin = EXAccountBalanceManager.manager.getCoinMapItem(self.coinName)
            self.leverModel.quoteEXNormalBalance = coin?.normal_balance ?? "0"
            self.leverModel.baseExNormalBalance = coin?.normal_balance ?? "0"
        }
        self.updateCoinDatas()
    }
//
//    func updateContractBalance() {
//        self.contractModel = EXAccountBalanceManager.manager.contractAccountModel
//        self.updateCoinDatas()
//    }
}

//event processing 
extension EXAccountTransferVc{
    ///Update currency pairs
    func handleAccountChangeAction() {
        var accounts = EXAppConfigManager.sharedInstance.getSupportAccounts()
        accounts.remove(at: 0)
        //Remove the first coin account
        var titles:[String] = []
        var types : [EXAccountType] = []
        if accounts.contains(.otc) {
            if EXAppConfigManager.sharedInstance.didOpenB2C() {
                titles.append("assets_text_otc_forotc".localized())
            }else{
                titles.append("assets_text_otc".localized())
            }
            types.append(.otc)
        }
        //MARK: Do not display contracts that have not been opened
        if SLUserConfig.checkHasOpenContract && accounts.contains(.contract){
            titles.append("assets_text_contract".localized())
            types.append(.contract)
        }
        if accounts.contains(.leverage) {
            titles.append("leverage_asset".localized())
            types.append(.leverage)
        }
        let sheet = EXOldActionSheetView()
        sheet.configButtonTitles(buttons: titles)
        sheet.actionIdxCallback = {[weak self] tag in
            self?.handleSheetAction(types[tag])
        }
        EXAlert.showSheet(sheetView:sheet)
    }
    
    func handleSheetAction(_ accountType:EXAccountType) {
        if accountType == .contract { //home page
            EXAccountBalanceManager.manager.updateContractAccountBalance()
        }
        if accountType == .leverage && !UserDefaults.standard.bool(forKey: "EXLeverageAlertView") && EXAppConfigManager.sharedInstance.getLeverProtocolURL().count > 0{
            let alertView = EXLeverageAlertView.show()
            if let alertView = alertView {
                alertView.isTransfer = true
                alertView.confirmBlock = {
                    self.handleSheetAction(.leverage)
                }
                alertView.cancleBlock = {
                    let accounts = EXAppConfigManager.sharedInstance.getSupportAccounts()
                    if accounts.count == 2 && accounts.contains(.leverage) {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            return
        }
        
//        if canTransferType == accountType {
//            return
//        }
        //The variable account has changed
        canTransferType = accountType
        amountView.setText(text: "")
        //Only lever display
        if accountType == .contract {
            coinDoubleView.isHidden = true
            if self.transferFlow == .exchangeToOther {
                accountTransferHeader.setToAccountTitle("assets_text_contract".localized())
                accountTransferHeader.setToAccountType(.contract)
            }else if self.transferFlow == .contractToExchagne {
                accountTransferHeader.setToAccountTitle("assets_text_contract".localized())
                accountTransferHeader.setToAccountType(.contract)
            }else if self.transferFlow == .otcToExchange {
                accountTransferHeader.setToAccountTitle("assets_text_contract".localized())
                accountTransferHeader.setToAccountType(.contract)
            }else if self.transferFlow == .leverageToExchagne {
                accountTransferHeader.setToAccountTitle("assets_text_contract".localized())
                accountTransferHeader.setToAccountType(.contract)
            }
            let firstModel = self.coinListVm.getFirstCoinModel(canTransferType)
            self.updateCoinEntity(firstModel)
        }else if accountType == .otc {

            let vc = EXSimplePickerVc.init()
            vc.setTitle("charge_action_selectCoin".localized())
            let source = EXAppMarketManager.sharedInstance.getAllOTCCoinList()
            vc.cellForTitle = { index -> String in
                let item = source[index]
                return item.name
            }
            vc.didSelected = { [weak self] index in
                guard let self = `self` else { return }
                self.coinDoubleView.isHidden = true
                if self.transferFlow == .exchangeToOther {
                    if EXAppConfigManager.sharedInstance.didOpenB2C(){
                        self.accountTransferHeader.setToAccountTitle("assets_text_otc_forotc".localized())
                    }else{
                        self.accountTransferHeader.setToAccountTitle("assets_text_otc".localized())
                    }
                    self.accountTransferHeader.setToAccountType(.otc)
                }else if self.transferFlow == .otcToExchange {
                    if EXAppConfigManager.sharedInstance.didOpenB2C(){
                        self.accountTransferHeader.setToAccountTitle("assets_text_otc_forotc".localized())
                    }else{
                        self.accountTransferHeader.setToAccountTitle("assets_text_otc".localized())
                    }
                    self.accountTransferHeader.setToAccountType(.otc)
                }else if self.transferFlow == .contractToExchagne {
                    if EXAppConfigManager.sharedInstance.didOpenB2C(){
                        self.accountTransferHeader.setToAccountTitle("assets_text_otc_forotc".localized())
                    }else{
                        self.accountTransferHeader.setToAccountTitle("assets_text_otc".localized())
                    }
                    self.accountTransferHeader.setToAccountType(.otc)
                }else if self.transferFlow == .leverageToExchagne {
                    self.accountTransferHeader.setToAccountTitle("assets_text_otc".localized())
                    self.accountTransferHeader.setToAccountType(.otc)
                }
                self.updateCoinEntity(source[index])
            }

            vc.source = source

            navigationController?.pushViewController(vc, animated: true)
        }else if accountType == .leverage {
            
            
//            if coinMapName.count == 0 {
//                let vc = EXLeverageCoinSearchVc.init(nibName: "EXLeverageCoinSearchVc", bundle: nil)
//                vc.backCoinNameBlock = {[weak self] str in
//                    guard let mySelf = self else {return}
//                    mySelf.coinMapName = str
//                    mySelf.coinTitleArr = (mySelf.coinMapName as NSString).components(separatedBy: "/")
//                    if mySelf.coinTitleArr.count > 0 {
//                        mySelf.coinName = mySelf.coinTitleArr[0]
//                    }
//                    mySelf.loadData()
//
//                }
//                self.navigationController?.pushViewController(vc, animated: true)
                let vc = EXSimplePickerVc.init()
                vc.setTitle("charge_action_selectCoin".localized())
                let source = EXAppMarketManager.sharedInstance.getAllLeverArray()
                vc.cellForTitle = { index -> String in
                    let item = source[index]
                    return item.name.aliasCoinMapName()
                }
                vc.didSelected = { [weak self] index in
                    let item = source[index]
                    guard let mySelf = self else {return}
                    mySelf.coinDoubleView.isHidden = false
                    if mySelf.transferFlow == .exchangeToOther {
                        mySelf.accountTransferHeader.setToAccountTitle("leverage_asset".localized())
                        mySelf.accountTransferHeader.setToAccountType(.leverage)
                    }else if mySelf.transferFlow == .otcToExchange {
                        mySelf.accountTransferHeader.setToAccountTitle("leverage_asset".localized())
                        mySelf.accountTransferHeader.setToAccountType(.leverage)
                    }else if mySelf.transferFlow == .contractToExchagne {
                        mySelf.accountTransferHeader.setToAccountTitle("leverage_asset".localized())
                        mySelf.accountTransferHeader.setToAccountType(.leverage)
                    }else if mySelf.transferFlow == .leverageToExchagne {
                        mySelf.accountTransferHeader.setToAccountTitle("leverage_asset".localized())
                        mySelf.accountTransferHeader.setToAccountType(.leverage)
                    }
                    mySelf.coinMapName = item.name
                    mySelf.coinTitleArr = (mySelf.coinMapName as NSString).components(separatedBy: "/")
                    if mySelf.coinTitleArr.count > 0 {
                        mySelf.coinName = mySelf.coinTitleArr[0]
                    }
                    mySelf.loadData()
                }

                vc.source = source

                navigationController?.pushViewController(vc, animated: true)
//            }
        }
        
//        self.symbol = firstModel.name
//        self.updateCoinDatas()
    }
    
    
   
    //MARK: Transfer interface
    @objc func doTransferAction() {
        //I don't know who will switch to who, but I have an exception
        guard let fromAccountType = accountTransferHeader.fromAccountView.accountType else {return}
        guard let toAccountType = accountTransferHeader.toAccountView.accountType else {return}
        
        let nsAmount = self.amount as NSString
        if nsAmount.isBig(fromModel.balance) {
            EXAlert.showFail(msg: "common_tip_balanceNotEnough".localized())
            return
        }
        var symolName = self.symbol
        if accountTransferHeader.upsideDown {
            if canTransferType == .leverage {
                symolName = coinName
            }
            self.transferVm.doTransfer(from: toAccountType, to: fromAccountType, amount:self.amount, symbol: symolName,symbolMap: coinMapName)
        }else {
            if canTransferType == .leverage {
               symolName = coinName
            }
            self.transferVm.doTransfer(from: fromAccountType, to:toAccountType, amount:self.amount, symbol: symolName,symbolMap: coinMapName)
        }
    }
    
    func handleViewTransition(_ upsideDonw:Bool) {
        configRightItem()
        self.updateCoinDatas()
        amountView.setText(text: "")
    }
}

//MARK: Experience Gold
extension EXAccountTransferVc{
    
    @objc func clickBounsTips() {
        let alert = EXNormalAlert()
        alert.configSigleAlert(title: "contract_swap_gift".localized(), message: "contract_tips_experienceGold".localized(), sigleBtnTitle: "alert_common_iknow".localized())
        //show
        EXAlert.showAlert(alertView: alert)
    }
    func isShowGrantsTip(toAccountType :EXAccountType) -> Bool {
        if accountTransferHeader.upsideDown == true {
            if EXAppConfigManager.sharedInstance.getContractVersion() == .old,toAccountType == .contract {
                if EXAppConfigManager.sharedInstance.getCoCouponSwitch().status == "1" {
                    if toAccountType == .contract {
                        let qty = contractModel?.bouns_qty ?? "0"
                        if qty.greaterThan(BTZERO) {
                            return true
                        }
                    }
                }
            }else {
                return true
            }
        }
        return false
    }
    
    func getGrantsBounsValue(toAccountType :EXAccountType) -> String{
        if isShowGrantsTip(toAccountType: toAccountType) {
            var qty = ""
            if EXAppConfigManager.sharedInstance.getContractVersion() == .old {
                qty = contractModel?.bouns_qty ?? ""
            }else {
                qty = coinModel?.coupon_balance ?? ""
            }
            let rst = qty as NSString
            if rst.isBig("0") {
                return qty
            }
        }
        return ""
    }
}

