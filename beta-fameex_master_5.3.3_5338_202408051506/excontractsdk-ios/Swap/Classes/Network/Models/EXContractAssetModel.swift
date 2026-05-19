//
//  EXContractAssetModel.swift
//  Chainup
//
//  Created by ZYJ on 2023/10/31.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

public class EXContractAssetModel: EXCOBaseModel {
    // 可用 English: available
    public var canUseAmount:String = "0"
    
    //三方币币可用 English: Tripartite coins available
    public var symbol:String = ""
    
    //逐仓保证金 English: Margin for each warehouse
    public var isolateMargin:String = ""
    
    //委托保证金 English: Entrusted deposit
    public var lockAmount:String = ""
    
    //已实现盈亏 English: Realized profit and loss
    public var realizedAmount:String = ""
    
    //总资产 English: total assets
    public var totalAmount:String = ""
    
    //全仓保证金 English: Full warehouse margin
    public  var totalMargin:String = ""
    
    public  var walletBalance:String = ""
    
    //未实现盈亏 English: Unrealized gains and losses
    public  var unRealizedAmount:String = ""
    
    public var totalMarginRate:String = ""
    //真实币对 English: Real currency pair
    public  var originalCoin: String = ""
    
}

