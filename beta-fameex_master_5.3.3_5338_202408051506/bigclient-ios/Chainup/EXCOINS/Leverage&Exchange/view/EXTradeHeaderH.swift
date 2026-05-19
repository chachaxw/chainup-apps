//
//  EXTradeHeaderH.swift
//  Chainup
//
//  Created by 劉軒 on 2023/10/31.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXTradeHeaderH: EXTradeHeaderBase {
    
    lazy var orderArea :TradeOrderAreaH = {
        let v = TradeOrderAreaH.init(entity: self.entity, orderType: self.orderType,layoutType: self.headerLayout,action: .buy)
        return v
    }()

    lazy var depthArea :TradeDepthAreaH = {
        let v = TradeDepthAreaH.init(entity: self.entity, orderType: self.orderType,layoutType: self.headerLayout,action: .buy)
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
        let v = EXRecommendETFBar()
        return v
    }()
    
    override func onCreate() {
        super.onCreate()
        centerView.addSubview(orderArea)
        centerView.addSubview(depthArea)
        configSuggestions()
        depthArea.clickDepthBlock =  {[weak self] entity in
            guard let `self` = self  else {return}
            self.orderArea.orderBuyArea.updatePrice(price: entity.price)
            self.orderArea.orderSellArea.updatePrice(price: entity.price)
        }
        
        if self.orderType == .leverage {
            centerView.addSubview(topBar)
            topBar.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.height.equalTo(30)
            }
            
            depthArea.snp.makeConstraints { (make) in
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.top.equalTo(topBar.snp.bottom).offset(8)
            }
            
            orderArea.snp.makeConstraints { (make) in
                make.top.equalTo(depthArea.snp.bottom)
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.bottom.equalToSuperview()
            }
        }else {
            configETFLayouts()
        }
    }
    
    func configETFLayouts() {
        if self.orderType == .leverage {
            return
        }
        
        let hasETFUpAndDowns = self.entity.etfUpAndDown.map { (etf) -> String in
            let etfItem = EXAppMarketManager.sharedInstance.getCoinMapEntityBySymbol(etf.lowercased())
            return etfItem.symbol
        }.filter{ $0.count > 0 }
        
        etfJumpBar.isHidden = hasETFUpAndDowns.isEmpty
        if !etfJumpBar.isHidden {
            if etfJumpBar.superview == nil {
                centerView.addSubview(etfJumpBar)
            }
            etfJumpBar.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.equalToSuperview()
                make.right.equalToSuperview()
            }
            etfJumpBar.updateWithEntity(entity: entity)
        }
        depthArea.snp.remakeConstraints { (make) in
            if etfJumpBar.isHidden {
                make.top.equalToSuperview()
            }else{
                make.top.equalTo(etfJumpBar.snp.bottom).offset(8)
            }
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        orderArea.snp.remakeConstraints { (make) in
            make.top.equalTo(depthArea.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            if cmFooter.isHidden {
                make.bottom.equalToSuperview()
            }else {
                make.bottom.equalTo(cmFooter.snp.top)
            }
        }
    }


    override func refreshEntity(entity: CoinMapEntity) {
        super.refreshEntity(entity: entity)
        configETFLayouts()
        orderArea.reload(entity)
        depthArea.reload(entity)
        self.orderArea.orderSellArea.suggestSellStr = ""
        self.orderArea.orderBuyArea.suggestBuyStr = ""
    }
    
    func configSuggestions() {
        depthArea.suggestBuy
            .subscribe(onNext: {[weak self] buy in
                guard let `self` = self  else {return}
                //Print ("Horizontal version switching currency pair buy")
                let str = self.orderArea.orderBuyArea.suggestBuyStr
                if str.isEmpty {
                    self.orderArea.orderBuyArea.suggestBuyStr = buy
                    self.orderArea.orderBuyArea.updatePrice(price: buy)
                }
    
            }).disposed(by: self.disposeBag)
        depthArea.suggestSell
            .subscribe(onNext: {[weak self] sell in
                guard let `self` = self  else {return}
                //Print ("Horizontal Switch Coin Pair Sell")
                let str = self.orderArea.orderSellArea.suggestSellStr
                if str.isEmpty {
                    self.orderArea.orderSellArea.suggestSellStr = sell
                    self.orderArea.orderSellArea.updatePrice(price: sell)
                }
            }).disposed(by: self.disposeBag)
    }
    
    func getOrderWayWidth() -> CGFloat {
        return self.orderArea.width
    }
    
    func updateOrderWay(orderWay:EXTradeOrderWay) {
        orderArea.orderWay = orderWay
        orderArea.onOrderWayChangend()
    }
    
    @objc func onLeverActionTapped() {
        self.onLeverPanelCallback?()
    }
    
    func udpateHLeverModel(model:EXLeverFinanceBalanceModel) {
        topBar.riskRateV.valueLabel.textColor = model.riskColor()
        topBar.riskRateV.valueLabel.text = model.fmsRiskRate()
        topBar.loseCutV.valueLabel.text = model.fmsburstPrice()
    }
    
    
    func clearLeverModel() {
        topBar.riskRateV.titleLabel.textColor = UIColor.ThemeLabel.colorMedium
        topBar.riskRateV.valueLabel.textColor = UIColor.ThemeLabel.colorMedium
        topBar.riskRateV.valueLabel.text = "--"
        topBar.loseCutV.valueLabel.text = "--"
    }
}

