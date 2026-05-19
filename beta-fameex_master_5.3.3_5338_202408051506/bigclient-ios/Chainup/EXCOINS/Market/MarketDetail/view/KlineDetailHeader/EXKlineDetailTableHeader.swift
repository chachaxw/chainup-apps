//
//  EXKlineDetailTableHeader.swift
//  Chainup
//
//  Created by liuxuan on 2023/10/13.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXKlineDetailTableHeader: UIView {
    
    var showMenuDuration = 0.23
    var hideMenuDuration = 0.23
    var dropDownViews: [UIView] = []
    var openedIndex:Int = 0 //More is 0, indicator is 1
    var opened: Bool = false
    var dropDownSender:UIButton?
    var isSwap: Bool = false //Inconsistent copy
    lazy var filterContainer:UIView = {
        let mask = UIView()
        mask.backgroundColor = UIColor.clear
        mask.clipsToBounds = true
        return mask
    }()

    lazy var maskbgView:UIView = {
        let mask = UIView()
        mask.backgroundColor = UIColor.ThemeView.mask
        let originY = self.menuBar.frame.minY
        mask.frame = CGRect(x: self.frame.origin.x, y: originY, width: self.frame.width, height: SCREEN_HEIGHT - originY)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(maskViewClicked(_:)))
        mask.addGestureRecognizer(tapGesture)
        let panGesture = UIPanGestureRecognizer.init(target: self, action:  #selector(maskViewClicked(_:)))
        mask.addGestureRecognizer(panGesture)
        mask.alpha = 0
        return mask
    }()
    
    typealias ZoomActionBlock = () -> ()
    var onZoomActionCallback : ZoomActionBlock?

    var coinEntity:CoinMapEntity = CoinMapEntity() {
        didSet {
            self.showNetWorth()
            klineView.hideSelection()
            klineView.priceDecimal = coinEntity.price
            klineView.volumeDecimal = coinEntity.volume
        }
    }
    
    ///Turn off net value display flag (true: hide net value display, even for ETFs)
    var isCloseNetworth: Bool = false {
        didSet {
            self.hideNetWorth()
        }
    }
    
    var menuModel = EXMenuSelectionModel.init() {
        didSet {
            klineView.updateMasterAlgorithm(to: menuModel.masterType)
            klineView.updateAssistantAlgorithm(to: menuModel.assitantType)
        }
    }
    var onMenuActionCallback:MenuActionCallback?

    lazy var tickerHeader:EXKlineTickerHeader = {
        let header:EXKlineTickerHeader = EXKlineTickerHeader.init(frame: .zero)
        return header
    }()
    
    lazy var etfBar:EXKlineETFHeader = {
        let header:EXKlineETFHeader = EXKlineETFHeader()
        return header
    }()
    
    lazy var menuBar:EXKlineFilterMenu = {
        let header:EXKlineFilterMenu = EXKlineFilterMenu()
        header.backgroundColor = UIColor.ThemekLine.viewBg
        return header
    }()
    
    lazy var klineView:EXKLineView = {
        let kview = EXKLineView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 500))
        return kview
    }()
    
    lazy var klineDepthView: EXKlineDepthView = {
        let kview = EXKlineDepthView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 500))
        return kview
    }()
    
    lazy var container:UIStackView = {
        let container:UIStackView = UIStackView.init()
        container.axis = .vertical
        return container
    }()
    
    lazy var klineContainer:UIView = {
        let container:UIView = UIView.init()
        container.backgroundColor = UIColor.ThemekLine.viewBg
        return container
    }()
    
    lazy var gap:UIView = {
        let header:UIView = UIView()
//        header.backgroundColor = UIColor.ThemekLine.navBg
//        header.backgroundColor = UIColor.red
        return header
    }()
    
    var scaleDrop:KlineScaleDropMenu?
    var indexDrop:KlineIndexDropMenu?

    required init(entity:CoinMapEntity) {
        coinEntity = entity
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: EXKlineDetailTableHeader.getHeightHasETF(entity.etfOpen == "1")))
//        self.addSubview(container)
        self.addSubview(tickerHeader)
        self.addSubview(etfBar)
        self.addSubview(menuBar)
//        container.addArrangedSubview(klineView)
//        container.addArrangedSubview(klineDepthView)
//        container.addArrangedSubview(gap)
        self.addSubview(klineContainer)
        klineContainer.addSubview(klineView)
        klineContainer.addSubview(klineDepthView)
        self.addSubview(gap)
        
        tickerHeader.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(76)
        }
        gap.snp.makeConstraints { (make) in
            make.height.equalTo(10)
            make.bottom.equalToSuperview()
            make.top.equalTo(klineContainer.snp.bottom)
            make.left.right.equalToSuperview()
        }
        
        let barHeight = entity.etfOpen == "1" ? 28 : 0
        
        etfBar.snp.makeConstraints { (make) in
            make.top.equalTo(tickerHeader.snp.bottom)
            make.left.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(barHeight)
        }
        
        menuBar.snp.makeConstraints { (make) in
            make.top.equalTo(etfBar.snp.bottom)
            make.left.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(36)
        }
        
//        container.snp.makeConstraints { (make) in
//            make.top.equalTo(menuBar.snp.bottom)
//            make.left.equalToSuperview()
//            make.width.equalToSuperview()
//            make.bottom.equalToSuperview()
//        }
//
        klineContainer.snp.makeConstraints { (make) in
            make.top.equalTo(menuBar.snp.bottom)
            make.left.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalTo(gap.snp.top)
        }
        
        klineView.priceDecimal = entity.price
        klineView.volumeDecimal = entity.volume
        klineView.chartsView.backgroundColor = UIColor.ThemekLine.viewBg
        klineDepthView.isHidden = true
        configFilters()
        if menuModel.scaleKey == EXKlineWsVm.keyLine {
            klineView.chartSerieSwitchToLineMode(on:true)
        }
    }
    
    
    
    func configFilters() {
        
        menuBar.actionCallback = {[weak self] (action,sender,key) in
            self?.handleMenuAction(action: action, sender: sender,key: key)
        }
        
        self.scaleDrop = KlineScaleDropMenu.init(frame: CGRect(x: self.frame.origin.x, y:menuBar.frame.minY, width: self.frame.size.width, height:KlineScaleDropMenu.getHeight()))
        self.scaleDrop?.scaleDidChange =  {[weak self] (sender,key) in
//            guard let key = sender.titleLabel?.text else {return}
            self?.handleMenuAction(action: .changeScale, sender: sender,key: key)
            self?.menuBar.moreMenuSelected(key: key)
            self?.hideMenu()
        }
        self.scaleDrop?.zoomActionCallback = {[weak self] (sender,key) in
            self?.handleMenuAction(action: .zoom, sender: sender,key: "")
            self?.hideMenu()
        }
        
        dropDownViews.append(scaleDrop!)
        
        self.indexDrop = KlineIndexDropMenu.init(frame: CGRect(x: self.frame.origin.x, y:menuBar.frame.minY, width: self.frame.size.width, height:KlineScaleDropMenu.getHeight()))
        indexDrop?.masterTypeChange = {[weak self] type in
            self?.menuModel.masterType = type
            self?.klineView.hideSelection()
            self?.klineView.updateMasterAlgorithm(to: type)
        }
        indexDrop?.assistantTypeChange = {[weak self] type in
            self?.menuModel.assitantType = type
            self?.klineView.hideSelection()
            self?.klineView.updateAssistantAlgorithm(to: type)
        }
        dropDownViews.append(indexDrop!)
    }
    //Switch menu
    func handleMenuAction(action:KLineFilterMenuAction,sender:UIButton,key:String) {
        
        if action == .switchDepth {
            //Switch Depth&kLine
            self.switchDepth(change: true)
        }else if action == .changeScale {
            //Switch Depth&kLine ->Modify Timeline
            klineView.hideSelection()
            self.switchDepth(change: false)
        }else if action == .moreScale {
            dropDownSender = sender
            scaleDrop?.updateScale(scaleKey: sender.titleLabel?.text ?? "")
            self.showAndHideMenu(at: 0)
        }else if action == .showIndex {
            indexDrop?.updateMasterType(masterType: menuModel.masterType, assistantType: menuModel.assitantType)
            dropDownSender = sender
            self.showAndHideMenu(at: 1)
        }else if action == .zoom {
            self.hideMenu()
        }
        self.onMenuActionCallback?(action,sender,key)
    }
    
    func switchDepth(change:Bool) {
        self.hideMenu()
        klineView.isHidden = change
        klineDepthView.isHidden = !change
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func getHeightHasETF(_ hasETF:Bool) -> CGFloat{
        if hasETF  {
            return 640 + 10
        }else {
            return 612 + 10
        }
    }
    
    func klineViewIsEmpty() -> Bool {
        return klineView.chartsView.datas.count == 0
    }
    //Contract page updates
    func reloadLable(isSwap:Bool = false) {
//        if isSwap {
//            self.isSwap = true
//            self.tickerHeader.reloadLable()
//            menuBar.updateSwapLoad()
//            self.scaleDrop?.uploadSwap()
//            self.indexDrop?.mainLabel.text = "cp_extra_text155".ex_localized()
//            self.indexDrop?.subLabel.text = "cp_extra_text156".ex_localized()
//        }else{
            menuBar.configMenus()
//        }
  
    }
}

extension EXKlineDetailTableHeader {
    
    func updateTicker(withItem item:TickItem) {
        tickerHeader.updateTicker(ticker: item,entity: coinEntity)
        klineView.chartsView.nowValue = CGFloat(Double(item.close)!)
    }
    
    //Whether to display net value
    func showNetWorth() {
        
        if self.isCloseNetworth == true {
            return
        }
        
        etfBar.isHidden = (coinEntity.etfOpen == "1") ? false : true
        let barHeight = coinEntity.etfOpen == "1" ? 28 : 0
        etfBar.snp.remakeConstraints { (make) in
            make.top.equalTo(tickerHeader.snp.bottom)
            make.left.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(barHeight)
        }
        
    }
    
    
    func hideNetWorth() {
        if self.isCloseNetworth == false {
            return
        }
        etfBar.snp.remakeConstraints { (make) in
            make.top.equalTo(tickerHeader.snp.bottom)
            make.left.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(0)
        }
    }
    
    
    func updateItems(depthItems:[CHKDepthChartItem],max:Float,price:String ,entity : CoinMapEntity) {
        if price != ""{
            klineDepthView.updatedepthData(models: depthItems, maxAmount: max, price: price , entity : entity)
        }else {
            klineDepthView.updatedepthData(models: depthItems, maxAmount: max, price:"--" , entity : entity)
        }
    }
    
    func setNetWorth(model:EXETFNetValueModel) {
        etfBar.setNetWorth(model: model,symbol: coinEntity.symbol)
    }
}

extension EXKlineDetailTableHeader {
    
    internal func showAndHideMenu(at index:Int) {
        if openedIndex != index && opened {
            self.hideMenu(dropView:  dropDownViews[openedIndex]) {
                self.showMenu(dropView: self.dropDownViews[index]) {}
            }
            openedIndex = index
            return
        }
        openedIndex = index
        if !opened {
            self.showMenu(dropView: dropDownViews[index]) {}
        } else {
            self.hideMenu(dropView:  dropDownViews[index]) {}
        }
        opened = !opened
    }
    
    internal func showMenu(dropView:UIView,didComplete:(()-> Void)?) {
        dropView.alpha = 1
        let originY = self.convert(menuBar.frame.origin, to: self.yy_viewController?.view).y + menuBar.frame.height
        
        filterContainer.frame = CGRect(x: self.frame.origin.x, y: originY, width: self.frame.width, height: SCREEN_HEIGHT)
        
        if self.openedIndex == 0 {
            dropView.frame = CGRect(x: self.frame.origin.x, y: -(KlineScaleDropMenu.getHeight()), width: self.frame.size.width, height: KlineScaleDropMenu.getHeight())
        }else {
            dropView.frame = CGRect(x: self.frame.origin.x, y: -(KlineIndexDropMenu.getHeight()), width: self.frame.size.width, height: KlineIndexDropMenu.getHeight())
        }
                
        maskbgView.frame = CGRect(x: self.frame.origin.x, y: 0, width: self.frame.width, height: SCREEN_HEIGHT)

        self.yy_viewController?.view.addSubview(filterContainer)
        filterContainer.addSubview(maskbgView)
        filterContainer.addSubview(dropView)

        UIView.animate(
            withDuration: self.showMenuDuration,
            delay: 0,
            options: [.curveEaseIn],
            animations: {
                self.maskbgView.alpha = 1
                dropView.frame.origin.y = 0
            }, completion: { _ in
                didComplete?()
            })
    }
    
    internal func hideMenu(dropView:UIView,didComplete:(()-> Void)?) {
        UIView.animate(
            withDuration: self.hideMenuDuration,
            delay: 0,
            options: [.curveEaseOut],
            animations: {
                self.maskbgView.alpha = 0
                if self.openedIndex == 0 {
                    dropView.frame.origin.y =  -(KlineScaleDropMenu.getHeight())
                }else {

                    dropView.frame.origin.y =  -(KlineIndexDropMenu.getHeight())
                }
        }, completion: { _ in
            self.maskbgView.removeFromSuperview()
            dropView.removeFromSuperview()
            self.filterContainer.removeFromSuperview()
            didComplete?()
        })
    }
    
    @objc internal func maskViewClicked(_ sender: UITapGestureRecognizer) {
        self.hideMenu()
    }
    
    open func hideMenu() {
        guard opened else { return }
        if let sender = self.dropDownSender {
            sender.isSelected = false
        }
        self.hideMenu(dropView:  dropDownViews[openedIndex]) {}
        opened = !opened
    }
}

