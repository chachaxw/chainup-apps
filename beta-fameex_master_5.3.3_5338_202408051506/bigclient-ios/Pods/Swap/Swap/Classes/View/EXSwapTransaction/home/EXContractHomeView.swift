//
//  EXContractHomeView.swift
//  Chainup
//
//  Created by cwd on 2022/10/8.
//  Copyright © 2022 Chainup. All rights reserved.
//
import UIKit
import JXPagingView
import JXSegmentedView
import EXKit
class EXContractHomeView: EXView {
    var refreshedAsset: Bool = false
    var viewModel: EXContractHomeViewModel?
    var titles =  ["cp_order_text1".ex_localized(),"cp_order_text2".ex_localized(), "cp_order_text3".ex_localized()]
    var newTitles =  ["cp_order_text1".ex_localized(),"cp_order_text2".ex_localized(), "cp_order_text3".ex_localized()]

    required init(viewModel: EXViewModelProtocol?) {
        self.viewModel = viewModel as? EXContractHomeViewModel
        super.init(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var pagingView: EXPagingView = {
        let v = EXPagingView(delegate: self, listContainerType: .scrollView)
        object_setClass(v.mainTableView, EXContractTransactionTable.self)
        v.extUseAutoLayout()
        v.backgroundColor = UIColor.ThemeView.newbg
        v.mainTableView.backgroundColor =  UIColor.ThemeView.newbg
        v.mainTableView.gestureDelegate = self
        v.mainTableView.shouldIgnoreScrollingAdjustment = true
        v.mainTableView.shouldRestoreScrollViewContentOffset = true
        v.mainTableView.mj_header = EXRefreshHeaderView(refreshingBlock: { [weak self]  in
            guard let `self` = self else { return }
//            //print("====刷新前 \(self.viewModel?.isScrolling)") English: Print ("===before refreshing \ (self. viewModel?. isScrolling)")
            //MARK: 如果断了,重连一下 /无数据重新请求 English: MARK: If disconnected, reconnect/request again with no data
            self.viewModel?.queryPubinfo(showErr: true, success: {
                [weak self] in
                    guard let newSelf = self else{
                        return
                    }
                if newSelf.pagingHeader.smallklineView.isVisible{
                    newSelf.viewModel?.subscribeKline()
                }
                newSelf.pagingView.mainTableView.mj_header.endRefreshing()
                newSelf.setHeaderEndRefreshing()
                newSelf.viewModel?.resetData()
//                //print("====刷新后 \(newSelf.viewModel?.isScrolling)") English: Print ("===After refreshing \ (newSelf. viewModel?. isScrolling)")
                newSelf.viewModel?.getFirstItemModel()
            }, failure: { [weak self] in
                guard let newSelf = self else{
                    return
                }
                newSelf.pagingView.mainTableView.mj_header.endRefreshing()
                newSelf.setHeaderEndRefreshing()
                newSelf.viewModel?.resetData()
               
            })
            //MARK: 更新用户配置 English: MARK: Updating User Configuration
            self.viewModel?.updateUserConfig(completion: { [weak self] in
                guard let newSelf = self else{
                    return
                }
                newSelf.pagingView.mainTableView.mj_header.endRefreshing()
                newSelf.setHeaderEndRefreshing()
                newSelf.viewModel?.resetData()
            }, fail: { [weak self] in
                    guard let newSelf = self else{
                        return
                    }
                newSelf.pagingView.mainTableView.mj_header.endRefreshing()
                newSelf.setHeaderEndRefreshing()
                newSelf.viewModel?.resetData()
            })
        })
        return v
    }()
    
    lazy var pagingHeader: EXContractHomeHeaderView = {
        let v = EXContractHomeHeaderView(viewModel: self.viewModel)
        v.extUseAutoLayout()
        let viewH = v.getDefaultViewH()
        v.frame = CGRect(x: 0, y: 0, width: Int(Device_W), height: viewH)
        v.headHightChangeBlock = { [weak self] height ,animate in
                guard let `self` = self else { return }
            UIView.animate(withDuration: notiBarClose, delay: 0) {
                self.reloadHeaderWith(height: height, animatable: animate)
            }
        }
        return v
    }()
    
    lazy var dataSource: JXSegmentedTitleDataSource = {
        let source = JXSegmentedTitleDataSource()
        source.titles = titles
        source.titleNormalColor = UIColor.ThemeLabel.colorMedium
        source.titleSelectedColor = UIColor.ThemeLabel.colorLite
        source.titleNormalFont    = UIFont.ThemeFont.HeadMedium
        source.titleSelectedFont = UIFont.ThemeFont.HeadMedium
        source.itemSpacing          = 10
        source.itemWidthIncrement   = 10
        source.isTitleZoomEnabled   = false
        source.isItemSpacingAverageEnabled = false
        return source
    }()
    
    lazy var secionHeader: EXContractNewSectionHeaderView = {
        let  v = EXContractNewSectionHeaderView(frame: .init(x: 0, y: 0, width: Device_W, height: 46))
        v.segmentedView.dataSource = dataSource
        return v
    }()
    
    //当前持仓 English: Current position
    lazy var posionList: EXContactHomeOrderListView = {
        let v = EXContactHomeOrderListView(viewModel: self.viewModel)
        v.transactionPriceType = .position
        v.closePositionSuccess = { [weak self] in
            guard let newSelf = self else{
                return
            }
            newSelf.viewModel?.updateUserConfig()
            //刷新成本 English: Refresh cost
            newSelf.updateAsset()
        }
        return v
    }()
    //当前委托 English: Current commission
    lazy var currentEntrustList: EXContactHomeOrderListView = {
        let v = EXContactHomeOrderListView(viewModel: self.viewModel)
        v.transactionPriceType = .limit
        return v
    }()
    //当前委托 English: Current commission
    lazy var planEntrustList: EXContactHomeOrderListView = {
        let v = EXContactHomeOrderListView(viewModel: self.viewModel)
        v.transactionPriceType = .plan
        return v
    }()
    
    override func setupView() {
        self.addSubview(pagingView)
        pagingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        reloadPagingLayout()
    }
    
    
    
    //事件监听 English: event listeners
    override func bindViewModel() {
      
        self.viewModel?.wsEventSubject.subscribe(onNext: { [weak self] event in
            guard let `self` = self else { return }
            switch event {
            case .logSuccess:
                // MARK: 更新资产 计算可开多可开空 English: MARK: Update asset calculation to allow for both opening and closing of assets
                self.refreshedAsset = false
                //仓位 English: Position
            case .positionData:
                self.updateTitleNumber(index: 0)
                if self.refreshedAsset == false {
                    // MARK: 更新资产 English: MARK: Update Assets
//                    self.pagingHeader.makeOrderView.makeOrderViewModel?.asset = self.viewModel?.asset
                    self.refreshedAsset = true
                }
                //当前委托 English: Current commission
            case .currentEntrustmentData:
                self.updateTitleNumber(index: 1)
                //计划委托 English: Plan delegation
            case .planEntrustmentData:
                self.updateTitleNumber(index: 2)
            case .closePositionSuccess:
                // 刷新成本 English: Refresh cost
                self.updateAsset()
//                self.pagingHeader.makeOrderView.reloadMakeOrderData()
            default:
                break
            }
        }).disposed(by: self.disposeBag)
    }
    
   
}
extension EXContractHomeView{
    func setHeaderEndRefreshing(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.viewModel?.isScrolling = false
//            EXLogLine(mark: "isScrolling", message: "self.viewModel?.isScrolling = \( self.viewModel?.isScrolling)",function: #function)
            
        }
    }
    // MARK: 更新资产 以及成本 English: MARK: Update assets and costs
    func updateAsset(){
//        //print("updateAsset =\( self.viewModel?.canUseAmount)")
        self.pagingHeader.makeOrderView.avilabelView.setAsset(amount:self.viewModel?.canUseAmount ?? "",unit: self.viewModel?.currentItemModel?.ex_contractInfo?.margin_coin ?? "")
        self.pagingHeader.makeOrderView.reloadMakeOrderData()

    }
    //MARK: 高度刷新 English: MARK: Height refresh
    func reladHomeHeader(){
        //更新单位 English: Update Unit
        self.pagingHeader.marketPriceView.updateHeadUnit()
        self.pagingHeader.updatePriceViewDataCount() //更新高度 English: Update height
    }
    func reloadHeaderWith(height: Int, animatable: Bool = false){
        var f = self.pagingHeader.frame
        f.size.height  = CGFloat(height)
        self.pagingHeader.frame = f
        //MARK: 只刷新高度 English: MARK: Only refresh height
        if animatable {
            self.pagingView.resizeTableHeaderViewHeight(animatable: animatable,duration: notiBarClose)
        }else{
            self.pagingView.resizeTableHeaderViewHeight(animatable: false)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            //MARK: 防止过快点击 English: MARK: Prevent too fast clicks
//            self.pagingHeader.smallklineView.rightArrow.isUserInteractionEnabled = true
        }
        
    }
   
    
    /// 刷新PagingView English: /Refresh PagingView
    func reloadPagingLayout() {
        secionHeader.segmentedView.listContainer = pagingView.listContainerView
        secionHeader.segmentedView.defaultSelectedIndex = 0
        secionHeader.segmentedView.delegate = self
        pagingView.defaultSelectedIndex    = 0
        dataSource.titles = newTitles
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.secionHeader.segmentedView.reloadData()
            self.pagingView.resizeTableHeaderViewHeight()
            self.pagingView.reloadData()
        }
    }
    
    func updateTitleNumber(index: Int){
//        debug//print("合约##==更新仓位标题") English: DebugPrint ("Contract # #=Update Position Title")
        var count: Int = 0
        if index == 0 {
           count = self.viewModel?.positionDatas.count ?? 0
        }else if index == 1 {
            count = self.viewModel?.currentEntrustmentDataCount ?? 0
        }else{
            count = self.viewModel?.planEntrustmentDataCount ?? 0
        }
        var new = titles[index]
        if EXSwapPlatformSDK.shared.activeAccount?.token != nil {
            new =  new + " " + "(\(count))"
        }
       
        newTitles[index] = new
        dataSource.titles = newTitles
        //只更新标题 English: Update only the title
        self.secionHeader.segmentedView.reloadDataWithoutListContainer()
    }
    
    func resetTitleList(){
        dataSource.titles = newTitles
        //Update titles only
        self.secionHeader.segmentedView.reloadDataWithoutListContainer()
    }
    
}
extension EXContractHomeView: JXSegmentedViewDelegate{
    
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        if EXSwapPlatformSDK.shared.activeAccount?.token == nil {
            EXSwapPlatformSDK.shared.loginCallBack?()
            return
        }
    }
}
extension EXContractHomeView: JXPagingMainTableViewGestureDelegate{
    func mainTableViewGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isMember(of:NSClassFromString("FlutterView")!) == true {
            return false
        }
        return true
    }
    
    func mainTableViewGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
//        MARK: 小k线左右滑动手势冲突处理 -时间轴 English: MARK: Small candlestick left and right sliding gesture conflict handling - Timeline
        if otherGestureRecognizer == pagingHeader.smallklineView.filterMenu.menuView.collectionView.panGestureRecognizer {
            return false
        }
        if otherGestureRecognizer == secionHeader.segmentedView.collectionView.panGestureRecognizer {
            return false
        }
        return gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self)
    }
}

extension EXContractHomeView: JXPagingViewDelegate{
    
    func tableHeaderViewHeight(in pagingView: JXPagingView) -> Int {
//        //print("刷新-高度 =\(Int(self.pagingHeader.frame.size.height))") English: Print ("Refresh Height=\ (Int (self. pagingHeader. frame. size. height)")
        return Int(self.pagingHeader.frame.size.height)
    }
    
    func tableHeaderView(in pagingView: JXPagingView) -> UIView {
        return self.pagingHeader
    }
    
    func heightForPinSectionHeader(in pagingView: JXPagingView) -> Int {
        return Int(secionHeader.frame.height)
    }
    
    func viewForPinSectionHeader(in pagingView: JXPagingView) -> UIView {
        return secionHeader
    }
    
    func numberOfLists(in pagingView: JXPagingView) -> Int {
        return dataSource.titles.count
    }
    
    func pagingView(_ pagingView: JXPagingView, initListAtIndex index: Int) -> JXPagingViewListViewDelegate {
        switch index {
        case 0:
            return posionList
        case 1:
            return currentEntrustList
        case 2:
            return planEntrustList
        default:
            let v = EXContactHomeOrderListView(viewModel: nil)
            return v
        }
    }
    
    func pagingView(_ pagingView: JXPagingView, mainTableViewWillBeginDragging scrollView: UIScrollView) {
        self.viewModel?.isScrolling = true
//        EXLogLine(mark: "isScrolling", message: "self.viewModel?.isScrolling = \( self.viewModel?.isScrolling)",function: #function)
        
    }
    func pagingView(_ pagingView: JXPagingView, mainTableViewDidEndDragging scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.viewModel?.isScrolling = false
//        EXLogLine(mark: "isScrolling", message: "self.viewModel?.isScrolling = \( self.viewModel?.isScrolling)",function: #function)
    }
    func pagingView(_ pagingView: JXPagingView, mainTableViewDidScroll scrollView: UIScrollView) {
        self.viewModel?.isScrolling = true
//        EXLogLine(mark: "isScrolling", message: "self.viewModel?.isScrolling = \( self.viewModel?.isScrolling)",function: #function)
    }
    func pagingView(_ pagingView: JXPagingView, mainTableViewDidEndDecelerating scrollView: UIScrollView) {
        debugPrint(#function)
        self.viewModel?.isScrolling = false
//        EXLogLine(mark: "isScrolling", message: "self.viewModel?.isScrolling = \( self.viewModel?.isScrolling)",function: #function)//        debugPrint(#function)
        
//        updateStatus(scrollView: scrollView)
    }
    func pagingView(_ pagingView: JXPagingView, mainTableViewDidEndScrollingAnimation scrollView: UIScrollView) {
        self.viewModel?.isScrolling = false
//        EXLogLine(mark: "isScrolling", message: "self.viewModel?.isScrolling = \( self.viewModel?.isScrolling)",function: #function)
        
    }
    
}



class EXContractTransactionTable: JXPagingMainTableView {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isMember(of:NSClassFromString("FlutterView")!) == true {
            return false
        }
        return true
    }
}

