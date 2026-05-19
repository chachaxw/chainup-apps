//
//  EXContractHomeHeaderView.swift
//  Chainup
//
//  Created by cwd on 2022/10/9.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import EXKit


enum EXSwapTransationViewShowType {
    case showOpen
    case showClose
}


/**
 当前持仓以上 English: Current position above
 */

let notiBarClose: TimeInterval = 0.25
class EXContractHomeHeaderView: EXView {
    typealias ClickTakeOrderBlock = (EXOrderBookModel) -> ()
    typealias refreshBlock = () -> ()
    typealias HeadHightChangeBlock = (Int, Bool) -> ()
    var clickTakeOrderBlock : ClickTakeOrderBlock?
    var willPushVcBlock:(() -> ())?
    var headHightChangeBlock: HeadHightChangeBlock?
    typealias ClickDepthBtnBlock = (Int) -> ()//点击深度回调 English: Click depth callback
    var clickDepthBtnBlock : ClickDepthBtnBlock?
    var didRefreshBlock:refreshBlock?
    var changeOrderCallBack:refreshBlock?
    /// 跳转至全部委托 VC English: /Jump to all delegated VC
    var jumpToAllTransactionVCCallback: (() -> (Void))?
    var transactionPriceType: EXSwapTransactionPriceType = .position
    var transactionShowType : EXSwapTransationViewShowType = .showOpen {
        didSet {
            updatePriceViewDataCount()
            makeOrderView.transactionShowType = transactionShowType
        }
    }
    
    var positionType:SLPositionMode = .both {
        didSet {
            makeOrderView.positionType = positionType
            switch positionType {
            case .single:
                makeOrderView.setupOnlySell(hide: true)
            case .both:
                makeOrderView.setupOnlySell(hide: false)
                
            }
            updatePriceViewDataCount()
            makeOrderView.layoutOrderTypeBtn()
            makeOrderView.updateOnlySellBtnLayout()
        }
    }
    /// 基础模型数据 English: /Basic model data
    var _itemModel : EXSwapItemModel?
    var currentUserConfig = SLUserConfig() {
        didSet{
            makeOrderView.currentUserConfig = currentUserConfig
        }
    }
    
    var itemModel : EXSwapItemModel? {
        set {
            if newValue?.instrument_id != _itemModel?.instrument_id {
                let vm = EXSwapMarkOrderViewModel()
                vm.itemModel = newValue
                makeOrderView.makeOrderViewModel = vm
            } else {
                makeOrderView.makeOrderViewModel?.itemModel = newValue!
            }
            _itemModel = newValue
            marketPriceView.itemModel = _itemModel
        }
        get {
            return _itemModel
        }
    }
    
    var viewModel: EXContractHomeViewModel?
    var depthPriceViewCurrentH :Int = 0 //EXContractHomeHeaderView.getdepthViewDefaultHeight()
    //MARK: lifecycle
    required init(viewModel: EXViewModelProtocol?) {
        self.viewModel = viewModel as? EXContractHomeViewModel
        super.init(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        container.exs_roundCorners(corners: [.topLeft,.topRight], radius: 15)
    }
    
    override func setupView(){
        self.addSubViews([noticeBar,smallklineView,container])
        self.backgroundColor = UIColor.ThemeView.newbg
        
        container.backgroundColor = UIColor.ThemeView.card1
        container.exs_addSubViews([headerView,makeOrderView,marketPriceView,bottomView])
        headerView.backgroundColor = UIColor.ThemeView.card1
        noticeBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(0)
        }
        smallklineView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(0)
            make.left.right.equalToSuperview()
            make.height.equalTo(0)
        }
//        upateSmallKline()
        container.snp.makeConstraints { make in
            make.top.equalTo(smallklineView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        headerView.snp.makeConstraints { (make) in
            make.top.equalToSuperview() //.offset(12)
            make.left.right.equalToSuperview()
            make.height.equalTo(EXSwapHeaderView.viewHeight)
        }
        
        marketPriceView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            //            make.right.equalTo(makeOrderView.snp.left)
            make.top.equalTo(headerView.snp.bottom) //.offset(10)
            make.width.equalTo(Device_W - exs_proportion_width - 16)
        }
        bottomView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(marketPriceView.snp.bottom)
            make.height.equalTo(20)
            make.bottom.equalToSuperview()
        }
        
        makeOrderView.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom) //.offset(10)
            make.width.equalTo(exs_proportion_width)
            make.bottom.equalTo(marketPriceView)
        }
        
    }
    
    
    
    lazy var smallklineView: EXSContractFlutterKLineChart = {
        let l = EXSContractFlutterKLineChart(viewModel: self.viewModel?.klineVM)
        l.setBottom(with: false)
        l.isHidden = true
        
        l.changeHeightBlock = { [weak self] _ in
            guard let `self` = self else { return }
            
            let klineH = self.smallklineView.intrinsicContentSize.height
            self.smallklineView.snp.updateConstraints { make in
                make.height.equalTo(klineH)
            }
            let total = self.getCurrentTotalH()
            self.headHightChangeBlock?(total,false)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.viewModel?.klineVM.wsEventSubject.onNext(.updateMainIndexVisible)
            }
            //self.updateChartLayout(top: true)
        }
        return l
    }()
    
    
    let container = UIView() //设置圆角用 English: Set rounded corners
    
    // MARK: - lazy 买入开多，卖出开空 English: MARK: - Lazy buy long, sell short
    lazy var makeOrderView : EXContractMakeOrderView = {
        let view = EXContractMakeOrderView()
        view.ext_UseAutoLayout()
        view.contractVm = self.viewModel ?? EXContractHomeViewModel()
        view.clickTradeBlock = {[weak self] order in
            self?.takeOrder(order: order)
        }
        view.updateTransactionShowTypeBlock = {[weak self] type in
            self?.transactionShowType = type
        }
        // MARK: 高度回调 English: MARK: Height callback
        view.updateDepthMaxCountBlock = {[weak self]  in
            self?.updatePriceViewDataCount()
            self?.makeOrderView.updateLastPrice(price: self?.marketPriceView.middleCell.priceLabel.text ?? "")
        }
        return view
    }()
    
    lazy var marketPriceView : EXSwapMarketPriceView = {
        let view = EXSwapMarketPriceView()
        view.ext_UseAutoLayout()
        view.clickRightBlock = {[weak self] orderModel in
            guard let mySelf = self else{return}
            mySelf.clickTakeOrderBlock?(orderModel)
        }
        view.clickDepthBtnBlock = {[weak self] idx in
            guard let mySelf = self else{return}
            mySelf.clickDepthBtnBlock?(idx)
        }
        return view
    }()
    
    lazy var bottomView : UIView = {
        let view = UIView()
        view.ext_UseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.card1
        return view
    }()
    lazy var headerView = EXSwapHeaderView()
    
    lazy var noticeBar: EXContractNoticeBarView = {
        let view = EXContractNoticeBarView()
        view.isHidden = true
        view.closeBlock = { [weak self] in
            guard let `self` = self else { return }
            //print("关闭")
            if self.hasLogin() &&  SLUserConfig.checkHasOpenContract == true { //登录且开通合约走接口 English: Login and enable contract access interface
                self.viewModel?.closeNoticeBar()
            }else{
                //直接关闭 English: Directly close
                self.updateNoticeBar(show: false)
            }
        }
        return view
    }()
}
extension EXContractHomeHeaderView{
    //处理公告栏 English: Processing bulletin boards
    func updateNoticeBar(show: Bool){
        
        self.noticeBar.isHidden = !show
        let height = show ? self.noticeBar.viewHeight : 0
        self.noticeBar.snp.updateConstraints { make in
            make.height.equalTo(height)
        }
        let smallKlineTop = show ? height + 8 : 0
        self.smallklineView.snp.updateConstraints { make in
            make.top.equalToSuperview().offset(smallKlineTop)
        }
        let total = self.getCurrentTotalH()
        self.headHightChangeBlock?(total,true)
        UIView.animate(withDuration: notiBarClose, delay: 0) {
            self.layoutIfNeeded()
        } completion: { _ in
            
        }
    }
}
extension EXContractHomeHeaderView{
    
    //MARK: - 高度计算 English: MARK: - Height calculation
    func getDefaultViewH(open: Bool = false)->Int{
        
        let headerH =  self.getHeaderHeight(klineOpen: open)
        let depathViewH = self.getdepthViewDefaultHeight()
        return headerH + depathViewH
    }
    
    // 全仓逐仓以及 公告栏 小k线这块的高度 顶部高度 English: The height of the entire warehouse and the top height of the small candlestick line on the bulletin board
    func getHeaderHeight(klineOpen: Bool = false, noticeBarShow: Bool? = false) -> Int{
        var h =  Int(EXSwapHeaderView.viewHeight) + 10 //顶部 English: Top
        let klineShow = EXStoreData.getSmallKlineShowTop()
        if klineShow {
//            h += Int(EXKlineFolderView.getViewH(open: klineOpen)) //k 线 English: K-line
            h += Int(self.smallklineView.intrinsicContentSize.height)
        }
        return h
    }
    
    func getCurrentTotalH() -> Int{
        let klineOpen = self.smallklineView.isVisible
        var h =  Int(EXSwapHeaderView.viewHeight) + 10 //顶部 English: Top
        let klineShow = EXStoreData.getSmallKlineShowTop()
        if klineShow {
            h += Int(self.smallklineView.intrinsicContentSize.height)
//            h += Int(EXKlineFolderView.getViewH(open: klineOpen)) //k 线 English: K-line
        }
        
        if self.noticeBar.isHidden == false{
            h += Int(self.noticeBar.viewHeight)
            h += 8
        }
        h += self.depthPriceViewCurrentH
        return h
    }
    
    //这个是获取 深度 默认高度 English: This is the default height for obtaining depth
    func getdepthViewDefaultHeight() -> Int{
        let indx = EXStoreData.storeInt(forKey: EXS_HOLD_MODE)
        let postionMode = indx == 0 ? SLPositionMode.single : SLPositionMode.both
        let cellRows = EXContractHomeHeaderView.getMaxDefaultCount(positionType: postionMode)
        let depthView = EXSwapMarketPriceView.getViewHeight(maxCount: cellRows)
        return depthView
        
    }
    
    
    //MARK: 下单 English: MARK: Placing an Order
    func takeOrder(order: EXContractOrderModel) {

        if EXStoreData.getOnComfirmSwapAlert() {
            if self.makeOrderView.onlySellBtn.isSelected{ /// 只减仓 -按平仓逻辑走 English: /Reduce positions only - follow closing logic
                order.closePosition = true //
            }
            let alert = EXSwapDoubleComfirmAlertView()
            alert.config(order)
            alert.confimModelCallBack = { [weak self]  in
                
                guard let mySelf = self else {return}
                mySelf.submitOrder(order: order, password: nil)
            }
            EXAlert.showAlert(alertView: alert)
            
        } else {
            submitOrder(order: order, password: nil)
        }
    }
    
    func hasLogin() -> Bool {
        
        if EXSwapPlatformSDK.shared.activeAccount != nil { // 已经登录 English: already logged
            return true
        }
        return false
    }
    
    func submitOrder(order: EXContractOrderModel, password : String?, isCheckLiq: Int = 1) {
        self.trackingEventBy(side: order.side, category: order.category)
        order.isCheckLiq = isCheckLiq
        EXContractNetwork.creatOrder(order: order) { [weak self] in
            guard let mySelf = self else {return}
            EXAlert.showSuccess(msg: "cp_extra_text109".ex_localized())
            mySelf.handleSubmitSuccess()
            mySelf.trackingEventWithResultBy(category: order.category, isSuccess: true)
        } failure: { [weak self] (error) in
            guard let mySelf = self else {return}
            mySelf.trackingEventWithResultBy(category: order.category, isSuccess: false)
            if let err = error as? EXSCustomNetworkError,err == .openOrderTipError{
                mySelf.baocangAlert(order: order)
            }
        }
    }
    //MARK: fix 爆仓弹框 English: MARK: Fix explosive box
    func baocangAlert(order: EXContractOrderModel){
        
        let alert = EXCommonAlert()
        let coinInfo = " " + order.showName() + " " + order.side.openDiretion + " "
        let content = "order_placement_text2".ex_localized()
        let info = String(format: content, coinInfo)
        alert.configAlert(tipImage: true,
                          title: "order_placement_text1".ex_localized(),
                          message:info,cancelBtnTitle: "order_placement_text5".ex_localized(),sureBtnTitle: "cp_overview_text56".ex_localized()) { type in
            EXAlert.dismiss()
            //MARK: fix 继续提交 English: MARK: Fix, continue submitting
            if type == .cancel{
                self.submitOrder(order: order, password: nil, isCheckLiq: 0)
            }
        }
        EXAlert.showAlert(alertView: alert)
        
    }
    
    
    /// 处理下单成功 English: /Successfully processed the order
    func handleSubmitSuccess() {
        self.viewModel?.queryAsset()
        makeOrderView.resetTextField(clearPrice: false)
        self.viewModel?.requestPositionData(new: true) //立马刷新仓位 English: Immediately refresh positions
        self.viewModel?.requestTransactionData()

    }
    
    /*
     双向 English: two-way
     开仓 - English: Opening a position-
     市价 - 9 English: Market price -9
     条件单 \\ 止盈止损 10 English: Condition sheet \ \ Stop profit and stop loss 10
     平仓 English: Closing position
     市价-7个 English: Market price -7 units
     条件单 \\ 止盈止损 8 English: Condition sheet \ \ Stop profit and stop loss 8
     单向持仓 English: Unidirectional position
     条件单 9个 English: 9 condition sheets
     市价 8 English: Market price 8
     只减仓 -1 English: Only reduce position -1
     条件单 8个 English: 8 condition sheets
     市价 7 English: Market price 7
     */
    class func getMaxDefaultCount(positionType: SLPositionMode) -> Int{
        var row: Int = 0
        switch positionType {
        case .both:
            row = 8
            //            if transactionShowType == .showOpen { //开仓 English: open a granary to provide relief
            //                row = 9
            //            }else{//平仓 English: Closing position
            //                row = 7
            //            }
            //            if makeOrderView.defineOrderType == .planOrder()||makeOrderView.stopPLButton.isSelected {
            //                row += 1
            //            }
            
        case.single://
            row = 8
            //条件单 English: Condition sheet
            //            if makeOrderView.defineOrderType == .planOrder() {
            //                row = 9
            //            }
            //            if makeOrderView.onlySellBtn.isSelected{ //只减仓比非只减仓少一行 English: Only reducing positions is one line less than not only reducing positions
            //                row -= 1
            //            }
        }
        return row * 2
    }
    func updatePriceViewDataCount() {
        var row: Int = 0
        var planOrder = false
        let orderType = makeOrderView.defineOrderType
        switch orderType{
        case .planOrder(_):
            planOrder = true
        default:
            break
        }
        
        
        switch positionType {
        case .both:
            if transactionShowType == .showOpen { //开仓 English: open a granary to provide relief
                row = 8
                if planOrder || makeOrderView.stopPLButton.isSelected{
                    row += 1
                }
            }else{//平仓 English: Closing position
                row = 7
                if planOrder{
                    row += 1
                }
            }
            
        case.single://
            row = 8
            //条件单 止盈止损输入 English: Condition sheet stop profit and stop loss input
            if planOrder || makeOrderView.stopPLButton.isSelected {
                row = 9
            }
            if makeOrderView.onlySellBtn.isSelected { //只减仓比非只减仓少一行 English: Only reducing positions is one line less than not only reducing positions
                row -= 1
            }
            
        }
        marketPriceView.maximumDataCount = row * 2
        let depethViewH = EXSwapMarketPriceView.getViewHeight(maxCount: marketPriceView.maximumDataCount)
        self.depthPriceViewCurrentH = depethViewH
        // k 线的高度 English: The height of the k-line
        //        var total = self.getHeaderHeight(klineOpen: (self.smallklineView.open))
        //        total += depethViewH
        var total = self.getCurrentTotalH()
        self.headHightChangeBlock?(total,false)
        marketPriceView.updateMiddleTCRowData()
        marketPriceView.updateDepthData(instrument_id: itemModel?.instrument_id ?? 0)
        
    }
}



// MARK: tracking Event
extension EXContractHomeHeaderView {
    
    /// 下单的tracking English: /Tracking for placing orders
    /// - Parameters:
    ///   - side: side
    ///   - category: category
    fileprivate func trackingEventBy(side: BTContractOrderWay, category: BTContractOrderCategory) {
        switch category {
        case .normal:
            EXTracking.shared.track(event: EXSwapTrackingEvent.app_futures_limit_order_place_order.rawValue, parameters: [side.trackingEventParameters:""])
        case .market:
            EXTracking.shared.track(event: EXSwapTrackingEvent.app_futures_market_order_place_order.rawValue, parameters: [side.trackingEventParameters:""])
        default:
            break
        }
    }
    
    /// 下单是否成功的的tracking English: /Tracking whether the order was successfully placed
    /// - Parameters:
    ///   - side: side
    ///   - category: category
    ///   - isSuccess: isSuccess
    fileprivate func trackingEventWithResultBy(category: BTContractOrderCategory, isSuccess: Bool = true) {
        let event: EXSwapTrackingEvent = isSuccess ? .app_futures_place_order_success : .app_futures_place_order_fail
        switch category {
        case .normal:
            EXTracking.shared.track(event: event.rawValue, parameters: [EXSwapTrackingEventOrderType.limit_order.rawValue:"1"])
        case .market:
            EXTracking.shared.track(event: event.rawValue, parameters: [EXSwapTrackingEventOrderType.market_order.rawValue:"1"])
        default:break
        }
    }

}

