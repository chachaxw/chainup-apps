//
//  EXSwapAllTransactionsVC.swift
//  Chainup
//
//  Created by KarlLichterVonRandoll on 2023/12/22.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import JXSegmentedView
import EXKit
/// 全部委托 English: /Full delegation
class EXSwapAllTransactionsVC: EXSNavCustomVC {
    var segmentViewSelectedIndex: Int = 0
    var itemModel: EXSwapItemModel?
    var lastItemModel: EXSwapItemModel?
    var oringItemId: Int64 = 0
    var currentOrderList = [EXContractOrderModel]()
    var historyOrderList = [EXContractOrderModel]()
    var type:EXSwapTransactionType = .current
    var page = 1
    /// 计划委托/限价委托 English: /Plan commission/price limit commission
    var transactionPriceType = EXSwapTransactionPriceType.limit {
        didSet {
            self.currentTransactionView.transactionPriceType = self.transactionPriceType
            self.historyTransactionView.transactionPriceType = self.transactionPriceType
        }
    }
    var currentTransactionModelArray = [EXContractOrderModel]()
    var historyTransactionModelArray = [EXContractOrderModel]()
    /// 当前委托类型 English: /Current delegation type
    var transactionWay: EXSwapMarketOrderType = .allTypes
    /// 历史委托类型 English: /Historical commission type
//    var historyTransactionWay: SLSwapHistoryTransactionWay = .allTypes
    //盈亏仓位方向 English: Profit and loss position direction
    var currentType:EXSPositionType = .all

    var positionSideArr = [EXSPositionType.all,EXSPositionType.openMore,EXSPositionType.openEmpty]
    var initialSwapName = ""
    
    
     //MARK: lifecyce
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.ThemeView.card1
        self.contentView.backgroundColor = UIColor.ThemeView.card1
        self.navCustomView.backView.backgroundColor = UIColor.ThemeView.card1
        //当前委托的处理的记录仅当前合约 English: The current entrusted processing record is only for the current contract
       let currentEntrustOnlyCurrent = EXStoreData.storeBool(forKey: currentEntrustOnlyCurrentContract)
       if currentEntrustOnlyCurrent == false{
           let item = EXSwapItemModel()
           item.instrument_id = -1
           self.itemModel = item
       }
        

        oringItemId = self.itemModel?.instrument_id ?? 0
        lastItemModel = self.itemModel
        self.contentView.addSubview(topView)
        self.contentView.addSubview(line)
        self.contentView.addSubview(cateGoryView)
        self.contentView.addSubview(self.listContainerView)
        topView.listContainer = self.listContainerView
        
        listViews.append(currentTransactionView)
        listViews.append(historyTransactionView)
        listViews.append(profitRecordView)
        
        self.initLayout()
        
        updateWithSegmentId(index: 0)

        self.currentTransactionView.contentTableView.mj_header = EXRefreshHeaderView(refreshingBlock: {[weak self] in
            guard let mySelf = self else { return }
            mySelf.page = 1
            mySelf.requestTransactionData(instrument_id: mySelf.itemModel?.instrument_id ?? 0)
        })
        addCurrentFooter()
        self.currentTransactionView.cancelTransactionCallback = {[weak self] order, priceType in
            self?.cancelTransaction(contractId: order.instrument_id, orderId: Int64(order.orderId), type: nil)
        }
        self.historyTransactionView.contentTableView.mj_header = EXRefreshHeaderView(refreshingBlock: {[weak self] in
            guard let mySelf = self else { return }
            mySelf.page = 1
            mySelf.requestTransactionData(instrument_id: mySelf.itemModel?.instrument_id ?? 0)
        })
        addHistoryFooter()
      
        self.profitRecordView.contentTableView.mj_header = EXRefreshHeaderView(refreshingBlock: {
            [weak self] in
            guard let mySelf = self else { return }
            mySelf.page = 1
            mySelf.requestPositionHistory()
        })
        self.profitRecordView.contentTableView.mj_footer = EXRefreshFooterView(refreshingBlock: {[weak self] in
            guard let mySelf = self else { return }
            mySelf.requestPositionHistory()
        })
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        EXNewTracking.shared.trackPage(name: .swapallcommissioned, isEnter:true)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        EXNewTracking.shared.trackPage(name: .swapallcommissioned, isEnter:false)
        EXNewTracking.shared.trackPage(name: .swapcurrentcommission, isEnter:false)
        EXNewTracking.shared.trackPage(name: .swaphistoricalcommission, isEnter:false)
        EXNewTracking.shared.trackPage(name: .swaplossrecord, isEnter:false)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func setNavCustomV() {
        self.lastVC = true
        self.navCustomView.middleTitle.text = ""
        self.navCustomView.addSubview(cancelAllButton)
        cancelAllButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(self.navCustomView.popBtn)
            make.centerY.equalTo(self.navCustomView.popBtn)
        }
    }
    func addHistoryFooter() {
        self.historyTransactionView.contentTableView.mj_footer = EXRefreshFooterView(refreshingBlock: {[weak self] in
            guard let mySelf = self else { return }
            mySelf.requestTransactionData(instrument_id: mySelf.itemModel?.instrument_id ?? 0)
        })
    }
    func addCurrentFooter() {
        self.currentTransactionView.contentTableView.mj_footer = EXRefreshFooterView(refreshingBlock: {[weak self] in
            guard let mySelf = self else { return }
            mySelf.requestTransactionData(instrument_id: mySelf.itemModel?.instrument_id ?? 0)
        })
    }
    //MARK: 布局 English: MARK: Layout
    private func initLayout() {
        self.topView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalTo(self.navCustomView.snp.bottom)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(44)
        }
        line.snp.makeConstraints { (make) in
            make.top.equalTo(self.topView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        self.cateGoryView.snp.makeConstraints { make in
            make.top.equalTo(self.line.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            make.height.equalTo(16)
        }
        
        self.listContainerView.snp.makeConstraints { make in
            make.top.equalTo(self.cateGoryView.snp.bottom).offset(5)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-(EX_TABBAR_BOTTOM + 10))
        }
        
    }
    
    //MARK:  更改筛选条件 English: MARK: Change filtering criteria
    private func showOrderTypeArray() -> [EXSwapMarketOrderType] {
        
        var array: [EXSwapMarketOrderType]
        
        //计划委托 English: Plan delegation
        if transactionPriceType == .plan{
           array = [EXSwapMarketOrderType.allTypes,
                    EXSwapMarketOrderType.limited,
                    EXSwapMarketOrderType.market]
        }else{ //普通委托 English: Ordinary entrustment
            if type == .current { //当前委托 English: Current commission
                array = currentOrderTypeArray
            } else {//历史委托 English: Historical commission
                array = orderTypeArray
            }
        }
        return array
    }
    
    //MARK: lazy
    lazy var orderTypeArray : [EXSwapMarketOrderType] = {
       return [EXSwapMarketOrderType.allTypes,
               EXSwapMarketOrderType.limited,
               EXSwapMarketOrderType.market,
               EXSwapMarketOrderType.postOnly,
               EXSwapMarketOrderType.immediateOrCance,
               EXSwapMarketOrderType.fillOrKill]
   }()
   
   lazy var currentOrderTypeArray : [EXSwapMarketOrderType] = {
       return [EXSwapMarketOrderType.allTypes,
               EXSwapMarketOrderType.limited,
               EXSwapMarketOrderType.postOnly]
   }()
   lazy var priceArray:[String] = {
      return ["cp_extra_text20".ex_localized(), "cp_order_text3".ex_localized()]
   }()
   //委托类型 English: Entrustment type
   lazy var entrustmentTypes:[EXSwapTransactionPriceType] = {
       return [.limit,.plan]
   }()
   
   lazy var cancelAllButton: UIButton = {
       let button = UIButton(buttonType: .custom, title: "cp_order_text52".ex_localized(), titleFont: UIFont.ThemeFont.BodyRegular, titleColor: .Ex.main4)
       button.ext_SetAddTarget(self, #selector(clickCancelAllButton))
       button.isHidden = true
       return button
   }()
   
   
   //所有的类型 English: All types
   var listTypes: [EXSwapTransactionType] = [.current,.history,.profitRecord]
   var listViews = [EXSTransactionListView]()
   //MARK: lazy
   //MARK: 头部 English: MARK: Head
   lazy var segmentDataSource: EKContractIndicatorSegmentDatasource = {
       let source = EKContractIndicatorSegmentDatasource()
       source.titles = listTypes.map({ item in
           return item.disPlayName
       })
       return source
   }()
   lazy var lineIndicatorLienView: EKIndicatorSegmentIndicator = {
       let view = EKIndicatorSegmentIndicator()
       return view
   }()
   lazy var topView: JXSegmentedView  = {
       let topView = JXSegmentedView()
       topView.delegate = self
       topView.dataSource = self.segmentDataSource
       topView.indicators = [self.lineIndicatorLienView]
       topView.backgroundColor = UIColor.ThemeView.card1
       topView.contentEdgeInsetLeft = 16
       return topView
   }()
   lazy var line: UIView = {
       let horLineView = UIView()
       horLineView.ext_UseAutoLayout()
       horLineView.backgroundColor = UIColor.ThemeView.seperator
       return horLineView
   }()
   lazy var listContainerView: JXSegmentedListContainerView! = {
       let v = JXSegmentedListContainerView(dataSource: self)
       if let pop = self.navigationController?.interactivePopGestureRecognizer{
           v.scrollView.panGestureRecognizer.require(toFail: pop)
       }
       return v
   }()
   
   
   //MARK: 一排按钮 English: MARK: A row of buttons
   lazy var cateGoryView: EXSCategaryView = {
       let v = EXSCategaryView()
       
       v.coinBtn.rx.controlEvent(.touchUpInside).subscribe { [weak self](_) in
           self?.coinBtnClick()
       }.disposed(by: self.exs_disposeBag)
       
       v.entrustmentBtn.rx.controlEvent(.touchUpInside).subscribe { [weak self] (_) in
           self?.entrustmentBtnClick()
       }.disposed(by: self.exs_disposeBag)
       
       v.allBtn.rx.controlEvent(.touchUpInside).subscribe { [weak self] (_) in
           self?.allBtnClick()
       }.disposed(by: self.exs_disposeBag)
       v.backgroundColor = UIColor.ThemeView.card1
       return v
   }()
   lazy var currentTransactionView: EXSTransactionListView = {
       let view = EXSTransactionListView()
       view.transactionType = .current
       return view
   }()
   
   lazy var historyTransactionView: EXSTransactionListView = {
       let view = EXSTransactionListView()
       view.transactionType = .history
       // 跳转至历史委托详情 English: Jump to historical commission details
       view.selectHistoryTransactionCallback = {[weak self] orderModel in
           let vc = EXSwapDetailTransactionVC()
           vc.orderModel = orderModel
           self?.navigationController?.pushViewController(vc, animated: true)
       }
       
       return view
   }()
   lazy var profitRecordView:EXSTransactionListView = {
       let view = EXSTransactionListView()
       view.transactionType = .profitRecord
       view.transactionPriceType = .position
       return view
   }()
}


// MARK: - Update Data

extension EXSwapAllTransactionsVC {
    fileprivate func updateUI(instrument_id: Int64, _ modelArray: [EXContractOrderModel], limit:Int, parmaModel: EXContractQueryCurrentOrderList?) {
        //给tableview组装数据 English: Assemble data for tableview
//        for item in modelArray {
//            item.instrument_id = instrument_id
//        }
        if segmentViewSelectedIndex == 0 && parmaModel?.isHistory == false { //Current delegation
            if page > 1 {
                currentTransactionModelArray += modelArray
            }else {
                currentTransactionModelArray = modelArray
            }
            self.currentTransactionView.updateView(modelArray: currentTransactionModelArray)
            if modelArray.count < limit {
                self.currentTransactionView.contentTableView.mj_footer.endRefreshingWithNoMoreData()
            }
        } else if segmentViewSelectedIndex == 1 && parmaModel?.isHistory == true{ //Historical commission
            if page > 1 {
                historyTransactionModelArray += modelArray
            }else {
                historyTransactionModelArray = modelArray
            }
            self.historyTransactionView.updateView(modelArray: historyTransactionModelArray)
            if modelArray.count < limit {
                self.historyTransactionView.contentTableView.mj_footer.endRefreshingWithNoMoreData()
            }
        }
    }
    /// 获取盈亏记录 English: /Obtain profit and loss records
    private func requestPositionHistory() {
        if itemModel == nil {
            return
        }
        let limit = 20
        EXContractNetwork.getUserHistoryPosition(contractId: itemModel!.instrument_id, side: currentType.parm, page: page, limit: limit) {[weak self] (positions) in
            guard let mySelf = self else {return}
            if mySelf.page > 1 {
                mySelf.profitRecordView.positionArr += positions
            }else {
                mySelf.profitRecordView.positionArr = positions
            }
            mySelf.page += 1
            mySelf.endRefresh()
            if positions.count < limit {
                mySelf.profitRecordView.contentTableView.mj_footer.endRefreshingWithNoMoreData()
            }else {
                mySelf.profitRecordView.contentTableView.mj_footer.resetNoMoreData()
            }
            mySelf.profitRecordView.contentTableView.reloadData()
        } failure: { (error) in
            self.endRefresh()
        }
    }
    /// 请求委托列表 English: /Request Delegation List
    func requestTransactionData(instrument_id: Int64) {
        if EXSwapPlatformSDK.shared.activeAccount == nil || instrument_id == 0  {
            self.resetTransactionView()
            self.endRefresh()
            return
        }
        
        let model = EXContractQueryCurrentOrderList()
        model.contractId = instrument_id
        if !transactionWay.parmDesc.isEmpty {
            model.type = transactionWay.parmDesc
        }
        model.page = page
        model.limit = 20
        model.needTrigger = transactionPriceType == .plan
        model.isHistory =  segmentViewSelectedIndex == 1 //self.historyButton.isSelected
        EXContractNetwork.queryCurrentOrderList(model: model) { (modelArray, paramModel,_) in
            self.endRefresh()
            self.updateUI(instrument_id: instrument_id, modelArray, limit: model.limit, parmaModel: paramModel)
            if self.segmentViewSelectedIndex == 0,self.currentTransactionView.tableViewRowDatas.count > 0 {
                self.cancelAllButton.isHidden = false
            }else {
                self.cancelAllButton.isHidden = true

            }
            self.page += 1
           
            
        } failure: { (_) in
            
            self.endRefresh()
        }.disposed(by: self.exs_disposeBag)
    }
    func resetFooter(){
        self.currentTransactionView.contentTableView.mj_footer?.resetNoMoreData()
        self.historyTransactionView.contentTableView.mj_footer?.resetNoMoreData()
        self.profitRecordView.contentTableView.mj_footer?.resetNoMoreData()
    }

    private func endRefresh() {
        self.currentTransactionView.contentTableView.mj_header?.endRefreshing()
        self.historyTransactionView.contentTableView.mj_header?.endRefreshing()
        self.currentTransactionView.contentTableView.mj_footer?.endRefreshing()
        self.historyTransactionView.contentTableView.mj_footer?.endRefreshing()
        self.profitRecordView.contentTableView.mj_footer?.endRefreshing()
        self.profitRecordView.contentTableView.mj_header?.endRefreshing()
    }
    
    /// 重置视图 English: /Reset View
    private func resetTransactionView() {
        self.currentTransactionView.updateView(modelArray: [])
        self.historyTransactionView.updateView(modelArray: [])
    }
    
    
    private func cancelTransaction(contractId: Int64, orderId: Int64?,type: Int64?) {
        
        EXContractNetwork.cancelOrder(contractId: contractId,
                                      orderId: orderId, type: type,
                                      isConditionOrder: transactionPriceType == .plan) {
            
            EXAlert.showSuccess(msg: "cp_content_text3".ex_localized())
            self.page = 1
            self.requestTransactionData(instrument_id: self.itemModel?.instrument_id ?? 0)
        } failure: { (error) in
            
            EXAlert.showFail(msg: "cp_content_text4".ex_localized())
        }
    }
    
    private func cancelAllTransactions() {
        var ty: Int64? = nil //全部不需要传 English: No need to transmit anything
        if self.transactionWay == .limited {
            ty = 1
        }else if self.transactionWay == .postOnly{
            ty = 5
        }
        //不传orderId撤销所有 English: Do not pass orderId and revoke all
        cancelTransaction(contractId: itemModel?.instrument_id ?? 0, orderId: nil,type: ty)
    }
    
    // MARK: Socket Data
    
}


// MARK: - Click Events

extension EXSwapAllTransactionsVC {
    /// 取消全部委托 English: /Cancel all delegation
    @objc func clickCancelAllButton() {
        if self.currentTransactionView.tableViewRowDatas.count <= 0 {
            return
        }
        let alert = EXCommonAlert()
        alert.configAlert(title: "cp_overview_text58".ex_localized()) { type in
            EXAlert.dismiss()
            if type == .sure{
                self.cancelAllTransactions()
            }
        }
        EXAlert.showAlert(alertView: alert)
    }
    
    func resetSelectedType() {
        transactionWay = .allTypes
    }
    //MARK: 左右滑动不用请求 - 单独处理了 English: MARK: No need to request left and right sliding - it will be handled separately
    func updateWithSegmentId(index: Int, request: Bool = true){
        page = 1
        resetSelectedType()
        
        if segmentViewSelectedIndex == 0{
            //当前委托 English: Current commission
            type = .current
            EXNewTracking.shared.trackPage(name: .swapcurrentcommission, isEnter:true)
        }else if segmentViewSelectedIndex == 1 {
            //历史委托 English: Historical commission
            type = .history
            EXNewTracking.shared.trackPage(name: .swaphistoricalcommission, isEnter:true)
            self.cancelAllButton.isHidden = true
        }else{
            //盈亏记录 English: Profit and loss records
            type = .profitRecord
            EXNewTracking.shared.trackPage(name: .swaplossrecord, isEnter:true)
            self.cancelAllButton.isHidden = true
            
        }
        self.cateGoryView.entrustmentBtn.isHidden = type == .profitRecord
        
       
        if request == true{
            updateTitleThenRequest()
        }else{
            setCategoryBtnTitle()
        }
        
    }
}

//MARK: 顶部标题点击 弹框 English: MARK: Click on the top title to pop up the box
extension EXSwapAllTransactionsVC {
    //MARK: 币种选择 English: MARK: Currency selection
    func coinBtnClick(){
        let v = EXSFiterView()
        // 添加全部选项 English: Add all options
        v.configAllData()

        v.vm.eventSubject.subscribe(onNext: {[weak self] event in
            guard let mySelf = self else{return}
            switch event{
            case .selectFinsh(let item):
                mySelf.itemModel = item
                if item.instrument_id > 0 {
                    mySelf.lastItemModel = item
                }
               // //print("item=\(item.ex_contractInfo?.showName() ?? "")")
                //请求 English: request
                mySelf.updateTitleThenRequest()
            default:
                break
            }
        }).disposed(by: disposeBag)
        //MARK: 默认币种选择 English: MARK: Default currency selection
        if let item = self.itemModel{
            v.configDefaultSelectedItem(item: item)
        }
        
        EXAlert.showSheet(sheetView: v)
    }
    //委托按钮 --- 当前委托 /历史委托 有 English: Delegate button - current/historical delegation available
    func entrustmentBtnClick(){
        
        let titles = self.entrustmentTypes.map { item in
            return item.display
        }
        let idx = self.entrustmentTypes.firstIndex(of: self.transactionPriceType) ?? 0
        let sheet = EXActionSheetView()
        sheet.actionIdxCallback = {[weak self](idx) in
            guard let mySelf = self else{return}
            mySelf.transactionPriceType = mySelf.entrustmentTypes[idx]
            mySelf.resetSelectedType() //重置全部             English: reset all
            mySelf.updateTitleThenRequest()
        }
        sheet.actionCancelCallback =  {[weak self]() in
            guard let mySelf = self else{return}
        }
        sheet.configButtonTitles(buttons: titles, selectedIdx: idx)
        EXAlert.showSheet(sheetView: sheet)
    
    }
    
    
    //全部按钮 English: All buttons
    func allBtnClick(){
        var titles = [String]()
        var idx = 0
        if type == .profitRecord { //盈亏是方向 English: Profit and loss are the direction
            titles = self.positionSideArr.map({ item in
                item.introduce
            })
            idx = self.positionSideArr.firstIndex(of: self.currentType) ?? 0
        }else{ //当前委托/历史 - 开单类型 English: Current commission/history - billing type
            titles = showOrderTypeArray().map { item in
                return item.display
            }
            idx = titles.firstIndex(of: self.transactionWay.display) ?? 0
        }

        let sheet = EXActionSheetView()
        sheet.actionIdxCallback = {[weak self](idx) in
            guard let mySelf = self else{return}
            if mySelf.type == .profitRecord{
                mySelf.currentType = mySelf.positionSideArr[idx]
            }else{
                mySelf.transactionWay = mySelf.showOrderTypeArray()[idx]
            }
            mySelf.updateTitleThenRequest()
        }
        sheet.actionCancelCallback =  {[weak self]() in
            guard let mySelf = self else{return}
            EXAlert.dismiss()
        }
        sheet.configButtonTitles(buttons: titles, selectedIdx: idx)
        EXAlert.showSheet(sheetView: sheet)
    }
    
    func setCategoryBtnTitle(){
        self.cateGoryView.coinBtn.titleLabel.text = self.itemModel?.ex_contractInfo?.showName()
        self.cateGoryView.entrustmentBtn.titleLabel.text = self.transactionPriceType.display
        var allTile = self.transactionWay.display
        if type == .profitRecord{
            allTile = currentType.introduce
        }
        self.cateGoryView.allBtn.titleLabel.text = allTile
        self.cateGoryView.relayouBtns()
    }
    
    
    func updateTitleThenRequest(){
        setCategoryBtnTitle()
        restartReuqest()
    }
    func restartReuqest(){
        page = 1 
        if type == .profitRecord {
            self.requestPositionHistory()
        }else{
            self.requestTransactionData(instrument_id: self.itemModel?.instrument_id ?? 0)
        }
    }
}
extension EXSwapAllTransactionsVC: JXSegmentedViewDelegate{
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        //print("index = \(index)")
        if index == segmentViewSelectedIndex{
            return
        }
        segmentViewSelectedIndex = index
        self.resetFooter()
        updateWithSegmentId(index: index,request: false)
        let view = listViews[index]
        view.contentTableView.mj_header.beginRefreshing()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = (segmentedView.selectedIndex == 0)
    }
   
}



extension EXSwapAllTransactionsVC: JXSegmentedListContainerViewDataSource {
    
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        return segmentDataSource.titles.count
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        return listViews[index]
    }
}


extension EXSwapAllTransactionsVC: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self.view
    }
}


