//
//  InviteRegisterRewardsView.swift
//  Chainup
//
//  Created by bradjohn on 2024/3/15.
//  Copyright © 2024 Chainup. All rights reserved.
//

import UIKit
import EXKit
import JXPagingView
import JXSegmentedView
import RxSwift

enum EXInviteRegisterType: Int, Codable, CustomStringConvertible {
    case invited
    case reward
    var description: String {
        switch self {
        case .invited: return "referral_inviteRewards_invitation".localized()
        case .reward:  return "referral_inviteRewards_reward".localized()
        }
    }
}

class EXInviteRegisterRewardsView: UIView {
  
    
    var updateNavigationTitleCallback: ((Bool) -> Void)?
    
    lazy var tableHeaderView: EXInsetLabel = {
        let v = EXInsetLabel(font: .Ex.bold(28), textColor: .Ex.text1)
        v.frame = .init(x: 0, y: 0, width: SCREEN_WIDTH, height: 0)
        v.edgeInset = .init(top: 0, left: 15, bottom: 0, right: 15)
        v.text = "invitation_register_rewards".localized()
        v.isHidden = true
        return v
    }()
    
    lazy var inviteCategories: [EXInviteRegisterType] = {
        let d: [EXInviteRegisterType] = [.invited, .reward]
        return d
    }()
   
    lazy var pagingView: JXPagingListRefreshView = {
        let v = JXPagingListRefreshView(delegate: self, listContainerType: .scrollView)
        v.mainTableView.gestureDelegate = self
        v.mainTableView.backgroundColor = .clear
        return v
    }()
    
    lazy var dataSource: JXSegmentedTitleDataSource = {
        let v = JXSegmentedTitleDataSource()
        v.titles = inviteCategories.map({ $0.description })
        v.titleNormalFont = .Ex.medium(14)
        v.titleSelectedFont = .Ex.medium(14)
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


extension EXInviteRegisterRewardsView: JXSegmentedViewDelegate {
    
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        
    }
}


extension EXInviteRegisterRewardsView: JXPagingViewDelegate, JXPagingMainTableViewGestureDelegate {
   
    
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
        let v = EXInviteRegisterRewardsListView()
        v.inviteType = inviteCategories[index]
        return v
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
class EXInviteRegisterRewardsListView: UIView, JXPagingViewListViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var inviteType: EXInviteRegisterType = .invited
    
    private var dataSource: [EXMyInvitationsItemModel] = []
    
    private var page: Int = 1
    private var pageSize = 20
    
    lazy var tableView: UITableView = {
        let v = UITableView(frame: .zero, style: .grouped)
        v.register(EXInviteRegisterRewardsListCell.self, forCellReuseIdentifier: "EXInviteRegisterRewardsListCell")
        v.contentInset = .init(top: 8, left: 0, bottom: 0, right: 0)
        v.separatorStyle = .none
        v.delegate = self
        v.dataSource = self
        v.emptyDataSetSource = self
        v.emptyDataSetDelegate = self
        v.rowHeight = UITableView.automaticDimension
        v.estimatedRowHeight = 100
        v.sectionFooterHeight = .leastNormalMagnitude
        v.backgroundColor = .clear
        if #available(iOS 15.0, *) {
            v.sectionHeaderTopPadding = 0
        }
        v.mj_header = EXRefreshHeaderView(refreshingBlock: { [weak self] in
            guard let self else { return }
            self.page = 1
            self.getInvitationList()
        })
        v.mj_footer = EXRefreshFooterView(refreshingBlock: { [weak self] in
            guard let self else { return }
            self.page += 1
            self.getInvitationList()
        })
        return v
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        onCreate()
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
    
    func listWillAppear() {
        guard dataSource.count == 0 else { return }
        getInvitationList()
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EXInviteRegisterRewardsListCell", for: indexPath)
        if let cell = cell as? EXInviteRegisterRewardsListCell {
            cell.setModel(self.dataSource[indexPath.section], inviteType)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func getInvitationList() {
        let currentlyRequest = (inviteType == .invited) ?
        appApi.rx.request(.myInvitationsApp(pageSize: String(pageSize), page: String(page))):
        appApi.rx.request(.myInvitationRewardsApp(pageSize: String(pageSize), page: String(page)))
        currentlyRequest.MJObjectMap(EXMyInvitationModel.self)
            .subscribe(onSuccess: {[weak self] result in
                guard let self else { return }
                var array:[EXMyInvitationsItemModel] = []
                if self.inviteType == .invited {
                    array = result.invitationList
                } else {
                    array = result.rewardList
                }
            
                if array.count < self.pageSize {
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                } else {
                    self.tableView.mj_footer.resetNoMoreData()
                }
                if page == 1 {
                    self.dataSource.removeAll()
                    self.dataSource.append(contentsOf: array)
                } else {
                    self.dataSource.append(contentsOf: array)
                }
            }, onFailure: { err in
                
            }, onDisposed: { [weak self] in
                guard let self else { return }
                self.tableView.mj_footer.endRefreshing()
                self.tableView.mj_header.endRefreshing()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }).disposed(by: disposeBag)
    }
}
