//
//  EXOTCHomeContainerVc.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/26.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXOTCHomeContainerVc: BaseVC,StoryBoardLoadable,NavigationPlugin {
    
    var otcPageTitle = EXOTCHomeTitleView()
    var buyFilterParam = [String:String]()
    var sellFilterParam = [String:String]()
    var buyVc = EXOTCHomeVc.instanceFromStoryboard(name: StoryBoardNameOTC)
    var sellVc = EXOTCHomeVc.instanceFromStoryboard(name: StoryBoardNameOTC)
    let filter = EXFilterView()
    
    var titleArr:[String] = [LanguageTools.getString(key: "otc_action_buy"),
                             LanguageTools.getString(key: "otc_action_sell")]
        {
        didSet{
            otcPageTitle.configTitles(titles: titleArr)
            self.otcPageTitle.selectedIndex = self.selectIndex
        }
    }

    
    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: nil, presenter: self,customHandleBack: true)
        nav.customBackCallback = {[weak self] in
            self?.back()
        }
        return nav
    }()
    
    var pageContentView = SGPageContentCollectionView()
    var selectIndex = 0
    var jumpIndex = 0

    @objc func back() {
        self.filter.dismissFilter()
        self.popBack()
    }
    
    func configNavigation(){
        if EXAppConfigManager.sharedInstance.didOpenB2C(){
            self.navigation.setTitle(title: "otc_text_desc_forotc".localized())
        }else{
            self.navigation.setTitle(title: "otc_text_desc".localized())
        }
        self.navigation.configRightItems(["fiat_order","public_filter"])
        self.navigation.rightItemCallback = {[weak self] tag in
            self?.rightItemAction(with: tag)
        }
    }
    
    func rightItemAction(with tag:Int) {
        if tag == 0 {
            if filter.isShow {
                filter.dismissFilter()
            }
            if XUserDefault.isOffLine() {
                BusinessTools.modalLoginVC()
                return
            }
            let history = EXOTCHistoryListVc.instanceFromStoryboard(name: StoryBoardNameOTC)
            self.navigationController?.pushViewController(history, animated: true)
        }else {
            if filter.isShow {
                return
            }
            filter.delegate = self
            if self.selectIndex == 0 {
                filter.filterParams = self.buyFilterParam
            }else {
                filter.filterParams = self.sellFilterParam
            }
            filter.show(inView: self.view)
            filter.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configNavigation()
        configChilds()
        configDefaultPayCoin()
        NotificationCenter.default.addObserver(self, selector: #selector(userInfo), name: Notification.Name(rawValue: "EXGetUserInfoSuccess"), object: nil)
        if self.selectIndex != self.jumpIndex {
            self.jumpTo(idx: jumpIndex)
        }
    }
    
    func configDefaultPayCoin(){
        let payCoin = OTCPulbicManager.sharedInstance.publicInfo.otcDefaultPaycoin
        if  payCoin.isEmpty == false{
            self.buyFilterParam["payCoin"] = payCoin
            self.sellFilterParam["payCoin"] = payCoin
            self.buyVc.payCoin = payCoin
            self.sellVc.payCoin = payCoin
        }
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        EXTracking.shared.trackPage(name: .fiat, isEnter:true)
        EXAuthenticManagerTool.getUserKysRight(symbol: nil) { _ in
            
        }
        self.userInfo()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        EXTracking.shared.trackPage(name: .fiat, isEnter:false)
    }
    
    @objc func userInfo(){
        if XUserDefault.getToken() != nil{//If logged in
            UserInfoEntity.sharedInstance().justGetUserInfo ({ [weak self] in
            }) {
                
            }
            if UserInfoEntity.sharedInstance().otcCompanyInfoModel.status == "0"{
                setTitleArrWithAds("1")
            }else{
                ////User Field Foreign Account Status, 0: Unauthenticated, 1: Ordinary Merchant, 2: Ordinary Merchant Release, 3: Super Merchant, 4: Super Merchant Release, 1 and 3 Display
                if UserInfoEntity.sharedInstance().userCompanyInfoModel.status == "1" || UserInfoEntity.sharedInstance().userCompanyInfoModel.status == "3"{
                    setTitleArrWithAds("1")
                }else{
                    setTitleArrWithAds("0")
                }
            }
        }else{//If not logged in
            setTitleArrWithAds("0")
        }
    }
    
    //Set Array
    func setTitleArrWithAds(_ type : String){
        if type == "0"{
            titleArr = [LanguageTools.getString(key: "otc_action_buy"),
                        LanguageTools.getString(key: "otc_action_sell")]
        }else{
            titleArr = [LanguageTools.getString(key: "otc_action_buy"),
                        LanguageTools.getString(key: "otc_action_sell"),"otc_text_ad".localized()]
        }
    }
    
    func configChilds (){
        
        var controllers : [UIViewController] = []
        buyVc.tradeType = .otcbuy
        sellVc.tradeType = .otcsell
        
        controllers .append(buyVc)
        controllers .append(sellVc)

        self.otcPageTitle.frame = CGRect(x: 0, y: NAV_SCREEN_HEIGHT, width: SCREEN_WIDTH, height: 42)
        otcPageTitle.backgroundColor = UIColor.ThemeNav.bg
        otcPageTitle.delegate = self
        otcPageTitle.configTitles(titles: titleArr)
        self.view.addSubview(self.otcPageTitle)
                
        self.pageContentView = SGPageContentCollectionView.init(frame: CGRect(x: 0, y: menuBarHeight + NAV_SCREEN_HEIGHT, width: SCREEN_WIDTH, height: CONTENTVIEW_HEIGHT - menuBarHeight), parentVC: self, childVCs: controllers)
        
        self.pageContentView.delegatePageContentCollectionView = self
        self.pageContentView.isScrollEnabled = false
        self.view.addSubview(pageContentView)
        self.selectIndex = 0
        self.otcPageTitle.selectedIndex = self.selectIndex
        self.pageContentView.setPageContentCollectionViewCurrentIndex(0)
    }

}

extension EXOTCHomeContainerVc : SGPageContentCollectionViewDelegate {
    
//    func pageContentCollectionView(_ pageContentCollectionView: SGPageContentCollectionView!, progress: CGFloat, originalIndex: Int, targetIndex: Int) {
//        if targetIndex == 2{
//            return
//        }
//        self.selectIndex = targetIndex
//        otcPageTitle.selectedIndex =  targetIndex
//    }
    
    func pageContentCollectionView(_ pageContentCollectionView: SGPageContentCollectionView!, index: Int) {
        self.selectIndex = index
        otcPageTitle.selectedIndex =  index
    }
}

extension EXOTCHomeContainerVc : OTCPageTitleDelegate {
    
    func pageTitle(pageTitleView: EXOTCHomeTitleView, selectedIdx: Int) {
        if selectedIdx == 2{
            let vc = EXOTCManagerVC()
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        self.selectIndex = selectedIdx
        pageContentView.setPageContentCollectionViewCurrentIndex(selectedIdx)
//        pageContentView.setPageContentScrollViewCurrentIndex(selectedIdx)
    }
}

extension EXOTCHomeContainerVc :EXFilterViewDelegate  {
    
    func getTradTypeModel()-> EXFilterDataModel {
        let folditems = EXFilterItem.getItem(titles: ["filter_fold_normalTrade".localized(),"filter_fold_blockTrade".localized()], valueKeys: ["0","1"])
        return EXFilterDataModel.getFoldModel(key: "isBlockTrade", title: "common_type".localized(), contents: folditems)
    }
    
    func filterDataSource() -> [EXFilterDataModel] {
        var models:[EXFilterDataModel] = []
        let tradeTypeModel = self.getTradTypeModel()
        let inputModel = EXFilterDataModel.getInputModel(key: "price", title: "filter_input_targetPrice".localized(), placeHolder: "filter_Input_placeholder".localized(), unit: "CNY",keyBoardType: .decimalPad)
        let paymentModel = OTCPulbicManager.sharedInstance.getFilterPaymentModel()
        let countryModel = OTCPulbicManager.sharedInstance.getFilterCountryModel()
        models.append(tradeTypeModel)
        models.append(inputModel)

        if !(OTCPulbicManager.sharedInstance.isPayCoinDisplayAtListView()) {
            let payCoinModel =  OTCPulbicManager.sharedInstance.getFilterPayCoinModel()
            models.append(payCoinModel)
        }
        models.append(paymentModel)
        models.append(countryModel)
        return models
        
    }
    
    func filterConfirm(params: [String : String]) {
        self.buyFilterParam = params
        self.sellFilterParam = params
        self.buyVc.searchParams = params
        self.sellVc.searchParams = params
        if self.selectIndex == 0 {
            self.buyVc.handlefilter(self.buyFilterParam)
        }else {
            self.sellVc.handlefilter(self.sellFilterParam)
        }
    }
}


extension EXOTCHomeContainerVc : EXTradeCmdProtocal {
    
    func jumpTo(idx:Int) {
        self.pageContentView.setPageContentCollectionViewCurrentIndex(idx)
    }
    
    func excuteCmd(symbol: String, action: String) {
        if action == "buy" {
            self.jumpIndex = 0
            self.pageContentView.setPageContentCollectionViewCurrentIndex(0)
        }else if action == "sell" {
            self.jumpIndex = 1
            self.pageContentView.setPageContentCollectionViewCurrentIndex(1)
        }
        if let entity = EXAppMarketManager.sharedInstance.getCoinEntity(symbol) {
//            self.coinEntity = entity
//            self.symbol = entity.name
//            self.page = 1
//            self.homeTableView.mj_header.beginRefreshing()
//            getConsiderPrice()
        }
    }
}

