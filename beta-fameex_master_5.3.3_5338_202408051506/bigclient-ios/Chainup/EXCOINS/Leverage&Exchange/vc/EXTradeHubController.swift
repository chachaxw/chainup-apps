//
//  EXTradeHubController.swift
//  Chainup
//
//  Created by liuxuan on 2023/10/26.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
import RxSwift

class EXTradeHubController: BaseVC,HubNavigationPlugin,EXTradeCmdProtocal{
    var drawerHub:EXDrawerHub?
    var drawerHubLever:EXDrawerHub?
    var drawerHubQuant:EXDrawerHub?
    var canDeposit: Bool?
    var jump: Bool = false
    var currentIdx:Int = 0
    
    var exEntity:CoinMapEntity = CoinMapEntity()
    var quantEntity:CoinMapEntity = CoinMapEntity()
    var leverEntity:CoinMapEntity = CoinMapEntity()
    
    lazy var tradeVC:EXTransactionTradeVC = {
        let vc = EXTransactionTradeVC.init(type: .exchange)
        vc.entity = self.exEntity
        return vc
    }()

    lazy var leverVC:EXLeverTradeVC = {
        let vc = EXLeverTradeVC.init(type: .leverage)
        vc.entity = self.leverEntity
        return vc
    }()
    
    lazy var quantVC: EXQuantTradeVC = {
        let vc = UIViewController.createControllerFromStoryBoard(name: .quant, type: EXQuantTradeVC.self)
        vc.entity = self.quantEntity
        return vc
    }()

    internal lazy var navigation : EXHubNavigation = {
        let nav =  EXHubNavigation.init(presenter: self,type: .trade,coinMapSymbol: self.exEntity.coinName)
        nav.bottomLineView.isHidden = true
        return nav
    }()
    
    lazy var rowDatas:[HubNavType] = navigation.segmentTypes
    
    func setDefaultEntity(){
        //Obtain default currency pairs
        //Obtain default leverage currency pairs
        self.exEntity = EXAppMarketManager.sharedInstance.getDefaultExchangeMap()
        if  EXAppConfigManager.sharedInstance.didOpenLever() {
            self.leverEntity = EXAppMarketManager.sharedInstance.getDefaultLeverCoin()
        }
        if EXAppConfigManager.sharedInstance.didOpenQuant() {
            self.quantEntity = EXAppMarketManager.sharedInstance.getDefaultQuantCoin()
        }
    }
    
    func updateEntity(entity:CoinMapEntity) {
        guard let fromType = getCurrentHubType(type: currentIdx) else { return }
        if fromType == .trade {
            self.exEntity = entity
            tradeVC.refreshEntity(entity)
        }else if fromType == .quant  {
            self.quantEntity = entity
            quantVC.refreshEntity(entity)
        }else if fromType == .lever {
            self.leverEntity = entity
            leverVC.refreshEntity(entity)
        }
        self.navigation.updateCoinMap(entity: entity,tick: nil)
    }
    
   
     //MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ThemeNav.bg
        EXTracking.shared.trackFirebase(firebaseKey: FirebaseKey.Tradepageview)
        registerWs()
        setDefaultEntity()
        configNavi()
        let frame = CGRect(x: 0, y: navigation.visibleHeight, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - navigation.visibleHeight - TABBAR_HEIGHT)
        for type in rowDatas {
            if type == .trade  {
                self.tradeVC.view.frame = frame
                tradeVC.view.autoresizingMask = []
                self.addChild(tradeVC)
                self.view.addSubview(tradeVC.view)
                self.bindScroll(tradeVC.transactionTable)
                // tradeVC.hubNavigation = navigation
            }else if type == .lever {
                self.leverVC.view.frame = frame
                leverVC.view.autoresizingMask = []
                self.addChild(leverVC)
                self.bindScroll(leverVC.transactionTable)
               // leverVC.hubNavigation = navigation
            }else if type == .quant {
                self.quantVC.view.frame = frame
                quantVC.view.autoresizingMask = []
                self.addChild(quantVC)
            }
        }
        EXAppMarketManager.sharedInstance.onMarketPublish.skip(1)
            .subscribe (onNext: {[weak self] (success) in
                guard success, let `self` = self else { return }
                self.updateEntityIfNeededForChildController(type: self.navigation.hubType)
            }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIApplication.didBecomeActiveNotification).take(until: self.rx.deallocated).throttle(.seconds(1), scheduler: MainScheduler.asyncInstance).subscribe(onNext: {[weak self] _ in
            guard let self else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                self.updateDepthAndTickerIfNeedForEntity(type: self.navigation.hubType)
            }
        }).disposed(by: disposeBag)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.exEntity.symbol.isEmpty {
            self.exEntity = EXAppMarketManager.sharedInstance.getDefaultExchangeMap()
            tradeVC.refreshEntity(exEntity)
        }
        if  EXAppConfigManager.sharedInstance.didOpenLever() {
            if self.leverEntity.symbol.isEmpty {
                self.leverEntity = EXAppMarketManager.sharedInstance.getDefaultLeverCoin()
                leverVC.refreshEntity(leverEntity)
            }
        }
        if EXAppConfigManager.sharedInstance.didOpenQuant() {
            if self.quantEntity.symbol.isEmpty {
                self.quantEntity = EXAppMarketManager.sharedInstance.getDefaultQuantCoin()
                quantVC.refreshEntity(quantEntity)
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        EXAccountBalanceManager.manager.getcoinList(sourceType: .sourceForDeposit) {  [weak self] reult in
            self?.canDeposit = reult
        }
    }
}

//MARK: naviagation Action
extension  EXTradeHubController {
    
    func configNavi() {
        self.navigation.updateCoinMap(entity: self.exEntity, tick: nil)
        //Switch currency drawer
        navigation.coinMapNavi.marketBtn.addTarget(self, action: #selector(clickLeftBtn(sender:)), for: .touchUpInside)
        //Three more points
        navigation.coinMapNavi.moreBtn.addTarget(self, action: #selector(moreBtnAction(_:)), for: .touchUpInside)
        //Currency pair
        navigation.coinMapNavi.exchangeBtn.addTarget(self, action: #selector(changeCoinPair(sender:)), for: .touchUpInside)
        //K line
        navigation.coinMapNavi.detailBtn.addTarget(self, action: #selector(goToKlineDetail(_:)), for: .touchUpInside)
        navigation.onSegmentCallback = {[weak self] idx in
            self?.changeSegment(idx: idx)
        }
    }
    
    func vcForType(_ type: HubNavType) -> UIViewController? {
        switch type {
        case .trade:
            return tradeVC
        case .quant:
            return quantVC
        case .lever:
            return leverVC
        default:
            return nil
        }
    }
    func getCurrentHubType(type:Int) -> HubNavType?{
        if navigation.segmentTypes.count == 0 {
            if type == 0 {
                return .trade
            }
        }else {
            if navigation.segmentTypes.count > type {
                let type = navigation.segmentTypes[type]
                return type
            }
        }
        return nil
    }

    
    func changeSegment(idx:Int) {
        guard let type = getCurrentHubType(type: idx) else {return}
        guard let fromType = getCurrentHubType(type: currentIdx) else { return }

        if currentIdx == idx {
            return
        }
        let toType = rowDatas[idx]
        
        let fromVC = vcForType(fromType)
        let toVC = vcForType(toType)
    
        if type == .trade {
            self.navigation.hubType = .trade
            self.navigation.updateCoinMap(entity: self.exEntity, tick:nil)
        }else if type == .quant {
            self.navigation.hubType = .quant
            self.navigation.updateCoinMap(entity: self.quantEntity, tick:nil)
        }else if type == .lever {
            self.navigation.hubType = .lever
            self.navigation.updateCoinMap(entity: self.leverEntity, tick:nil)
        }else if type == .fiat {
            EXTracking.shared.trackFirebase(firebaseKey: FirebaseKey.Trade_P2P_click)

            let otc = EXOTCHomeContainerVc.instanceFromStoryboard(name: StoryBoardNameOTC)
            self.navigationController?.pushViewController(otc, animated: true)
            // restore to previously selected tab
            self.navigation.menubar.selectItemAt(index: currentIdx)
        }

        if let fromVC = fromVC, let toVC = toVC {
            self.transition(from: fromVC, to: toVC, duration: 0.1, options: .transitionCrossDissolve, animations: nil) { [self] (finished) in
                if finished {
                    self.tradeVC.didMove(toParent: self)
                    self.leverVC.willMove(toParent: nil)
                }
            }
            currentIdx = idx
        }
    }
    
    
    func updateDepthAndTickerIfNeedForEntity(type: HubNavType) {
        switch type {
        case .trade:
            tradeVC.refreshDepthAndTicker()
        case .quant:
            quantVC.refreshDepthAndTicker()
        case .lever:
            leverVC.refreshDepthAndTicker()
        default: return
        }
    }
    
    func updateEntityIfNeededForChildController(type:HubNavType) {
        switch type {
            case .trade:
                if exEntity.symbol.isEmpty {
                    exEntity = EXAppMarketManager.sharedInstance.getDefaultExchangeMap()
                    tradeVC.refreshEntity(exEntity)
                }
            case .quant:
                if quantEntity.symbol.isEmpty {
                    quantEntity = EXAppMarketManager.sharedInstance.getDefaultQuantCoin()
                    quantVC.refreshEntity(quantEntity)
                }
            case .lever:
                if leverEntity.symbol.isEmpty {
                    leverEntity = EXAppMarketManager.sharedInstance.getDefaultLeverCoin()
                    leverVC.refreshEntity(leverEntity)
                }
            default: return
        }
    }
    
    
    
    func bindScroll(_ effectsScroll:UIScrollView) {
        guard rowDatas.count > 1 else { return }
        effectsScroll.rx.contentOffset
            .skip(1)
            .map { $0.y > 0 }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] hide in
                guard let self else { return }
                guard let fromType = self.getCurrentHubType(type: self.currentIdx) else { return }
                var viewController: EXTradeBaseVc?
                if fromType == .trade {
                    viewController = self.tradeVC
                } else if fromType == .lever {
                    viewController = self.leverVC
                }
                guard let viewController else { return }
                UIView.animate(withDuration: 0.3) {
                    hide == true ? self.navigation.hide() : self.navigation.show()
                    viewController.view.frame = .init(x: 0,
                                                      y: self.navigation.visibleHeight,
                                                      width: SCREEN_WIDTH,
                                                      height: SCREEN_HEIGHT - self.navigation.visibleHeight - TABBAR_HEIGHT)
                    self.view.layoutIfNeeded()
                }
            }).disposed(by: self.disposeBag)
    }
    
    @objc func clickLeftBtn(sender:UIButton){
        guard let type = getCurrentHubType(type: currentIdx) else { return }

        self.view.isUserInteractionEnabled = false
        sender.isEnabled = false

        let vc = EXDrawerVC()
        if type == .trade {
            if self.drawerHub == nil {
                drawerHub = EXDrawerHub.init(type: .trade,symbol: self.exEntity.symbol)
            }
            drawerHub?.symbolsAry = self.exEntity.getAllSymbolsAndETFs()
            drawerHub?.symbol = self.exEntity.symbol
            vc.addView(drawerHub!)
            vc.pullBlock = {[weak self] in
                sender.isEnabled = true
                self?.drawerHub?.cancelAllSubCoins()
                self?.view.isUserInteractionEnabled = true
            }
            drawerHub?.clickCellBlock = {[weak self](entity) in
                guard let mySelf = self else{return}
                mySelf.handleDrawerEntity(entity: entity,drawerVc: vc,sender: sender)
            }
            drawerHub?.reloadSubCoins()
        } else if type == .quant {
            if self.drawerHubQuant == nil {
                drawerHubQuant = EXDrawerHub.init(type: .quant,symbol: self.exEntity.symbol)
            }
            drawerHubQuant?.symbol = self.quantEntity.symbol
            vc.addView(drawerHubQuant!)
            vc.pullBlock = {[weak self] in
                sender.isEnabled = true
                self?.drawerHubQuant?.cancelAllSubCoins()
                self?.view.isUserInteractionEnabled = true
            }
            drawerHubQuant?.clickCellBlock = {[weak self](entity) in
                guard let mySelf = self else{return}
                mySelf.handleDrawerEntity(entity: entity,drawerVc: vc,sender: sender)
            }
            drawerHubQuant?.reloadSubCoins()
        } else {
            if self.drawerHubLever == nil {
                drawerHubLever = EXDrawerHub.init(type: .lever,symbol: self.leverEntity.symbol)
            }
            drawerHubLever?.symbol = self.leverEntity.symbol
            vc.addView(drawerHubLever!)
            vc.pullBlock = {[weak self] in
                sender.isEnabled = true
                self?.drawerHubLever?.cancelAllSubCoins()
                self?.view.isUserInteractionEnabled = true
            }
            drawerHubLever?.clickCellBlock = {[weak self](entity) in
                guard let mySelf = self else{return}
                mySelf.handleDrawerEntity(entity: entity,drawerVc: vc,sender: sender)
            }
            drawerHubLever?.reloadSubCoins()
        }
    }
    
    func handleDrawerEntity(entity:CoinDetailsEntity,drawerVc:EXDrawerVC,sender:UIButton) {
        guard let type = getCurrentHubType(type: currentIdx) else { return }
        
        drawerVc.pullAnimationCallback {
            sender.isEnabled = true
            self.view.isUserInteractionEnabled = true
            if type == .trade {
                self.drawerHub?.cancelAllSubCoins()
            }else if type == .quant {
                self.drawerHubQuant?.cancelAllSubCoins()
            }else {
                self.drawerHubLever?.cancelAllSubCoins()
            }
            self.updateEntity(entity: EXAppMarketManager.sharedInstance.getCoinMapEntityByName(entity.name))
        }
    }
    
    @objc func moreBtnAction(_ sender:UIButton){
        guard let fromType = getCurrentHubType(type: currentIdx) else { return }

        let options: [EXPopoverOption] = [.type(.auto), .cornerRadius(4), .showBlackOverlay(true),.blackOverlayColor(UIColor.ThemeView.mask),.arrowSize(CGSize.init(width: 10, height: CGFloat.leastNonzeroMagnitude)),.ignoreFromViewHeight(true)]
        let popover = EXPopover(options: options, showHandler: nil, dismissHandler: nil)
        popover.popoverColor = UIColor.ThemeView.bg

        var models:[EXBouncedModel] = []
        var height = 0
        if fromType == .trade {
            models = getmodels()
            height = models.count * 50
        }else if fromType == .lever {
            models = getLeverModels()
            height = models.count * 50
        }else if fromType == .quant {
            models = getQuantModels()
            height =  models.count * 50
        }
        let view = EXBouncedView.init(frame: CGRect(x: 0, y: 0, width: 148, height:height))
        if fromType == .trade || fromType == .quant {
            view.setData(models)
            view.clickViewBlock = {[weak self] action  in
                guard let mySelf = self else{return}
                popover.dismiss()
                if action == .horizontal ||
                    action == .vertical {
                    mySelf.tradeVC.changeHeaderLayout(action: action)
                }else {
                    if XUserDefault.isOffLine() {
                        BusinessTools.modalLoginVC()
                        return
                    }else {
                        if action == .recharge {
                            //Opened Kyc authentication for coin charging
                            if EXAppConfigManager.sharedInstance.getKycConfigModel("1"){
                                if EXOTCSafetyCheckVm.manager.checkKycRequire(mySelf) == false{
                                    return
                                }
                            }
                            
                            if let reslut = self?.canDeposit { //
                                self?.goToNext(reslut: reslut)
                                return
                            }
                            sender.isUserInteractionEnabled = false
                            
                            EXAccountBalanceManager.manager.getcoinList(sourceType: .sourceForDeposit) {  [weak self] reult in
                                sender.isUserInteractionEnabled = true
                                self?.goToNext(reslut: reult)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                sender.isUserInteractionEnabled = true
                            }
                        }else if action == .transfer {
                            
                            let transfer = EXAccountTransferVc.instanceFromStoryboard(name: StoryBoardNameAsset)
                            if mySelf.currentIdx == 0 {
                                transfer.transferFlow = .exchangeToOther
                                transfer.symbol = mySelf.exEntity.marketName.uppercased()
                            }else {
                                transfer.transferFlow = .leverageToExchagne
                                transfer.coinMapName = mySelf.leverEntity.name
                            }
                            self?.navigationController?.pushViewController(transfer, animated: true)
                        }
                    }
                }
            }
        }else {
            view.setData(models)
            view.clickViewBlock = {[weak self] action  in
                guard let mySelf = self else{return}
                popover.dismiss()
                if action == .horizontal ||
                    action == .vertical {
                    mySelf.leverVC.changeHeaderLayout(action: action)
                }else {
                    if XUserDefault.isOffLine() {
                        BusinessTools.modalLoginVC()
                        return
                    }else {
                        if action == .leverReturn {
                            //This old class is called 'borrow', but it's about returning content

                            let vc = EXCoinBorrowRecordVc.init(nibName: "EXCoinBorrowRecordVc", bundle: nil)
                            let model = EXLeverageCoinMapItem()
                            model.name = mySelf.leverEntity.name
                            vc.model = model
                            mySelf.navigationController?.pushViewController(vc, animated: true)
                        }else if action == .leverBorrow {
                            //This old class is called a return, but it is a loan content
                            let vc = EXLeverageReturnVc.init(nibName: "EXLeverageReturnVc", bundle: nil)
                            vc.type = .leverageBorrow
                            vc.currentCoinName = mySelf.leverEntity.name
                            mySelf.navigationController?.pushViewController(vc, animated: true)
                              
                        }else if action == .transfer {
                            
                            let transfer = EXAccountTransferVc.instanceFromStoryboard(name: StoryBoardNameAsset)
                            transfer.transferFlow = .leverageToExchagne
                            transfer.coinMapName = mySelf.leverEntity.name
                            mySelf.navigationController?.pushViewController(transfer, animated: true)
                        }
                    }
                }
            }
        }
      
        popover.show(view, fromView: sender)
    }
    func goToNext(reslut: Bool){
        if reslut == false {
            EXAlert.showFail(msg: "charge_tip_notavailable".localized())
            return
        }
        let searchVc = EXCoinSearchListVc.instanceFromStoryboard(name: StoryBoardNameAsset)
        searchVc.sourceType = .sourceForDeposit
        searchVc.needPush = true
        self.navigationController?.pushViewController(searchVc, animated: true)
    }
    func getmodels() -> [EXBouncedModel]{
        var models = [EXBouncedModel]()
        let model = EXBouncedModel()
        model.img = "coins_recharge"
        model.name = "coin_text_recharge".localized()
        model.action = .recharge
        model.showSeperator = true
        models.append(model)
        
        if EXAppConfigManager.sharedInstance.didOpenFiat() {
            let model1 = EXBouncedModel()
            model1.img = "coins_more_transfer"
            model1.name = "assets_action_transfer".localized()
            model1.action = .transfer
            model1.showSeperator = true
            models.append(model1)
        }
        
        let model2 = EXBouncedModel()
        if tradeVC.headerLayout == .vertical {
            model2.img = "exchange_horizontalversion"
            model2.name = "coin_text_horizontalDish".localized()
            model2.action = .horizontal
        }else {
            model2.img = "exchange_verticalversion"
            model2.name = "coin_text_verticalDish".localized()
            model2.action = .vertical
        }
        model2.showSeperator = true
        models.append(model2)
        return models
    }
    
    func getLeverModels() -> [EXBouncedModel]{
        var models = [EXBouncedModel]()
        let model = EXBouncedModel()
        model.img = "coins_borrow"
        model.name = "leverage_borrow".localized()
        model.action = .leverBorrow
        models.append(model)
        
        let model1 = EXBouncedModel()
        model1.img = "coins_more_transfer"
        model1.name = "assets_action_transfer".localized()
        model1.action = .transfer
        models.append(model1)
        
        let model3 = EXBouncedModel()
        model3.img = "coins_return"
        model3.name = "leverage_return".localized()
        model3.action = .leverReturn
        models.append(model3)
        
        let model2 = EXBouncedModel()
        if leverVC.headerLayout == .vertical {
            model2.img = "exchange_horizontalversion"
            model2.name = "coin_text_horizontalDish".localized()
            model2.action = .horizontal
        }else {
            model2.img = "exchange_verticalversion"
            model2.name = "coin_text_verticalDish".localized()
            model2.action = .vertical
        }
        models.append(model2)
        return models
    }
    
    func getQuantModels() ->[EXBouncedModel] {
        var models = [EXBouncedModel]()
        let model = EXBouncedModel()
        model.img = "coins_recharge"
        model.name = "coin_text_recharge".localized()
        model.action = .recharge
        model.showSeperator = true
        models.append(model)
        
        if EXAppConfigManager.sharedInstance.didOpenFiat() {
            let model1 = EXBouncedModel()
            model1.img = "coins_more_transfer"
            model1.name = "assets_action_transfer".localized()
            model1.action = .transfer
            model1.showSeperator = true
            models.append(model1)
        }
        return models
    }
    
    func changeCoinModels() -> [EXBouncedModel] {
        guard let fromType = getCurrentHubType(type: currentIdx) else { return [] }
        var name:String = ""
        if fromType == .trade {
            name = exEntity.coinName
        }else if fromType == .lever {
            name = leverEntity.coinName
        }else if fromType == .quant {
            name = quantEntity.coinName
        }
        var models:[EXBouncedModel] = []
        if fromType == .trade {
            let markets = EXAppMarketManager.sharedInstance.getMarketSorts()
            for market in markets {
                let coins = EXAppMarketManager.sharedInstance.getCoinPairsBy(marketName: market)
                let selectedCoins = coins.filter({return $0.coinName == name})
                for coin in selectedCoins {
                    let model1 = EXBouncedModel()
                    model1.selectedColor = (self.exEntity.name == coin.name) ? UIColor.ThemeView.bgTab : UIColor.ThemeView.bg
                    model1.titleColor = (self.exEntity.name == coin.name) ? UIColor.ThemeView.highlight : UIColor.ThemeLabel.colorLite
                    
                    model1.name = coin.name.aliasCoinMapName()
                    model1.action = .changeCoinMap(coin.name)
                    model1.showArrow = true
                    model1.showSeperator = true
                    models.append(model1)
                }
            }
        }else if fromType == .lever {
            let markets = EXAppMarketManager.sharedInstance.getAllLeverMarketArray()
            for market in markets {
                let coins = EXAppMarketManager.sharedInstance.getLeverMarketMaps(market)
                let selectedCoins = coins.filter({return $0.coinName == name})
                for coin in selectedCoins {
                    let model1 = EXBouncedModel()
                    model1.selectedColor = (self.leverEntity.name == coin.name) ? UIColor.ThemeView.bgTab : UIColor.ThemeView.bg
                    model1.titleColor = (self.leverEntity.name == coin.name) ? UIColor.ThemeView.highlight : UIColor.ThemeLabel.colorLite
                    model1.name = coin.name.aliasCoinMapName()
                    model1.action = .changeCoinMap(coin.name)
                    model1.showArrow = true
                    model1.showSeperator = true
                    models.append(model1)
                }
            }
        }else if fromType == .quant {
            let markets = EXAppMarketManager.sharedInstance.getAllQuantMarketNameArray()
            for market in markets {
                let coins = EXAppMarketManager.sharedInstance.getQuantMarketMaps(market)
                let selectedCoins = coins.filter({return $0.coinName == name})
                for coin in selectedCoins {
                    let model1 = EXBouncedModel()
                    model1.selectedColor = (self.quantEntity.name == coin.name) ? UIColor.ThemeView.bgTab : UIColor.ThemeView.bg
                    model1.titleColor = (self.quantEntity.name == coin.name) ? UIColor.ThemeView.highlight : UIColor.ThemeLabel.colorLite
                    model1.name = coin.name.aliasCoinMapName()
                    model1.action = .changeCoinMap(coin.name)
                    model1.showArrow = true
                    model1.showSeperator = true
                    models.append(model1)
                }
            }
        }
        return models
    }
    
    func commonTradePopOption()->[EXPopoverOption] {
        let options: [EXPopoverOption] = [.type(.auto), .cornerRadius(4), .showBlackOverlay(true),.blackOverlayColor(UIColor.ThemeView.mask),.arrowSize(CGSize.init(width: 10, height: CGFloat.leastNonzeroMagnitude)),.ignoreFromViewHeight(true)]
        return options
    }
    
    @objc func changeCoinPair(sender:UIButton) {
        let models = changeCoinModels()
        if models.count > 0 {
            let popover = EXPopover(options: commonTradePopOption(), showHandler: nil, dismissHandler: nil)
            popover.popoverColor = UIColor.ThemeView.bg
            let view = EXBouncedView.init(frame: CGRect(x: 0, y: 0, width: 180, height: models.count * 50))
            view.setData(models)
            view.clickViewBlock = {[weak self] action  in
                guard let mySelf = self else{return}
                popover.dismiss()
                switch action {
                case .changeCoinMap(let value):
                    mySelf.updateEntity(entity: EXAppMarketManager.sharedInstance.getCoinMapEntityByName(value))
                default:
                    break
                }
            }
            popover.show(view, fromView: sender)
        }
    }
    
    @objc func goToKlineDetail(_ sender:UIButton) {
        guard let fromType = getCurrentHubType(type: currentIdx) else { return }
        EXTracking.shared.trackFirebase(firebaseKey: FirebaseKey.Trade_Kline_click)
        if fromType == .trade {
            let dvc = EXKlineDetailNewVC(entity: self.exEntity, kDetailType: .coin)
            self.navigationController?.pushViewController(dvc, animated: true)
        }else if fromType == .quant {
            let dvc = EXKlineDetailNewVC(entity: self.quantEntity, kDetailType: .quant)
            self.navigationController?.pushViewController(dvc, animated: true)
        }else if fromType == .lever {
            let dvc = EXKlineDetailNewVC(entity: self.leverEntity, kDetailType: .lever)
            self.navigationController?.pushViewController(dvc, animated: true)
        }
        
    }
}

extension EXTradeHubController{
    
    func excuteCmd(symbol: String, action: String) {
        var entity = CoinMapEntity()
        if symbol.count > 0 { //If the currency is transferred, update it
            entity = EXAppMarketManager.sharedInstance.getCoinMapEntityBySymbol(symbol)
            if entity.name == ""{
                EXAlert.showFail(msg: "common_tip_hasNoCoinPair".localized())
                return
            }
            self.updateEntity(entity: entity)
        }
        if action == "buy" || action == "sell"{
            //If the lever is activated, the segment will be switched
            if EXAppConfigManager.sharedInstance.didOpenLever() {
                switchTransaction()
            }
            tradeVC.clickTrading(action, entity: entity)
        }else if action == "leverBuy" || action == "leverSell"{
            switchLeverage()
            leverVC.clickTrading(action, entity: entity)
        }else if action == "quant" {
            if EXAppConfigManager.sharedInstance.didOpenQuant() {
                switchToQuant()
                quantVC.refreshEntity(entity)
            }
        }
        //from other page resub
    
        
    }
    
    @objc func switchTransaction(){
        if let index = rowDatas.firstIndex(of: .trade) {
            self.navigation.menubar.selectItemAt(index: index)
            self.changeSegment(idx: 0)
        }
    }
    
    func switchLeverage(){
        self.loadViewIfNeeded()
        if let leverIdx = self.rowDatas.firstIndex(of: .lever) {
            self.navigation.menubar.selectItemAt(index: leverIdx)
            self.navigation.changeIdx(idx: leverIdx)
        }
    }
    
    func switchToQuant() {
        self.loadViewIfNeeded()
        if let leverIdx = self.rowDatas.firstIndex(of: .quant) {
            self.navigation.menubar.selectItemAt(index: leverIdx)
            self.navigation.changeIdx(idx: leverIdx)
        }
    }
}


//MARK: ws
extension EXTradeHubController{
    func registerWs() {
        EXWebSocket.marketService.onwskLineEventCallback
            .subscribe(onNext: {[weak self] (event,datas,symbol) in
//                print(datas)
                guard let mySelf = self else { return }
                if event == .ticker {
                    guard let tickerModel = EXKlineTictModel.mj_object(withKeyValues: datas) else { return }
                    mySelf.dispatchTickerData(tickerModel,symbol)
                }else if event == .klineDepth {
                    guard let model = ContractWsDepthModel.mj_object(withKeyValues: datas) else {return}
                    mySelf.dispatchDepthData(model,symbol)
                }
            }).disposed(by: self.disposeBag)
    }
    
    func dispatchTickerData(_ model:EXKlineTictModel, _ symbol:String) {
        guard let type = getCurrentHubType(type: currentIdx) else { return }

        if type == .trade {
//            print(symbol)
            if exEntity.symbol == symbol {
                self.navigation.updateCoinMap(entity: self.exEntity, tick: model.tick)
                tradeVC.ticker = model
            }else  {
                if exEntity.etfUpAndDown.count > 0,exEntity.etfUpAndDown.contains(symbol) {
                    tradeVC.bindETFsTicker(symbol: symbol, ticker: model)
                }
            }
        }else if type == .lever {
            if leverEntity.symbol != symbol {
                return
            }
            self.navigation.updateCoinMap(entity: self.leverEntity, tick: model.tick)
            leverVC.ticker = model
        }else if type == .quant {
            if quantEntity.symbol != symbol {
                return
            }
            self.navigation.updateCoinMap(entity: self.quantEntity, tick: model.tick)
            quantVC.ticker = model
        }
    }
    
    func dispatchDepthData(_ model:ContractWsDepthModel,_ symbol:String) {
        guard let type = getCurrentHubType(type: currentIdx) else { return }
        if type == .trade {
            if exEntity.symbol != symbol {
                return
            }
            tradeVC.depth = model
        }else if type == .lever {
            if leverEntity.symbol != symbol {
                return
            }
            leverVC.depth = model
        }
    }
    
}
