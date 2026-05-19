//
//  EXAssetsEnums.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/27.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import Foundation

enum EXAccountType {
    case coin
    case otc
    case contract
    case b2c
    case leverage
}

enum EXAssetToolBarAction {
    case none
    case recharge //Recharge
    case withdraw //Withdrawal
    case transfer //Transfer
    case internalTransfer //Direct transfer within the station
    case journalAccount //running water
    case paymentTerm//Payment method
    case contract//contract
    case transaction //transaction
    case redPack //Red envelope
    case B2CRecharge //B2C recharge
    case B2CWithdraw //Withdrawal of B2C coins
    case B2CJournalAccount //Capital flow of B2C
    case borrow//Lending
    case swapGift //Contract gift
    
}

class EXAssetToolBarItem:NSObject {
    var title :String = ""
    var iconImageName :String = ""
    var action :EXAssetToolBarAction = .none
}



