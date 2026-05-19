//
//  EXOTCMerchantDetailVc.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/10.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import JXPagingView
import JXSegmentedView
import EXKit

class EXOTCMerchantDetailVc: BaseVC,StoryBoardLoadable,NavigationPlugin, JXSegmentedViewDelegate {
    
    var topHeight:CGFloat = 0
    var pagingView :JXPagingListRefreshView!
    var header:EXOTCMerchantHeaderView!
    
    var userID:String?
    var onMyList:Bool = false
    var hasPaymentType:Bool = false //Check if your balance is 0 when selling
    var myPaymentTypeModel:CommonAryModel = CommonAryModel()
    var balanceModel:EXOTCAccountListModel?
    var otcVm:EXOTCVm = EXOTCVm()
    var currentIdx:Int = 0 {
        didSet {
            if currentIdx == 1 {
                updateBalance()
            }
        }
    }
    
    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: nil, presenter: self)
        return nav
    }()
    
    lazy var segmentedView: JXSegmentedView = {
        let view = JXSegmentedView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
        view.delegate = self
        return view
    }()
    
    lazy var segmentedDataSource: JXSegmentedTitleDataSource = {
        let source = JXSegmentedTitleDataSource()
        source.itemSpacing = 0
        source.titleNormalColor = UIColor.ThemeLabel.colorMedium
        source.titleSelectedColor = UIColor.ThemeLabel.colorLite
        source.titleNormalFont = UIFont.systemFont(ofSize: 14.0, weight: .medium)
        source.titleSelectedFont = UIFont.systemFont(ofSize: 14.0, weight: .medium)
        return source
    }()
    
    lazy var indicatorLineView: JXSegmentedIndicatorLineView = {
        let view = JXSegmentedIndicatorLineView()
        view.indicatorWidth = 20
        view.indicatorColor = UIColor.ThemeView.highlight
        view.indicatorHeight = 2
        view.indicatorCornerRadius = 0
        return view
    }()
    
    func updateBalance() {
        if XUserDefault.isOffLine() {
            return
        }
        appApi.rx.request(.financeAccountList)
            .MJObjectMap(EXOTCAccountListModel.self,false)
            .subscribe{[weak self] event in
                switch event {
                case .success(let model):
                    self?.checkBalance(model: model)
                    break
                case .failure(_):
                    break
                }
            }.disposed(by: self.disposeBag)
        self.refreshPayments()
    }
    
    func refreshPayments() {
        otcApi.hideAutoLoading()
        otcApi.rx.request(.paymentFind(isOpen: "1"))
        .MJObjectMap(CommonAryModel.self,false)
        .subscribe{[weak self] event in
            switch event {
            case .success(let model):
                self?.handelUserPayments(model)
                break
            case .failure(_):
                break
            }
        }.disposed(by: self.disposeBag)
    }
    
    func handelUserPayments(_ model:CommonAryModel) {
        self.myPaymentTypeModel = model
        self.hasPaymentType = model.dictAry.count > 0
    }

    
    func checkBalance(model:EXOTCAccountListModel) {
        self.balanceModel = model
    }
    
    func handleNavigation(){
        navigation.setdefaultType(type: .list)
        navigation.setTitle(title: "otc_text_merchantHomePage".localized())
        navigation.rightItemCallback = {[weak self] tag in
            self?.handleRightAction()
        }
    }
    
    func handleRightAction() {
        if XUserDefault.isOffLine() {
            BusinessTools.modalLoginVC()
            return
        }
        
        var msg = ""
        if onMyList {
            msg = "common_tip_removeBlackList".localized()
        }else {
            msg = "common_tip_addToBlackList".localized()
        }
        let commonAlert = EXNormalAlert()
        commonAlert.configAlert(title: "common_text_tip".localized(), message:msg, passiveBtnTitle: "common_action_thinkAgain".localized(), positiveBtnTitle:"common_text_btnConfirm".localized())
        commonAlert.alertCallback = {[weak self] tag in
            if tag == 0 {
                self?.blackListAction()
            }
        }
        EXAlert.showAlert(alertView: commonAlert)
    }
    
    func blackListAction() {
        guard let mUid = self.userID else {return}

        if onMyList {
            otcApi.rx.request(.userContactsRemove(uid: mUid))
            .MJObjectMap(EXVoidModel.self)
            .subscribe(onSuccess: {[weak self] (entity) in
                self?.removeSuccess(true)
            }) {[weak self] (error) in
                self?.removeSuccess(false)
            }.disposed(by: disposeBag)
        }else {
            otcApi.rx.request(.userContacts(uid: mUid, relationType:OTCRelationType.blackList.rawValue))
                .MJObjectMap(EXVoidModel.self)
                .subscribe(onSuccess: {[weak self] (entity) in
                    self?.addSucess(true)
                }) {[weak self] (error) in
                    self?.addSucess(false)
                }.disposed(by: disposeBag)
        }
    }
    
    func removeSuccess(_ success:Bool)  {
        if success  {
            EXAlert.showSuccess(msg: "otc_tip_didRemoveBlackList".localized())
            onMyList = false
            navigation.configRightItems(["otc_action_addBlackList".localized()], isImageName: false)
        }
    }
    
    func addSucess(_ success:Bool) {
        if success  {
            EXAlert.showSuccess(msg: "common_tip_didinBlacklist".localized())
            onMyList = true
            navigation.configRightItems(["common_action_removeBlackList".localized()], isImageName: false)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidLoad() {
        
        segmentedDataSource.titles = ["otc_action_merchantBuy".localized(),"otc_action_merchantSell".localized()]
        segmentedView.dataSource = segmentedDataSource
        segmentedView.indicators = [indicatorLineView]

//        segment = EXSelectionTitleBar()
//        segment.bindTitleBar(with: ["otc_action_merchantBuy".localized(),"otc_action_merchantSell".localized()])
//        segment.setSelected(atIdx: 0)
//        segment.titleBarCallback = {[weak self] tag in
//            guard let mySelf = self else{return}
//            mySelf.currentIdx = tag
//            guard let collectionView = mySelf.pagingView.listContainerView.scrollView as? UICollectionView else { return }
//            collectionView.scrollToItem(at: IndexPath(item: tag, section: 0), at: .centeredHorizontally, animated: true)
//            mySelf.pagingView.listContainerView.didClickSelectedItem(at: tag)
//        }
        header = EXOTCMerchantHeaderView()
        header.backgroundColor = UIColor.ThemeView.bg
        header.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 170)
        pagingView = JXPagingListRefreshView(delegate: self)
        pagingView.mainTableView.backgroundColor = UIColor.ThemeView.bg
        self.view.addSubview(pagingView)
        segmentedView.listContainer = pagingView.listContainerView

        handleNavigation()
        self.handleRelationList()
        self.handleMerchantDetail()
        
        let addPayMentSuccess = NSNotification.Name(rawValue: "AddPayMentSuccessNotification")
        _ = NotificationCenter.default.rx
        .notification(addPayMentSuccess)
        .takeUntil(self.rx.deallocated)
        .subscribe(onNext:{ [weak self] notification in
            self?.refreshPayments()
        })
               
        super.viewDidLoad()
    }
    
    func handleRelationList() {
        if XUserDefault.isOffLine() {
            navigation.configRightItems(["otc_action_addBlackList".localized()], isImageName: false)
            return
        }
        guard let _ = self.userID else {return}

        otcApi.rx
            .request(.personRelationship(relationType:  "BLACKLIST", pageSize:"100", page: "1"))
            .MJObjectMap(EXShieldEntity.self)
            .subscribe(onSuccess: {[weak self] (entity) in
                self?.configRelations(list: entity.relationshipList)
            }) {[weak self] (error) in
                self?.configRelations(list: [])
            }.disposed(by: disposeBag)
    }
    
    func configRelations(list:[EXRelationShip]) {
        var blackList:[String] = []
        for relation in list {
            blackList.append(relation.userId)
        }
        
        onMyList = blackList.contains(userID!)
        
        if blackList.contains(userID!) {
            navigation.configRightItems(["common_action_removeBlackList".localized()], isImageName: false)
        }else {
            navigation.configRightItems(["otc_action_addBlackList".localized()], isImageName: false)
        }
        
    }
    
    func handleMerchantDetail() {
        guard let muid = self.userID else {return}
        
        otcApi.rx
            .request(.personHomePage(uid:muid))
            .MJObjectMap(EXMerchantModel.self)
            .subscribe(onSuccess: {[weak self] (model) in
                self?.updateHeader(model: model)
            }) {[weak self] (error) in
                
            }.disposed(by: disposeBag)
    }
    
    func updateHeader(model:EXMerchantModel) {
        header.bindHeaderInfo(model: model)
    }
    
    
    func largeTitleValueChanged(height: CGFloat) {
        pagingView.frame = CGRect(x: 0, y: height, width: SCREEN_WIDTH, height: self.view.bounds.height - NAV_SCREEN_HEIGHT)
    }
}

extension EXOTCMerchantDetailVc : JXPagingViewDelegate {
    
    func tableHeaderViewHeight(in pagingView: JXPagingView) -> Int {
        return 170
    }
    
    func tableHeaderView(in pagingView: JXPagingView) -> UIView {
        return header
    }
    
    func heightForPinSectionHeader(in pagingView: JXPagingView) -> Int {
        return 44
    }
    
    func viewForPinSectionHeader(in pagingView: JXPagingView) -> UIView {
        return segmentedView
    }
    
    func numberOfLists(in pagingView: JXPagingView) -> Int {
        return 2
    }
    
    func pagingView(_ pagingView: JXPagingView, initListAtIndex index: Int) -> JXPagingViewListViewDelegate {
        let list = EXOTCMerchantListView()
        list.uid = self.userID
        if index == 0 {
            list.otcTradeType = .otcbuy
        }else if index == 1 {
            list.otcTradeType = .otcsell
        }else {
            list.otcTradeType = .none
        }
        list.onTradeConfirmCallback = {[weak self] item,type in
            guard let `self` = self else {return}
            self.handleListItem(item, type)
        }
        list.beginLoading()
        return list
    }
    
    func handleListItem(_ item:EXAdListItem,_ type:OTCTradeType) {
        self.otcVm.otcOrderPreCheck(advertId: item.advertId, type: type, vc: self,emptyBalance:self.balanceModel?.isBalanceEmpty(coinSymbol: item.coin),hasPayment:hasPaymentType,sellerPayment: item.payments,myPaymentModel:myPaymentTypeModel)
    }
    
    func mainTableViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        if navigation.navtype == .list{
            if y > 0.0 {
                navigation.navtype = .listtitle
            }
        }else if navigation.navtype == .listtitle{
            if y <= 0.0 {
                navigation.navtype = .list
            }
        }
    }
    
    
    func pagingView(_ pagingView: JXPagingView, mainTableViewDidEndDecelerating scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        if x > SCREEN_WIDTH/2 {
            currentIdx = 1
        }else {
            currentIdx = 0
        }
    }
}

extension EXOTCMerchantDetailVc : EXRefreshProtocal {
    func refreshProtocalTrigger() {
        self.pagingView.reloadData()
    }
}

