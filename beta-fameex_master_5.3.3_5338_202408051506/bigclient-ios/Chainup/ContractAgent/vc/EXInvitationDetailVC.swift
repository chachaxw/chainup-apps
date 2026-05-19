//
//  EXInvitationDetailVC.swift
//  Chainup
//
//  Created by chainup on 2023/8/31.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
import RxRelay

class EXInvitationDetailVC: NavCustomVC {
    
    var pageContentView = SGPageContentCollectionView()
    var pageTitleView = SGPageTitleView()
    var currentIdx = 0
    var personsCurrentPage = 1
    var rewardsCurrentPage = 1
    
    lazy var personsTableView : UITableView = {
        let tableView = self.getTableView()
        return tableView
    }()
    
    lazy var rewardsTableView : UITableView = {
        let tableView = self.getTableView()
        return tableView
    }()
    
    func getTableView() -> UITableView {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.rowHeight = 36
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.ThemeView.bg
        tableView.allowsSelection = false
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.extRegistCell([EXhorizontalThreeLabelTableViewCell.classForCoder()], ["EXInvitationRecordTableViewCell"])
        return tableView
    }
    
    let personList = BehaviorRelay(value: [EXInvitationPerson]())
    let rewardlist = BehaviorRelay(value: [EXInvitationRewardDetail]())
    
    fileprivate func initializePageView() {
        
        let config = SGPageTitleViewConfigure.defaultConfig()
        config.showBottomSeparator = true
        
        self.pageTitleView = SGPageTitleView.init(frame: CGRect.zero, delegate: self, titleNames: ["invitation_my_invitation".localized(), "invitation_invite_rewards".localized()], configure: config)
        pageTitleView.backgroundColor = UIColor.ThemeView.bg
        pageTitleView.selectedIndex = currentIdx

        contentView.addSubview(pageTitleView)
        pageTitleView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(menuBarHeight)
        }
        
        contentView.layoutIfNeeded()
        let personsVc = UIViewController()
        personsVc.view.addSubview(personsTableView)
        personsTableView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        let rewardsVc = UIViewController()
        rewardsVc.view.addSubview(rewardsTableView)
        rewardsTableView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        
        self.pageContentView = SGPageContentCollectionView.init(frame: CGRect(x: 0, y: pageTitleView.frame.maxY, width: SCREEN_WIDTH, height: contentView.frame.height - pageTitleView.frame.height), parentVC: self, childVCs: [personsVc, rewardsVc])

        contentView.addSubview(pageContentView)

        pageContentView.setPageContentCollectionViewCurrentIndex(currentIdx)
        pageContentView.backgroundColor = UIColor.ThemeView.bg
        pageContentView.delegatePageContentCollectionView = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lastVC = true
        
        setupTableView()
        initializePageView()
        
        bindData()
        queryData()
    }
    
    func setupTableView() {
        personsTableView.mj_footer = EXRefreshFooterView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.queryPersonsData()
        })
        rewardsTableView.mj_footer = EXRefreshFooterView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.queryRewardsData()
        })
    }
    
    fileprivate func queryRewardsData() {
        appApi.rx
            .request(.myInvitationRewards(page: "\(rewardsCurrentPage)", pageSize: "20"))
            .MJObjectMap(EXInvitationRewardDetailsModel.self)
            .subscribe(onSuccess: { (model) in
                
                self.rewardsCurrentPage += 1
                var new = self.rewardlist.value
                new += model.rewardList
                self.rewardlist.accept(new)
//                self.rewardlist.value = self.rewardlist.value + model.rewardList
                self.rewardsTableView.mj_footer.endRefreshing()
                if model.rewardList.count < 10 {
                    self.rewardsTableView.mj_footer.removeFromSuperview()
                }
            }){[weak self] (error) in
            self?.rewardsTableView.mj_footer.endRefreshing()
            }
            .disposed(by: disposeBag)
    }
    
    fileprivate func queryPersonsData() {
        appApi.rx
            .request(.myInvitationPersons(page: "\(personsCurrentPage)", pageSize: "20"))
            .MJObjectMap(EXInvitationPersonsModel.self)
            .subscribe(onSuccess: { (model) in
                
                self.personsCurrentPage += 1
                var new = self.personList.value
                new += model.invitationList
                self.personList.accept(new)
//                self.personList.value = self.personList.value + model.invitationList
                self.personsTableView.mj_footer.endRefreshing()
                if model.invitationList.count < 10 {
                    self.personsTableView.mj_footer.removeFromSuperview()
                }
            }){[weak self] (error) in
            self?.personsTableView.mj_footer.endRefreshing()
            }
            .disposed(by: disposeBag)
    }
    
    func queryData() {
        queryRewardsData()
        queryPersonsData()
    }
    
    func bindData() {
        rewardsTableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        personsTableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        personList
            .asObservable()
            .bind(to: personsTableView.rx.items(cellIdentifier: "EXInvitationRecordTableViewCell", cellType: EXhorizontalThreeLabelTableViewCell.self)){ row, model, cell in
                cell.setCell(left: model.levelZeroRegisterUid,
                             middle: model.accountName(),
                             right:model.registerTime.isEmpty ? "" : DateTools.strToTimeString(model.registerTime, dateFormat:"yyyy-MM-dd"))
                
        }.disposed(by: disposeBag)
        
        rewardlist
            .asObservable()
            .bind(to: rewardsTableView.rx.items(cellIdentifier: "EXInvitationRecordTableViewCell", cellType: EXhorizontalThreeLabelTableViewCell.self)){ row, model, cell in
                cell.setHighlightLabel(left: false, middle: false, right: true)
                cell.setCell(left: model.sendTime.isEmpty ? "" : DateTools.strToTimeString(model.sendTime, dateFormat:"yyyy-MM-dd"),
                             middle: model.userAccountNum,
                             right: model.conversionAmount.formatAmount("USDT"))
        }.disposed(by: disposeBag)
    }
    
    override func setNavLeft() {
        self.setTitle(LanguageTools.getString(key: "invitation_register_rewards"))
        self.navtype = .list
    }
}

extension EXInvitationDetailVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = EXhorizontalThreeLabelView(user: .header)
        let headerDesc = headerDescStr(tableView: tableView)
        header.setData(left: headerDesc.0, middle: headerDesc.1, right: headerDesc.2)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }
}
extension EXInvitationDetailVC {
    
    func headerDescStr(tableView: UITableView) -> (String, String, String) {
        if tableView == personsTableView {
            return ("UID",  "invitation_register_account".localized(), "invitation_registed_date".localized())
        }else if tableView == rewardsTableView {
            return ( "invitation_release_time".localized(), "invitation_register_account".localized(), "invitation_rewards_amount".localized() + "(USDT)")
        }
        return ("","","")
    }
}

extension EXInvitationDetailVC :SGPageTitleViewDelegate, SGPageContentCollectionViewDelegate {
    
    func pageContentCollectionViewWillBeginDragging() {}
    func pageContentCollectionViewDidEndDecelerating() {}
    
    
    func pageTitleView(_ pageTitleView: SGPageTitleView!, selectedIndex: Int) {
        //        handleCurrentIdx(idx: selectedIndex)
        pageContentView.setPageContentCollectionViewCurrentIndex(selectedIndex)
    }
    
    func pageContentCollectionView(_ pageContentCollectionView: SGPageContentCollectionView!, index: Int) {
        //        handleCurrentIdx(idx:index)
    }
    
    func pageContentCollectionView(_ pageContentCollectionView: SGPageContentCollectionView!, progress: CGFloat, originalIndex: Int, targetIndex: Int) {
        pageTitleView.setPageTitleViewWithProgress(progress, originalIndex: originalIndex, targetIndex: targetIndex)
    }
    
}
