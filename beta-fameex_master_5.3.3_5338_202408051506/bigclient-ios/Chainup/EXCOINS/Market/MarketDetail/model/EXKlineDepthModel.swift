//
//  EXKlineDepthModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/20.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXKlineDepthModel: EXBaseModel {
    
    @objc var asks:[[Any]] = []
    @objc var buys:[[Any]] = []
    @objc var middle:Double = 0
    @objc var time:String = ""
}
