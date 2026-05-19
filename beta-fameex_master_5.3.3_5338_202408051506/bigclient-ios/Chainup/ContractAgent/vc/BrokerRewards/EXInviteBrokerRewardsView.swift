//
//  EXInviteBrokerRewardsView.swift
//  Chainup
//
//  Created by bradjohn on 2024/3/15.
//  Copyright © 2024 Chainup. All rights reserved.
//

import UIKit
import EXKit
import JXPagingView
import JXSegmentedView

class EXInviteBrokerRewardsView: UIView {
    
    
    var updateNavigationTitleCallback: ((Bool) -> Void)?
    
    lazy var tableHeaderView: EXInsetLabel = {
        let v = EXInsetLabel(font: .Ex.bold(28), textColor: .Ex.text1)
        v.frame = .init(x: 0, y: 0, width: SCREEN_WIDTH, height: 64)
        v.edgeInset = .init(top: 0, left: 15, bottom: 0, right: 15)
        v.text = "合约经纪人".localized()
        return v
    }()
    
    lazy var pagingView: JXPagingListRefreshView = {
        let v = JXPagingListRefreshView(delegate: self, listContainerType: .scrollView)
        v.mainTableView.gestureDelegate = self
        return v
    }()
    
    lazy var dataSource: JXSegmentedTitleDataSource = {
        let v = JXSegmentedTitleDataSource()
        v.titles = ["客户人数".localized(), "收益汇总".localized(), "奖励明细".localized()]
        v.titleNormalFont = .Ex.bold(16)
        v.titleSelectedFont = .Ex.bold(16)
        v.titleNormalColor = .Ex.text2
        v.titleSelectedColor = .Ex.text1
        v.itemSpacing = 20
        v.isItemSpacingAverageEnabled = false
        return v
    }()
    
    lazy var segmentView: JXSegmentedView = {
        let v = JXSegmentedView()
        v.frame = .init(x: 0, y: 0, width: SCREEN_WIDTH, height: 38)
        v.delegate = self
        v.dataSource = dataSource
        v.contentEdgeInsetLeft = 15
        v.indicators = [EKIndicatorSegmentIndicator()]
        
        let bottomBorder = UIView()
        bottomBorder.backgroundColor = .Ex.fill4
        v.addSubview(bottomBorder)
        bottomBorder.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(0.5)
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        onCreate()
        onBindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onCreate() {
        addSubViews([pagingView])
        segmentView.listContainer = pagingView.listContainerView
        self.segmentView.reloadData()
        self.pagingView.reloadData()
        pagingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func onBindViewModel() {
        
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}


extension EXInviteBrokerRewardsView: JXSegmentedViewDelegate {
    
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        
    }
}


extension EXInviteBrokerRewardsView: JXPagingViewDelegate, JXPagingMainTableViewGestureDelegate {
    
    
    func tableHeaderViewHeight(in pagingView: JXPagingView) -> Int {
        return Int(CGRectGetHeight(tableHeaderView.frame))
    }
    
    func tableHeaderView(in pagingView: JXPagingView) -> UIView {
        return tableHeaderView
    }
    
    func heightForPinSectionHeader(in pagingView: JXPagingView) -> Int {
        return Int(CGRectGetHeight(segmentView.frame))
    }
    
    func viewForPinSectionHeader(in pagingView: JXPagingView) -> UIView {
        return segmentView
    }
    
    func numberOfLists(in pagingView: JXPagingView) -> Int {
        return dataSource.titles.count
    }
    
    func pagingView(_ pagingView: JXPagingView, initListAtIndex index: Int) -> JXPagingViewListViewDelegate {
        return EXInviteRegisterRewardsListView()
    }
    
    func pagingView(_ pagingView: JXPagingView, mainTableViewDidScroll scrollView: UIScrollView) {
        updateNavigationTitleCallback?(scrollView.contentOffset.y > CGRectGetHeight(tableHeaderView.frame) * 0.7)
    }
    
    func mainTableViewGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer == segmentView.collectionView.panGestureRecognizer {
            return false
        }
        return gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self)
    }
    
}



// MARK: -- EXInviteRegisterRewardsListView
class EXInviteBrokerRewardsListView: UIView, JXPagingViewListViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    lazy var tableView: UITableView = {
        let v = UITableView(frame: .zero, style: .plain)
        v.delegate = self
        v.dataSource = self
        return v
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onCreate() {
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    
    // MARK: - JXPagingViewListViewDelegate
    var scrollCallback: ((UIScrollView) -> ())?
    
    func listView() -> UIView {
        return self
    }
    
    func listScrollView() -> UIScrollView {
        return self.tableView
    }
    
    func listViewDidScrollCallback(callback: @escaping (UIScrollView) -> ()) {
        self.scrollCallback = callback
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollCallback?(scrollView)
    }
    
    
    // MARK:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
}
