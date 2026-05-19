//
//  EXTradeBaseVc.swift
//  Chainup
//
//  Created by liuxuan on 2023/11/20.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
class EXTradeBaseVc: BaseVC {
    
    var tradeType:EXTradeOrderType
    
    var depthStep:Int = 0
    var depthLayoutIdx:Int = 0 //0 default 1 buy 2 sell
    var orderWay:EXTradeOrderWay = .limit //Market price
    
    var entity:CoinMapEntity = CoinMapEntity()
    var preEntity:CoinMapEntity = CoinMapEntity()

    var headerLayout:TradeHeaderLayout = .vertical

    var rowDatas:[EXCurrentEntrustEntity] = []
    let handler = EXTradeOrderHandler()
    var currentOrderIds:String = ""
    var orderListNewTimer: Disposable? = nil
    
    var track_begin:Date?
    var track_end:Date?

    let popOverSubject : BehaviorSubject<Bool> = BehaviorSubject.init(value:false)

    var ticker:EXKlineTictModel = EXKlineTictModel() {
        didSet {
            self.reloadTicker()
        }
    }
    var depth:ContractWsDepthModel = ContractWsDepthModel() {
        didSet {
            self.reloadDepth()
        }
    }
    
    lazy var transactionTable : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.estimatedSectionHeaderHeight = 44
        tableView.contentInset = .init(top: 0, left: 0, bottom: SCREEN_HEIGHT * 0.2, right: 0)
        tableView.scrollIndicatorInsets = .init(top: 16, left: 0, bottom: 0, right: 0)
        tableView.extRegistCell([EXCurrentEntrustTC.classForCoder(),EXTradeEmptyCell.classForCoder()], ["EXCurrentEntrustTC","EXTradeEmptyCell"])
        tableView.extSetTableView(self, self)
        tableView.mj_header = EXRefreshHeaderView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.reloadTicker()
            mySelf.heartBeats()
        })
        return tableView
    }()
    
    lazy var tradeHeaderV:EXTradeHeaderV = {
        let trade = EXTradeHeaderV.init(entity: self.entity, orderType: self.tradeType, layout: .vertical, orderWay: self.orderWay)
        return trade
    }()
    
    lazy var tradeTitleHeader : EXTransactionEntrustView = {
        let view = EXTransactionEntrustView()
        view.clickAllEntrustBlock = {[weak self] in
            self?.gotoCurrentEntrust()
        }
        return view
    }()
    
    lazy var tradeHeaderH:EXTradeHeaderH = {
        let trade = EXTradeHeaderH.init(entity: self.entity, orderType: self.tradeType, layout: .horizontal, orderWay: self.orderWay)
        return trade
    }()
    
    lazy var tradeSkeleton: EXSkeletonTradingView = {
        let v = EXSkeletonTradingView()
        v.isUserInteractionEnabled = false
        return v
    }()
    
    
    
    func entityDidRefreshed() {}//Updated currency pairs
    func gotoCurrentEntrust() {}
    func heartBeats(){}
    
    func createOrderAction(element:OrderCreateElement) {}
    @objc func cancelOrderAction(entity:EXCurrentEntrustEntity) {}
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        suspendTask()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resumeTask()
    }
    
    required init(type:EXTradeOrderType) {
        self.tradeType = type
        super.init(nibName: nil, bundle: nil)
    }

    
    required init?(coder aDecoder: NSCoder) {
        self.tradeType = .exchange
        super.init(coder: aDecoder)
    }
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.roundCorners(corners: [.topLeft, .topRight], radius: 20)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(transactionTable)
        handleNotifi()
        configHeaderActions()
        transactionTable.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    
        tradeHeaderV.refreshEntity(entity: entity)
        tradeHeaderV.orderArea.onOrderWayChangend()
        transactionTable.tableHeaderView = tradeHeaderV
        if let tableHeaderView = transactionTable.tableHeaderView {
            let size = CGSize(width: Device_W, height: UIView.layoutFittingCompressedSize.height)
            tableHeaderView.height = tableHeaderView.systemLayoutSizeFitting(size, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
            transactionTable.tableHeaderView = tableHeaderView
            transactionTable.reloadData()
            transactionTable.layoutIfNeeded()
        }
        popOverSubject
            .asObserver()
            .bind(to: tradeHeaderV.orderArea.orderTypeBtn.rx.isOn)
            .disposed(by: self.disposeBag)
    }
    
    
    func configHeaderActions() {
        
        tradeHeaderV.orderArea.orderCommonArea.transferBlock = {[weak self] in
            guard let self else { return }
            self.onTransfer()
        }
        
        tradeHeaderV.depthArea.onDepthLayoutBlock = {[weak self] in
            self?.changeDepthLayouts()
        }
        tradeHeaderV.depthArea.onDepthScaleBlock = {[weak self] in
            self?.changeDepthScale()
        }
        tradeHeaderV.orderArea.onOrderCreateBlock = {[weak self] element in
            self?.createOrderAction(element: element)
        }
        
        tradeHeaderV.orderArea.onOrderWayBlock = {[weak self] sender in
            self?.onOrderWayClicked(sender: sender)
        }
        
        //Horizontal plate
        tradeHeaderH.orderArea.transferBlock = {[weak self] in
            guard let self else { return }
            self.onTransfer()
        }
        tradeHeaderH.orderArea.onOrderCreateBlock = {[weak self] element in
            self?.createOrderAction(element: element)
        }
        tradeHeaderH.depthArea.onDepthScaleBlock = {[weak self] in
            self?.changeDepthScale()
        }
        tradeHeaderH.orderArea.onOrderWayChangedBlock = {[weak self] value in
            self?.updateOrderWay(with: value)
        }
    
    }
    
    func commonTradePopOption()->[EXPopoverOption] {
        let options: [EXPopoverOption] = [.type(.auto),
                                          .cornerRadius(4),
                                          .verticalOffset(5),
                                          .showBlackOverlay(true),
                                          .blackOverlayColor(UIColor.ThemeView.mask.withAlphaComponent(0.1)),
                                          .arrowSize(CGSize.init(width: 10, height: CGFloat.leastNonzeroMagnitude))]
        return options
    }
    
    func orderWaysModel() -> [EXBouncedModel] {
        var models:[EXBouncedModel] = []
        let model = EXBouncedModel()
        model.name = "contract_action_limitPrice".localized()
        model.action = .tradeOrderWayLimit
        model.selectedColor = (self.orderWay == .limit) ? UIColor.ThemeView.bgTab : UIColor.ThemeView.bg
        model.titleColor = (self.orderWay == .limit) ? UIColor.ThemeView.highlight : UIColor.ThemeLabel.colorLite
        
        models.append(model)
        
        let modelB = EXBouncedModel()
        modelB.name = "contract_action_marketPrice".localized()
        modelB.action = .tradeOrderWayMarket
        modelB.selectedColor = (self.orderWay == .market) ? UIColor.ThemeView.bgTab : UIColor.ThemeView.bg
        modelB.titleColor = (self.orderWay == .market) ? UIColor.ThemeView.highlight : UIColor.ThemeLabel.colorLite
        
        models.append(modelB)
        
        return models
    }
    
    @objc func onOrderWayClicked(sender:UIButton) {
        self.view.endEditing(true)
        let popover = EXPopover(options: commonTradePopOption(), showHandler: nil, dismissHandler: nil)
        popover.popoverColor = .Ex.fill6
        let models = orderWaysModel()
        let width = self.headerLayout == .vertical ? tradeHeaderV.getOrderWayWidth() : tradeHeaderH.getOrderWayWidth()
        let view = EXBouncedView.init(frame: CGRect(x: 0, y: 0, width:width, height: CGFloat(models.count * 36)))
        view.setData(models,cellHeight: 36)
        view.clickViewBlock = {[weak self] action  in
            popover.dismiss()
            guard let mySelf = self else{return}
            mySelf.popOverSubject.onNext(false)

            if mySelf.orderWay == .limit, action == .tradeOrderWayLimit {
                return
            }
            if mySelf.orderWay == .market, action == .tradeOrderWayMarket {
                return
            }
            
            var _orderWay: EXTradeOrderWay = .limit
            switch action {
            case .tradeOrderWayLimit:
                _orderWay = .limit
                break
            case .tradeOrderWayMarket:
                _orderWay = .market
                break
            default:
                break
            }
            mySelf.updateOrderWay(with: _orderWay)
        }
        popover.blackOverlayColor = .Ex.fill7
        popOverSubject.onNext(true)
        popover.show(view, fromView: sender)
    }
    
    func updateOrderWay(with value:EXTradeOrderWay) {
        guard orderWay != value  else { return }
        orderWay = value
        tradeHeaderV.updateOrderWay(orderWay: orderWay)
        tradeHeaderH.updateOrderWay(orderWay: orderWay)
        tradeHeaderV.depthArea.updateTableViewHeight()
    
        if let tableHeaderView = transactionTable.tableHeaderView {
            let size = CGSize(width: Device_W, height: UIView.layoutFittingCompressedSize.height)
            tableHeaderView.height = tableHeaderView.systemLayoutSizeFitting(size, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
            transactionTable.tableHeaderView = tableHeaderView
        }
        
        transactionTable.reloadData()
        transactionTable.layoutIfNeeded()
    }
    
    //Click depth
    func changeDepthScale(){
        let arr = self.entity.depthArrayShow
        
        let sheet = EXOldActionSheetView()
        sheet.actionIdxCallback = {[weak self](idx) in
            guard let mySelf = self else{return}
            if mySelf.depthStep == idx {
                return
            }
            mySelf.updateDepthScale(newScale: idx)
        }
        sheet.actionCancelCallback = {[weak self]() in
            guard let self  else{ return }
        }
        sheet.configButtonTitles(buttons:  arr,selectedIdx: depthStep)
        EXAlert.showSheet(sheetView: sheet)
    }
    
    func updateDepthScale(newScale:Int) {
        //Market_ Filcoinusdt_ Depth_ Step 0 subscription is processed based on the index of the data, not the displayed data
        print("newScale=\(newScale)")
        self.cancelDepth()
        self.depthStep = newScale
        fetchDepth()
        self.tradeHeaderV.depthArea.depthScale = newScale
        self.tradeHeaderH.depthArea.depthScale = newScale
    }
    
    @objc func onTransfer() {
        if XUserDefault.isOffLine() {
            BusinessTools.modalLoginVC()
            return
        }
        if self.tradeType == .exchange {
            let transfer = EXAccountTransferVc.instanceFromStoryboard(name: StoryBoardNameAsset)
            transfer.transferFlow = .exchangeToOther
            transfer.symbol = entity.marketName.uppercased()
            self.navigationController?.pushViewController(transfer, animated: true)
        }else {
            let transfer = EXAccountTransferVc.instanceFromStoryboard(name: StoryBoardNameAsset)
            transfer.transferFlow = .leverageToExchagne
            transfer.coinMapName = self.entity.name
            self.navigationController?.pushViewController(transfer, animated: true)
        }

    }
    
    func clearInputFields() {
        tradeHeaderV.orderArea.orderCommonArea.reloadFiedls()
        tradeHeaderH.orderArea.orderBuyArea.reloadFiedls()
        tradeHeaderH.orderArea.orderSellArea.reloadFiedls()
    }
}

extension EXTradeBaseVc {
    func cancelDepth() {
        let channel = "market_\(entity.symbol)_depth_step\(depthStep)"
        EXWebSocket.marketService.cancelTaskSubObject(channel: channel)
    }
    
    func fetchDepth() {
        let channel = "market_\(entity.symbol)_depth_step\(depthStep)"
        let cb_id = "trade_depth_\(entity.symbol)"
        let item = WSRecordItem.init(event: "sub", channels: channel, cbid: cb_id, asks: "150", bids: "150")
        EXWebSocket.marketService.addRecordObject(recordItem: item)
    }
    
    func fetchTicker() {
//        var tickers = "market_\(entity.symbol)_ticker"
//        if self.entity.etfUpAndDown.count > 0 {
//            let otherTicker = entity.etfUpAndDown.map { (str) -> String in
//                return  "market_\(str)_ticker"
//            }
//            let etf = otherTicker.joined(separator: ",")
//            tickers.append(",\(etf)")
//        }
        let tickers = self.entity.getAllSymbolsAndETFs().map {
            (str) -> String in
            return  "market_\(str)_ticker"
        }.joined(separator: ",")

//        let channel_ticker = "market_\(entity.symbol)_ticker"
        let cb_id_ticker = "trade_ticker\(entity.symbol)"
        let tickerItem = WSRecordItem.init(event: "sub_batch", channels: tickers, cbid: cb_id_ticker)
        EXWebSocket.marketService.addRecordObject(recordItem: tickerItem)
    }
    
    func beginFetchDepthTicker() {
        fetchDepth()
        fetchTicker()
        trackActionOn()
    }
    
    
    /// only called when switching currency pairs
    func updateTickerIfNeedWhenOnlyChangeEntity() {
        self.ticker = EXKlineTictModel()
    }
    
    func reloadTicker() {
        //Update the latest price of inventory
        self.tradeHeaderV.depthArea.bindTicker(tick: self.ticker)
        self.tradeHeaderH.depthArea.bindTicker(tick: self.ticker)
        //Update the buy/sell price to the limit commission column, only set once
        reloadSuggestions()
        //Update title with the latest price
    }
    
    func reloadDepth() {
        if self.track_end == nil {
            self.track_end = Date()
        }
        //Update disk data
        self.tradeHeaderV.depthArea.bindDepth(depthModel: self.depth, volDecimal: self.entity.volDecimal())
        self.tradeHeaderH.depthArea.bindDepth(depthModel: self.depth, volDecimal: self.entity.volDecimal())
        //Update the buy/sell price to the limit commission column, only set once
        reloadSuggestions()
    }
    

    func changeHeaderLayout(action :EXBouncedModelAction) {
        if action == .horizontal {
            if self.headerLayout == .horizontal {return}
            self.headerLayout = .horizontal
            transactionTable.tableHeaderView = tradeHeaderH
            
            self.tradeHeaderH.orderArea.onOrderWayChangend()
            self.tradeHeaderH.depthArea.bindTicker(tick: self.ticker)
            self.tradeHeaderH.depthArea.bindDepth(depthModel: self.depth, volDecimal: self.entity.volDecimal())
        }else if action == .vertical {
            if self.headerLayout == .vertical {return}
            self.headerLayout = .vertical
            transactionTable.tableHeaderView = tradeHeaderV
            
            self.tradeHeaderV.orderArea.onOrderWayChangend()
            self.tradeHeaderV.depthArea.bindTicker(tick: self.ticker)
            self.tradeHeaderV.depthArea.bindDepth(depthModel: self.depth, volDecimal: self.entity.volDecimal())
        }
        
        if let tableHeaderView = transactionTable.tableHeaderView {
            let size = CGSize(width: Device_W, height: UIView.layoutFittingCompressedSize.height)
            tableHeaderView.height = tableHeaderView.systemLayoutSizeFitting(size, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
            transactionTable.tableHeaderView = tableHeaderView
            transactionTable.reloadData()
            transactionTable.layoutIfNeeded()
        }
        reloadSuggestions()
        updateOrderTitles()
    }
    
    func reloadSuggestions() {
        self.tradeHeaderV.depthArea.configSuggestBuy()
        self.tradeHeaderV.depthArea.configSuggestSell()
        self.tradeHeaderH.depthArea.configSuggestBuy()
        self.tradeHeaderH.depthArea.configSuggestSell()
    }
    
    func updateOrderTitles() {
        self.tradeHeaderV.orderArea.orderCommonArea.configBtnTitle()
        self.tradeHeaderH.orderArea.configOrderBtn()
    }
}

//MARK: Get the current delegate orderlistnew
extension EXTradeBaseVc {
    
    func repeatOrderListNew() {
        orderListNewTimer?.dispose()
        heartBeats()
        orderListNewTimer = Observable<Int>.interval(.seconds(3), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (element) in
                guard let `self` = self else { return }
                self.heartBeats()
            })
    }
    
    func paddingsOfBottomByTransactionTable(with rows: Int) -> CGFloat {
        switch rows {
        case 0:
            return SCREEN_HEIGHT * 0.3
        case 1:
            return SCREEN_HEIGHT * 0.25
        case 2:
            return SCREEN_HEIGHT * 0.1
        default:
            return 0
        }
    }
   
    
    func handleOrderList(entity:EXCurrentEntrustArr) {
        self.rowDatas = entity.orderList
        self.tradeHeaderV.orderArea.entrustEntity = entity
        self.tradeHeaderH.orderArea.entrustEntity = entity
   
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { [weak self] in
            guard let self else { return }
            let bottom = self.paddingsOfBottomByTransactionTable(with: self.rowDatas.count)
            self.transactionTable.contentInset = .init(top: 0, left: 0, bottom: bottom, right: 0)
        }
        
        self.transactionTable.reloadData()
        
        
        //OrderListnew, constantly scrolling, keep scrolling every order once
        if rowDatas.count > 0 {
            let ids = rowDatas.map( {return $0.id} ).joined(separator: ",")
            if currentOrderIds != ids {
                print("Order has changed, add or hide small dots")
                let prices = rowDatas.map {return $0.price}
                self.tradeHeaderV.depthArea.orderPrices = prices
                self.tradeHeaderH.depthArea.orderPrices = prices
                currentOrderIds = ids
            }
        }
    }
    
    func clearPankouOrders() {
        currentOrderIds = ""
        self.tradeHeaderV.depthArea.orderPrices = [""]
        self.tradeHeaderH.depthArea.orderPrices = [""]
    }
}

//MARK: Drawer
extension EXTradeBaseVc {
    
    func refreshEntity(_ newEntity:CoinMapEntity) {
        suspendTask()//cancel last
        self.preEntity = self.entity
        self.entity = newEntity
        self.currentOrderIds = ""
        depthLayoutIdx = 0
        tradeHeaderV.refreshEntity(entity: newEntity)
        tradeHeaderH.refreshEntity(entity: newEntity)
        if self.headerLayout == .horizontal {
            transactionTable.tableHeaderView = tradeHeaderH
        }else if self.headerLayout == .vertical {
            transactionTable.tableHeaderView = tradeHeaderV
        }
        beginFetchDepthTicker()
        updateTickerIfNeedWhenOnlyChangeEntity()
        entityDidRefreshed()
    }
}

extension EXTradeBaseVc {
    
    func refreshDepthAndTicker() {
        beginFetchDepthTicker()
    }
    
}



extension EXTradeBaseVc : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if rowDatas.count == 0 {
            return 182
        }
        return 120
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.tradeTitleHeader
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if rowDatas.count == 0{
            return 1
        }
        return rowDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if rowDatas.count == 0{
            let cell : EXTradeEmptyCell = tableView.dequeueReusableCell(withIdentifier: "EXTradeEmptyCell") as! EXTradeEmptyCell
            return cell
        }
        let orderEntity = rowDatas[indexPath.row]
        let cell : EXCurrentEntrustTC = tableView.dequeueReusableCell(withIdentifier: "EXCurrentEntrustTC") as! EXCurrentEntrustTC
        cell.cancelBlock = {[weak self]entity in
            self?.cancelOrderAction(entity: orderEntity)
        }
        cell.setCell(orderEntity)
        return cell
    }
}

extension EXTradeBaseVc {
    
    func suspendTask() {
        orderListNewTimer?.dispose()
        EXWebSocket.marketService.cancellAlltaskObj()
    }
    
    func resumeTask() {
        updateOrderTitles()
        beginFetchDepthTicker()
        repeatOrderListNew()
    }
    
    func handleNotifi() {
        _ = NotificationCenter.default.rx
            .notification(UIApplication.didBecomeActiveNotification)
            .take(until: self.rx.deallocated) //Page destruction automatic removal notification listening
            .subscribe(onNext: {[weak self] noti in
                self?.homeBtnAction(false)
            })
        
        _ = NotificationCenter.default.rx
            .notification(UIApplication.willResignActiveNotification)
            .take(until: self.rx.deallocated) //Page destruction automatic removal notification listening
            .subscribe(onNext: {[weak self] noti in
                self?.homeBtnAction(true)
            })
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(clearAsset),
                                               name: NSNotification.Name(rawValue: EXNoti.logOut.rawValue),
                                               object: nil)
    }
    
    func homeBtnAction(_ enterBackground :Bool) {
        //Pay attention to the current controller
        guard let top = AppService.topViewController() else {return}
        if top == self {
            if enterBackground {
                suspendTask()
            }else {
                resumeTask()
            }
        }
    }
    
    @objc func clearAsset(){
        tradeHeaderV.orderArea.orderCommonArea.caculateAvailableValue()
        tradeHeaderH.clearLeverModel()
        tradeHeaderV.clearLeverModel()
        self.rowDatas.removeAll()
        self.transactionTable.reloadData()
    }
    func changeDepthLayouts() {
        let arr = ["contract_text_defaultMarket".localized(),
                   "contract_text_buyMarket".localized(),
                   "contract_text_sellMarket".localized()]
        let sheet = EXOldActionSheetView()
        sheet.actionIdxCallback = {[weak self](idx) in
            guard let mySelf = self else{return}
            if mySelf.depthLayoutIdx == idx {
                return
            }
            mySelf.depthLayoutIdx = idx
            if mySelf.headerLayout == .vertical {
                mySelf.tradeHeaderV.updateDepthLayout(idx)
            }
            mySelf.transactionTable.reloadData()
        }
        sheet.configButtonTitles(buttons:arr,selectedIdx: depthLayoutIdx)
        EXAlert.showSheet(sheetView: sheet)
    }
}

extension EXTradeBaseVc {
    func trackActionOn() {
        print("Record Start Time ->")
        track_begin = Date()
        track_end = nil
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector:#selector(handleInterfaceData), object: nil)
        self.perform(#selector(handleInterfaceData), with: nil, afterDelay: 3)
    }
    
    @objc func handleInterfaceData() {
//        if self.defineCurrentVcIsTopVc() == false {
//            return
//        }
        let interfaceData:EXInterfaceData = EXInterfaceData.init(page: .transaction, action: .subDepth)
        var duration = ""
        var errorType = "0"
        if let begin = self.track_begin,let end = self.track_end {
            let interval = end.timeIntervalSince(begin)
            let millisecond = CLongLong(round(interval*1000))
            duration = "\(millisecond)"
        }
        
        if tradeHeaderV.depthArea.isEmptyUI() {
            if EXWebSocket.marketService.isConnecting() == false {
                errorType = "1"
            }else if self.tradeHeaderV.depthArea.isEmptyData() {
                errorType = "2"
            } else {
                errorType = "3"
            }
        }

        interfaceData.errorType = errorType
        interfaceData.duration = duration
        EXTracking.shared.uploadInterFaceData(model: interfaceData)
    }
}



// MARK: add/remove skeleton
extension EXTradeBaseVc {
    
    /// add skeleton for view
    func addTradeSkeleton()  {
        guard tradeSkeleton.superview == nil else { return }
        view.addSubview(tradeSkeleton)
        view.bringSubviewToFront(tradeSkeleton)
        tradeSkeleton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-44)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    /// remove skeleton for view
    /// - Parameter completion: callback
    func removeTradeSkeleton(with completion:(() -> Void)? = nil) {
        guard tradeSkeleton.superview != nil else { return }
        UIView.animate(withDuration: 0.25, delay: 0.5) {
            self.tradeSkeleton.alpha = 0.0
        } completion: { _ in
            self.tradeSkeleton.removeFromSuperview()
            self.tradeSkeleton.alpha = 1.0
        }
    }
    
}
