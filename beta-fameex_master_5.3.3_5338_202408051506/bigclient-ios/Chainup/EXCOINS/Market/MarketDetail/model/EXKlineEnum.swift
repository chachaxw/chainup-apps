//
//  EXKlineEnum.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/23.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

enum KLineAccountType : Int {
    case coin = 0//Currency market
    case contract = 1//Contract quotation
    case lever = 2//Leverage market
    case quant = 3//Leverage market
}

enum MasterAlgorithmType : Int {
    case none = 0
    case MA = 1
    case BOLL = 2
    case Hides = 3
}

enum AssistantAlgorithmType : Int {
    case none = 0
    case MACD = 1
    case KDJ = 2
    case RSI = 3
    case WR = 4
    case Hides = 5
}


let KlineScaleDefaultKey = "15min"

class EXKlineEnum: NSObject {
    
    static func masterMenuTitles() ->[String] {
        return ["MA","BOLL"]
    }
    
    static func assistantTitles() ->[String] {
        return ["MACD","KDJ","RSI","WR"]
    }
}

