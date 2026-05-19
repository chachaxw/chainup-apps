//
//  EXMarketDetailViewController.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/12.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import SwiftEventBus
import EXKit
import Swap
//Bring in indicators/bring in map switches/k line data

class EXMarketDetailHolzontalVc: UIViewController,StoryBoardLoadable {
    
    @IBOutlet var leftSafeAreaWidth: NSLayoutConstraint!
    @IBOutlet var rightSafeAreaWidth: NSLayoutConstraint!
    @IBOutlet var indexFooterView: EXHorizonlIndexContainer!
    @IBOutlet var topSafeAreaWidth: NSLayoutConstraint!
    @IBOutlet var topRSafeAreaWidth: NSLayoutConstraint!
    @IBOutlet var klineView: EXKLineView!
    
    @IBOutlet var topLeftHeader: EXHorizontalTopLeft!
    @IBOutlet var topRightHeader: EXHorizontalTopRight!
    @IBOutlet var mainMenu: EXHorizontalMainMenu!
    @IBOutlet var assistantMenu: EXHorizonAssistantMenu!
    let menuPublish : PublishSubject<EXMenuSelectionModel> = PublishSubject.init()
    @IBOutlet var closeBtn: UIButton!
    var accountType:KLineAccountType = .coin
    var viewModel = EXMarketHorlzontalViewModel()
    var coinMapEntity:CoinMapEntity =  CoinMapEntity()
    var hasLoadedAllKline = false

    var menuModel:EXMenuSelectionModel = EXMenuSelectionModel(){
        didSet {

        }
    }
    var wsService:EXMarketKlineService = EXMarketKlineService()
//    var wsVm:EXKlineWsVm = EXKlineWsVm()
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
    func transform(){
        self.view.frame = CGRect(x:0, y:0, width:SCREEN_HEIGHT, height:SCREEN_WIDTH)
        let frame = UIScreen.main.bounds
        let center = CGPoint(x: frame.origin.x + ceil(frame.size.width/2), y: frame.origin.y + ceil(frame.size.height/2))
        self.view.center = center
        self.view.transform = CGAffineTransform(rotationAngle: CGFloat(Float.pi/2))
    }
    
    func handleSafeArea(){
        leftSafeAreaWidth.constant = BANG_HEIGHT
        rightSafeAreaWidth.constant = TABBAR_BOTTOM
        topSafeAreaWidth.constant = BANG_HEIGHT
        topRSafeAreaWidth.constant = TABBAR_BOTTOM
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.handleNotifi()
        self.transform()
        self.handleKlinePrePage()
        self.handleSafeArea()
        self.handleMenu()
        self.handlekLineWs()
        self.handlekLineScale()
        self.klineView.chartsView.backgroundColor = UIColor.ThemekLine.viewBg
        self.klineView.priceDecimal = coinMapEntity.price
        self.klineView.volumeDecimal = coinMapEntity.volume
        closeBtn.setImage(UIImage.exs_themeImageNamed(imageName: "public_close"), for: .normal)
        topLeftHeader.backgroundColor = UIColor.ThemekLine.navBg
        topRightHeader.backgroundColor = UIColor.ThemekLine.navBg
        self.handleScale(key: self.menuModel.scaleKey)
    }
    
    func handlekLineWs() {
        self.wsService.register()
        self.wsService.accountType = self.accountType
        self.wsService.entity = self.coinMapEntity
        self.wsService.kLineHistroyDatas
            .subscribe(onNext:{[weak self] (historys,hasPre) in
                guard let `self` = self else {return}
                self.handleHistory(klineData: historys,prepage: hasPre)
        }).disposed(by: self.disposeBag)

        self.wsService.kLineNowDatas
            .subscribe(onNext:{[weak self] historys in
                guard let `self` = self else {return}
                self.handleNow(klineData: historys)
            }).disposed(by: self.disposeBag)

        self.wsService.tickPriceData
            .subscribe(onNext:{[weak self] item in
                guard let `self` = self else {return}
                self.handlePrice(item: item)
            }).disposed(by: self.disposeBag)
        
        wsService.kLineHistroyFinish
               .subscribe(onNext:{[weak self] (finished) in
                   guard let `self` = self else {return}
                   if finished {
                       self.hasLoadedAllKline = true
                       self.klineView.hideLoading()
                   }
               }).disposed(by: self.disposeBag)
    }
    
    func handleKlinePrePage() {
        SwiftEventBus.onMainThread(self, name: EXEventBusConst.onKlinePrePageTrigger) {[weak self] result in
            guard let `self` = self else {return}

            if self.hasLoadedAllKline {
                return
            }
            self.wsService.wsHistoryKLinePre()
            self.klineView.showLoading()
        }
    }
    
    func handleMenu(){
        
        mainMenu.selectOn(type: menuModel.masterType)
        self.klineView.updateMasterAlgorithm(to: menuModel.masterType)
        mainMenu.masterAlgorithmCallback = {[weak self] type in
            self?.menuModel.masterType = type
            self?.klineView.updateMasterAlgorithm(to: type)
            self?.klineView.hideSelection()
        }
        
        assistantMenu.selectOn(type: menuModel.assitantType)
        self.klineView.updateAssistantAlgorithm(to: menuModel.assitantType)

        assistantMenu.assistantAlgorithmCallback = {[weak self] type in
            self?.menuModel.assitantType = type
            self?.klineView.updateAssistantAlgorithm(to: type)
            self?.klineView.hideSelection()

        }

        
    }
    
    func handlekLineScale(){
        indexFooterView.loadItems()
        indexFooterView.defaultScale(key:menuModel.scaleKey)
//        self.handleScale(key: menuModel.scaleKey)
        indexFooterView.scaleDidChage = {[weak self] key in
            if self?.menuModel.scaleKey == key {
                return 
            }
            self?.menuModel.scaleKey = key
            self?.handleScale(key: key)
            self?.klineView.hideSelection()
            self?.hasLoadedAllKline = false
            self?.klineView.showLoading()
        }
    }
    
    func handleHistory(klineData:[KLineChartItem],prepage:Bool = false) {
        self.klineView.hideLoading()
        if prepage {
            klineView.reloadPreData(data: klineData)
        }else {
            klineView.reloadData(data: klineData)
        }
    }
    
    func handleNow(klineData:KLineChartItem) {
        klineView.appendData(data: klineData)
    }
    
    func handlePrice(item:TickItem) {
        if self.accountType == .contract {
            
            topRightHeader.updatePrices(item: viewModel.handleContractPrice(item: item))
            topLeftHeader.rmbLabel.isHidden = true
            
        }else {
            
            topRightHeader.updatePrices(item: item,basicSymbol:self.coinMapEntity.marketName)
        }
        topLeftHeader.updatePrices(item: item,title:self.coinMapEntity.name.aliasCoinMapName())
        klineView.chartsView.nowValue = CGFloat(Double(item.close)!)

    }
    
    func handleScale(key:String) {
        wsService.candleScale.accept(key)
        klineView.chartSerieSwitchToLineMode(on: (key == EXKlineWsVm.keyLine))
    }

    @IBAction func close(_ sender: Any) {
        menuPublish.onNext(self.menuModel)
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension EXMarketDetailHolzontalVc {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        wsService.getHistoriesAndTicker()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        wsService.cancelAll()
    }
    
    func handleNotifi() {
        _ = NotificationCenter.default.rx
            .notification(UIApplication.didBecomeActiveNotification)
            .take(until: self.rx.deallocated) //Page destruction automatic removal notification listening
            .subscribe(onNext: {[weak self] noti in
                self?.homeBtnAction(false)
            })
        
        _ = NotificationCenter.default.rx
            .notification(UIApplication.willResignActiveNotification)
            .take(until: self.rx.deallocated) //Page destruction automatic removal notification listening
            .subscribe(onNext: {[weak self] noti in
                self?.homeBtnAction(true)
            })
        
        _ = NotificationCenter.default.rx
            .notification(Notification.Name(rawValue: NOTI_WS_RECONNECTED))
            .take(until: self.rx.deallocated) //Page destruction automatic removal notification listening
            .subscribe(onNext: {[weak self] noti in
                self?.wsService.reConnectAll()
            })
    }
    
    func homeBtnAction(_ enterBackground:Bool) {
        //Pay attention to the current controller
        guard let top = AppService.topViewController() else {return}
        if top == self {
            if enterBackground {
                wsService.cancelAll()
            }else {
                wsService.getHistoriesAndTicker()
            }
        }
    }
}

