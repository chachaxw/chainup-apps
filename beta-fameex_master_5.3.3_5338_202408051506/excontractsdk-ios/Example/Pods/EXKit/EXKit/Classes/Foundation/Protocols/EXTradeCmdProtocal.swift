//
//  EXTradeCmdProtocal.swift
//  Chainup
//
//  Created by liuxuan on 2019/4/25.
//  Copyright © 2019 zewu wang. All rights reserved.
//

import UIKit

public protocol EXTradeCmdProtocal {
    //symbol = ex.xrpusdt, action = buy or sell
    func excuteCmd(symbol:String,action:String)
}

public protocol EXTabActionProtocal {
    func handleParameter(_ parameters:[String:String])
}
