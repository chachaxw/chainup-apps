//
//  EXPosDetailServer.swift
//  Chainup
//
//  Created by lcus on 2023/10/15.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXPosDetailServer: NSObject {

    
    public static var sharedInstance : EXPosDetailServer{
        struct Static {
            static let instance : EXPosDetailServer = EXPosDetailServer()
        }
        return Static.instance
    }
    
    var inputValue:String?
    var projectId = ""
    var tipMine:String = ""
    
    func handCoinMonney(coinName:String,number:NSNumber) ->String {
        if let entity = EXAppMarketManager.sharedInstance.getCoinEntity(coinName){
            return number.stringValue.formatAmountUseDecimal(entity.showPrecision)
        }
        return "0.0"
    }
    
    
}
