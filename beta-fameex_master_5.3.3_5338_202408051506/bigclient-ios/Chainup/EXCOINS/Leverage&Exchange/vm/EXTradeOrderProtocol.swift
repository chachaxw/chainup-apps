//
//  EXTradeOrderProtocol.swift
//  Chainup
//
//  Created by 劉軒 on 2023/10/30.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit


enum EXTradeOrderAction {
    case buy
    case sell
}

enum EXTradeOrderWay {
    case limit //Specify price
    case market //market price
    var description: String {
        switch self {
        case .limit:
            return "contract_action_limitPrice".localized()
        case .market:
            return "contract_action_marketPrice".localized()
        }
    }
}

enum EXTradeOrderType {
    case exchange
    case leverage
}

enum EXLeverPositionType: CustomStringConvertible {
    case isolated //Isolated position is default
    case cross //Cross position
    ///
    var description: String {
        switch self {
        case .isolated:
            return "lever_isolated_margin".localized()
        case .cross:
            return "lever_cross_margin".localized()
        }
    }
}

enum EXLeverSupportType {
    case onlyIsolated
    case onlyCross
    case all
    case none
}


enum EXTradeHeaderLayout {
    case vertical
    case horizontal
}

struct OrderCreateElement {
    var side:String
    var type:String
    var volume:String
    var price:String
}

protocol EXTradeOrderProtocol {
    func createOrder(side:String,type:String,volume:String,price:String,entity:CoinMapEntity)
    func cancelOrder(entity:EXCurrentEntrustEntity)
}


