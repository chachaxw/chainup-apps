//
//  EXRewardMianView.swift
//  Chainup
//
//  Created by cwd on 2023/7/25.
//  Copyright © 2023 Chainup. All rights reserved.
//

import JXPagingView
import EXKit
import Swap
import JXSegmentedView



class EXRewardMianView: EXView {
    var titles = RewardType.allCases.map { type in
        return type.describe
    }
    
    var lists = [EXRewardListView]()
    var vm: EXTaskViewModel?
    var currentIdx = 0
    required init(viewModel: EXViewModelProtocol?) {
        self.vm = viewModel as? EXTaskViewModel
        super.init(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func setupView() {
        configSubView()
        configData()
        subEvenet()
    }
    //MARK: lazy
    lazy var pagingHeader: EXRewardsHeaderView = {
        let v = EXRewardsHeaderView(frame: CGRect(x: 0, y: 0, width: Device_W, height: EXRewardsHeaderView.getTotalHeightShowDesLabel(show: false)))
        v.doWithdrawCallback = { [weak self] in
            guard let `self` = self else { return }
            self.vm?.doWithdrawRequset()
        }
        return v
    }()
    lazy var pagingView: EXPagingView = {
        let v = EXPagingView(delegate: self, listContainerType: .scrollView)
        v.extUseAutoLayout()
        v.backgroundColor =  .Ex.fill2
        v.mainTableView.backgroundColor =  .Ex.fill2
        v.mainTableView.mj_header = EXRefreshHeaderView(refreshingBlock: { [weak self]  in
            guard let `self` = self else { return }
            self.vm?.getRewardCenterHomeAllInfo()
        })
        return v
    }()
    
    
    lazy var dataSource: JXSegmentedTitleDataSource = {
        let source = JXSegmentedTitleDataSource()
        source.titles = titles
        source.titleNormalColor = UIColor.Ex.text2
        source.titleSelectedColor = UIColor.Ex.text1
        source.titleNormalFont    = UIFont.Ex.regular(14)
        source.titleSelectedFont = UIFont.Ex.medium(14)
        source.itemSpacing          = 20
        source.itemWidthIncrement   = 0
        source.isTitleZoomEnabled   = false
        source.isItemSpacingAverageEnabled = false
        return source
    }()
    
    lazy var secionHeader: EXTaskCenterSegmentView = {
        let  v = EXTaskCenterSegmentView(frame: .init(x: 0, y: 0, width: Device_W, height: 44))
        v.segmentedView.dataSource = dataSource
        return v
    }()
                                              
}
extension EXRewardMianView{
    
    func reloadHeader(){
        let show = self.vm?.withdrawalInfo?.leftWithdrawPendingUsdt.greaterThan("0") ?? false
        let height =  EXRewardsHeaderView.getTotalHeightShowDesLabel(show: show)
        var f = self.pagingHeader.frame
        f.size.height  = CGFloat(height)
        self.pagingHeader.frame = f
        self.pagingView.resizeTableHeaderViewHeight()
    }
    func configSubView(){
        self.addSubview(pagingView)
        pagingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configData(){
        lists.removeAll()
        for type in RewardType.allCases {
            let view = EXRewardListView(viewModel: self.vm)
            view.rewadType = type
            lists.append(view)
        }
        secionHeader.segmentedView.listContainer = pagingView.listContainerView
//        secionHeader.segmentedView.delegate = self
    }
    
    func subEvenet(){
        vm?.wsEventSubject.subscribe(onNext: { [weak self] event in
            guard let `self` = self else { return }
            switch(event){
            case .withdrawInfo:
                self.endRefresh()
                self.reloadHeader()
                self.pagingHeader.taskHome = self.vm?.taskHome
                self.pagingHeader.withDrawInfo = self.vm?.withdrawalInfo
            case .doWithdraw:
                EXAlert.showSuccess(msg: "myReward_text10".localized())
                self.vm?.getRewardCenterHomeAllInfo() //need to refresh unWaitDrawInfo and waitDrawedInfo
            case .userRewardUnWithdraw:
                self.pagingHeader.unWithdrawal = self.vm?.userRewardUnWithdrawalData
                self.reloadList(rewadType: .waitTowithDraw)
            case .userRewardRecords:
                self.reloadList(rewadType: .rewadDetail)
            case .userWithdrawRecords:
                self.reloadList(rewadType: .WithDrawRecoad)
            default:
                break
            }
        }).disposed(by: self.disposeBag)
    }
    
    func endRefresh(){
         
        for listView in lists{
            listView.tableView.mj_footer.resetNoMoreData()
        }
        self.pagingView.mainTableView.mj_header.endRefreshing()
    }
    
    //
    func reloadList(rewadType: RewardType){
        guard let index = RewardType.allCases.firstIndex(of: rewadType) else{
            return
        }
        let view = lists[index]
        var listCount: Int = 0
        if rewadType == .rewadDetail {
            listCount = self.vm?.userRewardRecoardData?.list?.count ?? 0
        }else if rewadType == .waitTowithDraw{
            listCount = self.vm?.userRewardUnWithdrawalData?.unWithdrawList?.count ?? 0
        }else{
            listCount = self.vm?.userRewardWithdrawalData?.list?.count ?? 0
        }
        if listCount < (self.vm?.pageSize ?? 20) {
            view.tableView.mj_footer.endRefreshingWithNoMoreData()
        }else{
            view.tableView.mj_footer.endRefreshing()
        }
        view.tableView.reloadData()
    }
}

extension EXRewardMianView: JXPagingViewDelegate{
    
    func tableHeaderViewHeight(in pagingView: JXPagingView) -> Int {
//Print ("Refresh Height= (Int (self. pagingHeader. frame. size. height)")
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
        let v = lists[index]
        return v
    }
}



//extension EXRewardMianView:JXSegmentedViewDelegate {
    
//    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
//        if currentIdx != index {
//            currentIdx = index
//            self.indexDidChanged()
//        }
//    }
//    func indexDidChanged(){
//        let type = RewardType.allCases[currentIdx]
//        self.vm?.getRewardCenterData(reward: type)
//        print("currentIdx = \(currentIdx)")
//    }
//}
