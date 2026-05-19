//
//  EXHomepageVc.swift
//  Chainup
//
//  Created by liuxuan on 2023/6/3.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import SwiftEventBus
import RxSwift
import YYWebImage
import RxCocoa
import YYWebImage
import Tiercel
import EXKit
import AVFoundation
import Swap
import EXKit
class EXHomepageVc: BaseVC {
    var firstTime = true
    var tickerDisposeBag: Disposable? = nil
    var tickerReceiver:[String:EXTickerModel] = [:]
    var track_begin:Date?
    var track_end:Date?
    let vm = EXOTCSafetyCheckVm()
    private var viewModel:EXHomePageListViewModel = EXHomePageListViewModel()
    var pages:[EXHomePageCellTypes] = []
    var homePageModel:EXHomeIndexViewModel = EXHomeIndexViewModel()
    
    var assetModel:EXHomeAssetModel = EXHomeAssetModel()
    let balance: PublishSubject<EXHomeAssetModel> = PublishSubject.init()
    let coBalance: PublishSubject<String> = PublishSubject.init()
    var homedisposeBag = DisposeBag()
    var coBalanceStr:String = "0"
    var timerDisposable: Disposable? = nil
    var rankIdx:Int = 0
    
    static let adDownloader:SessionManager = SessionManager.init("StartUpDownLoader", configuration: SessionConfiguration())
    
    var adIsShow:Bool = false
    
    lazy var homeSkeleton: EXSkeletonHomeView = {
        let v = EXSkeletonHomeView()
        return v
    }()
    
     //MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configViewAndData()
        getData()
        addHomeSketelon()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        EXTracking.shared.trackPage(name: .home, isEnter:true)
        //Refresh asset registration status
        if EXHomeViewModel.status() == .three {
            getAccountBalance()
        }
        if firstTime {
            getReadyToReload()
        } else {
            self.perform(#selector(getReadyToReload), with: nil, afterDelay: 0.5)
        }
        checkingUserIsLogin()
        
        if(!XUserDefault.isOffLine()){
            getNoRead()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if firstTime {
            firstTime = false
            trackActionOn()
            prepareGuides()
        }
        if EXHomeViewModel.isContractStatus() {
            subscribeTickers()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        EXTracking.shared.trackPage(name: .home, isEnter:false)
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(getReadyToReload), object: nil)
        tickerDisposeBag?.dispose()
        //        mainView.timer?.fireDate = Date.distantFuture
        EXWebSocket.marketService.cancel()
        if EXAppConfigManager.sharedInstance.getContractVersion() == .new {
            EXSwapSocketManager.shared.suspend()

        }
    }
   
    //MARK: lazy
    lazy var navView : EXHomeNavBar = {
        var view = EXHomeNavBar()
        view.searchBar.jumpCallBack = {[weak self] _ in
            guard let self else { return }
            self.clickSearch()
        }
        view.qrBtn.addTarget(self, action: #selector(clickQrBtn), for: .touchUpInside)
        view.extUseAutoLayout()
        return view
    }()
    
    lazy var loginTabV : EXLoginTabView = {
        let v = EXLoginTabView()
        return v
    }()
    
    lazy var mainTable : UITableView = {
        let view = UITableView.init(frame: .zero, style:.plain)
//        view.bounces = false
        view.delegate = self
        view.dataSource = self
        view.estimatedRowHeight = 0
        view.estimatedSectionHeaderHeight = 0
        view.estimatedSectionFooterHeight = 0
        view.extUseAutoLayout()
        view.mj_header = EXRefreshHeaderView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.reloadHomePage()
        })
        return view
    }()
    
    lazy var redPacketBtn : EXRedPacketButton = {
        let btn = EXRedPacketButton.sharedInstance
        btn.clickBtnBlock = {[weak self]tag in
            guard let mySelf = self else{return}
            switch tag{
            case 0:
                self?.redPacketBtn.isHidden = true
            case 1:
                if XUserDefault.getToken() == nil{
                    BusinessTools.modalLoginVC()
                    return
                }
                if self?.vm.checkRedpacketSafety(mySelf) == true{
                    let vc = EXSendRedPacketVC()
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            default:
                break
            }
        }
        return btn
    }()
    
}

extension EXHomepageVc : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let pageType = self.pages[indexPath.row]
        if pageType == .ranking {
            var currentRecommendCount = 0
            if self.homePageModel.home_recommend_list.count > 0 {
                currentRecommendCount = self.homePageModel.home_recommend_list[rankIdx].list.count
//                for item in self.homePageModel.home_recommend_list{
//                    if item.list.count > currentRecommendCount{
//                        currentRecommendCount = item.list.count
//                    }
//                }
                let height = CGFloat(EXHomePageHeightHelper.rankingH * CGFloat(currentRecommendCount) + EXHomePageHeightHelper.rankingMenu + EXHomePageHeightHelper.rankingHeader)
//                print("Recommended height at the bottom of the homepage")
                return height
            }else{
                return 300
            }
        }
        return EXHomePageHeightHelper.getHeightByCellTypes(pageType, model: self.homePageModel)
    }
    
    
    func needRoundCorners(idx:Int) -> Bool {
        //Is there any announcement? The second one requires rounded corners
        //Banner announcement rounded corners
        //Banner gap fillet
        return idx == 2
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let page = self.pages[indexPath.row]
        if page == .banner {
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as EXBannerCell
            cell.bindBanner(self.homePageModel.cmsAppAdvertList)
            return cell
        }else if page == .notice {
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as EXNoticeCell
            cell.bindNoticeItems(homePageModel.noticeInfoList)
            return cell
        }else if page == .recommend {
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as EXHomeNominateCell
            cell.roundCorners = self.needRoundCorners(idx:indexPath.row)
            cell.bindRecommendCoins(homePageModel.header_symbol)
            return cell
        }else if page == .subbanner {
            if homePageModel.subBannerType == .singleColoum {
                let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as EXHomeSubBannerCell
                cell.roundCorners = self.needRoundCorners(idx:indexPath.row)
                if EXHomeViewModel.status() == .three {
                    cell.bindBanners(subBanner: homePageModel.cmsAppAdvertList)
                }else {
                    cell.bindBanners(subBanner: homePageModel.cmsAppDataListOther)
                }
                return cell
            }else {
                let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as EXDoubleBannerCell
                cell.roundCorners = self.needRoundCorners(idx:indexPath.row)
                cell.bindBanners(subBanner: homePageModel.cmsAppDataListOther)
                return cell
            }
        }else if page == .tool {
            if EXHomeViewModel.status() == .two {
                let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as EXOneByTwoCell
                cell.setView(homePageModel.cmsAppDataList)
                return cell
            }else {
                let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as EXHomeSudokuCell
                cell.roundCorners = self.needRoundCorners(idx:indexPath.row)
                cell.bindSudokus(homePageModel.cmsAppDataList,style: homePageModel.kingkongType)
                cell.onMoreCallback = {[weak self] in
                    self?.moreKingkongAction()
                }
                return cell
            }
        }else if page == .account {
            if XUserDefault.isOffLine() {
                let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as EXNoLoginAccountCell
                return cell
            }else {
                let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as EXLoginAccountCell
                cell.setView(self.assetModel)
                return cell
            }
            
        }else if page == .japanAccount {
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as EXJapanAccountCell
            cell.setView(self.assetModel.totalBalance)
            return cell
        }else if page == .ranking {
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as EXRankingContainerCell
            cell.roundCorners = self.needRoundCorners(idx:indexPath.row)
            cell.bindRankings(datas: homePageModel.home_recommend_list)
            cell.recieveDataCallBack = { [weak self] in
                guard let `self` = self else { return }
                self.dismissLoading()
            }
            cell.onIndexChanges = {[weak self] (idx, key) in
                self?.handleRankingChange(idx: idx, key: key, indexPath: indexPath)
            }
            cell.onReloadTable = {[weak self] in
                self?.mainTable.mj_header.beginRefreshing()
            }
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as EXSeperatorCell
            if page == .bgGap {
                cell.contentView.backgroundColor = UIColor.ThemeView.bg
            }
            return cell
        }
    }
    
    func handleRankingChange(idx:Int,key:String,indexPath:IndexPath) {
        self.rankIdx = idx
        debugPrint(key)

        if !EXHomeViewModel.isContractStatus() {
//            self.onUpdateTradeListV4()
//            self.restartTradeListV4()
//            self.mainTable.reloadRows(at: [indexPath], with: .none)
//            if let cell = self.mainTable.cellForRow(at: indexPath) as? EXRankingContainerCell{
////                cell.setSelectIndex(index: idx)
//            }
        }else {
            self.mainTable.reloadData()
        }
        if key == "falling" {
            EXTracking.shared.trackFirebase(firebaseKey: FirebaseKey.Home_TopLosers_click)
        }else if key == "rasing" {
            EXTracking.shared.trackFirebase(firebaseKey: FirebaseKey.Home_TopGainers_click)
        }else if key == "deal" {
            EXTracking.shared.trackFirebase(firebaseKey: FirebaseKey.Home_VOLLeaders_click)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 && EXWebSocket.marketService.retryTime > 3 && homePageModel.home_recommend_list.count > 0{
            let errorview = EXEmptyNetworkCell.init()
            return errorview
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && EXWebSocket.marketService.retryTime > 3 && homePageModel.home_recommend_list.count > 0 {
            return 44
        }
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
}



extension EXHomepageVc {
    
    func configLoading(){
        self.showLottieLoadingView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.dismissLoading()
        }
    }
    func checkingUserIsLogin() {
        self.navView.configUserBtn()
        if XUserDefault.isOffLine() {
            if self.loginTabV.superview != nil {
                return
            }
            self.mainTable.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 56, right: 0)
            self.view.addSubview(self.loginTabV)
            loginTabV.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.height.equalTo(56)
            }
            self.bringHomeSkeletonToFront(view: loginTabV)
        }else {
            if self.loginTabV.superview != nil {
                self.mainTable.contentInset = UIEdgeInsets.zero
                self.loginTabV.removeFromSuperview()
            }
            if EXAppConfigManager.sharedInstance.didOpenContract() {
                XUserDefault.clearLocalLanguageDefaultsData()
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.swapSDKLoadPlatForm()
            }
        }
    }
    
  
    @objc func getReadyToReload() {
        //Refresh homepage
        if !EXHomeViewModel.isContractStatus() {
            EXHomeWsDataVm.shared().reConnect()
        }
        handleTicker()
    }
    
    func reloadAccountView() {
        if EXHomeViewModel.status() == .three {
            if let accountIdx = self.pages.firstIndex(of: .japanAccount) {
                self.mainTable.reloadRows(at: [IndexPath.init(row: accountIdx, section: 0)], with: .none)
            }
        }
    }
    
    func getAccountBalance() {
        reloadAccountView()
        if XUserDefault.isOffLine(){
            return
        }
        
        _ = EXAssetsManager.manager.allAssetsSignal().subscribe(onNext: { [weak self] model in
            guard let self = `self` else { return }
            self.assetModel = model
            self.handleHomeAssetView(model: self.assetModel)
        })
    }
    
    func handleHomeAssetView(model:EXHomeAssetModel) {
        if EXHomeViewModel.isUIStatusNormal() {
            if let accountIdx = self.pages.firstIndex(of: .account) {
                if let accountCell = self.mainTable.cellForRow(at: IndexPath.init(row: accountIdx, section: 0)) as? EXLoginAccountCell {
                    accountCell.setView(model)
                }
            }
        }else if EXHomeViewModel.status() == .three {
            if let accountIdx = self.pages.firstIndex(of: .japanAccount) {
                if let accountCell = self.mainTable.cellForRow(at: IndexPath.init(row: accountIdx, section: 0)) as? EXJapanAccountCell {
                    accountCell.setView(model.totalBalance)
                }
            }
        }
    }
    
    
    //MARK:  Notification
    func configNoti() {
        EXAppConfigManager.sharedInstance.resetBehaviorSubject()
        EXAppMarketManager.sharedInstance.resetBehaviorSubject()
        EXAppConfigManager.sharedInstance.onPbV5Publish.subscribe (onNext: {[weak self] (success) in
            guard let `self` = self else {return}
            if success {
//                print("onPbV5Publish ")
                if EXAppConfigManager.sharedInstance.didOpenQRLogin(){
                    self.navView.dealScanBtn(show: true)
                }
                self.reloadTabbarModules()
            }
        },onError: { [weak self] _ in
            
        }).disposed(by: self.disposeBag)
       
        EXAppMarketManager.sharedInstance.onMarketPublish.subscribe (onNext: {[weak self] (success) in
            guard let `self` = self else {return}
            if success {
                self.reloadHomePage()
            }
        },onError: { [weak self] _ in
            
        }).disposed(by: self.disposeBag)
        NotificationCenter.default.rx.notification(EXLanguage.currentLocalizationsDidChangeNotification)
            .debounce(.seconds(5), scheduler: MainScheduler.instance)
            .subscribe(onNext: {[weak self] _ in
                self?.lanDownloadSuccess()
            }).disposed(by: disposeBag)
//        NotificationCenter.default.addObserver(self,
//                                                   selector: #selector(lanDownloadSuccess),
//                                                   name: EXLanguage.currentLocalizationsDidChangeNotification,
//                                                   object: nil)
            
        SwiftEventBus.onMainThread(self, name: EXReachabilityKey.onNetworkConnected) { (result) in
            self.onNetworkConnected()

        }
        SwiftEventBus.onMainThread(self, name: EXEventBusConst.onLinkReconnected) { (result) in
            self.getReadyToReload()
        }
        _ = NotificationCenter.default.rx
            .notification(Notification.Name(rawValue: NOTI_WS_CONNECTED))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: {[weak self] noti in
                self?.tryGetReview()
            })
        
        _ = NotificationCenter.default.rx
            .notification(UIApplication.didBecomeActiveNotification)
            .takeUntil(self.rx.deallocated) //Page destruction automatic removal notification listening
            .subscribe(onNext: {[weak self] noti in
                self?.homeBtnAction(false)
            })
        
        _ = NotificationCenter.default.rx
            .notification(UIApplication.willResignActiveNotification)
            .takeUntil(self.rx.deallocated) //Page destruction automatic removal notification listening
            .subscribe(onNext: {[weak self] noti in
                self?.homeBtnAction(true)
            })
        //Notify when the interface requests Future ticker data updates, and new contracts are also used
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(subscribeTickers),
                                               name: NSNotification.Name(rawValue: EXContractLoadFuturesData_Notification),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(wscontentChange),
                                               name: NSNotification.Name(rawValue: NOTI_WS_RECONNECTED),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(wscontentChange),
                                               name: NSNotification.Name(rawValue: NOTI_WS_RECONNECTEDFALL),
                                               object: nil)
        
    }
    
    @objc func lanDownloadSuccess(){ //
//        print("lanDownloadSuccess")
        if let tab = TopVC()?.tabBarController as? TabbarController {
            tab.updateiconIfNeeded()
        }
        self.loginTabV.refreshTitles()
    }
    
    func reloadTabbarModules(){
        if let tab = TopVC()?.tabBarController as? TabbarController {
            tab.reloadTabbar()
        }
    }
    func onNetworkConnected() {
        if firstTime == false {
            if EXAppMarketManager.sharedInstance.hasLoaded() == false {
                self.showLottieLoadingView()
                getData()
            }
        }
    }
    
    
    ///Add socket data notification
    @objc private func subscribeTickers() {
        if EXHomeViewModel.isContractStatus() == false {
            return
        }
        //Received notification of successful interface return
        EXSwapSocketManager.shared.subscribeTickers()
        EXSwapSocketManager.shared.onwsEventCallback
            .subscribe(onNext: {[weak self] (event,datas,symbol) in
                guard let mySelf = self else { return }
                if event == .ticker {
                    let wsSymbol = EXMarketWsEvent.getTickerChannelSymbol(channel: datas.channel)
                    mySelf.updateNewCoHome(ticker: datas.tick, symbol: wsSymbol)
                    
                }
            }).disposed(by: self.disposeBag)
    }
    
    @objc private func wscontentChange(notification:NSNotification){
        if Thread.isMainThread {
            self.mainTable.reloadData()
        } else {
            DispatchQueue.main.async {
                self.mainTable.reloadData()
            }
        }
       
    }
    
    
    
    func tryGetReview(){
        EXMarketReqVm.shared().registerPubLicInfoSignal()
    }
    
    func homeBtnAction(_ enterBackground :Bool) {
        //Pay attention to the current controller
        guard let top = AppService.topViewController() else {return}
        if top == self {
            if enterBackground {
                //                mainView.timer?.fireDate = Date.distantFuture
                EXWebSocket.marketService.cancel()
            }else {
                //Todo Subscribing to Coin Pairs
                if firstTime == false {
                    getReadyToReload()
                    reloadHomePage()
                }
            }
        }
    }
}

//Update the list of price increases and decreases
extension EXHomepageVc {
    
    private func handleReuslts(results:Array<Any>,updateModel:EXRecommendList) {
        var updateIdx = -1
        homePageModel.home_recommend_list.enumerated().forEach { (idx,item) in
            if item.key == updateModel.key {
                updateIdx = idx
            }
        }
        if updateIdx >= 0 {
            if results.count > 0{
                var datas:[EXHomeTicker] = []
                for (idx,item) in results.enumerated() {
                    if let model = EXHomeTicker.mj_object(withKeyValues: item){
                        model.app_serial_number = idx + 1
                        datas.append(model)
                    }
                }
                if datas.count > 10 {
                    updateModel.list = datas.prefix(10).map { $0 }
                }else {
                    updateModel.list = datas
                }
                if updateModel.key == "deal" {
                    EXHomeWsDataVm.shared().rankingV2 = []
                }else {
                    if datas.count > 10 {
                        EXHomeWsDataVm.shared().rankingV2 = datas.prefix(10).map { $0 }
                    }else {
                        EXHomeWsDataVm.shared().rankingV2 = datas
                    }
                }

                if let rankingIdx = pages.firstIndex(of: .ranking) {
                    if let rankingContainerCell = self.mainTable.cellForRow(at: IndexPath.init(row: rankingIdx, section: 0)) as? EXRankingContainerCell {
                        rankingContainerCell.updateColumn(data: updateModel, pageIdx: updateIdx)
                    }
                }
            }
        }
    }
}

extension EXHomepageVc {
    
    func prepareWs() {
        EXMarketReqVm.destroy()
        EXHomeWsDataVm.shared().registerHomeCoinsV2()
        EXWebSocket.marketService.onwsEventCallback
            .subscribe(onNext: {[weak self] (event,datas,symbol) in
                guard let mySelf = self else { return }
                if event == .ticker {
                    mySelf.updateHomeTicker(ticker: datas.tick,symbol:symbol)
                }
                mySelf.mainTable.mj_header.endRefreshing()
            }).disposed(by: self.disposeBag)
    }
    
    func updateHomeTicker(ticker:EXTickerModel, symbol:String) {
        //Update recommended options
        tickerReceiver[symbol] = ticker
    }
    
    func handleTicker() {
        self.handleReceiver()
        self.tickerDisposeBag?.dispose()
        self.tickerDisposeBag = Observable<Int>.interval(.seconds(2), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (element) in
                guard let `self` = self else { return }
                self.handleReceiver()
            })
    }
    
    func handleReceiver() {
        let tickers = tickerReceiver
        self.tickerReceiver.removeAll()
        if tickers.count > 0 {
            //Update Model
            for (key,ticker) in tickers {
                //Refresh the homepage recommended currency pairs+price increase/decrease list
                updateRankIdx { (rankingCell) in
                    rankingCell.updateRankingItem(item: ticker, symbol:key)
                }
                
                updateRecommendIdx { (recommendCell) in
                    var updateItem:EXHomeTicker?
                    var updateIdx:Int = 0
                    let arr = homePageModel.header_symbol
                    for (idx,item) in arr.enumerated() {
                        if item.symbol == key {
                            item.updateModelWithTicker(ticker: ticker)
                            updateItem = item
                            updateIdx = idx
                            break
                        }
                    }
                    guard let update = updateItem else {return}
                    recommendCell.updateNewItem(homeTicker: update, idx: updateIdx)
                }
            }
        }
        self.mainTable.mj_header.endRefreshing()
    }
}

//MARK: lazy
extension EXHomepageVc {
    
    func prepareGuides () {
        //Update New Popup
        appApi.rx.request(.appHomeAd)
            .MJObjectMap(EXHomeAdModel.self)
            .subscribe(onSuccess: {[weak self] (model) in
                guard let mySelf = self else{return}
                mySelf.handleAdRst(newModel: model)
            }) {[weak self] (error) in
                guard let mySelf = self else{return}
                mySelf.configOtherShow()
        }.disposed(by: disposeBag)
    }
    
    func handleAdRst(newModel:EXHomeAdModel) {
        if let cacheHomeModel = EXAppCache.sharedCache.getHomeAdCache() {
            if EXHomeAdModel.isNeedShowToday(startTime: cacheHomeModel.startTimeInterval,
                                             endTime: cacheHomeModel.endTimeInterval,
                                             isLogin: cacheHomeModel.isLogin),
               adIsShow == false,
               EXHomeFirstDisplayView.needShow() == false
            {
                if let path = Self.adDownloader.cache.filePath(url: cacheHomeModel.picturePath) {
                    if let icon = UIImage.init(contentsOfFile: path) {
                        if EXAlert.isCurrentlyDisplaying() {
                            return
                        }
                        if cacheHomeModel.isLogin == "2" || cacheHomeModel.isLogin == "3" {
                            EXAppCache.sharedCache.setAppAdShowTime()
                        }
                        let alert = EXStartAdAlert()
                        alert.adImageView.image = icon
                        alert.bindHref(ahref: cacheHomeModel.pictureUrl)
                        EXAlert.showAlert(alertView: alert)
                        alert.clickAdCallback = {[weak self] href in
                            self?.gotoAdWebVc(str: href,title: cacheHomeModel.activityTitle)
                        }
                        adIsShow = true
                    }
                }else {
                    configOtherShow()
                }
            }else {
                configOtherShow()
            }
        }else {
            configOtherShow()
            navView.configUserBtn()
        }
        self.saveAdCache(model: newModel)
    }
    
    func saveAdCache(model:EXHomeAdModel) {
        Self.adDownloader.totalCancel()
        Self.adDownloader.download(model.picturePath)
        EXAppCache.sharedCache.updateHomeAdCache(model: model)
    }
    
    func configOtherShow() {
        if EXHomeFirstDisplayView.needShow() {
            EXHomeFirstDisplayView.show()
        }
    }
    
    func gotoAdWebVc(str:String,title:String) {
        let web = WebVC()
        web.customTitle = title
        web.loadUrl(str)
        self.navigationController?.pushViewController(web, animated: true)
    }
}

extension EXHomepageVc {
    
    func configContract(){
        if EXAppConfigManager.sharedInstance.didOpenContract() {
            ///重链接
            _ = NotificationCenter.default.rx
                .notification(Notification.Name(rawValue: NOTI_CONCTRACT_WS_RECONNECTED))
                .take(until: self.rx.deallocated) //页面销毁自动移除通知监听
                .subscribe(onNext: {[weak self] noti in
                    //获取全量数据
                     EXContractMarketReqVm.shared().registerPubLicInfoSignal()
                })
            
            EXContractMarketReqVm.shared().registerPubLicInfoSignal()
            EXContractNetwork.querySymboRatelist { SymbolRate in
                EXSwapPublicInfo.shared.symboRate = SymbolRate
//                print("EXSwapPublicInfo.shared.symboRate =\(EXSwapPublicInfo.shared.symboRate)")
            } failure: { err in
                
            }
        }
    }
    func trackActionOn() {
        print("Record Start Time ->")

//        NSObject.cancelPreviousPerformRequests(withTarget: self, selector:#selector( ), object: nil)
        self.perform(#selector(handleInterfaceData), with: nil, afterDelay: 3)
    }
    
    @objc func handleInterfaceData() {
        if  self.defineCurrentVcIsTopVc() == false {
            return
        }
        
        updateRankIdx { (rankingCell) in
            let interfaceData:EXInterfaceData = EXInterfaceData.init(page: .home, action: .httpHome)
            var duration = ""
            var errorType = "0"
            if let begin = self.track_begin,let end = self.track_end {
                let interval = end.timeIntervalSince(begin)
                let millisecond = CLongLong(round(interval*1000))
                duration = "\(millisecond)"
            }
            if rankingCell.isLoadBeforeMarket() {
                errorType = "5"
            }else {
                if rankingCell.isEmptyUI() {
                    if rankingCell.isEmptyData(){
                        errorType = "4"
                    } else {
                        errorType = "3"
                    }
                }
            }

            interfaceData.errorType = errorType
            interfaceData.duration = duration
            EXTracking.shared.uploadInterFaceData(model: interfaceData)
        }
    }
    
    
    
    func refreshLogTabView(){
        if XUserDefault.isOffLine() == true{
            return
        }
        self.loginTabV.refreshTitles()
    }
}
//MARK:  scan
extension EXHomepageVc {
    func configViewAndData(){
        EXTracking.shared.trackFirebase(firebaseKey: FirebaseKey.HomePageview)
        if !EXHomeViewModel.isContractStatus() {
            prepareWs()
        }
//Print ("homepage viewdidload")
        configNoti()
        EXCustomConfigVm.shared().registerCustomConfig()
        EXMarketReqVm.shared().registerPubLicInfoSignal()
      
        
        registerCells()
        self.mainTable.backgroundColor =  UIColor.ThemeNav.bg//UIColor.ThemeView.bg
        if #available(iOS 11.0, *) {
            mainTable.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.mainTable.separatorStyle = .none
        self.view.addSubViews([self.mainTable,self.navView])
        handleNavigation()
        registerHomeAlert()
        if XUserDefault.isOffLine() == false {
            UserInfoEntity.sharedInstance().getUserInfo {} _: {}
        }
        configLoading()
        configContract()
    }
    
    
    func registerHomeAlert() {

        //If the red envelope button is turned on
        if EXAppConfigManager.sharedInstance.didOpenRedPack() {
            self.redPacketBtn.show(self.view)
            self.bringHomeSkeletonToFront(view: view)
        }else{//If the red envelope button is turned off
            self.redPacketBtn.dismiss()
        }
    }
   
    func registerCells() {
        self.mainTable.register(EXSeperatorCell.self)//Division line
        self.mainTable.register(EXBannerCell.self)//banner
        self.mainTable.register(EXNoticeCell.self)//announcement
        self.mainTable.register(EXHomeSudokuCell.self)//functional module
        self.mainTable.register(EXNoLoginAccountCell.self)//Not logged in
        self.mainTable.register(EXLoginAccountCell.self)//Account module
        self.mainTable.register(EXRankingContainerCell.self)//Price List
        self.mainTable.register(EXHomeNominateCell.self)//Recommended currency pair
        self.mainTable.register(EXHomeSubBannerCell.self)//Deputy banner
        self.mainTable.register(EXDoubleBannerCell.self)//Deputy Banner, 2
        self.mainTable.register(EXJapanAccountCell.self)//Japanese version login module
        self.mainTable.register(EXOneByTwoCell.self)//International version functional module
    }
    
    func handleNavigation() {
        self.handleViewConstraint(useTransparent: false)
    }
    
    func handleViewConstraint(useTransparent:Bool) {

        mainTable.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: useTransparent ? 0 : NAV_SCREEN_HEIGHT, left: 0, bottom: 0, right: 0))
        }
        
        navView.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.right.equalToSuperview()
            make.height.equalTo(NAV_SCREEN_HEIGHT)
        }
        self.mainTable
            .rx
            .contentOffset
            .subscribe {[weak self] in
                if let contentOffset = $0.element {
                    let y = contentOffset.y
                    let poor = y - EXHomePageHeightHelper.bannerH / 2
                    if poor > 0{
                        self?.navView.seperator.alpha = (poor / (EXHomePageHeightHelper.bannerH / 2 - NAV_SCREEN_HEIGHT))
                    }else{
                        self?.navView.seperator.alpha = 0
                    }
                }
            }.disposed(by: disposeBag)
    }
    
   
    
    
    
    
}

//MARK:  Scan
extension EXHomepageVc {
    
    func handleScanedRst(rst:String) {
        if XUserDefault.isOffLine() {
            BusinessTools.modalLoginVC()
            return
        }
        if rst.isEmpty {
            EXCustomToast.showMsg(msg: "scan_fail_erro".localized())
            return
        }
        self.fetchLoginInfo(rst: rst)
    }
    
    func fetchLoginInfo(rst:String) {
        appApi.rx.request(.getIpByCode(qrid: rst))
            .MJObjectMap(EXQRLoginModel.self)
            .subscribe(onSuccess: {[weak self] (model) in
                guard let mySelf = self else{return}
                mySelf.toWebLogin(model: model,qrId: rst)
            }) { (error) in
        }.disposed(by: disposeBag)
    }
    
    func toWebLogin(model:EXQRLoginModel,qrId:String) {
        let loginVC = EXWebLoginVC()
        loginVC.qrID = qrId
        loginVC.infoBg.ipValueLabel.text = model.ipAddress
        loginVC.infoBg.deviceValueLabel.text = model.equipment
        let pvc = EXPresentContainer.init(contentVC: loginVC,closeBtnR: true)
        pvc.modalPresentationStyle = .fullScreen
        self.navigationController?.present(pvc, animated: true)
    }
}
//MARK:  Action
extension EXHomepageVc {
    
    @objc func clickSearch() {
        EXTracking.shared.trackFirebase(firebaseKey: FirebaseKey.Home_Search_click)
        EXNavigationHandler.sharedHandler.commonJumpCommand(EXRouterActionKey.appSearch.rawValue)
    }
    @objc func clickQrBtn() {
        
        if XUserDefault.getToken() == nil{
            BusinessTools.modalLoginVC()
            return
        }
        LBXPermissions.authorizeCameraWith { [weak self] result in
            
            if result == true{
                let vc = EXScanVc()
                vc.tipLabel.text = "scan_tip_aimToScan".localized()
                vc.onScanResultCallback = {[weak self] backstr in
                    self?.handleScanedRst(rst: backstr)
                }
//                vc.albumFailedResultCallback = { [weak self] in
//                    EXCameraAlert.popAuthAlert(album: true)
//                }
                self?.navigationController?.pushViewController(vc, animated: true)
            }else{
                
                EXCameraAlert.popAuthAlert()
            }
        }
    }
    
    func moreKingkongAction() {
        let sheet = EXHomeMenuSheet()
        sheet.bindSudokus(self.homePageModel.cmsAppDataList)
        sheet.menuItemCallback = {[weak self] item in
            self?.menuAction(item: item)
        }
        EXAlert.showSheet(sheetView: sheet)
    }
    
    func menuAction(item:CmsAppDataItem) {
        HomeGOTO().gotoVC(self, tnativeUrl: item.nativeUrl, httpUrl: item.fmtUrl(),title:item.title)
    }
}

//MARK: requesting
extension EXHomepageVc{
    
    func getData(){
      
        DispatchQueue.global().async(execute: {[weak self] in
            guard self != nil else { return }
            EXAppConfigManager.sharedInstance.fetchAppConfig()
         })
             
        DispatchQueue.global().async(execute: {[weak self] in
            guard self != nil else { return }
            EXAppMarketManager.sharedInstance.fetchMarket()
            
         })
    }
    
//     func reloadHomePageFromCaches(){
//         viewModel.fetchHomeCachesPageViewModels()
//             .subscribe(onNext:{[weak self] homevm in
//                 if EXHomeViewModel.isContractStatus() {
//                     self?.handleContractHomeData(homevm)
//                 }else {
//                     self?.handleHomeData(homevm)
//                 }
//             },onError: {  [weak self] _ in
//             }).disposed(by: disposeBag)
//     }
    
     func reloadHomePage() {
         if EXHomeViewModel.isContractStatus() == false{
             track_begin = Date()
             track_end = nil
         }
         viewModel.fetchHomePageViewModels()
             .subscribe(onNext:{[weak self] homevm in
                 if EXHomeViewModel.isContractStatus() {
                     self?.handleContractHomeData(homevm)
                 }else {
                     self?.handleHomeData(homevm)
                 }
             },onError: {  [weak self] _ in
             }, onDisposed: { [weak self] in
                 self?.removeHomeSketelon()
             }).disposed(by: disposeBag)
     }
    
    func getNoRead(){
        appApi.hideAutoLoading()
        appApi.rx.request(AppAPIEndPoint.getNoReadMessageCount)
            .MJObjectMap(EXNoReadEntity.self)
            .subscribe(onSuccess: {[weak self] (entity) in
                guard let mySelf = self else{return}
                let count = entity.noReadMsgCount
                mySelf.navView.showMessageRedDot(show: count != "0")
            }) { (error) in
                
            }.disposed(by: disposeBag)
    }
    
}
//MARK: dataHandle
extension EXHomepageVc{
    func handleContractHomeData(_ vm:EXHomePageViewModel) {
        self.pages = vm.getRowDataTypes()
        EXAppMarketManager.sharedInstance.recommendCoins = vm.homePageModel.header_symbol
        
        if self.homePageModel.home_recommend_list.isEmpty {
            self.homePageModel = vm.homePageModel
        }
        self.mainTable.reloadData()
    }
    
    func handleHomeData(_ vm:EXHomePageViewModel) {
        self.pages = vm.getRowDataTypes()
        EXAppMarketManager.sharedInstance.recommendCoins = vm.homePageModel.header_symbol
        
        self.homePageModel = vm.homePageModel
        
        EXHomeWsDataVm.shared().recommendedV2 = vm.homePageModel.header_symbol
        if homePageModel.home_recommend_list.count > 0 {
            if EXHomeViewModel.isContractStatus() == false{
                if self.track_end == nil {
                    self.track_end = Date()
                }
            }
            
            let model = homePageModel.home_recommend_list[0]
            if model.key != "deal" {
                EXHomeWsDataVm.shared().rankingV2 = model.list
            }
        }
        self.mainTable.reloadData()
    }
    
    func updateRankIdx(closure:(_ rankingCell:EXRankingContainerCell) -> ()) {
        
        if let rankingIdx = pages.firstIndex(of: .ranking) {
            if let rankingCell = self.mainTable.cellForRow(at: IndexPath.init(row: rankingIdx, section: 0)) as? EXRankingContainerCell {
                
               closure(rankingCell)
            }
        }
    }
    
    func updateRecommendIdx(closure:(_ rankingCell:EXHomeNominateCell) -> ()) {
        
        if let recommendIdx = pages.firstIndex(of: .recommend) {
            if let recommendCell = self.mainTable.cellForRow(at: IndexPath.init(row: recommendIdx, section: 0)) as? EXHomeNominateCell {
               closure(recommendCell)
            }
        }
    }
    
    func updateNewCoHome(ticker:EXCOTickerModel, symbol:String) {
        let tick = EXTickerModel.getNewInstanceFromModel(tick: ticker)
        var coID:Int64 = 0
        for recommend in homePageModel.home_recommend_list {
            for item in recommend.list {
                if  symbol == item.symbol {
                    coID = item.contract_id
                    item.updateModelWithTicker(ticker: tick)
                    break;
                }
            }
        }
        updateRankIdx { (rankingCell) in
            rankingCell.updateRankingItem(contract_id: coID)
        }
    }
    
    func reloadHomeWhenLanChange(){
        self.reloadHomePage()
        self.loginTabV.refreshTitles()
        self.navView.reloadLan()
    }
}


// MARK: -congfigure loading
extension EXHomepageVc {
    
    fileprivate func showLottieLoadingView() {
        guard (EXHomeCache.sharedManager.getHomeCache() != nil) else {
            return
        }
        self.showLoading()
    }
}
    


// MARK: add/remove skeleton
extension EXHomepageVc {
    
    private func addHomeSketelon() {
        guard EXHomeCache.sharedManager.getHomeCache() == nil else { return }
        guard homeSkeleton.superview == nil else { return }
        view.addSubview(homeSkeleton)
        view.bringSubviewToFront(homeSkeleton)
        homeSkeleton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    private func removeHomeSketelon(with completion: (() -> Void)? = nil) {
        guard homeSkeleton.superview != nil else { return }
        UIView.animate(withDuration: 0.25) {
            self.homeSkeleton.alpha = 0.0
        } completion: { _ in
            self.homeSkeleton.removeFromSuperview()
            self.homeSkeleton.alpha = 1.0
        }
    }
    
    private func bringHomeSkeletonToFront(view: UIView) {
        guard homeSkeleton.superview != nil else { return }
        guard !homeSkeleton.isHidden else { return }
        self.view.insertSubview(view, belowSubview: homeSkeleton)
    }
}
