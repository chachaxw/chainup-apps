////
////  EXKlineFolderView.swift
////  Chainup
////
////  Created by cwd on 2022/9/30.
////  Copyright © 2022 Chainup. All rights reserved.
////
//
//import UIKit
//import JXSegmentedView
//import SwiftEventBus
//import EXKit
//
/////Contract homepage foldable view
//class EXKlineFolderView: EXView {
//    var viewModel: EXContractHomeViewModel?
//    var klineViewModel = EXContractFlutterKLineChartViewModel()
//    var menuModel:EXCOMenuSelectionModel = EXCOMenuSelectionModel()
//    var isBottom = false {
//        didSet{
//            if isBottom == false {
////                self.klineView.style = EXSPricelineStyle.lineStyle
//            }
//        }
//    }
//    //MARK: k line section
//    var hasLoadedAllKline = false
//    var lastScaleKey = ""
//    var heightChangeBlock: EXComBoolBlock?
//    //Do you want to open the shape
//    var open: Bool = false
//    var hasSubKline = false //是否订阅了k 线 //Once subscribed English: Once subscribed
//    let defuatKeyIndex: Int = 3  //MARK: Fix. The default time for writing dead text here is 15 minutes
//    //Title displayed during the k-line period
//    let convenienceScalesTitle = EXSwapKlineDataTool.getSmallAllKlineScale()
//    //The key used for subscription on the K line
//    let convenienceScales = EXSwapKlineDataTool.getContractSaceKeys()
// 
//    required init(viewModel: EXViewModelProtocol?) {
//        self.viewModel = viewModel as? EXContractHomeViewModel
//        self.klineViewModel = self.viewModel!.klineVM
//        super.init(viewModel: viewModel)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func setupView(){
//        configUI()
//        reloadView(openView: false)
//        upateEntity()
//    }
//    
//    override func bindViewModel() {
//        super.bindViewModel()
//        self.viewModel?.wsEventSubject.subscribe(onNext: { [weak self] event in
//            guard let `self` = self else { return }
//            if self.viewModel?.isScrolling == true {return}
//            switch event {
//            case .updateItemModel:
//                self.upateEntity()
//            default:
//                break
//            }
//        }).disposed(by: self.disposeBag)
//        self.handlekLineWs()
//    }
//    
//    //MARK: Update selected indicators
//    func updateSelectIndex(){
//        //print("convenienceScales = \(convenienceScales)")
//        let scaleKey = menuModel.scaleKey
//        if let dftIdx = convenienceScales.firstIndex(of: scaleKey){
//            self.klineTimeView.defaultSelectedIndex = dftIdx
//            self.klineTimeView.reloadData()
//        }else {
//            //MARK: Default 15min
//            self.klineTimeView.defaultSelectedIndex = 3
//        }
//    }
//    //MARK: lazy UI
//    ///Name
//    lazy var titleLabel: UILabel = {
//        let label = UILabel(text:"--", font: UIFont.ThemeFont.SecondaryBold, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.left)
//        label.ext_UseAutoLayout()
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(click))
//        label.addGestureRecognizer(tap)
//        label.isUserInteractionEnabled = true
//        return label
//    }()
//    
//    
//    lazy var dataSource:JXSegmentedTitleDataSource = {
//        //Configure Data Source
//        let dataSource = JXSegmentedTitleDataSource()
//        dataSource.isTitleColorGradientEnabled = true
//        dataSource.titleSelectedColor = UIColor.ThemeLabel.colorLite
//        dataSource.titleNormalColor = UIColor.ThemeLabel.colorMedium
////        dataSource.isTitleZoomEnabled = true
//        dataSource.isItemSpacingAverageEnabled = false
//        dataSource.titleNormalFont = UIFont.ThemeFont.SecondaryBold
//        dataSource.titleSelectedFont = UIFont.ThemeFont.SecondaryBold
//        dataSource.itemSpacing = 16
//        return dataSource
//    }()
//    
//   
//    //getConvenienceKlineScale(isSwap: true)
//    lazy var topSeperatorLine: UIView = {
//        let v = UIView()
//        v.backgroundColor = UIColor.ThemeView.seperator
//        v.isHidden = true
//        return v
//    }()
//    //K line
//    lazy var klineTimeView:JXSegmentedView = {
//        let v = JXSegmentedView()
//        self.dataSource.titles = convenienceScalesTitle
//        v.dataSource = self.dataSource
//        //Configure Indicator
//        v.indicators = [self.lineIndicatorLienView]
//        v.delegate = self
//        return v
//    }()
//    
//    lazy var lineIndicatorLienView: EKIndicatorSegmentIndicator = {
//        let view = EKIndicatorSegmentIndicator()
//        view.indicatorHeight = 4
//        view.indicatorWidth = 22
//        view.indicatorCornerRadius = 0
//        return view
//    }()
//    
//    //Right button
//    lazy var rightArrow :EXDropImageView = {
//        let v =  EXDropImageView()
//        v.backgroundColor = UIColor.ThemeView.newbg
//        v.openBlock = { [weak self] open in
//            guard let newSelf = self else {
//                return
//            }
//            newSelf.open = !newSelf.open
//            EXLogLine(mark:klineWorklog, message:"smallkline-open")
//            newSelf.dealKline(open: newSelf.open)
//            EXNewTracking.shared.trackPage(name: .smallkline, isEnter:true)
//            newSelf.reloadView(openView: newSelf.open)
//            newSelf.heightChangeBlock?(newSelf.open)
//            
//        }
//        return v
//    }()
//    
//    @objc func click(){
//        EXNewTracking.shared.trackPage(name: .smallkline, isEnter:true)
//        self.rightArrow.click()
//    }
//    
//    lazy var klineView: EXContractFlutterKLine = { //default -bottom
//        let kview = EXContractFlutterKLine(viewModel: self.klineViewModel)
//        kview.isHidden = true
//        return kview
//    }()
//    
//    lazy var seperatorLine: UIView = {
//        let v = UIView()
//        v.backgroundColor = UIColor.ThemeView.seperator
//        v.isHidden = true
//        return v
//    }()
//}
//
//extension EXKlineFolderView{
//    class func getViewH(open: Bool) -> CGFloat{
//        return open ? 205 : 40
//    }
//    //MARK: method
//    func reloadView(openView: Bool){
//        
//        UIView.animate(withDuration: 0.15, animations: { [weak self] in
//            guard let self = self else { return }
//            self.titleLabel.isHidden = openView
//            self.klineTimeView.isHidden = !openView
//            self.seperatorLine.isHidden = !openView
//            self.klineView.isHidden = !openView
//        })
//        
//       
//        
//    }
//    //Currency pair switching
//    func upateEntity(){
//        //Title processing
//        if let contractInfo = self.viewModel?.currentItemModel?.ex_contractInfo {
//            let text = "cp_contract_perpetual_chart".ex_localized().replacingOccurrences(of: "%@", with: "")
//            titleLabel.text = contractInfo.showName() + text
////            klineView.contactM = contractInfo
////            klineView.priceDecimal = contractInfo.coinResultVo.symbolPricePrecision
////            klineView.volumeDecimal = String(EXSTools.decimalValue(px_unit: contractInfo.volumeDecial))
//            EXLogLine(mark:klineWorklog, message:"small kline update to \(contractInfo.showName())")
//            self.hasSubKline = false
//        }
//        
//        if self.open == false {
//            return
//        }
//        self.viewModel?.subscribeKline()
//    }
//    
//    func configUI(){
//        self.backgroundColor = UIColor.ThemeView.newbg
//        self.exs_addSubViews([topSeperatorLine,titleLabel,klineTimeView,rightArrow,seperatorLine,klineView])
//        
//        topSeperatorLine.snp.makeConstraints { make in
//            make.top.equalToSuperview()
//            make.left.right.equalToSuperview()
//            make.height.equalTo(0.5)
//        }
//        titleLabel.snp.makeConstraints { make in
//            make.left.equalToSuperview().offset(16)
//            make.top.equalToSuperview().offset(12)
//            make.height.equalTo(16)
//        }
//        rightArrow.snp.makeConstraints { make in
//            make.left.equalTo(titleLabel.snp.right).offset(10)
//            make.right.equalToSuperview().offset(-16)
//            make.centerY.equalTo(titleLabel)
//            make.width.height.equalTo(30)
//        }
//        klineTimeView.snp.makeConstraints { make in
//            make.left.equalToSuperview() //.offset(16)
//            make.right.equalTo(rightArrow.snp.left)
//            make.height.equalTo(34)
//            make.top.equalTo(2)
//        }
//
//        seperatorLine.snp.makeConstraints { make in
//            make.top.equalTo(klineTimeView.snp.bottom)
//            make.left.right.equalToSuperview()
//            make.height.equalTo(0.5)
//        }
//        
//        klineView.snp.makeConstraints { make in
//            make.top.equalTo(seperatorLine.snp.bottom)
//            make.left.right.bottom.equalToSuperview()
//        }
//    }
//    
//    
//    
//}
////Switching k line subscription cycles
//extension EXKlineFolderView: JXSegmentedViewDelegate{
//    func segmentedView(_ segmentedView: JXSegmentedView, didClickSelectedItemAt index: Int) {
//        //print("index= \(index)")
//        EXStoreData.setStoreObjectAndKey(index, key: smallklineScaleKeyIndex)
//        let key = convenienceScales[index]
//        handleScale(key: key)
//    }
//}
////K line refresh
//extension EXKlineFolderView{
//    
//    func dealKline(open: Bool){
//        if open{
//            //Synchronize selected indicators for size k line
//            updateSelectIndex()
//            //Differentiation between time-sharing and normal k-line
//            //            klineView.chartSerieSwitchToLineMode(on: (menuModel.scaleKey == EXNewKlineWsVm.keyLine))
//            //            klineView.updateMasterAlgorithm(to: menuModel.masterType)
//            if self.hasSubKline == false{
//                EXLogLine(mark:klineWorklog, message:"open-to subscribeKline")
//                self.viewModel?.subscribeKline()
//                self.hasSubKline = true
//            }
//        }
//    }
//    
//    
//    //Switching the k-line cycle
//    func handleScale(key:String) {
//        if lastScaleKey == key {
//            return
//        }
//        self.hasLoadedAllKline = false
//        lastScaleKey = key
//        EXStoreData.setStoreObjectAndKey(key, key: EXSklineScaleKey)
//        //        //print("Stored key= (EXCOMenuSelectionModel(). scaleKey)")
//        //        self.viewModel?.wsService.candleScale.value = key
//        self.viewModel?.klineVM.wsService.candleScale.accept(key)
//        //        klineView.showLoading()
//        //        klineView.chartSerieSwitchToLineMode(on: (key == EXNewKlineWsVm.keyLine))
//        //        klineView.updateMasterAlgorithm(to: menuModel.masterType)
//        
//    }
//    
//    
//    func handlekLineWs(){
//        
//        //K-line flipping
//        SwiftEventBus.onMainThread(self, name: EXCOEventBusConst.onKlinePrePageTrigger) {[weak self] result in
//            guard let `self` = self else {return}
//            if self.hasLoadedAllKline {
//                return
//            }
//            if self.open == false {return}
//            if self.viewModel?.isScrolling == true {return}
//            self.viewModel?.klineVM.wsService.wsHistoryKLinePre()
//        }
//    }
//}
////        self.viewModel?.wsService.flutterKLineHistroyDatas
////            .subscribe(onNext:{[weak self] (historys,hasPrePage) in
////                guard let `self` = self else {return}
////                if self.open == false {return}
////                if self.viewModel?.isScrolling == true {return}
//////                EXLogLine(mark:klineWorklog, message:"kLineHistroyDatas")
////
////                self.klineViewModel.flutterKLineHistroyDatas.onNext((historys, hasPrePage))
//////                self.handleHistory(klineData: historys,prepage: hasPrePage)
//////                EXLogLine(mark:klineWorklog, message:"render klineview")
////
////            }).disposed(by: self.disposeBag)
////
////        self.viewModel?.wsService.flutterkLineHistroyFinish
////            .subscribe(onNext:{[weak self] (finished) in
////                guard let `self` = self else {return}
////                if self.open == false {return}
////                if self.viewModel?.isScrolling == true {return}
////                if finished {
////                    EXLogLine(mark:klineWorklog, message:"kLineHistroyFinish")
////                    self.hasLoadedAllKline = true
////                    self.klineView.hideLoading()
////                }
////            }).disposed(by: self.disposeBag)
////
////        self.viewModel?.wsService.flutterkLineNowDatas
////            .subscribe(onNext:{[weak self] historys in
////                guard let `self` = self else {return}
////                if self.open == false {return}
////                if self.viewModel?.isScrolling == true {return}
////                self.handleNow(klineData: historys)
////            }).disposed(by: self.disposeBag)
////        // ticker
////        self.viewModel?.wsService.flutterTickPriceData
////            .subscribe(onNext:{[weak self] item in
////                guard let `self` = self else {return}
////                if self.open == false {return}
////                if self.viewModel?.isScrolling == true {return}
////               self.updateTicker(withItem: item)
////            }).disposed(by: self.disposeBag)
////    }
////
////    func handleHistory(klineData:[EXSKLineChartItem],prepage:Bool = false) {
////        klineView.hideLoading()
////        if prepage {
////            klineView.reloadPreData(data: klineData)
////        }else {
////           klineView.reloadData(data: klineData)
////        }
////    }
////
////    func handleNow(klineData:EXSKLineChartItem) {
////        klineView.appendData(data: klineData)
////    }
////    //Refresh the latest price
////    func updateTicker(withItem item:EXSTickItem) {
////        klineView.chartsView.nowValue = CGFloat(Double(item.close)!)
////    }
//
////}

