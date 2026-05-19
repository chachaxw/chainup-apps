//
//  EXTradeAreaBase.swift
//  Chainup
//
//  Created by 劉軒 on 2023/10/31.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import RxSwift
import EXKit

class EXTradeAreaBase: UIView {
    typealias OrderCreateBlock = (OrderCreateElement) -> ()
    var onOrderCreateBlock:OrderCreateBlock?
    
    typealias ClickDepthBlock = (EXDepthEntity) -> ()//Click on the cell callback
    var clickDepthBlock : ClickDepthBlock?
    
    typealias ClickOrderActionBlock = (EXTradeOrderAction) -> ()//Click on the buy and sell callback
    var clickOrderActionBlock : ClickOrderActionBlock?
    
    
    typealias ActionBlock = () -> ()
    var onDepthScaleBlock:ActionBlock?
    var onDepthLayoutBlock:ActionBlock?
    
    typealias ActionWayBlock = (UIButton) -> ()
    var onOrderWayBlock:ActionWayBlock?
    var onOrderWayChangedBlock:((EXTradeOrderWay)->())?
    var onOrderWayTipsBlock:ActionWayBlock?
    var onLeverSettingBlock:ActionWayBlock?
    
    var entity:CoinMapEntity
    var orderType:EXTradeOrderType
    var layoutType:EXTradeHeaderLayout
    
    var orderAction:EXTradeOrderAction
    var orderWay:EXTradeOrderWay = .limit {
        didSet {
            onUpdateLayout(with: orderWay)
        }
    }
    
    var suggestBuyStr:String = ""//Suggest buying
    var suggestSellStr:String = ""//Suggest selling
    
    let suggestBuy = PublishSubject<String>()
    let suggestSell = PublishSubject<String>()
    
    var firstBuy:String? //Buy 1
    var firstSell:String?//Sell 1
    var priceNow:String?//Current price

    required init(entity:CoinMapEntity,orderType:EXTradeOrderType,layoutType:EXTradeHeaderLayout,action:EXTradeOrderAction){
        self.entity = entity
        self.orderType = orderType
        self.layoutType = layoutType
        self.orderAction = action
        super.init(frame:.zero)
        onCreate()
    }
    
    required init?(coder: NSCoder) {
        self.entity = CoinMapEntity()
        self.orderType = .exchange
        self.layoutType = .vertical
        self.orderAction = .buy 
        super.init(coder: coder)
        onCreate()
    }
    
    func onCreate() {}
    func onOrderWayChangend() {}
    func onUpdateLayout(with orderWay:EXTradeOrderWay) {
        layoutIfNeeded()
    }
    
}

//Actions
extension EXTradeAreaBase {
    
    func configSuggestBuy() {
        //Purchase order, fill in Sell 1
        guard let sell = firstSell else { return }
        guard let now = priceNow else { return }
        let d_sell = NumberHandler.handleDouble(sell)
        let d_now = NumberHandler.handleDouble(now)
        let per = ((fabs(d_sell - d_now))/d_sell * 100)
        if per < 2 {
            self.suggestBuy.onNext(sell)
        }
    }
    
    func configSuggestSell() {
        guard let buy = firstBuy else { return }
        guard let now = priceNow else { return }
        let d_buy = NumberHandler.handleDouble(buy)
        let d_now = NumberHandler.handleDouble(now)
        let per = ((fabs(d_buy - d_now))/d_buy * 100)
        if per < 2 {
            self.suggestSell.onNext(buy)
        }
    }
}

