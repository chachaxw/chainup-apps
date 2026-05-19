//
//  EXGridTradeVC.swift
//  Chainup
//
//  Created by wangdong on 2023/1/29.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import EXKit

enum EXQuantStrategyType {
    case aiStrategy
    case customStrategy
}

class EXQuantHeader:UIView {
    var requesting: Bool = false
    lazy var orderLabel: UILabel = {
        let v = UILabel(text:"quant_ordering".localized(),font: .Ex.medium(16), textColor: .Ex.text1)
        return v
    }()
    
    lazy var hideOthers: EXCheckBox = {
        let v = EXCheckBox.init()
        v.isHidden = true
        v.checked(check: true)
        v.checkLabel.font = .Ex.medium(14)
        v.checkLabel.textColor = .Ex.text1
        v.text(content: "quant_hide_otherSymbol".localized())
        return v
    }()
    
    lazy var historyBtn: UIButton = {
        let v = UIButton.init(type: .custom)
        v.setImage(EXKitBundle.image(named: "public_icon_order"), for: .normal)
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configHeaderLayouts()
    }
    
    func configHeaderLayouts() {
        self.addSubview(orderLabel)
        self.addSubview(hideOthers)
        self.addSubview(historyBtn)
        orderLabel.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(15)
            maker.centerY.equalToSuperview()
        }
        hideOthers.snp.makeConstraints { (maker) in
            maker.right.equalTo(historyBtn.snp.left).offset(-20)
            maker.centerY.equalToSuperview()
            maker.height.equalToSuperview()
        }
        historyBtn.snp.makeConstraints { (maker) in
            maker.right.equalToSuperview().offset(-15)
            maker.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if let context = UIGraphicsGetCurrentContext() {
            context.setLineWidth(1)
            UIColor.Ex.fill4.setStroke()
            context.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            context.strokePath()
        }
    }
    
}

class EXQuantTradeVC: BaseVC {
    var currentPage:Int = 1
    var strategyType:EXQuantStrategyType = .aiStrategy
    var entity:CoinMapEntity = CoinMapEntity()
    var close :String = ""
    
    var ticker:EXKlineTictModel = EXKlineTictModel() {
        didSet {
            self.reloadTicker()
        }
    }
    var rowDatas:[EXQuantStrategyListItem] = []
    
    var aiConfig:EXQuantSaveStrategyConfig = EXQuantSaveStrategyConfig()
    var customConfig:EXQuantSaveStrategyConfig = EXQuantSaveStrategyConfig()
    
    var orderListTimer: Disposable? = nil

    var coinBalance:String = ""
    var marketBalance:String = ""
    var closePrice:String = ""
    var calBaseModel:EXCalBaseModel = EXCalBaseModel()

    

    var hideOthers:Bool = true
    var requesting: Bool = false
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    lazy var pagingHeaderView: EXQuantPagingHeaderView = {
        let v = EXQuantPagingHeaderView()
        return v
    }()
    
    lazy var segmentView: EXQuantSegmentView = {
        let v = EXQuantSegmentView()
        v.delegate = self
        return v
    }()
    
    
    lazy var tableView: UITableView = {
        let v = UITableView(frame: .zero, style: .plain)
        v.separatorStyle = .none
        v.backgroundColor = .clear
        v.delegate = self
        v.dataSource = self
        v.register(EXQuantOrderListCell.self, forCellReuseIdentifier: "EXQuantOrderListCell")
        v.register(EXTradeEmptyCell.classForCoder(), forCellReuseIdentifier: "EXTradeEmptyCell")
        v.mj_header = EXRefreshHeaderView (refreshingBlock: {[weak self] in
            guard let self else {return}
            self.currentPage = 1
            self.getStrategyList(page: self.currentPage)
        })
        v.mj_footer = EXRefreshFooterView (refreshingBlock: {[weak self] in
            guard let self else {return}
            self.currentPage += 1
            self.getStrategyList(page: self.currentPage)
        })
        return v
    }()
    
    
    lazy var sectionHeaderView: EXQuantHeader = {
        let view = EXQuantHeader.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 44))
        view.backgroundColor = .Ex.fill2
        view.hideOthers.checkCallback = {[weak self] checked in
            self?.hideOthers = checked
            self?.currentPage = 1
            self?.getStrategyList(page:1)
        }
        view.historyBtn.addTarget(self, action: #selector(toHistoryLists), for: .touchUpInside)
        return view
    }()
    
    lazy var aiHeader: EXQuantAIHeaderView = {
        let header = EXQuantAIHeaderView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 392))
        header.heightCallBack = {[weak self] height in
            guard let self else { return }
            self.aiHeader.height = height
        }
        header.confirmButton.addTarget(self, action: #selector(saveStrategy), for: .touchUpInside)
        return header
    }()
    
    lazy var customHeader: EXQuantCustomHeaderView = {
        let header = EXQuantCustomHeaderView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 462))
        header.heightCallBack = {[weak self] height in
            guard let self else { return }
            self.customHeader.height = height
        }
        header.confirmButton.addTarget(self, action: #selector(saveStrategy), for: .touchUpInside)
        return header
    }()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.requesting = false
        configUserLogin()
        repeatOrder()
        getAIStrategyInfo()
        updateBalance()
        if XUserDefault.isOffLine() {
            self.rowDatas.removeAll()
            self.tableView.reloadData()
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.roundCorners(corners: [.topLeft, .topRight], radius: 15)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        suspendTask()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchTicker()
    }
    
    func updateBalance() {
        if XUserDefault.isOffLine() {
            return
        }
        
        appApi.rx.request(.accountBalance(coinSymbols: "\(self.entity.coinName),\(self.entity.marketName)"))
            .MJObjectMap(EXAccountBalanceModel.self)
            .subscribe{[weak self] event in
                guard let mySelf = self else {return}
                switch event {
                case .success(let model):
                    mySelf.handleBalance(balanceModels: model.allCoinMapList)
                    break
                case .failure(_):
                    break
                }
            }.disposed(by: self.disposeBag)
    }
    @objc func clearAsset(){
        self.aiHeader.clearData(true)
        self.customHeader.clearData(true)
        sectionHeaderView.orderLabel.text = "quant_ordering".localized()
        
        
    }
    func handleBalance(balanceModels:[EXAccountCoinMapItem]) {
        //https://jira.hiotc.pro/browse/CHAINUP-14524
        for model in balanceModels {
            if model.coinName == self.entity.coinName {
                self.coinBalance = model.normal_balance.decimalString(value: entity.volDecimal())
            }else if model.coinName == self.entity.marketName {
                self.marketBalance = model.normal_balance.decimalString(value: entity.priceDecimal())
            }
        }
        aiHeader.bindAccountBalance(coinB: self.coinBalance, baseB: self.marketBalance)
        customHeader.bindAccountBalance(coinB: self.coinBalance, baseB: self.marketBalance)
    }
    
    func configUserLogin() {
        if XUserDefault.isOffLine() {
            aiHeader.confirmButton.setTitle("login_action_login".localized(), for: .normal)
            customHeader.confirmButton.setTitle("login_action_login".localized(), for: .normal)
        }else {
            aiHeader.confirmButton.setTitle("quant_start_trade".localized(), for: .normal)
            customHeader.confirmButton.setTitle("quant_start_trade".localized(), for: .normal)
        }
    }
    
    
    func configBindDatas() {
        
        aiHeader.useOwnBaseSwitch.onValueChangeCallback = {[weak self] on in
            guard let `self` = self  else { return }
            self.aiConfig.useOwnBase = on ? "1" : "0"
            self.checkUseOwnBase(model: self.aiConfig)
        }

        aiHeader.quoteAmountInputView.textfieldValueChangeBlock = {[weak self] str in
            guard let `self` = self  else { return }
            self.aiConfig.totalQuoteAmount = str
            self.checkUseOwnBase(model: self.aiConfig)
        }
        aiHeader.stopLowInputView.textfieldValueChangeBlock =  {[weak self] str in
            guard let `self` = self  else { return }
            self.aiConfig.stopLowPrice = str
            self.checkUseOwnBase(model: self.aiConfig)
        }
        aiHeader.stopHighInputView.textfieldValueChangeBlock =  {[weak self] str in
            guard let `self` = self  else { return }
            self.aiConfig.stopHighPrice = str
            self.checkUseOwnBase(model: self.aiConfig)
        }
        
        
        customHeader.useOwnBaseSwitch.onValueChangeCallback = {[weak self] on in
            guard let `self` = self  else { return }
            self.customConfig.useOwnBase = on ? "1" : "0"
            self.checkUseOwnBase(model: self.customConfig)
        }
        
        customHeader.minProfitPublish
            .subscribe(onNext:{[weak self] minProfits in
                guard let `self` = self else {return}
                self.customConfig.everyProfitMin = minProfits
            }).disposed(by: self.disposeBag)
        
        customHeader.quoteAmountInputView.textfieldValueChangeBlock = {[weak self] str in
            guard let `self` = self  else { return }
            self.customConfig.totalQuoteAmount = str
            self.checkUseOwnBase(model: self.customConfig)
        }
        customHeader.stopLowInputView.textfieldValueChangeBlock =  {[weak self] str in
            guard let `self` = self  else { return }
            self.customConfig.stopLowPrice = str
            self.checkUseOwnBase(model: self.customConfig)
        }
        customHeader.stopHighInputView.textfieldValueChangeBlock =  {[weak self] str in
            guard let `self` = self  else { return }
            self.customConfig.stopHighPrice = str
            self.checkUseOwnBase(model: self.customConfig)
        }
        
        customHeader.lowPriceInputView.textfieldValueChangeBlock =  {[weak self] str in
            guard let `self` = self  else { return }
            self.customConfig.lowestPrice = str
            self.checkUseOwnBase(model: self.customConfig)
        }
        customHeader.highPriceInputView.textfieldValueChangeBlock =  {[weak self] str in
            guard let `self` = self  else { return }
            self.customConfig.highestPrice = str
            self.checkUseOwnBase(model: self.customConfig)
        }
        customHeader.gridAmountTextField.textfieldValueChangeBlock =  {[weak self] str in
            guard let `self` = self  else { return }
            self.customConfig.gridNumber = str
            self.checkUseOwnBase(model: self.customConfig)
        }
        
        customHeader.gridLineChangeBlock = {[weak self] type in
            guard let `self` = self  else { return }
            self.customConfig.gridLineType = type
            self.checkUseOwnBase(model: self.customConfig)
            
        }
    }
    
    @objc func toHistoryLists() {
        if checkUserIsLogin() {
            let vc = EXQuantHistoryListVC.init()
            vc.entity = self.entity
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
     
        view.addSubViews([pagingHeaderView, segmentView, tableView])
        pagingHeaderView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        pagingHeaderView.heightCallBack = {[weak self] height in
            guard let self else { return }
            self.pagingHeaderView.snp.updateConstraints { $0.height.equalTo(height) }
        }
        segmentView.snp.makeConstraints { make in
            make.top.equalTo(pagingHeaderView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(segmentView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.aiHeader.heightCallBack = {[weak self] height in
            guard let self else { return }
            self.aiHeader.height = height
        }
   
        
        self.aiHeader.bindSymbol(coinSym: entity.coinName, marketSym: entity.marketName)
        self.customHeader.bindSymbol(entity.name)
        
        tableView.tableHeaderView = self.aiHeader
        configBindDatas()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(clearAsset),
                                               name: NSNotification.Name(rawValue: EXNoti.logOut.rawValue),
                                               object: nil)
    }
    

    override func userGoHomeScreen(_ to: Bool) {
        guard let top = AppService.topViewController() else {return}
        if top == self {
            if to {
                suspendTask()
            }else {
                fetchTicker()
                repeatOrder()
            }
        }
    }
}

extension EXQuantTradeVC {
    
    func checkUserIsLogin() ->Bool {
        if XUserDefault.isOffLine() {
            BusinessTools.modalLoginVC()
            return false
        }
        return true
    }
    
    func checkCanSaveStrategy(model:EXQuantSaveStrategyConfig) -> Bool {
        //https://jira.hiotc.pro/browse/CHAINUP-14449
        //Judgment empty
        if strategyType == .aiStrategy {
            if model.isAiHasEmpty() {
                EXAlert.showFail(msg: "otc_mustWrite_tex".localized())
                return false
            }
        }else {
            if model.isCustomHasEmpty() {
                EXAlert.showFail(msg: "otc_mustWrite_tex".localized())
                return false
            }
        }

        let priceDecimal = entity.priceDecimal()
        
        
        //Minimum profit per grid>0
        if "0".isBiggerThan(model.everyProfitMin) {
            EXAlert.showFail(msg: "quant_everyProfitMin_error".localized())
            return false
        }

        if closePrice.count > 0 {
            if model.lowestPrice.decimalString(value: entity.priceDecimal()).isBiggerThan(closePrice) {
                EXAlert.showFail(msg: "quant_grid_closeLessThanLow".localized())
                return false
            }
            if closePrice.isBiggerThan(model.highestPrice.decimalString(value: entity.priceDecimal())) {
                EXAlert.showFail(msg: "quant_grid_closeGreaterThanHigh".localized())
                return false
            }
        }
        
        //Insufficient balance
        if marketBalance.isSmallerThan(model.totalQuoteAmount) {
            EXAlert.showFail(msg: self.entity.marketName + "quant_balance_error".localized())
            return false
        }
        
        //Minimum order amount
        if model.minimumOrderQuantity.isBiggerThan(model.totalQuoteAmount) {
            EXAlert.showFail(msg: "quant_minimumOrderQuantity_error".localized())
            return false
        }
        
        if strategyType == .customStrategy {

            let r = customConfig.lowestPrice.stringByMultiplying(multiple: "1.02", decimal: entity.priceDecimal())
            //Judging low * 1.02<high
            if r.isBiggerThan(model.highestPrice) {
                EXAlert.showFail(msg: "quant_range_error".localized())
                return false
            }
            
            //Determine grid range 2-100
            if model.gridNumber.isSmallerThan("2") || model.gridNumber.isBiggerThan("100") {
                EXAlert.showFail(msg: "quant_gridLineNumber_error".localized(),holdResponder: true)
                return false
            }
        }
        
        //Stop loss and stop profit, current price judgment
        if model.stopLowPrice.count > 0 {
            if model.stopLowPrice.greaterThanOrEqualto(model.lowestPrice) && strategyType == .customStrategy {
                EXAlert.showFail(msg: "quant_stop_low_error".localized(),holdResponder: true)
                return false
            }

            if model.stopLowPrice.greaterThanOrEqualto(self.closePrice) {
                EXAlert.showFail(msg: "quant_stopMinPrice_error".localized(),holdResponder: true)
                return false
            }
  
        }
        
        if model.stopHighPrice.count > 0 {
            if model.stopHighPrice.lessThanOrEqualto(model.highestPrice) && strategyType == .customStrategy {
                EXAlert.showFail(msg: "quant_stop_high_error".localized(),holdResponder: true)
                return false
            }
            if model.stopHighPrice.lessThanOrEqualto(self.closePrice) {
                EXAlert.showFail(msg: "quant_stopMaxPrice_error".localized(),holdResponder: true)
                return false
            }
        }
        
        if let gridNumber = Int(model.gridNumber) {
            //Correction: User investment amount>max (minimum investment in a single grid * (number of grids -1), minimum investment amount)
            var max = model.limitTotalMin
            let totalGridAmount = model.everyGridLimitMin.stringByMultiplying(multiple: ("\(gridNumber - 1)"), decimal: -1)
            if totalGridAmount.isBiggerThan(model.limitTotalMin) {
                max = totalGridAmount
            }
            
            if max.isBiggerThan(model.totalQuoteAmount) {
                let error = String.init(format: "quant_limitInvestment_error".localized(), "\(totalGridAmount.decimalString(value: priceDecimal)) \(self.entity.marketName.aliasName())")
                EXAlert.showFail(msg: error,holdResponder: true)
                return false
            }
        }
        
        return true
    }
    
    @objc func saveStrategy() {
        if checkUserIsLogin() {
            var model:EXQuantSaveStrategyConfig?
            if strategyType == .aiStrategy {
                model = aiConfig
            }else if strategyType == .customStrategy {
                model = customConfig
                if self.customConfig.lowestPrice.greaterThan(self.customConfig.highestPrice){
                    EXAlert.showFail(msg: "quant_grid_price_check".localized())
                    return
                }
            }
            if let configM = model, checkCanSaveStrategy(model: configM) {
                if configM.useOwnBase == "1" {
                    if calBaseModel.baseAmount.isBiggerThan(self.coinBalance) {
                        EXAlert.showFail(msg: "quant_baseBalance_error".localized() + " " + calBaseModel.baseAmount + " " + self.entity.coinName.aliasName())
                    }else {
                        self.quantOrderCreate(amount: calBaseModel.baseAmount, configM: configM)
                    }
                }else {
                    self.quantOrderCreate(amount: "0", configM: configM)
                }
            }
        }
    }
    
    func quantOrderCreate(amount:String,configM:EXQuantSaveStrategyConfig) {
        if requesting {
            return
        }
        requesting = true
        appApi.rx.request(.quantSaveStrategy(symbol: configM.symbol,
                                             quantType: configM.quantType,
                                             gridLineType: configM.gridLineType,
                                             gridNumber: configM.gridNumber,
                                             lowestPrice: configM.lowestPrice.decimalString1(entity.priceDecimal()),
                                             highestPrice: configM.highestPrice.decimalString1(entity.priceDecimal()),
                                             stopHighPrice: configM.stopHighPrice,
                                             stopLowPrice: configM.stopLowPrice,
                                             totalQuoteAmount: configM.totalQuoteAmount,
                                             useOwnBase: configM.useOwnBase,
                                             fee:configM.fee,
                                             totalBaseAmount: amount))
            .MJObjectMap(EXVoidModel.self)
            .subscribe(onSuccess: {[weak self] (model) in
                guard let self else{return}
                self.requesting = false
                self.clearData(clearBalance: false)
                EXAlert.showSuccess(msg: "quant_toast_saveSuccess".localized())
                self.reloadCurrents()
            }, onFailure: { [weak self] _ in
                guard let self else { return }
                self.requesting = false
            }).disposed(by: disposeBag)
    }
    
    func clearData(clearBalance:Bool) {
        self.aiConfig.clearAIConfig()
        self.customConfig.clearCustomConfig()
        self.closeSwitch()
        self.aiHeader.clearData(clearBalance)
        self.customHeader.clearData(clearBalance)
    }
}

extension EXQuantTradeVC {
    func refreshDepthAndTicker() {
        fetchTicker()
    }
}

extension EXQuantTradeVC {
    
    func refreshEntity(_ entity:CoinMapEntity) {
        self.entity = entity
        self.clearData(clearBalance: true)
        self.aiHeader.bindSymbol(coinSym: entity.coinName, marketSym: entity.marketName)
        self.customHeader.bindSymbol(entity.name)
        getAIStrategyInfo()
        updateBalance()
        fetchTicker()
    }
    
    func reloadTicker() {
        guard let close = self.ticker.tick?.close else {return}
        self.close = close
        self.closePrice = close.formatAmountUseDecimal(entity.price)
        pagingHeaderView.updateTict(tict: self.ticker, entity: self.entity)
    }
    
    func getAIStrategyInfo() {
        if entity.symbol.isEmpty {
            return
        }
        
        appApi.rx.request(.quantGetAIStrategyInfo(symbol: entity.name))
            .MJObjectMap(EXQuantAIStrategyInfoDataModel.self)
            .subscribe(onSuccess: {[weak self] (model) in
                guard let mySelf = self else{return}
                mySelf.updateStrategyInfo(model: model)
            }, onFailure: { _ in
                
            }).disposed(by: disposeBag)
    }
    
    func updateStrategyInfo(model:EXQuantAIStrategyInfoDataModel) {
        aiConfig.configWithAI(model: model)
        customConfig.configWithCustom(model: model)
        aiHeader.bindDatas(model: model)
        customHeader.bindDatas(model: model)
    }
    
    func repeatOrder() {
        if XUserDefault.isOffLine() {
            return
        }
        orderListTimer?.dispose()
        heartBeats()
        orderListTimer = Observable<Int>.interval(.seconds(3), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (element) in
                guard let `self` = self else { return }
                self.heartBeats()
            })
    }
    
    func heartBeats() {
        self.currentPage = 1
        self.getStrategyList(page: self.currentPage)
    }
    

    func getStrategyList(page:Int, isShowLoading: Bool = false) {
        if XUserDefault.isOffLine() {
            self.endRefresh()
            return
        }
        
        if entity.symbol.isEmpty {
            self.endRefresh()
            return
        }
        
        var symbol = ""
        if hideOthers == true {
            symbol = entity.name
        }
        //We need to poll here and display 100 items
        if isShowLoading {
            appApi.showAutoLoading()
        } else {
            appApi.hideAutoLoading()
        }
        appApi.rx.request(.quantGetStrategyList(symbol:symbol,
                                                page:"\(page)",
                                                status:"1",
                                                pageSize:"100"))
            .MJObjectMap(EXQuantStrategyList.self)
            .subscribe(onSuccess: {[weak self] (model) in
                guard let mySelf = self else{return}
                mySelf.handleStrategyLists(results: model.strategyVoList)
            }, onFailure: { [weak self] _ in
                guard let self else { return }
                self.endRefresh()
            }, onDisposed: {
                appApi.hideAutoLoading()
            }).disposed(by: disposeBag)
    }
    
    func endRefresh() {
        self.tableView.mj_header.endRefreshing()
        self.tableView.mj_footer.endRefreshing()
    }
    
    func handleStrategyLists(results:[EXQuantStrategyListItem]) {
        if results.count < 20 {
            self.tableView.mj_footer.endRefreshingWithNoMoreData()
        }else {
            self.tableView.mj_footer.endRefreshing()
        }
        self.tableView.mj_header.endRefreshing()
        if results.count > 0{
            if self.currentPage == 1 {
                self.rowDatas = results
            }else {
                self.rowDatas = self.rowDatas + results
            }
        }else {
            self.rowDatas.removeAll()
        }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.tableView.reloadData()
        }
    }
    
    func getOrderingCount() ->String {
        let allOrdering = rowDatas.count
        if allOrdering > 99 {
            return "99+"
        }else {
            return "\(allOrdering)"
        }
    }
    
}

extension EXQuantTradeVC: EXQuantSegmentViewDelegate {
    
    func segmentedView(_ segmentedView: EXQuantSegmentView, didSelectedItemAt index: Int) {
        if index == 0 {
            strategyType = .aiStrategy
            tableView.tableHeaderView = aiHeader
        }
        else {
            strategyType = .customStrategy
            tableView.tableHeaderView = customHeader
        }
    }
    
    func segmentedView(_ scrollView: EXQuantSegmentView, didTap guideButton: UIButton) {
        let alert = EXQuantGuideAlert.init()
        let imgnames:[String] = []
        alert.updateImgs(guideImageNames:imgnames, title: "quant_grid_guide".localized())
        EXAlert.showAlert(alertView: alert, offset: 32)
    }
}

extension EXQuantTradeVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if XUserDefault.isOffLine(){
            sectionHeaderView.orderLabel.text = "quant_ordering".localized()
        }else{
            sectionHeaderView.orderLabel.text = "quant_ordering".localized() + "(\(getOrderingCount()))"
        }
        return sectionHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if rowDatas.count == 0 {
            return 182
        }
        return 356
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rowDatas.count > 0 ? rowDatas.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.rowDatas.count > 0 {
            let model = rowDatas[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "EXQuantOrderListCell") as! EXQuantOrderListCell
            cell.bindItems(item: model)
            cell.closeQuantCallback = {[weak self] sid in
                self?.closeQuant(sid: sid)
            }
            cell.detailQuantCallback = {[weak self] sid in
                self?.toDetail(sid: sid,model: model)
            }
            return cell
        }else {
            let cell : EXTradeEmptyCell = tableView.dequeueReusableCell(withIdentifier: "EXTradeEmptyCell") as! EXTradeEmptyCell
            return cell
        }
    }
    
    func toDetail(sid:String,model:EXQuantStrategyListItem ) {
        if sid.isEmpty {
            return
        }
        let vc = EXQuantDetailContainer.init(strategyID: sid,listItem: model)
        vc.close = self.close
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func closeQuant(sid:String) {
        if sid.isEmpty {
            return
        }
        
        let normalAlert = EXNormalAlert.init()
        normalAlert.configAlert(title: "common_text_tip".localized(), message: "quant_alert_stopGrid".localized())
        normalAlert.alertCallback = {[weak self] idx in
            if idx == 0 {
                self?.confirmClose(sid: sid)
            }
        }
        EXAlert.showAlert(alertView: normalAlert)
    }
    
    func confirmClose(sid:String) {
        appApi.rx.request(.quantStopStrategy(strategyId: sid))
            .MJObjectMap(EXVoidModel.self)
            .subscribe(onSuccess: {[weak self] (model) in
                guard let mySelf = self else{return}
                mySelf.reloadCurrents()
            }, onFailure: { _ in
                
            }).disposed(by: disposeBag)
    }
    
    func reloadCurrents() {
        self.currentPage = 1
        self.getStrategyList(page: self.currentPage, isShowLoading: true)
    }
}

extension EXQuantTradeVC {
    
    func fetchTicker() {
        let channel_ticker = "market_\(entity.symbol)_ticker"
        let cb_id_ticker = "trade_ticker\(entity.symbol)"
        let tickerItem = WSRecordItem.init(event: "sub", channels: channel_ticker, cbid: cb_id_ticker)
        EXWebSocket.marketService.addRecordObject(recordItem: tickerItem)
    }
    
    func suspendTask() {
        orderListTimer?.dispose()
        EXWebSocket.marketService.cancellAlltaskObj()
    }
    

}

extension EXQuantTradeVC {
    func checkUseOwnBase(model:EXQuantSaveStrategyConfig) {
        if model.useOwnBase == "1" {
            tryToGetCalBaseAmount(model)
        }else {
            hideCalBalance()
        }
    }
    
    func tryToGetCalBaseAmount(_ configM:EXQuantSaveStrategyConfig) {
        if checkUserIsLogin() {
            if checkCanCalBase(model: configM) {
                if strategyType == .customStrategy {
                    let r = configM.lowestPrice.stringByMultiplying(multiple: "1.02", decimal: entity.priceDecimal())
                    //Judging low * 1.02<high
                    if r.isBiggerThan(customConfig.highestPrice) {
                        EXAlert.showFail(msg: "quant_range_error".localized())
                        closeSwitch()
                        return
                    }
                }
                appApi.rx.request(.quantCalBaseAmount(symbol: configM.symbol,
                                                      lowP: configM.lowestPrice,
                                                      highP: configM.highestPrice,
                                                      gridNumber: configM.gridNumber,
                                                      gridLineType: configM.gridLineType,
                                                      fee: configM.fee,
                                                      totalQuoteAmount: configM.totalQuoteAmount,
                                                      currentPrice: self.closePrice))
                    .MJObjectMap(EXCalBaseModel.self)
                    .subscribe(onSuccess: {[weak self] (model) in
                        guard let mySelf = self else{return}
                        mySelf.updateCalBalance(model: model)
                    }, onFailure: { _ in
                        
                    }).disposed(by: disposeBag)
            }else {
                closeSwitch()
            }
        }else {
            closeSwitch()
        }
    }
    
    func updateCalBalance(model:EXCalBaseModel) {
        self.calBaseModel = model
        if strategyType == .aiStrategy{
            aiHeader.updateCalBlanceTitle(balance: model.baseAmount)
        }else {
            customHeader.updateCalBlanceTitle(balance: model.baseAmount)
        }
    }
    
    
    func checkCanCalBase(model:EXQuantSaveStrategyConfig) -> Bool {
        //Only judge empty
        if strategyType == .aiStrategy {
            if model.isAiHasEmpty() {
      //If the invested asset is empty, it will be directly false without prompting
                EXAlert.showFail(msg: "otc_mustWrite_tex".localized())
                return false
            }
        }else {
            if model.isCustomHasEmpty() {
                EXAlert.showFail(msg: "otc_mustWrite_tex".localized())
                return false
            }
        }
        return true
    }
    
    func hideCalBalance() {
        if strategyType == .aiStrategy {
            aiHeader.updateCalBlanceTitle(balance: "")
        }else {
            customHeader.updateCalBlanceTitle(balance:
                "")
        }
    }
    
    func closeSwitch() {
        if strategyType == .aiStrategy {
            aiHeader.useOwnBaseSwitch.isOn = false
            aiConfig.useOwnBase = "0"
        }else {
            customHeader.useOwnBaseSwitch.isOn = false
            customConfig.useOwnBase = "0"
        }
        hideCalBalance()
    }
}
