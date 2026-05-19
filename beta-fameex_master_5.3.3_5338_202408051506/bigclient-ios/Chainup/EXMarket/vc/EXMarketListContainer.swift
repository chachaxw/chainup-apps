//
//  EXMaketListContainer.swift
//  Chainup
//
//  Created by liuxuan on 2023/7/15.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import EXKit
import JXSegmentedView

let menuBarHeight:CGFloat = 46 //Top sliding height
//Ranking List Currency Selection
class EXMarketListContainer: EXBaseContainerVc {
    
    var marketLists :[EXMarketListVc] = []
    //[Currency Pair]=>[Main Area], [Innovation Area], [Observation Area], [Half Reduction Area]
    var marketCoins:[String:[[CoinDetailsEntity]]] = [:]
    //Market: [main area, innovation area, observation area, halved area]
    var marketZones:[String:[EXCoinZoneType]] = [:]
    
    lazy var listContainerView: JXSegmentedListContainerView! = {
        return JXSegmentedListContainerView(dataSource: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //When switching languages and skins, there was an issue with the signal. Please reset the EXMarketsDataHandler first
        EXMarketsDataHandler.destroy()
        EXMarketsDataHandler.shared().registerPubLicInfoSignal()
        registerMarketCoinsChange()
        addMarketSketelon()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if marketLists.count > currentIdx {
            //Attempt to connect to ws
            let currentVc = marketLists[currentIdx]
            currentVc.fetchwsDatas()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func indexDidChanged() {
        if marketLists.count > currentIdx {
            let vc = marketLists[currentIdx]
            if vc.marketCoins.count == 0,vc.marketZones.count == 0 {
                vc.bindMarketsAndZone(markets: self.marketCoins[vc.symbol] ?? [], zones: self.marketZones[vc.symbol] ?? [])
            }
            EXWebSocket.marketService.cancel()
            vc.fetchwsDatas()
        }
    }
}

//MARK: delegate
extension EXMarketListContainer {
    
    override func configTitles() -> [String]{
        return EXMarketsDataHandler.shared().marketNamesShow()
    }
}


//MARK: Old Logic

extension EXMarketListContainer {
    
    func checkReqData() {
        if EXMarketReqVm.shared().wsReviewData.isEmpty {
            EXMarketReqVm.shared().retryFetchReqV2()
        }
    }
    
    func registerMarketCoinsChange() {
        checkReqData()
        
        //When calling all market currency pairs, there is a pitfall. When switching languages, publicinfo will be called and a signal will be returned. This distinguishes between public_ After the info, it's ready
        EXMarketsDataHandler.shared().onFullMarketsPublish
            .subscribe(onNext: {[weak self] (markets,zones) in
                guard let `self` = self else {return}
                //All markets, markets: zone ->currency pairs
                //All markets+zones: zones ->zone classification
                //Print ("Received all currency pairs")
                self.marketCoins = markets
                self.marketZones = zones
                self.bindMarketlists()
                self.marketLists.removeAll()
                let markets = EXMarketsDataHandler.shared().marketNamesShow()
                self.updateTabbars(with: markets)                
            }).disposed(by: self.disposeBag)
        
        //Got the review v2
        EXMarketReqVm.shared().rx_wsReviewData
            .skip(1)
            .subscribe(onNext: {[weak self] (datas) in
                guard let `self` = self else {return}
                if datas.count > 0 {
//                    print("Received price change for req")
                    self.prepareDefaultPrices()
                }
            }).disposed(by: self.disposeBag)
    }
    
    func prepareDefaultPrices() {
        let wsDataInfo = EXMarketReqVm.shared().wsReviewData
        //TODO: After receiving the data, you need to
        //Initialize all existing market currency pairs
        if wsDataInfo.count > 0 {
            for vc in marketLists {
                vc.prepareDefaultPrices(false)
            }
        }
    }
    
    func listContainerReloadData() {
        //Pay attention to the current controller
        if marketLists.count > currentIdx {
            let currentVc = marketLists[currentIdx]
            currentVc.fetchwsDatas()
            checkReqData()
        }
    }
    
    func resetExMarketData() {
        EXMarketsDataHandler.destroy()
    }
}


//MARK: Processing currency pair display, ws, etc
extension EXMarketListContainer {
    
    func currentVc() -> EXMarketListVc? {
        if marketLists.count > currentIdx {
            let currentVc = marketLists[currentIdx]
            return currentVc
        }
        return nil
    }
    
    func bindMarketlists() {
        
        if segmentedView.listContainer == nil {
            segmentedView.listContainer = self.listContainerView
            self.view.addSubview(self.listContainerView)
            listContainerView.snp.remakeConstraints { make in
                make.top.equalTo(segmentedView.snp.bottom)
                make.left.right.bottom.equalToSuperview()
            }
        }
       
    }


    
    func distributeTicker(_ data:EXMarketWsModel,symbol:String) {
        if marketLists.count > currentIdx,symbol.count > 0 {
//Print ("distribution")
            let currentVc = marketLists[currentIdx]
            currentVc.updateTicker(ticker: data.tick, symbol: symbol)
        }
    }
}


extension EXMarketListContainer : EXTradeCmdProtocal {
    
    func excuteCmd(symbol: String, action: String) {
        let names:[String] = EXMarketsDataHandler.shared().marketNames()
        if names.count == 0 {
            return
        }
        
        var scrollIdx = 0
        for (idx,item) in names.enumerated() {
            if item == symbol {
                scrollIdx = idx
            }
        }
        if marketLists.count > scrollIdx {
            self.segmentedView.selectItemAt(index: scrollIdx)
        }
    }
}

extension EXMarketListContainer: JXSegmentedListContainerViewDataSource {
    
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        let name = EXMarketsDataHandler.shared().marketNames()[index]
        let market = EXMarketListVc()
        market.symbol = name
        market.bindMarketsAndZone(markets: self.marketCoins[name] ?? [], zones: self.marketZones[name] ?? [])
        if index == 0 {
            market.fetchwsDatas()
        }
        if !marketLists.contains(market) {
            marketLists.append(market)
        }
        return market
    }
}


extension EXMarketListContainer: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self.view
    }
}

