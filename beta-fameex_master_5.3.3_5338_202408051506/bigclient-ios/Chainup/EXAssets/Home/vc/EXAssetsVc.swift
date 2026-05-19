//
//  EXAssetsVc.swift
//  Chainup
//
//  Created by wangdong on 2023/9/7.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import JXPagingView
import JXSegmentedView
import SnapKit
import EXKit
import Swap
class EXAssetsVc: BaseVC {
    
    var assetModels:[EXCommonAssetModel] = []
    var assetType:EXAccountType?
    let segmentedHeight: CGFloat = 44.0
    let safeAdviseViewHeight: CGFloat = 40.0
    let tableHeaderViewHeight: CGFloat = 121.0
    let canBackTableHeaderViewHeight: CGFloat = 141.0
    private var selectIndex = 0
    
    lazy var assetSketelon: EXSkeletonAssetsViewFive = {
        let v = EXSkeletonAssetsViewFive()
        v.header.gradient.colors = [UIColor.Ex.main2, UIColor.Ex.main1]
        return v
    }()
    
    lazy var pagingView: JXPagingListRefreshView = {
        let view = JXPagingListRefreshView.init(delegate: self)
        view.pinSectionHeaderVerticalOffset = 85 - Int(self.navOffset())
        if EXAppConfigManager.sharedInstance.getSupportAccounts().count <= 1 {
            view.pinSectionHeaderVerticalOffset = 0
        }
        view.listContainerView.listCellBackgroundColor = UIColor.ThemeView.bg
        return view
    }()
    
    lazy var segmentedView: JXSegmentedView = {
        let view = JXSegmentedView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: self.segmentedHeight))
        view.delegate = self
        view.contentEdgeInsetLeft = 24
        view.contentEdgeInsetRight = 24
        return view
    }()
    
    lazy var segmentedDataSource: JXSegmentedTitleDataSource = {
        let source = JXSegmentedTitleDataSource()
        source.itemSpacing = 0
        source.titleNormalColor = UIColor.white.withAlphaComponent(0.5)
        source.titleSelectedColor = UIColor.white
        source.titleNormalFont = UIFont.ThemeFont.BodyMedium
        source.titleSelectedFont = UIFont.ThemeFont.BodyMedium
//        if EXAppConfigManager.sharedInstance.getSupportAccounts().count <= 1 {
//            source.itemSpacing = 20
//        }
        return source
    }()
    
    lazy var indicatorLienView: JXSegmentedIndicatorLineView = {
        let view = JXSegmentedIndicatorLineView()
        view.indicatorWidth = 20
        view.indicatorColor = UIColor.white
        view.indicatorHeight = 2
        view.indicatorCornerRadius = 0
        return view
    }()
    
    lazy var assetsHeaderView: EXAssetsHeaherView = {
        let view = EXAssetsHeaherView()
        return view
    }()
    
    lazy var gradientBackgroundView: UIView = {
        let height = self.isFirstController() ? (CGFloat(self.pinSectionHeight()) +
            self.tableHeaderViewHeight) : (CGFloat(self.pinSectionHeight()) + self.canBackTableHeaderViewHeight) - navOffset()
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: height))
        view.backgroundColor =  .Ex.main1
        return view
    }()
    
    lazy var segmentdContainerView: UIView = {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 90))
        return view
    }()
    
    lazy var safeView: UIView = {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50))
        view.backgroundColor = UIColor.ThemeView.bgTab
        return view
    }()
    
    var controllers: Array<JXPagingViewListViewDelegate> = []
    
    lazy var coinAsset: EXAssetsListContentVc = {
        return EXAssetsListContentVc.instanceFromStoryboard(name: StoryBoardNameAsset)
    }()
    
//    lazy var swapAsset: SLSwapAssetListVc = {
//        return SLSwapAssetListVc.instanceFromStoryboard(name: StoryBoardNameAsset)
//    }()
    lazy var newSwapAsset: EXSwapAssetListVC = {
        let vc = EXSwapAssetListVC()
        vc.actionBlock = { [weak self] in
            guard let newSelf = self else{
                return
            }
            newSelf.swapToTransfer()
        }
        vc.openContactBlock =  { [weak self] in
            guard let newSelf = self else{
                return
            }
            newSelf.gotoOpenContract()
        }
        vc.accountBlaceCallBlock = { [weak self] in
            guard let newSelf = self else{
                return
            }
            newSelf.getContractAccountBlance()
        }
        vc.openContractAlertCallBack = { [weak self] in
            guard let self else { return }
            
            EXLogger.debug(message: "topvc = \(TopVC())")
            guard let topvc = TopVC(),topvc.isKind(of: EXAssetsVc.self) else {
                return
            }
            let curretV = self.controllers[selectIndex]
            EXLogger.debug(message: "selectIndex = \(selectIndex) curretV = \(curretV)")
            
            if curretV.isKind(of: EXSwapAssetListVC.self){
                if let selectedVC = curretV as? EXSwapAssetListVC {
                    selectedVC.openContractAlert()
                }
                
            }
            
//            if let vc = TopVC(){
//                if vc.isKind(of: EXAssetsVc.self){
//                    if let v = vc as? EXAssetsVc {
//                        let curretV = v.controllers[selectIndex]
//                        EXLogger.debug(message: "curretV = \(curretV)")
//                        
//                        if curretV.isKind(of: EXSwapAssetListVC.self){
//                            if let selectedVC = curretV as? EXSwapAssetListVC {
//                                selectedVC.openContractAlert()
//                            }
//                            
//                        }
//                    }
//                }
//            }
        }
        return vc
    }()
    lazy var otcAsset: EXOTCAssetsListVc = {
        return EXOTCAssetsListVc.instanceFromStoryboard(name: StoryBoardNameAsset)
    }()
    
    lazy var leverageAssett: EXLeverageAssetsListVc = {
        return EXLeverageAssetsListVc.init(nibName: "EXLeverageAssetsListVc", bundle: nil)
    }()
    
    lazy var backButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage.exs_themeImageNamed(imageName:"public_return"), for: .normal)
        button.setEnlargeEdgeWithTop(20, left: 10, bottom: 20, right: 20)
        return button
    }()
    
    lazy var navTitleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect.zero)
        label.text = "mainTab_text_assets".localized()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.alpha = 0.0
        label.textColor = UIColor.ThemeLabel.white
        return label
    }()
    
    var hiddenSafeView = false
    
    var segmentedTitles: Array<String> = []
    
    func navOffset() -> CGFloat {
        if isiPhoneX {
            return 0
        }
        else {
            return 24.0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        prepareGuides()
        EXAuthenticManagerTool.getUserKysRight(symbol: nil) { _ in
           
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleNoti()
        configChilds()
        
        pagingView.mainTableView.backgroundColor = UIColor.clear
        
        segmentedDataSource.titles = segmentedTitles
        segmentedView.dataSource = segmentedDataSource
        segmentedView.indicators = [indicatorLienView]
        
        view.addSubview(gradientBackgroundView)
        view.addSubview(pagingView)
        
        segmentedView.backgroundColor = UIColor.clear
        assetsHeaderView.containerView.backgroundColor = UIColor.clear
        
        segmentedView.listContainer = pagingView.listContainerView
        
        pagingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        if assetModels.count > 1 {
            segmentdContainerView.addSubview(segmentedView)
            if XUserDefault.safetyAdviceIsOff() {
                hiddenSafeView = true
                var frame = segmentdContainerView.frame
                frame.size.height = segmentedHeight
                segmentdContainerView.frame = frame
            }
            else {
                createSafeView()
            }
        }
        
        assetsHeaderView.eyesButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.privacyBtnAction()
            self?.assetsHeaderView.updatePrivacy()
        }).disposed(by: self.disposeBag)
        
        updateAssets()
        configPrivacy()
        
        if !self.isFirstController() {
            view.addSubview(backButton)
            backButton.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(15.0)
                make.top.equalToSuperview().offset(NAV_STATUS_HEIGHT + 10)
            }
            backButton.rx.tap.subscribe(onNext: { [weak self] in
                guard let self = `self` else { return }
                self.navigationController?.popViewController(animated: true)
            }).disposed(by: self.disposeBag)
        }
        
        view.addSubview(navTitleLabel)
        navTitleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(NAV_STATUS_HEIGHT + 10)
        }
        
        addAssetsSketelon()
    }
    
    func handleNoti() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(loginSuccess),
                                               name: NSNotification.Name(rawValue: "EXLoginSuccess"),
                                               object: nil)
    }
    
    @objc func loginSuccess() {
        if controllers.count > selectIndex {
            if let vc = controllers[selectIndex] as? EXAssetsListContentVc {
                vc.requestBalalance()
            }
        }
    }
    
    
    func privacyBtnAction() {
        if XUserDefault.assetPrivacyIsOn() {
            XUserDefault.switchAssets(false)
            EXStoreData.switchAssets(false)
        }else {
            XUserDefault.switchAssets(true)
            EXStoreData.switchAssets(true)
        }
        updateContainersPrivacy()
        configPrivacy()
    }
    
    func configPrivacy(){
        if XUserDefault.assetPrivacyIsOn() {
            assetsHeaderView.eyesButton.setImage(UIImage.themeImageNamed(imageName: "assets_Invisible"), for: .normal)
        }else {
            assetsHeaderView.eyesButton.setImage(UIImage.themeImageNamed(imageName: "assets_visible"), for: .normal)
        }
    }
    
    func updateContainersPrivacy() {
        for controller in controllers {
            if let vc = controller as? EXAssetBaseVc {
                vc.updatePrivacy()
            }
            if let vc = controller as? EXSwapAssetListVC{
                vc.updatePrivacy()
            }
        }
    }
    //Contract transfer - related transfers
    func swapToTransfer(){
        let transfer = EXAccountTransferVc.instanceFromStoryboard(name: StoryBoardNameAsset)
        transfer.transferFlow = .contractToExchagne
        transfer.onTrasferSuccessCallback = { [weak self] (ftype,ttype) in
//            self?.updateBalance(ftype)
//            self?.updateBalance(ttype)
        }
        self.navigationController?.pushViewController(transfer, animated: true)
    }
    
    func gotoOpenContract(){
        if let idx = EXAppConfigManager.sharedInstance.appModules.firstIndex(of: .contract) {
            self.cyl_popSelectTabBarChildViewController(at:UInt(idx))
        }
    }
    
    
    func createSafeView() {
        segmentdContainerView.addSubview(safeView)
        let safeImage =  UIImage.svgImage(named: "assets_warning", version: .five)
        let safeImageView = UIImageView.init(image: safeImage)
        safeView.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(segmentedHeight)
            maker.left.right.bottom.equalToSuperview()
        }
        
        safeView.addSubview(safeImageView)
        
        let safeLabel = UILabel.init(frame: CGRect.zero)
        safeLabel.textColor = UIColor.Ex.main1
        safeLabel.text = "assets_security_advice".localized()
        safeLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        safeView.addSubview(safeLabel)
        
        let safeButton = UIButton.init(type: .custom)
        
        safeView.addSubview(safeButton)
        
        safeImageView.snp.makeConstraints { maker in
            maker.centerY.equalToSuperview()
            maker.left.equalToSuperview().offset(15)
            maker.width.height.equalTo(15)
        }
        
        safeLabel.snp.makeConstraints { maker in
            maker.left.equalTo(safeImageView.snp.right).offset(8)
            maker.centerY.equalToSuperview()
        }
        
        let viewSafeButton = UIButton.init(type: .custom)
        viewSafeButton.setTitle("otc_text_adLook".localized(), for: .normal)
        viewSafeButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        viewSafeButton.setTitleColor(UIColor.Ex.main1, for: .normal)
        viewSafeButton.rx.tap.subscribe(onNext: { [weak self] _ in
            let alert = EXSafetyAdviceAlert()
            alert.didClose = { selected in
                if selected {
                    self?.hideSafeView()
                }
            }
            EXAlert.showAlert(alertView: alert)
        }).disposed(by: self.disposeBag)
        safeView.addSubview(viewSafeButton)
        
        viewSafeButton.snp.makeConstraints { (maker) in
            maker.centerY.equalToSuperview()
            maker.right.equalToSuperview().offset(-15)
        }
    }
    
    func hideSafeView() {
        XUserDefault.setSafetyAdviceOff(true)
        hiddenSafeView = true
        var frame = segmentdContainerView.frame
        frame.size.height = segmentedHeight
        segmentdContainerView.frame = frame
        safeView.removeFromSuperview()
        pagingView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    func updateAssets() {
//        appApi.rx.request(AppAPIEndPoint.totalAccountBalanceV5).MJObjectMap(EXTotalAccountBalanceModel.self).subscribe(onSuccess: {[weak self] (model) in
//            self?.assetsHeaderView.assetsModel = model
//        }) { (error) in
//
//        }.disposed(by: disposeBag)
        _ = EXAssetsManager.manager.allAssetsSignal().subscribe(onNext: { [weak self] model in
            guard let self = `self` else { return }
            self.assetsHeaderView.assetsModel = model
        },onDisposed: { [weak self] in
            self?.removeAssetsSketelon()
        })
    }
    
    func pinSectionHeight() -> Int {
        return hiddenSafeView ? Int(segmentedHeight) : Int((segmentedHeight + safeAdviseViewHeight))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        EXTracking.shared.trackPage(name: .assets, isEnter:false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        EXTracking.shared.trackPage(name: .assets, isEnter:true)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.prepareGuides()
        }
    }
}

extension EXAssetsVc: JXPagingViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        
        EXLogger.debug(message: "segmentedView didSelectedItemAt = \(index)")
        selectIndex = index
    }
    func tableHeaderViewHeight(in pagingView: JXPagingView) -> Int {
        
        if EXAppConfigManager.sharedInstance.getSupportAccounts().count <= 1 {
            return Int(0)
        }
        
        if self.isFirstController() {
            return Int(tableHeaderViewHeight - navOffset())
        }
        return Int(canBackTableHeaderViewHeight - navOffset())
        
    }
    
    func tableHeaderView(in pagingView: JXPagingView) -> UIView {
        if EXAppConfigManager.sharedInstance.getSupportAccounts().count <= 1 {
            return UIView()
        }
        if self.isFirstController() {
            assetsHeaderView.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: tableHeaderViewHeight - navOffset())
        }
        else {
            assetsHeaderView.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: canBackTableHeaderViewHeight - navOffset())
        }
        return assetsHeaderView
    }
    
    func heightForPinSectionHeader(in pagingView: JXPagingView) -> Int {
        if EXAppConfigManager.sharedInstance.getSupportAccounts().count <= 1 {
            return Int(tableHeaderViewHeight + 15)
        }
        return pinSectionHeight()
    }
    
    func viewForPinSectionHeader(in pagingView: JXPagingView) -> UIView {
        if EXAppConfigManager.sharedInstance.getSupportAccounts().count <= 1 {
            assetsHeaderView.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height:tableHeaderViewHeight)
            assetsHeaderView.remakeSubview()
            return assetsHeaderView
        }
        return segmentdContainerView
    }
    
    func numberOfLists(in pagingView: JXPagingView) -> Int {
        return controllers.count
    }
    
    func pagingView(_ pagingView: JXPagingView, initListAtIndex index: Int) -> JXPagingViewListViewDelegate {
        return controllers[index]
    }
    
    func pagingView(_ pagingView: JXPagingView, mainTableViewDidScroll scrollView: UIScrollView) {
        
        if EXAppConfigManager.sharedInstance.getSupportAccounts().count <= 1 {
            return
        }
        let rate = (30 - scrollView.contentOffset.y) / 30
        assetsHeaderView.assetsInfoView.alpha = rate
        navTitleLabel.alpha = 1 - rate
        
        if (1 - rate) > 0.1 {
            assetsHeaderView.lineView.alpha = 0.1
        }
        else {
            assetsHeaderView.lineView.alpha = 1 - rate
        }
    }
    
    func configChilds (){
        
        
        if isSupport(type: .coin) {
            let model = EXCommonAssetModel()
            model.title = "assets_text_exchange".localized() + "assets_text_total".localized()
            model.bgIcon = "assets_exchange"
            model.assetType = .coin
            assetModels.append(model)
            controllers.append(coinAsset)
            if EXHomeViewModel.isContractStatus() {
                segmentedTitles.append("mainTab_text_assets".localized())
            }else {
                segmentedTitles.append("mainTab_text_transaction".localized())
            }
        }
        
        if isSupport(type: .contract) {
            let model = EXCommonAssetModel()
            model.title = "home_text_contractTotal".localized()
            model.bgIcon = "assets_contract"
            model.assetType = .contract
            assetModels.append(model)
            controllers.append(newSwapAsset)
            segmentedTitles.append("mainTab_text_contract".localized())
        }
        
        if isSupport(type: .otc) {
            let model = EXCommonAssetModel()
            if EXAppConfigManager.sharedInstance.didOpenB2C() {
                model.title = "home_text_otcTotal_forotc".localized()
            }else{
                model.title = "home_text_otcTotal".localized()
            }
            model.assetType = .otc
            model.bgIcon = "assets_otc"
            assetModels.append(model)
            controllers .append(otcAsset)
            segmentedTitles.append("mainTab_text_otc".localized())
        }
        
        if !EXHomeViewModel.isContractStatus() {
            if isSupport(type: .leverage) {
                let model = EXCommonAssetModel()
                model.title = "leverage_total_balance".localized()
                model.assetType = .leverage
                model.bgIcon = "assets_leverage"
                assetModels.append(model)
                controllers.append(leverageAssett)
                segmentedTitles.append("contract_action_lever".localized())
            }
        }
        
        let left = self.segmentedView.contentEdgeInsetLeft
        let right = self.segmentedView.contentEdgeInsetRight
        var segmentWidth: CGFloat = left + right//contentInset
        if segmentedTitles.count > 0 {
            
            for title in self.segmentedTitles {
                let w = title.getTextWidth(font: 16)
                segmentWidth += w
                segmentWidth += 16
            }
            var segmentframe = self.segmentedView.frame
            segmentframe.size.width = segmentWidth
            self.segmentedView.frame = segmentframe
        }
        
        
        
        
        coinAsset.onAssetupdate = {[weak self] assetModel in
            self?.updateAssets()
        }
        otcAsset.onAssetupdate = {[weak self] assetModel in
            self?.updateAssets()
        }
//        swapAsset.onAssetupdate = {[weak self] assetModel in
//            self?.updateAssets()
//        }
//        newSwapAsset.onAssetupdate = {[weak self] assetModel in
//            self?.updateAssets()
//        }
        
        
        leverageAssett.onAssetupdate = {[weak self] assetModel in
            self?.updateAssets()
        }
    }
    
    func supportAccounts() ->[EXAccountType] {
        return EXAppConfigManager.sharedInstance.getSupportAccounts()
    }
    
    func isSupport(type:EXAccountType) -> Bool {
        let supportAccounts = self.supportAccounts()
        return supportAccounts.contains(type)
    }
    
    func anchorToAssetAccount() {
        if let accountType = self.assetType {
            for item in assetModels {
                if item.assetType == accountType {
                    let index = assetModels.index(of: item) ?? 0
                    self.handleCurrentAccount(index)
                    break;
                }
            }
        }else {
            self.handleCurrentAccount(0)
        }
    }
    
    func handleCurrentAccount(_ idx:Int) {
        self.selectIndex = idx
        segmentedView.selectItemAt(index: idx)
    }
    
    func isFirstController() -> Bool {
        if let navC = self.navigationController {
            let controllers = navC.viewControllers
            if controllers.count == 1 {
                return true
            }
        }
        return false
    }
}


extension EXAssetsVc: JXSegmentedViewDelegate {
    
}

//extension JXPagingListContainerView: JXSegmentedViewListContainer {}

extension EXAssetsVc : EXTradeCmdProtocal {
    
    func excuteCmd(symbol: String, action: String) {
        if action == "otc" {
            self.assetType = .otc
        }else if action == "contract" {
            self.assetType = .contract
        }else if action == "b2c" {
            self.assetType = .b2c
        }else if action == "leverage" {
            self.assetType = .leverage
        }else {
            self.assetType = .coin
        }
        self.anchorToAssetAccount()
    }
    
}

extension EXAssetsVc {
    func prepareGuides () {
        
        if EXAppConfigManager.sharedInstance.getSupportAccounts().count <= 1 {
            return
        }
        if EXAppCache.sharedCache.getAppGuideFirstShow(byType: .asset){
            var guides = [PopGuideItem]()
            let view =  self.coinAsset.getPieChartBtn()
            let itemPop = PopGuideItem()
            itemPop.title = "common_guide_asset_hint".localized()
            itemPop.subTitle = ""
            itemPop.tilteFont = UIFont.ThemeFont.BodyBold
            itemPop.subtitleFont = UIFont.ThemeFont.SecondaryBold
            itemPop.popoverType = .down
            itemPop.maxWidth = 198~
            itemPop.formView = view
            guides.append(itemPop)
            let m = EXPopGuidManger.shared
            m.guideItems = guides
            m.strartPop()
            m.finshCallBack = { [weak self] in
                EXAppCache.sharedCache.setAppGuideDidShow(byType: .asset)
            }
            
        }
    }
}
//Contract Asset Request
extension EXAssetsVc{
    func getContractAccountBlance(){
        //Convert all currencies to BTC
        EXAssetsManager.manager.allAssetsSignal().subscribe(onNext: { [weak self,weak newSwapAsset] model in
            guard let self = `self` else { return }
            let assetModel = EXCommonAssetModel()
            assetModel.totalBalanceSymbol = model.totalBalanceSymbol
            assetModel.totalBalance = model.futuresTotalBalance
            assetModel.title = "assets_contract_value".localized()
            let contractAsset = self.getBlanceInfo(assetModel: assetModel)
            newSwapAsset?.assetModel = contractAsset
        }).disposed(by: disposeBag)
    }
    func getBlanceInfo(assetModel: EXCommonAssetModel) -> EXContractBlance{
        let contractBlance = EXContractBlance()
        if assetModel.totalBalanceSymbol.count > 0 {
            assetModel.title += " (\(assetModel.totalBalanceSymbol))"
        }
        //BTC account balance
        let btcAccount =  assetModel.totalBalance.formatAmount(assetModel.totalBalanceSymbol,isLeverage:false)
        //Equivalent to RMB
        let rmb = assetModel.getCaculatePrice()
        contractBlance.title = assetModel.title
        contractBlance.btcAccount = btcAccount
        contractBlance.rmbAccount = rmb
        return contractBlance
    }
    
}


// MARK: add/remove assets sketelon
extension EXAssetsVc {
    
    private func addAssetsSketelon() {
        guard assetSketelon.superview == nil else { return }
        view.addSubview(assetSketelon)
        view.bringSubviewToFront(assetSketelon)
        assetSketelon.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    private func removeAssetsSketelon() {
        guard assetSketelon.superview != nil else { return }
        UIView.animate(withDuration: 0.25) {
            self.assetSketelon.alpha = 0.0
        } completion: { _ in
            self.assetSketelon.removeFromSuperview()
            self.assetSketelon.alpha = 1.0
        }
    }
}
