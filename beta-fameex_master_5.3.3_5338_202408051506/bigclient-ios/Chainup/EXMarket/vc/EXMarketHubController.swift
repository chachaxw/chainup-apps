//
//  EXMarketHubController.swift
//  Chainup
//
//  Created by liuxuan on 2023/9/21.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import EXKit
import JXSegmentedView
import Swap
enum EXMarketSegmentType:Int {
    case customZone = 0
    case exchange
    case coExchange
}

let segmentHeight:CGFloat = 44
let segmentOffset:CGFloat = 0
let bibiViewDidAppear = "bibiViewDidAppear"
class EXMarketHubController: BaseVC,NavigationPlugin {
    
    var vcData:[UIViewController] = []
    var rowDatas:[EXMarketSegmentType] = []
    var segmentTitles:[String] = []
    var currentIdx:Int = 0
    let segmentedView = JXSegmentedView()

    lazy var searchBar: EXSearchBarView = {
        let v = EXSearchBarView()
        v.canSearch = false
        v.placeHolder = "market_search_ex".localized()
        return v
    }()
    
    
    lazy var listContainerView: JXSegmentedListContainerView! = {
        return JXSegmentedListContainerView(dataSource: self)
    }()
    
    lazy var segmentedDataSource: EKIndicatorSegmentDatasource = {
        let source = EKIndicatorSegmentDatasource()
        source.titles = ["search_topSearch_title".localized()]
        return source
    }()
    
    lazy var indicatorLienView: EKIndicatorSegmentIndicator = {
        let view = EKIndicatorSegmentIndicator()
        return view
    }()
    
    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: nil, presenter: self,customHandleBack: true)
        return nav
    }()
    
    lazy var editBtn : UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor.ThemeLabel.colorLite, for: .normal)
        btn.addTarget(self, action: #selector(editClick), for: UIControl.Event.touchUpInside)
        btn.setImage(UIImage.themeImageNamed(imageName: "quotes_optional"), for: .normal)
        return btn
    }()
    
    func configNavi() {
        navigation.setCustomView(searchBar)
        navigation.backgroundColor = .ThemeNav.bg
        navigation.backView.backgroundColor = .ThemeNav.bg
        searchBar.snp.remakeConstraints { make in
            make.bottom.equalToSuperview().offset(-6)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(32)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.ThemeNav.bg
        handleNotifi()
        configNavi()
        checkReqData()
        if EXAppConfigManager.sharedInstance.didOpenContract(){
            rowDatas = [.customZone,.exchange,.coExchange]
            segmentTitles = ["market_text_customZone".localized(),
                             "mainTab_text_transaction".localized(),
                             "mainTab_text_contract".localized()]
        }else {
            rowDatas = [.customZone,.exchange]
            segmentTitles = ["market_text_customZone".localized(),
                             "mainTab_text_transaction".localized()]
        }
        segmentedDataSource.titles = segmentTitles
        self.segmentedView.dataSource = segmentedDataSource
        self.segmentedView.indicators = [self.indicatorLienView]
        self.segmentedView.delegate = self
        self.segmentedView.backgroundColor = .clear
        self.segmentedView.frame = CGRect(x: 0, y: NAV_SCREEN_HEIGHT + segmentOffset, width: SCREEN_WIDTH, height: 44)
        self.view.addSubview(self.segmentedView)
        self.view.addSubview(self.listContainerView)
        let y =  (self.segmentedView.frame.maxY)
        //Contract not opened - add edit option button on the right side of segmetn
        if !EXAppConfigManager.sharedInstance.didOpenContract(){
            self.segmentedView.width -= 45
            self.view.addSubview(editBtn)
            editBtn.snp.makeConstraints { make in
                make.right.equalToSuperview().offset(-20)
                make.width.equalTo(20)
                make.height.equalTo(20)
                make.centerY.equalTo(self.segmentedView)
            }
        }
        
    
        self.listContainerView.frame = CGRect(x: 0, y:y, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - TABBAR_HEIGHT - y)
        segmentedView.listContainer = self.listContainerView
        self.listContainerView.roundCorners(corners: [.topLeft,.topRight], radius: 20)
        
        if XUserDefault.getCollectionCoinMap().count == 0 {
            currentIdx = 1
            self.segmentedView.defaultSelectedIndex = 1
        }
        
        self.searchBar.jumpCallBack = { isContract in
            if isContract {
                EXNavigationHandler.sharedHandler.commonJumpCommand(EXRouterActionKey.appSearch.rawValue,"contract")
            }else{
                EXNavigationHandler.sharedHandler.commonJumpCommand(EXRouterActionKey.appSearch.rawValue)
            }
        }
        
        EXWebSocket.marketService.onwsEventCallback
            .subscribe(onNext: {[weak self] (event,datas,symbol) in
                guard let mySelf = self else { return }
                if event == .ticker {
                    mySelf.handleMarketWsData(datas: datas, symbol: symbol)
                }
            }).disposed(by: self.disposeBag)
        
        
        configContract()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        EXTracking.shared.trackPage(name: .market, isEnter:true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        EXTracking.shared.trackPage(name: .market, isEnter:false)
        EXWebSocket.marketService.cancel()
    }
    func checkReqData() {
        if EXMarketReqVm.shared().wsReviewData.isEmpty {
            EXMarketReqVm.shared().retryFetchReqV2()
        }
    }
    @objc func editClick(){
        let v = EXEditFavoriteContainer()
        self.navigationController?.pushViewController(v, animated: true)
    }
    func handleNotifi() {
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
       
        _ = NotificationCenter.default.rx
            .notification(Notification.Name(rawValue: bibiViewDidAppear))
            .takeUntil(self.rx.deallocated) //Page destruction automatic removal notification listening
            .subscribe(onNext: {[weak self] noti in
               // let obj = ["cell": cell]
                if let dic = noti.object as? [String : UIView]{
                    let view = dic["cell"]
                    self?.prepareGuides(view: view)
                }
            })
        
    }
    
    func homeBtnAction(_ enterBackground :Bool) {
        //Pay attention to the current controller
        guard let top = AppService.topViewController() else {return}
        if top == self {
            if enterBackground {
                EXWebSocket.marketService.cancel()
            }else {
                if currentIdx == 0 {
                    for vc in vcData {
                        if vc is EXFavoritesContainerVC {
                            let topvc = vc as! EXFavoritesContainerVC
                            topvc.listContainerReloadData()
                        }
                    }
                }else if currentIdx == 1 {
                    for vc in vcData {
                        if vc is EXMarketListContainer {
                            let topvc = vc as! EXMarketListContainer
                            topvc.listContainerReloadData()
                        }
                    }
                }
            }
        }
    }
}
extension EXMarketHubController{
    func configContract(){
        if EXAppConfigManager.sharedInstance.didOpenContract() {
            ///重链接
            _ = NotificationCenter.default.rx
                .notification(Notification.Name(rawValue: NOTI_CONCTRACT_WS_RECONNECTED))
                .take(until: self.rx.deallocated) //页面销毁自动移除通知监听
                .subscribe(onNext: {[weak self] noti in
                    //获取全量数据
                     EXContractMarketReqVm.shared().registerPubLicInfoSignal()
                     EXSwapSocketManager.shared.subscribeTickers()
                })
            EXContractMarketReqVm.shared().registerPubLicInfoSignal()
            EXContractNetwork.querySymboRatelist { SymbolRate in
                EXSwapPublicInfo.shared.symboRate = SymbolRate
//                print("EXSwapPublicInfo.shared.symboRate =\(EXSwapPublicInfo.shared.symboRate)")
            } failure: { err in
                
            }
            EXContractNetwork.getUserConfig()
        }
    }
    func handleMarketWsData(datas:EXMarketWsModel,symbol:String) {
        //The order of vcdata is dynamically added during the stroke, not sequentially
        if currentIdx == 0 {
            for vc in vcData {
                if vc is EXFavoritesContainerVC {
                    let topvc = vc as! EXFavoritesContainerVC
                    topvc.distributeTicker(datas, symbol: symbol)
                }
            }
        }else if currentIdx == 1 {
            for vc in vcData {
                if vc is EXMarketListContainer {
                    let topvc = vc as! EXMarketListContainer
                    topvc.distributeTicker(datas, symbol: symbol)
                }
            }
        }
    }
}

extension EXMarketHubController:JXSegmentedViewDelegate {
    
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        self.currentIdx = index
        if EXAppConfigManager.sharedInstance.didOpenContract(){
            searchBar.toContract = false
            if index == self.rowDatas.count - 1 {
                searchBar.toContract = true
            }
        }
    }
}

extension EXMarketHubController : EXTradeCmdProtocal {
    
    func excuteCmd(symbol: String, action: String) {
        //TODO: Positioning to go market
        let index = EXMarketSegmentType.exchange.rawValue
        if index < segmentTitles.count ,vcData.count > index {
            self.segmentedView.selectItemAt(index: index)
            if let vc = vcData[index] as? EXTradeCmdProtocal {
                vc.excuteCmd(symbol: symbol, action: action)
            }
        }
    }
}


extension EXMarketHubController  {
    func prepareGuides(view: UIView?) {
        if EXAppCache.sharedCache.getAppGuideFirstShow(byType: .market){
            var guides = [PopGuideItem]()
            if view != nil{
                let itemPop = PopGuideItem()
                itemPop.title = "guide_1".localized()
                itemPop.subTitle = "guide_3".localized()
                itemPop.tilteFont = UIFont.ThemeFont.BodyBold
                itemPop.subtitleFont = UIFont.ThemeFont.SecondaryBold
                itemPop.popoverType = .up
                itemPop.formView = view
                guides.append(itemPop)
            }
            
            if EXAppConfigManager.sharedInstance.didOpenContract(){ //Contract guidance
                let collection = self.segmentedView.collectionView
                let index = IndexPath(item:rowDatas.count - 1, section: 0)
                let lastCell = collection?.cellForItem(at: index)
                if lastCell != nil {
                    let itemPop = PopGuideItem()
                    itemPop.title = "guide_2".localized()
                    itemPop.subTitle = "guide_3".localized()
                    itemPop.tilteFont = UIFont.ThemeFont.BodyBold
                    itemPop.subtitleFont = UIFont.ThemeFont.SecondaryBold
                    itemPop.popoverType = .down
                    itemPop.formView = lastCell
                    guides.append(itemPop)
                }
            }
            let m = EXPopGuidManger.shared
            m.guideItems = guides
            m.strartPop()
            m.finshCallBack = { [weak self] in
//                print("End")
                EXAppCache.sharedCache.setAppGuideDidShow(byType: .market)
            }
            
        }
    }
}


extension EXMarketHubController: JXSegmentedListContainerViewDataSource {
    
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        let type = rowDatas[index]
        switch type {
        case .exchange:
            let vc = EXMarketListContainer()
            vcData.append(vc)
            return vc
        case .customZone:
            let vc = EXFavoritesContainerVC()
            vcData.append(vc)
            return vc
        case .coExchange:
            let vc = EXCoMarketListContainer()
            vcData.append(vc)
            return vc
        }
    }
}


