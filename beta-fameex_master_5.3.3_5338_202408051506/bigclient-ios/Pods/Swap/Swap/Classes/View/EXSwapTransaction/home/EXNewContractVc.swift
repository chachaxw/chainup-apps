//
//  EXNewContractVc.swift
//  Chainup
//
//  Created by cwd on 2022/10/9.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import EXKit
//import SwiftSVG
public let EXNewFuturesContractID = "EXNewFuturesContractID"
//大k线时间轴变化 English: Changes in the timeline of the candlestick chart
public let ContractKTimeScakeyChanged = "KTimeScakeyChanged"


public class EXNewContractVc: EXSNavCustomVC {
    //MARK:  属性 English: MARK: Properties
    var lastRate: String = "" //上次的涨跌幅 English: Last time's fluctuations
    var vm = EXContractHomeViewModel()
    var beforeTag = 1000
    let height = Device_H - TABBAR_H - NAV_H - 44 - 30
    let useLike = EXContractUserVm()
    var levelSheet: EXSChangeLevelSheet?
    //MARK: lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        configSkeleton()
        vm.setupNotes()
        vm.setupWs()
        subscribeTableContentOffset()
        eventSubscribe()
        setVcUI()
        _ = NotificationCenter.default.rx
            .notification(UIApplication.didBecomeActiveNotification)
            .takeUntil(self.rx.deallocated) //页面销毁自动移除通知监听 English: Page destruction automatically removes notification listening
            .subscribe(onNext: {[weak self] noti in
                self?.vm.resetData()
            })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if (self.contractSkeleton.superview != nil) {
                self.contractSkeleton.removeFromSuperview()
            }
        }
    }
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        contractSkeleton.isHidden = true
        self.vm.upDatePubinfo()
        self.updateChartLayout(top: true)
        self.updateChartLayout(top: false)
        self.vm.last = nil //这样每次进来都重新订阅 English: This way, every time I come in, I will subscribe again
        self.vm.reloadData()
        self.vm.reSubscribeData()
        self.vm.queryAsset()//更新资产 English: Update assets
        self.newView.reladHomeHeader()
        if let cm = self.vm.currentItemModel?.ex_contractInfo {
            self.swapTransactionView.makeOrderView.avilabelView.canTransfer = cm.area != .CONTRACT_BLOCK_SIMULATION
        }
        EXTracking.shared.track(event: EXSwapTrackingEvent.app_futures_main_page.rawValue)
        EXNewTracking.shared.trackPage(name: .swapfirst, isEnter:true)
        if self.newView.pagingHeader.makeOrderView.defineOrderType == .market { //市价需要刷新一下 English: The market price needs to be refreshed
            self.newView.pagingHeader.makeOrderView.updateVolumeTextFieldTypeSource()
            self.newView.pagingHeader.makeOrderView.updateVolumeTextFieldTypeBtn()
        }
        self.vm.queryNoticeBarInfo()
        
        self.vm.klineVM.wsEventSubject.onNext(.updateMainIndexVisible)
       
    }
    public override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        //未开通合约-默认设置为币 English: Contract not opened - default to coin
        if SLUserConfig.checkHasOpenContract == false{
            EXStoreData.setStoreObjectAndKey("1", key: EXS_UNIT_VOL)
            self.newView.pagingHeader.makeOrderView.updateVolumeTextFieldTypeSource()
            self.newView.pagingHeader.makeOrderView.updateVolumeTextFieldTypeBtn()
        }
        //首页金刚位进来位置不对处理 English: Handling the incorrect position of the Diamond position on the homepage
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.prepareGuides(view: self?.newView.pagingHeader.makeOrderView.volumeTextField.typeBtn)
        }
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.vm.isNeedUnSubscribeTikcerUI {
            self.vm.stopWs()
        }
        EXNewTracking.shared.trackPage(name: .swapfirst, isEnter:false)
        EXNewTracking.shared.trackPage(name: .swaptransactionsettings, isEnter:false)
        EXNewTracking.shared.trackPage(name: .swapCapitalFlow, isEnter:false)
        EXNewTracking.shared.trackPage(name: .swapcontractinformation, isEnter:false)
        EXNewTracking.shared.trackPage(name: .swapfundtransfer, isEnter:false)
//        self.view.endEditing(true)
    }
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.vm.isNeedUpdateSubscribeTickerUI = false
        self.vm.stopSubscribeData()
        ///清空上次输入的价格 English: /Clear the last entered price
        self.swapTransactionView.makeOrderView.clearLastPrice()
    }
    
    public override func setNavCustomV() {
        self.navtype = .nopopback
        self.navCustomView.backView.exs_addSubViews([chooseBtn,titleLabel,rateLabel,chargeBtn,detailBtn])
        self.navCustomView.backgroundColor = UIColor.ThemeView.newbg
        setNavUI()
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(clickChooseBtn))
        titleLabel.addGestureRecognizer(tap)
    }
    
    // MARK: - Lazy UI
    //k 线 English: K-line
    lazy var contractSkeleton: EXSkeletonContractView = {
        let v = EXSkeletonContractView()
        return v
    }()

//
//    lazy var smallklineView: EXKlineFolderView = {
//        let l = EXKlineFolderView(viewModel: self.vm)
//        l.backgroundColor =  UIColor.ThemeTab.bg//UIColor.ThemeView.markBg
//        l.klineTimeView.backgroundColor = UIColor.ThemeTab.bg
//        l.rightArrow.backgroundColor = UIColor.ThemeTab.bg
//        l.rightArrow.imageView.image = UIImage.exs_themeImageNamed(imageName: "public_icon_arrow_superior")
//        l.isBottom = true
//        l.heightChangeBlock = { [weak self] expand in
//            self?.smallklineView.rightArrow.isUserInteractionEnabled = false
//            let h = EXKlineFolderView.getViewH(open: expand)
//            self?.smallklineView.snp.updateConstraints { make in
//                make.height.equalTo(h)
//            }
//            self?.smallklineView.rightArrow.isUserInteractionEnabled = true
//        }
//        return l
//    }()
    
    lazy var smallklineView: EXSContractFlutterKLineChart = {
        let view = EXSContractFlutterKLineChart(viewModel: self.vm.klineVM)
        view.setBottom(with: true)
        view.changeHeightBlock = { [weak self] _ in
            guard let `self` = self else { return }
            self.updateChartLayout(top: false)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.vm.klineVM.wsEventSubject.onNext(.updateMainIndexVisible)
            }
        }
        return view
    }()
    
    
    //MARK:  切换合约 English: MARK: Switching Contracts
    lazy var chooseBtn : EXButton = {
        let btn = EXButton()
        btn.selectStyle = .onlyImage
        btn.exs_setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
        btn.setImage(UIImage.exs_themeImageNamed(imageName: "public_icon_switchcurrency"), for: .normal)
        btn.ext_SetAddTarget(self, #selector(clickChooseBtn))
        return btn
    }()
    
    //MARK: 合约名称 English: MARK: Contract Name
    lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.ext_UseAutoLayout()
        label.isUserInteractionEnabled = true
        label.font = UIFont.ThemeFont.H3Bold
        label.textColor = UIColor.ThemeLabel.colorLite
        label.text = "--"
        return label
    }()
    //涨跌 English: Rise and fall
    lazy var rateLabel : UILabel = {
        let label = UILabel()
        label.ext_UseAutoLayout()
        label.font = UIFont.ThemeFont.MinimumRegular
        label.text = "--"
        label.textColor = UIColor.ThemekLine.up
        label.layer.cornerRadius = 1
        label.textAlignment = .center
        label.layer.masksToBounds = true
        return label
    }()
    
    // 合约详情 English: Contract details
    lazy var detailBtn : EXButton = {
        let btn = EXButton()
        btn.selectStyle = .onlyImage
        btn.ext_UseAutoLayout()
        btn.setImage(UIImage.exs_themeImageNamed(imageName: "public_icon_details"), for: .normal)
        btn.ext_SetAddTarget(self, #selector(clickDetailBtn))
        return btn
    }()
    
    // 更多按钮 English: More buttons
    lazy var chargeBtn : EXButton = {
        let btn = EXButton()
        btn.selectStyle = .onlyImage
        btn.ext_UseAutoLayout()
        btn.setImage(UIImage.exs_themeImageNamed(imageName: "public_icon_more"), for: .normal)
        btn.ext_SetAddTarget(self , #selector(clickMoreBtn(sender:)))
        return btn
    }()
    
    lazy var line: UIView = {
        let v = UIView()
        v.backgroundColor = .Ex.fill4
        return v
    }()
    //底部按钮 English: Bottom button
    lazy var rightBottomBtn:EXButton = {
        let btn = EXButton()
        btn.selectStyle = .onlyImage
        btn.setBackgroundImage(UIImage.exs_themeImageNamed(imageName: "contract_tothetop"), for: .normal)
        //MARK: fix
        btn.rx.tap
            .subscribe(onNext:{ [weak self] in
                self?.newView.pagingView.mainTableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            })
            .disposed(by: exs_disposeBag)
        return btn
    }()
    lazy var rateAlertView:EXSwapRateAlertView = {
       let v = EXSwapRateAlertView()
        return v
    }()
    

    
    lazy var headerView : EXSwapHeaderView = {
        let view = newView.pagingHeader.headerView
        view.firstButtonWillClick = {  [weak self] in
            guard let newSelf = self else{
                return
            }
            let pass = newSelf.vm.passed()
            if pass{
                newSelf.headerView.currentUserConfig = newSelf.vm.currentUserConfig
                newSelf.headerView.alertMarginView()
//                newSelf.vm.updateUserConfig()
            }
        }
        
        view.clickMarginTypeBlock = { [weak self] marginMode in
            guard let newSelf = self else{
                return
            }
            EXContractNetwork.changeMarginMode(id:newSelf.vm.currentItemModel?.instrument_id ?? 0, currentMode: marginMode) {[weak newSelf] success in
                if success {
                    newSelf?.vm.updateUserConfig()
                }
            }
        }
        
        view.leverButtonClick = { [weak self] in
            guard let newSelf = self else{
                return
            }
            newSelf.headerView.secondButton.isUserInteractionEnabled = false
            if newSelf.vm.passed() {
                newSelf.changeLevel()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                newSelf.headerView.secondButton.isUserInteractionEnabled = true
            }
        }
        view.rateClick = { [weak self] in
            self?.rateUpdate()
            EXAlert.showAlert(alertView: self!.rateAlertView)
        }
        return view
    }()
    //MARK: 更新杠杆 English: MARK: Update lever
    func changeLevel(){
        if !self.vm.currentUserConfig.leverageCanChange() {
            let alert = EXSNormalAlert()
            alert.msgLabel.textAlignment = .center
            alert.msgLabel.textColor = UIColor.ThemeLabel.colorLite
            alert.configSigleAlert(title: "", message: "cp_contract_setting_text11".ex_localized(),sigleBtnTitle:"cp_extra_text28".ex_localized())
            EXAlert.showAlert(alertView: alert)
            
        }else {
            let sheet = EXSChangeLevelSheet(frame:  CGRect(x: 0, y: 0, width: self.view.frame.width, height: 380), minLevel: self.vm.currentUserConfig.minLevel, maxLevel: self.vm.currentUserConfig.maxLevel,availableLevel: self.vm.currentUserConfig.userMaxLevel)
            /*
             切换杠杆后会,通过接口更新杠杆,后重新拉取用户的配置信息获取杠杆信息。但是接口偶然会延迟,配置未更新完成时，快速操作时会导致杠杆信息不一致，
             所有self.vm.currentLevel 记录了最新的杠杆信息.避免不一致的问题
             After switching the lever, the lever will be updated through the interface, and then the user's configuration information will be pulled again to obtain the lever information. However, the interface may occasionally be delayed, and when the configuration is not updated completely, quick operations can cause inconsistent lever information. All self.vm.currentLevels record the latest lever information to avoid inconsistency issues
             */
            var currentlevel = self.vm.currentUserConfig.nowLevel
            if self.vm.currentLevel.greaterThan("0"){
                currentlevel = self.vm.currentLevel
            }
            self.levelSheet = sheet
            sheet.highestLevelLabel.text = "cp_extra_text114".ex_localized() + " " + self.vm.currentUserConfig.userMaxLevel + "x"
            sheet.multiplierCoin = self.vm.currentUserConfig.multiplierCoin
            sheet.leverAndMaxCoinDic = self.vm.currentUserConfig.leverAndMaxCoinDic
            let makeOrderViewModel = EXSwapMarkOrderViewModel()
            makeOrderViewModel.itemModel = self.vm.currentItemModel
            sheet.makeOrderViewModel = makeOrderViewModel
            sheet.slider.updateSliderValue(value: Float(currentlevel) ?? 1)
            sheet.clickConfirmButtonBlock = { [weak self] leverage in
                EXAlert.dismiss()
                self?.vm.currentLevel = leverage
                self?.updateLevel()
            }
            EXAlert.showSheet(sheetView: sheet)
        }
    }
    
    func updateLevel(){
        //先刷uI后刷接口 English: Brush uI first and then interface
        var currentlevel = self.vm.currentLevel
        self.headerView.setUserData(marginMode: self.vm.currentUserConfig.marginMode().introduced, leverage: currentlevel + "X")
        EXContractNetwork.editLeverageValue(value: currentlevel, id: self.vm.currentItemModel?.instrument_id ?? 0) {[weak self] success in
            guard let newSelf = self else{
                return
            }
            if success {
                newSelf.vm.updateUserConfig()
            }else{
//                EXAlert.showFail(msg: "切换杠杆失败") English: EXAlert. showFailure (msg: "Switch lever failed")
            }
        }
    }
    
    lazy var newView: EXContractHomeView = {
        let v = EXContractHomeView(viewModel: self.vm)
        v.secionHeader.clickAllTransactionCallback =  {[weak self] in
            guard let newSelf = self else{
                return
            }
            if newSelf.vm.passed() {
                let vc = EXSwapAllTransactionsVC()
                vc.itemModel = newSelf.vm.currentItemModel
                newSelf.navigationController?.pushViewController(vc, animated: true)
            }
        }
        v.pagingHeader.makeOrderView.avilabelView.btnBlock = { [weak self]  in
            guard let newSelf = self else{return}
            newSelf.view.endEditing(true)
            let margin_coin = newSelf.vm.currentItemModel?.ex_contractInfo?.marginCoin ?? ""
            EXSwapPlatformSDK.shared.transferOnClickedCallBack?(margin_coin,newSelf)
        }
        v.pagingHeader.makeOrderView.moneyShortCallBack = { [weak self]  in
            guard let newSelf = self else{return}
            if let cm = newSelf.vm.currentItemModel?.ex_contractInfo {
                if (cm.area == .CONTRACT_BLOCK_SIMULATION) {
                    //MARK: 模拟合约 不用弹框 余额不足 English: MARK: Simulate contract without pop-up box. Insufficient balance
                    EXAlert.showFail(msg: "cp_str_insufficient".ex_localized(),holdResponder: true)
                    return 
                }
            }
            newSelf.insufficientFundsAlert()
        }
        v.pagingHeader.makeOrderView.openContractAlert = { [weak self] in
            guard let newSelf = self else{return}
            newSelf.sl_showOpenContractView()
        }
        return v
    }()
    // 合约交易页面 English: Contract Trading Page
    lazy var swapTransactionView: EXContractHomeHeaderView = {
        let view = self.newView.pagingHeader
        view.willPushVcBlock = {[weak self] in
            guard let mySelf = self else{return}
            mySelf.vm.isNeedUnSubscribeTikcerUI = false
        }

        view.clickTakeOrderBlock = {[weak self] orderModel in
            guard let mySelf = self else{return}
            if mySelf.swapTransactionView.makeOrderView.defineOrderType == .limited {
                EXTracking.shared.track(event: EXSwapTrackingEvent.app_futures_limit_order_price_click.rawValue)
            }
            //点击价格，填入field English: Click on the price and fill in the field
            if mySelf.swapTransactionView.makeOrderView.defineOrderType == .limited ||
                mySelf.swapTransactionView.makeOrderView.defineOrderType.isHighOrderType(){
                
                mySelf.swapTransactionView.makeOrderView.priceTextField.input.text = orderModel.px
                mySelf.swapTransactionView.makeOrderView.textFieldValueHasChanged(textField: mySelf.swapTransactionView.makeOrderView.priceTextField.input)
            } else {
                mySelf.swapTransactionView.makeOrderView.performTextField.input.text = orderModel.px
                mySelf.swapTransactionView.makeOrderView.textFieldValueHasChanged(textField: mySelf.swapTransactionView.makeOrderView.triggerTextField.input)
            }
        }
        view.didRefreshBlock = { [weak self] in
            self?.vm.startWs()
        }
        view.clickDepthBtnBlock = {[weak self] depthIdx in
            self?.vm.currentDepthIdx = depthIdx
            self?.vm.startWs()
        }
       
        return view
    }()
    
}

// MARK: - Event Click
extension EXNewContractVc{
    // 点击选择合约按钮 English: Click the Select Contract button
    @objc func clickChooseBtn(){
        self.view.isUserInteractionEnabled = false
        let vc = EXSDrawerVC()
        let list = EXDrawContainerVC()
        list.vm.eventSubject.subscribe(onNext: {[weak self,weak vc] event in
            guard let mySelf = self else{return}
            switch event{
            case .selectFinsh(let item):
                if item.instrument_id != mySelf.vm.currentItemModel?.instrument_id {
                    // 订阅深度 English: Subscription depth
                    mySelf.vm.currentDepthIdx = 0
                    mySelf.swapTransactionView.makeOrderView.clearLastPrice()
                    //mySelf.newView.pagingHeader.marketPriceView.reloadView()
                    //mySelf.swapTransactionView.marketPriceView.clearDepathData()
                    mySelf.vm.currentItemModel = item
                    mySelf.updateTicer()
                    EXStoreData.setStoreObjectAndKey(String(item.instrument_id), key: EXNewFuturesContractID)
                    if let cm = item.ex_contractInfo {
                        mySelf.swapTransactionView.makeOrderView.avilabelView.canTransfer = cm.area != .CONTRACT_BLOCK_SIMULATION
                    }
                    //更新单位 English: Update Unit
                    mySelf.swapTransactionView.makeOrderView.avilabelView.setAsset(amount:mySelf.vm.canUseAmount,unit: mySelf.vm.currentItemModel?.ex_contractInfo?.margin_coin ?? "")
                }
                vc?.pullAnimation()
            default:
                break
            }
        }).disposed(by: disposeBag)
        vc.pullBlock = {[weak self] in
            self?.vm.reSubCurrentTicker() // 行情页面消失，会取消所有币行情-,需重新订阅当前币对 English: The market page will disappear and all currency market trends will be cancelled. You need to subscribe to the current currency pair again
            self?.view.isUserInteractionEnabled = true
        }
        vc.contentVc = list
        vc.addVC(list)
        
    }
    
    // 点击合约详情按钮 English: Click on the contract details button
    @objc func clickDetailBtn(){
        self.view.endEditing(true)
        self.vm.isNeedUpdateSubscribeDepthData = false
        self.vm.isNeedUnSubscribeTikcerUI = false
        let vc = EXSwapKLineDetailVC()
        vc.itemModel = self.vm.currentItemModel
        vc.changeItemCallback = {[weak self] itemModel in
            // 这里直接记录下来 English: Record it directly here
            if itemModel.instrument_id > 0 {
                EXStoreData.setStoreObjectAndKey(String(itemModel.instrument_id), key: EXNewFuturesContractID)

                self?.swapTransactionView.marketPriceView.clearDepathData()
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // 点击更多按钮 English: Click on the More button
    @objc func clickMoreBtn(sender:UIButton){
        let models =  EXSBouncedModel.getContractMenulist()
        let viewH = EXContractMenuSheet.getViewHeight(count: models.count)
        let sheet = EXContractMenuSheet(frame: CGRect(x: 0, y: 0, width: Device_W, height: viewH))
        sheet.itemModel = self.vm.currentItemModel
        sheet.bindSudokus(models)
        sheet.menuItemCallback = {[weak self] item in
            self?.menuAction(item: item)
        }
        sheet.addFavirateCallback = { [weak self] add in
            guard let myself = self else{
                return
            }
            guard let swapId = myself.vm.currentItemModel?.instrument_id, swapId > 0 else{
                return
            }
            myself.useLike.handleCoFavorite(actionType: !add ? .singleDelete : .singleAdd, swapIds: [String(swapId)]) { [weak self] success in
//                guard let `self` = self else {return}
//                if success{
//                }
            }
        }
        EXAlert.showDropView(view: sheet)
    }

    @objc func menuAction(item:EXSBouncedModel){
        switch item.action {
        case .contractSetting: // 合约设置 English: Contract settings
            self.goSetting()
        case .contractCaculator: // 合约 计算器 English: Contract Calculator
            self.goCalculator()
        case .contractRecord:
            goContractRecord()
        case .contractTransfer: // 资金划转 English: Fund transfer
            self.toTransfer()
        case .contractSwapInfo:  // 合约信息 English: Contract information
            goSwapInfo()
        case .contractGuideLine:
            goContractGuideLine()
        default:
            break
        }
    }
}
//MARK: 跳转 English: MARK: Jump
extension EXNewContractVc {
    func goCalculator(){
        let calculatorVc = EXSwapCalculatorVc()
        let vm = EXSwapDataViewModel()
        vm.itemModel = self.vm.currentItemModel
//        vm.leverAndMaxCoinDic = self.vm.currentUserConfig.leverAndMaxCoinDic
        calculatorVc.viewModel = vm
        self.navigationController?.pushViewController(calculatorVc, animated: true)
    }
    func goContractRecord() {
        if !self.vm.passed() {
            return
        }
        let vc = EXSAssetsRecordVC()
        vc.currentMarginCoin = self.vm.currentItemModel?.ex_contractInfo?.margin_coin ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
        EXNewTracking.shared.trackPage(name: . swapCapitalFlow, isEnter:true)
    }
    func goSwapInfo() {
        let vc =  EXSwapDetailViewController()
        let vm = EXSwapDataViewModel()
        vm.itemModel = self.vm.currentItemModel
        vc.viewModel = vm
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func goContractGuideLine() {
        EXNewTracking.shared.trackPage(name: . swapcontractinformation, isEnter:true)
        if !self.vm.passed() {
            return
        }
        var urlString="https://futuresdoc.gitbook.io/help-center/"
        let configUrl = EXSwapPublicInfo.shared.infoModel.contractProInfo
        if configUrl.count > 0 && configUrl.hasPrefix("http") {
            urlString = configUrl
        }
        EXSwapPlatformSDK.shared.goToH5?(urlString,"cp_extra_text144".ex_localized(),self,nil)
    }
    
    @objc func toTransfer() {
        if !self.vm.passed(){
            return
        }
        EXSwapPlatformSDK.shared.transferOnClickedCallBack?(self.vm.currentItemModel?.ex_contractInfo?.margin_coin ?? "",self)
        EXNewTracking.shared.trackPage(name: .swapfundtransfer, isEnter:true)
    }
    func goSetting() {
        if !self.vm.passed() {
            return
        }
        let settingVc = EXSwapSettingVc()
        settingVc.isPositionModeCanSwitch = self.vm.currentUserConfig.isPositionModeCanSwitch()
        settingVc.currentID = self.vm.currentItemModel?.instrument_id ?? 0
        settingVc.changeUserConfigCallBlock = { [weak self] in
            guard let weakSelf = self else{return}
            
            weakSelf.vm.shouldUpdateUserConfig = true
        }
        settingVc.changePositionCallBlock = {[weak self] in
            guard let weakSelf = self else{return}
            weakSelf.newView.reladHomeHeader()
        }
        settingVc.selectUnitBlock = {[weak self] in
            guard let weakSelf = self else{return}
            
            weakSelf.vm.shouldUpdateUserConfig = true
            weakSelf.swapTransactionView.makeOrderView.updateVolumTextUnit()
            weakSelf.swapTransactionView.marketPriceView.updateDepthData(instrument_id: weakSelf.vm.currentItemModel?.instrument_id ?? 0)
            weakSelf.swapTransactionView.makeOrderView.makeOrderViewModel?.makerOrderUnitChangeBlock?()
        }
        
        self.navigationController?.pushViewController(settingVc, animated: true)
        EXNewTracking.shared.trackPage(name: . swaptransactionsettings, isEnter:true)
    }
}
//MARK: 自定义方法 English: MARK: Custom Method
extension EXNewContractVc {
   //更新 English: update
    func publicMarketDataUpdate(info:SLPublicMarketInfo){
        self.headerView.setRate(rateText: info.currentFundRateDisplay())
        self.rateAlertView.config(second: info.currentFundRateDisplay(), third: info.nextFundRateDisplay())
        self.swapTransactionView.marketPriceView.updateData(fairPx: info.tagPrice, indexPx: info.indexPrice)
    }
    //更新标记价格/ 这个 English: Update marked prices/this
    func updateIndexPrice(item: EXPricelistModel){
        if let model = item.priceModel{
            self.swapTransactionView.marketPriceView.updateData(fairPx: model.tagPrice, indexPx: model.lastPrice)
        }
      
    }
    //深度 English: depth
    func depthDataUpdate(){
        self.swapTransactionView.marketPriceView.updateDepthData(
            instrument_id: self.vm.currentItemModel?.instrument_id ?? 0)
    }
    //资金费率 English: Fund rate
    func rateUpdate() {
        if EXAlert.isCurrentlyDisplaying() == false{
            return //费率未弹出,不显示时间信息等. English: Rate not popped up, time information not displayed, etc
        }
        guard let item = self.vm.currentItemModel,let info = item.ex_contractInfo else {
            return
        }
        
        
        
        var result = info.currentAndNextRateTime()
        if result.0 == "00:00" { //需要请求下一次接口 English: Need to request the next interface
            self.vm.queryPubinfoOnly {
              
            } failure: {
                
            }
        }
        self.rateAlertView.config(first:result.0 + result.1)
    }
//    // 币对更换 English: Currency pair replacement
    func updateItemModel(){
        let entity = self.vm.currentItemModel!
        self.swapTransactionView.itemModel = entity
        self.titleLabel.text = entity.ex_contractInfo?.showName()
        //清空价格 English: Clear prices
        self.swapTransactionView.makeOrderView.clearLastPrice()
        self.swapTransactionView.makeOrderView.updateVolumTextUnit()
        self.swapTransactionView.makeOrderView.updateVolumeTextFieldTypeBtn()
    }
    //MARK: 更新最新价 English: MARK: Update the latest price
    func updateTicer() {
        guard let entity = self.vm.currentItemModel else{return}
        if entity.last_px.isEmpty { //取缓存 English: Retrieve cache
            entity.setDefaultTicerData()
        }
        self.swapTransactionView.makeOrderView.avilabelView.setAsset(amount:self.vm.canUseAmount,unit: self.vm.currentItemModel?.ex_contractInfo?.margin_coin ?? "")
        self.updateRateData(rateText: entity.change_rate.toPercentString(2), bgColor: entity.bgColor())
        let last_px = entity.last_px.toPricePrecision(withContractID: entity.instrument_id)
        self.swapTransactionView.marketPriceView.middleCell.updatePriceData(priceText: last_px,
                                                                            rateText: entity.change_rate.toPercentString(2) ,
                                                                            bgColor: entity.bgColor())
        self.swapTransactionView.makeOrderView.updateLastPrice(price: last_px)
        self.swapTransactionView.makeOrderView.makeOrderViewModel?.itemModel?.last_px = last_px

    }
    
    func handleUserConfig() {
        let currentUserConfig = self.vm.currentUserConfig
        swapTransactionView.currentUserConfig = self.vm.currentUserConfig
        headerView.setUserData(marginMode: currentUserConfig.marginMode().introduced, leverage: currentUserConfig.nowLevel + "X")
        swapTransactionView.makeOrderView.changeLevel(currentUserConfig.nowLevel)
        swapTransactionView.positionType = currentUserConfig.positionMode()
        swapTransactionView.makeOrderView.reloadUnitData()
        swapTransactionView.makeOrderView.reloadTransationTypeView()
        
    }
    func updateUnit(){
        swapTransactionView.makeOrderView.getUserConfigUpdateDateVolumTextUnit()
    }
    //MARK: 开通合约 English: MARK: Contract activation
    func sl_showOpenContractView() {
        // 开通合约 English: Open contract
        let alert = EXSwapOpenSwapView()
        alert.alertCallback = { idx in
            if idx == 0 {
                self.handleAgreementRegist()
            }
            
        }
        alert.show()
    }
    //MARK: 余额不足弹框 充值 English: MARK: Insufficient balance pop-up recharge
    func insufficientFundsAlert(){
        let title = "cp_str_insufficient".ex_localized()
        let msg = "cp_set_4".ex_localized()
        let alert = EXCommonAlert()
        alert.contentLabel.textAlignment = .center
        alert.configAlert(tipImage: nil, title: title, message: msg, cancelBtnTitle: "cp_overview_text56".ex_localized(), sureBtnTitle: "cp_contract_opened_dialog_btn1".ex_localized(), btnLayoutStyle: .horizontal) { [weak self] type in
            guard let newSelf = self else{return}
            switch type{
            case .cancel:
                EXAlert.dismiss()
            case .sure:
                let margin_coin = newSelf.vm.currentItemModel?.ex_contractInfo?.marginCoin ?? ""
                EXSwapPlatformSDK.shared.transferOnClickedCallBack?(margin_coin,newSelf)
            default:
                break
            }
        }
        EXAlert.showAlert(alertView: alert,touchCanDissmiss: true)
    }
    
    //MARK:  开通成功 English: MARK: Successfully opened
    func showOpenContractSusscessView(success: Bool) {
        let title = "cp_contract_opened_successfully"  //: "cp_extra_text142"
        let msg =  "cp_contract_opened_success_msg" //: "cp_alert_1"
        let alert =  EXContractOpenSuccessedView()
        alert.configAlert(
            title: title.ex_localized(),
            titleFont: nil,
            image: nil,
            message: msg.ex_localized())
        alert.alertCallback = { [weak self] idx in
            guard let weak = self else{return}
            weak.jumpToVc(inx: idx)
        }
        EXAlert.showAlert(alertView: alert,offset: 32)
    }

    func jumpToVc(inx: Int){
        if inx == 1 { //划转 English: Transfer
            let margin_coin = self.vm.currentItemModel?.ex_contractInfo?.marginCoin ?? ""
            EXSwapPlatformSDK.shared.transferOnClickedCallBack?(margin_coin,self)
        }else if inx == 2 { // 合约指南 English: Contract Guidelines
            goContractGuideLine()
        }else{ //取消 -- 立即刷新公告 --上面2个返回会立即刷新/这里无需处理 English: Cancel - Refresh announcement immediately - The two returns above will refresh immediately/No need to process here
             self.vm.queryNoticeBarInfo()
        }
    }
    //key验证 English: Key verification
    func kycLimitValite(){
        //kyc 限制 English: KYC restriction
        self.handleKycForceTip()
    }
    func gotokyc(){
        
        EXSwapPlatformSDK.shared.realNameAuthenticationCallBack?()
        
//        let realName = EXRealNameCertificationChooseVC()
//        self.navigationController?.pushViewController(realName, animated: true)
//        self.vm.shouldUpdateUserConfig = false
    }
    func handleKycForceTip(){
        
        /*
         未认证 2,3- 认证 English: Uncertified 2,3-certified
         */
        //认证提示 English: Certification prompt
        var tipMsg = ""
        let authLevel = EXSUserAuthLevel.init(rawValue: self.vm.currentUserConfig.authLevel)
        switch authLevel{
        case .newbie,.reject: //未认证 English: Unauthenticated
            let msg = "cp_extra_text183"
            let alert = EXSNormalAlert()
            alert.configAlert(title: "cp_extra_text189".ex_localized(), message:msg.ex_localized() + "\n" + "cp_extra_text190".ex_localized(),positiveBtnTitle:"cp_extra_text184".ex_localized())
            alert.alertCallback = { [weak self]idx in
                if idx == 0 {
                    self?.gotokyc()
                }
            }
            EXAlert.showAlert(alertView: alert)
            return
        case .pending: //审核中 English: Under review
                tipMsg = "cp_extra_text185"
        default:
            break
           
        }
        alertShow(msg: tipMsg)
    }
    func alertShow(msg: String){
        let alert = EXSNormalAlert()
        alert.configSigleAlert(title: "cp_extra_text27".ex_localized(), message: msg.ex_localized())
        EXAlert.showAlert(alertView: alert)
    }
    //MARK: 确认开通合约 English: MARK: Confirm opening of contract
    func confirmOpenSwap() {
        let token = EXSwapPlatformSDK.shared.activeAccount?.token ?? ""
        EXContractNetwork.creatContractAccount(token:token) {[weak self] success in
            if success{
                guard let newSelf = self else {
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    newSelf.vm.updateUserConfig(completion: { [weak newSelf] in
                        newSelf?.swapTransactionView.makeOrderView.refreshBtnTitle()
                    })
                }
                self?.showOpenContractSusscessView(success: true)
            }
        }
    }
    
    func handleAgreementRegist(kycForce: Bool? = false) {
        
        let limitHandler = {
            if self.vm.currentUserConfig.shouldLimit {//限制国家 English: Restricting countries
                let msg = (kycForce ?? false) ? "cp_extra_text188" : "cp_extra_text188"
                let alert = EXSNormalAlert()
                alert.configSigleAlert(title: "cp_extra_text27".ex_localized(), message: msg.ex_localized())
                EXAlert.showAlert(alertView: alert)
                return
            }
            self.confirmOpenSwap()
        }
        
        let goKyc = {
            EXSwapPlatformSDK.shared.realNameAuthenticationCallBack?()
        }
        
        let authLevel = EXSUserAuthLevel.init(rawValue: self.vm.currentUserConfig.authLevel)
        switch authLevel {
        case .pass://成功 English: success
            limitHandler()
            return
        case .pending://审核中 English: Under review
            let msg = (kycForce ?? false) ? "cp_extra_text185" : "cp_extra_text185"
            let alert = EXSNormalAlert()
            alert.configSigleAlert(title: "cp_extra_text27".ex_localized(), message: msg.ex_localized())
            EXAlert.showAlert(alertView: alert)
            return
        case .reject://失败去认证 English: Failed to authenticate
            
            if let force = kycForce, force == true{
                // kyc 认证 2和3 弹一个框 English: KYC certification 2 and 3 pop a box
                let msg = (kycForce ?? false) ? "cp_extra_text183" : "cp_extra_text183"
                //没开通Kyc English: Kyc not activated
                let alert = EXSNormalAlert()
                
                alert.configAlert(title: "cp_extra_text189".ex_localized(), message:msg.ex_localized() + "\n" + "cp_extra_text190".ex_localized(),positiveBtnTitle:"cp_extra_text184".ex_localized())
                alert.alertCallback = {idx in
                    if idx == 0 {
                        goKyc()
                    }
                }
                
                EXAlert.showAlert(alertView: alert)
                return
            }
            
            let alert = EXSNormalAlert()
            alert.configAlert(title: "cp_extra_text27".ex_localized(), message: "cp_extra_text187".ex_localized())
            alert.alertCallback = {idx in
                if idx == 0 {
                    goKyc()
                }
            }
            EXAlert.showAlert(alertView: alert)
            return
        case .newbie:
            let msg = (kycForce ?? false) ? "cp_extra_text183" : "cp_extra_text183"
            //没开通Kyc English: Kyc not activated
            let alert = EXSNormalAlert()
            
            alert.configAlert(title: "cp_extra_text189".ex_localized(), message:msg.ex_localized() + "\n" + "cp_extra_text190".ex_localized(),positiveBtnTitle:"cp_extra_text184".ex_localized())
            alert.alertCallback = {idx in
                if idx == 0 {
                    goKyc()
                }
            }
            
            EXAlert.showAlert(alertView: alert)
            return
        case .notGet:
            let alert = EXSNormalAlert()
            alert.configSigleAlert(title: "cp_extra_text186".ex_localized(), message: "")
            EXAlert.showAlert(alertView: alert)
            return
        case .none :break
        }
        
    }
}



extension EXNewContractVc {
    private func setNavUI() {
        chooseBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(5)
            make.width.equalTo(40)
            make.height.equalTo(40)
            make.centerY.equalTo(self.navCustomView.popBtn)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(chooseBtn.snp.right).offset(0)
            make.height.equalTo(25)
            make.centerY.equalTo(chooseBtn)
        }
        rateLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.right).offset(12)
            make.width.width.equalTo(30)
            make.height.equalTo(20)
            make.centerY.equalTo(titleLabel)
        }
        chargeBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.height.width.equalTo(16)
            make.centerY.equalTo(chooseBtn)
        }
        detailBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(chooseBtn)
            make.right.equalTo(chargeBtn.snp.left).offset(-12)
            make.height.width.equalTo(16)
        }
        chargeBtn.setEnlargeEdgeWithTop(10, left: 6, bottom: 10, right: 16)
        detailBtn.setEnlargeEdgeWithTop(10, left: 16, bottom: 10, right: 6)
    }
    //skeleton
    func configSkeleton(){
        self.view.addSubview(contractSkeleton)
        contractSkeleton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.view.insertSubview(contractSkeleton, aboveSubview: navCustomView)
    }
    
    private func setVcUI() {
        contentView.exs_addSubViews([newView,line,smallklineView,rightBottomBtn])
//        let klineShow = EXStoreData.getSmallKlineShowBottom()
//        let h = klineShow ? EXKlineFolderView.getViewH(open: false) : 0
        let h = 0
       smallklineView.isHidden = true
        line.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(0.5)
        }
        updateLine()
        newView.snp.makeConstraints { (make) in
            make.top.equalTo(line.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        smallklineView.snp.makeConstraints { make in
            make.top.equalTo(newView.snp_bottomMargin)
            make.left.right.equalToSuperview()
            make.height.equalTo(h)
            make.bottom.equalToSuperview()

        }
        rightBottomBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(25)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-(EXTABBAR_HEIGHT + 15))
        }
        forbidMoveFromScreenLeft()

    }
    //顶部分割线 English: Top dividing line
    func updateLine(){
        //k线在下时  以及k线关闭时不显示 English: Not displayed when the K line is offline and when the K line is closed
        let klineBottom = EXStoreData.getSmallKlineShowBottom()
        line.isHidden = false
        var lineh = 0.5
        
        if klineBottom || EXStoreData.getSmallKlineShow() == false{
            lineh = 0
            line.isHidden = true
        }
        line.snp.updateConstraints { make in
            make.height.equalTo(lineh)
        }
    }
    
//    func updateSmallKlineLocationBottom(){
//        let klineShow = EXStoreData.getSmallKlineShowBottom()
//        updateLine()
//        smallklineView.isHidden = !klineShow
//        let h = klineShow ? EXKlineFolderView.getViewH(open: self.smallklineView.open) : 0
//        smallklineView.snp.updateConstraints { make in
//            make.height.equalTo(h)
//        }
//        if self.smallklineView.isHidden == false && self.smallklineView.open == true {
//            self.smallklineView.upateEntity()
////            self.vm.subscribeKline()
//        }
//
//    }
}

extension EXNewContractVc {
//    /// token失效 English: /Token failure
//    @objc func tokenLoseEffectiveness() {
//        EXSwapPlatformSDK.shared.loginCallBack?()
//        self.swapTransactionView.transactionShowType = .showClose
//        self.swapTransactionView.makeOrderView.reloadTransationTypeView()
//     //   self.toolView.reloadBtnStatus(self.toolView.openBtn)
//        refreshLogout()
//    }
//    
  
    
    @objc private func refreshLogout() {
//        debug//print("合约##--控制器--退出登录") English: DebugPrint ("Contract # # - Controller - Log Out")
        swapTransactionView.makeOrderView.makeOrderViewModel?.asset?.reset()
        self.vm.cleanDataWhenLogout()
        swapTransactionView.makeOrderView.refreshBtnTitle()
        swapTransactionView.makeOrderView.reloadMakeOrderData()
        self.newView.resetTitleList()
    }

    
}
extension EXNewContractVc{
    //右下脚的小三角 English: The small triangle on the lower right foot
    func subscribeTableContentOffset(){
        let height = self.newView.pagingHeader.height
        self.newView.pagingView.mainTableView.rx.contentOffset
            .subscribe(onNext: {  [weak self] offsetPoint in
//                //print("offset = \(offsetPoint.y)")
                self?.view.endEditing(false)
                self?.rightBottomBtn.isHidden = offsetPoint.y < height
//                if (offsetPoint.y < height){ //顶部显示全了 English: The top display is full
//                    //print("=====> 需要刷新",self?.vm.isScrolling) English: Print ("needs to be refreshed", self?. vm. isScrolling)
//                    self?.vm.isScrolling = false
//                }else{
//                    //print("=====> 停止刷新",self?.vm.isScrolling) English: Print ("stop refreshing", self?. vm. isScrolling)
//                    self?.vm.isScrolling = true //底部列表 English: Bottom List
//                }
                //MARK: 处理置顶圆角 English: MARK: Handling Topped Rounds
                if offsetPoint.y >= height {
                    self?.newView.secionHeader.backgroundColor = UIColor.ThemeView.newbg
                    if self?.line.isHidden == false{
                        self?.line.backgroundColor =  UIColor.ThemeView.newbg
                    }
                }else{
                    if self?.line.isHidden == false{
                        self?.line.backgroundColor =  UIColor.ThemeView.seperator
                    }
                    self?.newView.secionHeader.backgroundColor = UIColor.ThemeView.card1
                }
            })
            .disposed(by: exs_disposeBag)
    }
}

extension EXNewContractVc{
    func prepareGuides(view: UIView?) {
        if EXStoreData.getContractNewfunctionFirstTiped() == false {
            var guides = [PopGuideItem]()
            if view != nil{
                let itemPop = PopGuideItem()
                itemPop.title = "order_setting_text5".ex_localized()
                itemPop.subTitle = "guide_3".localized()
                itemPop.tilteFont = UIFont.ThemeFont.BodyBold
                itemPop.subtitleFont = UIFont.ThemeFont.SecondaryBold
                itemPop.popoverType = .down
                itemPop.maxWidth = 198~
                itemPop.formView = view
                guides.append(itemPop)
            }
            
            let m = EXPopGuidManger.shared
            m.guideItems = guides
            m.strartPop()
            m.finshCallBack = {
                EXStoreData.setContractNewfunctionFirstTiped()
            }
        }
    }
}
//事件监听 English: event listeners
extension EXNewContractVc{
    
    func eventSubscribe(){
        self.vm.wsEventSubject.subscribe(onNext: { [weak self] event in
            guard let `self` = self else { return }
            
            DispatchQueue.main.async {
                switch event {
                case .logSuccess:
//                    debug//print("====logSuccess")
                    self.swapTransactionView.makeOrderView.reloadMakeOrderData()
//                    self.swapTransactionView.makeOrderView.refreshBtnTitle()
                case .updateItemModel:
//                    debug//print("====updateItemModel")
                    self.updateItemModel()
                case .updateTicer:
//                    debug//print("====updateTicer")
                    self.updateTicer()
                case .updateUserConfig:
                    self.handleUserConfig()
                    if (self.contractSkeleton.superview != nil) {
                        self.contractSkeleton.removeFromSuperview()
                    }
//                    debug//print("====updateUserConfig")
                case .publicMarketData(let info):
//                    debug//print("====publicMarketData")
                    self.publicMarketDataUpdate(info: info)
                case .depthData:
//                    debug//print("====depthData")
                    self.depthDataUpdate()
                case .kycLimitValite:
                    self.kycLimitValite()
                case .sl_showOpenContractView:
                    self.sl_showOpenContractView()
                case .refreshLogout:
//                    debug//print("====refreshLogout")
                    self.refreshLogout()
                case .reloadData:
                    break
                case .updateRate:
//                    debug//print("====updateRate")
                    self.rateUpdate()
                case .updateOpenUnit:
                    self.updateUnit()
                case .cancelPositionSuccess:
                    self.newView.updateAsset()
                case .updateAssetInfo:
                    self.newView.updateAsset()
                case .noticeInfo(let notice):
                    self.updateNoticeBar(show: true, noticeInfo: notice)
                case .noticeClose:
                    self.updateNoticeBar(show: false, noticeInfo: nil)
                default:
                    break
                }
            }
        }).disposed(by: self.disposeBag)
    }
    
    //更新涨跌幅 English: Update price fluctuations
    func updateRateData(rateText:String,bgColor:UIColor) {
        
        let color = EXSTools.colorWithUpAndDownText(rateText)
        if color != nil {
            self.rateLabel.textColor = color
            self.rateLabel.backgroundColor = color?.withAlphaComponent(0.15)
        }
        if rateText.greaterThan("0.00") {
            self.rateLabel.text = "+\(rateText)"
        }else {
            self.rateLabel.text = "\(rateText)"
        }
        if lastRate.count == (self.rateLabel.text?.count ?? 0) {
            return
        }
        lastRate = self.rateLabel.text ?? ""
        self.rateLabel.titleResizeSize()
    }
    
}

extension EXNewContractVc{
    ///公告栏处理 English: /Announcement board processing
    func updateNoticeBar(show: Bool, noticeInfo: EXContractNotice?){
        if show == false{
            self.swapTransactionView.updateNoticeBar(show: false)
        }else{
            if let info = noticeInfo {
                self.swapTransactionView.noticeBar.notice = info
                self.swapTransactionView.updateNoticeBar(show: true)
            }else{
                self.swapTransactionView.updateNoticeBar(show: false)
            }
        }
    }
    
}

extension EXNewContractVc{
    func updateChartLayout(top: Bool) {
        let showTop = EXStoreData.getSmallKlineShowTop()
        let showBottom = EXStoreData.getSmallKlineShowBottom()
        var chartHeight:CGFloat = 0
        if top == false{
            if showBottom{
                chartHeight = smallklineView.intrinsicContentSize.height
            }
            self.smallklineView.isHidden = !showBottom
            self.smallklineView.snp.updateConstraints({ make in
                make.height.equalTo(chartHeight)
            })
            if showBottom == false{
                smallklineView.filterMenu.refresh()
            }
            
        }else{
            if showTop{
                chartHeight =  self.newView.pagingHeader.smallklineView.intrinsicContentSize.height
            }
            self.newView.pagingHeader.smallklineView.isHidden = !showTop
            self.newView.pagingHeader.smallklineView.snp.updateConstraints({ make in
                make.height.equalTo(chartHeight)
            })
            if showBottom == false{
                self.newView.pagingHeader.smallklineView.filterMenu.refresh()
            }
        }
    }
}

