//
//  EXKlineEnum.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/23.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

enum EXSKLineAccountType : Int {
    case coin = 0//币币行情 English: Currency market
    case contract = 1//合约行情 English: Contract market
    case lever = 2//杠杆行情 English: Leverage market
}

enum EXSMasterAlgorithmType : Int {
    case none = 0
    case MA = 1
    case BOLL = 2
    case Hides = 3
}

enum EXSAssistantAlgorithmType : Int {
    case none = 0
    case MACD = 1
    case KDJ = 2
    case RSI = 3
    case WR = 4
    case Hides = 5
}


let EXSKlineScaleDefaultKey = "15min"

//class EXKlineEnum: NSObject {
//    
//    static func masterMenuTitles() ->[String] {
//        return ["MA","BOLL"]
//    }
//    
//    static func assistantTitles() ->[String] {
//        return ["MACD","KDJ","RSI","WR"]
//    }
//}

