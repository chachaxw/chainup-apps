//
//  EXCItemCoinModel.swift
//  Chainup
//
//  Created by ZYJ on 2023/11/7.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

@objcMembers public class EXCItemCoinModel: EXCOBaseModel {
 
    public var canUseAmount = ""
    public var totalAmount = ""
    public var coin_code = ""
    public var originalCoin = ""
    public func reset() {
        canUseAmount = "0"
        totalAmount = "0"
    }
}
