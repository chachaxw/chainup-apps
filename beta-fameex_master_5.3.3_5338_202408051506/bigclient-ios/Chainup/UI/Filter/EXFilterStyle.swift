//
//  EXFilterStyle.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/2.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

@objc enum AppFilterStyle:Int {
    case fold
    case input
    case onoff
    case date
    case mix //Input+Select
    case selection //Push New Page Selection Type
    //Sheet type used for all delegates/historical delegates
    case singleSheet
}

