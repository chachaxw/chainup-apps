//
//  EXTradeHeaderV.swift
//  Chainup
//
//  Created by liuxuan on 2023/10/26.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import RxSwift

class EXTradeHeaderV: EXTradeHeaderBase {
    //362 height

    lazy var orderArea :TradeOrderArea = {
        let v = TradeOrderArea.init(entity: self.entity, orderType: self.orderType,layoutType: self.headerLayout,action: .buy)
        return v
    }()

    lazy var depthArea :TradeDepthArea = {
        let v = TradeDepthArea.init(entity: self.entity,orderType: self.orderType,layoutType: self.headerLayout,action: .buy)
        return v
    }()
    
    lazy var topBar: EXLeverTradeTopBar = {
        let v = EXLeverTradeTopBar.init()
        v.tappedCallback = {[weak self]  in
            self?.onLeverActionTapped()
        }
        return v
    }()
    
    lazy var etfJumpBar: EXRecommendETFBar = {
        let v = EXRecommendETFBar.init()
        return v
    }()
    
    override func onCreate() {
        configTradeHeaderSubviews()
        depthArea.clickDepthBlock = {[weak self] entity in
            guard let `self` = self  else {return}
            self.orderArea.orderCommonArea.updatePrice(price: entity.price)
        }
        orderArea.clickOrderActionBlock = {[weak self] action in
            guard let `self` = self  else {return}
            self.clearSuggestStr()
            if action == .buy {
                self.depthArea.configSuggestBuy()
            }else {
                self.depthArea.configSuggestSell()
            }
        }
        configSuggestions()
        super.onCreate()
    }
    
    func configSuggestions() {

        depthArea.suggestBuy
            .subscribe(onNext: {[weak self] buy in
                guard let `self` = self  else {return}
                //print ("Vertical Switch Coin Pair Buy")
                let str = self.orderArea.orderCommonArea.suggestBuyStr
                if str.isEmpty {
                    self.orderArea.orderCommonArea.suggestBuyStr = buy
                    self.orderArea.orderCommonArea.updatePrice(price: buy)
                }
            }).disposed(by: self.disposeBag)
        depthArea.suggestSell
            .subscribe(onNext: {[weak self] sell in
                guard let `self` = self  else {return}
                //print ("Vertical Switch Coin Pair Sell")
                let str = self.orderArea.orderCommonArea.suggestSellStr
                if str.isEmpty {
                    self.orderArea.orderCommonArea.suggestSellStr = sell
                    self.orderArea.orderCommonArea.updatePrice(price: sell)
                }

            }).disposed(by: self.disposeBag)
    }
    
    func configTradeHeaderSubviews() {
        centerView.addSubViews([orderArea, depthArea])
   
        let leftWidth = (SCREEN_WIDTH - contentInsets.left - contentInsets.right)*0.54667
        if self.orderType == .leverage {
            
            centerView.addSubview(topBar)
            topBar.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.right.equalToSuperview()
                make.height.equalTo(30)
            }
            
            depthArea.snp.makeConstraints { (make) in
                make.top.equalTo(topBar.snp.bottom).offset(12)
                make.left.equalToSuperview()
                make.bottom.equalToSuperview()
            }
            
            orderArea.snp.makeConstraints { (make) in
                make.top.equalTo(depthArea)
                make.bottom.lessThanOrEqualTo(depthArea)
                make.left.equalTo(depthArea.snp.right).offset(16)
                make.right.equalToSuperview()
                make.width.equalTo(leftWidth)
             
            }

        }else {
            configEtfLayouts()
        }
    }
    
    func configEtfLayouts(){
        if self.orderType == .leverage {
            return 
        }
        let leftWidth =  (SCREEN_WIDTH - contentInsets.left - contentInsets.right)*0.54667
        var etfBar:UIView?
        let hasETFUpAndDowns = self.entity.etfUpAndDown.map { (etf) -> String in
            let etfItem = EXAppMarketManager.sharedInstance.getCoinMapEntityBySymbol(etf.lowercased())
            return etfItem.symbol
        }.filter{ $0.count > 0 }
        
        if hasETFUpAndDowns.count > 0 {
            etfJumpBar.isHidden = false
            if etfJumpBar.superview == nil {
                centerView.addSubview(etfJumpBar)
            }
            etfJumpBar.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.equalToSuperview()
                make.right.equalToSuperview()
            }
            etfBar = etfJumpBar
            etfJumpBar.updateWithEntity(entity: self.entity)
        }else {
            etfJumpBar.isHidden = true
        }
        
        depthArea.snp.remakeConstraints { (make) in
            if let hasEtf = etfBar {
                make.top.equalTo(hasEtf.snp.bottom).offset(12)
            }else {
                make.top.equalToSuperview()
            }
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        orderArea.snp.remakeConstraints { (make) in
            make.top.equalTo(depthArea)
            make.bottom.lessThanOrEqualTo(depthArea)
            make.left.equalTo(depthArea.snp.right).offset(16)
            make.right.equalToSuperview()
            make.width.equalTo(leftWidth)
        }
    }
    
    override func refreshEntity(entity:CoinMapEntity) {
        super.refreshEntity(entity: entity)
        configEtfLayouts()
        orderArea.reload(entity)
        depthArea.reload(entity)
        clearSuggestStr()
    }
    
    func clearSuggestStr() {
        self.orderArea.orderCommonArea.suggestSellStr = ""
        self.orderArea.orderCommonArea.suggestBuyStr = ""
    }
    
    func resetSuggestions() {
        self.depthArea.firstSell = nil
        self.depthArea.firstBuy = nil
        self.depthArea.priceNow = nil
    }
    
    @objc func onLeverActionTapped() {
        self.onLeverPanelCallback?()
    }
    
    func udpateLeverModel(model:EXLeverFinanceBalanceModel) {
        topBar.riskRateV.valueLabel.textColor = model.riskColor()
        topBar.riskRateV.valueLabel.text = model.fmsRiskRate()
        topBar.loseCutV.valueLabel.text = model.fmsburstPrice()
    }
    func clearLeverModel() {
        topBar.riskRateV.titleLabel.textColor = .Ex.text2
        topBar.riskRateV.valueLabel.textColor = .Ex.text2
        topBar.riskRateV.valueLabel.text = "--"
        topBar.loseCutV.valueLabel.text = "--"
    }
}

//MARK:Actions
extension EXTradeHeaderV {
    
    func updateDepthLayout(_ idx:Int) {
        //Idx 0 1 2 default/buy/sell
        depthArea.updateDepthLayout(idx)
    }
    
    func getOrderWayWidth() -> CGFloat {
        return self.orderArea.width
    }
    
    
    
    func updateOrderWay(orderWay:EXTradeOrderWay) {
        depthArea.orderWay = orderWay
        orderArea.orderWay = orderWay
        orderArea.onOrderWayChangend()
    }
}


