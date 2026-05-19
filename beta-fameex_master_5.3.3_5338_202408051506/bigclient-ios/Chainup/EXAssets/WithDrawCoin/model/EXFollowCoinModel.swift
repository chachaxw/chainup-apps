//
//  EXFollowCoinModel.swift
//  Chainup
//
//  Created by ljw on 2023/12/23.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXFollowCoinModel: EXBaseModel {
    var userWithdrawAddrList:[AddressItem] = []
    var defaultFee:String = ""
    var withdraw_min = ""
    var withdraw_max = ""
    var feeMin:String = ""
    var feeMax:String = ""
    var mainChainNameTip  = ""//Prompt copy
    var showErr:Bool = false
    var withdraw_max_day = ""
    var innerTransferFee = ""
    var withdrawWhitelistFlag: String {
        return UserInfoEntity.sharedInstance().withdrawWhitelistFlag
    }
    
    override func mj_keyValuesDidFinishConvertingToObject() {
           self.userWithdrawAddrList = AddressItem.mj_objectArray(withKeyValuesArray: self.userWithdrawAddrList).copy() as! [AddressItem]
    }
    
    class func errorFollowCoinModel() ->EXFollowCoinModel {
        let model = EXFollowCoinModel()
        model.showErr = true
        model.defaultFee = "--"
        model.withdraw_min = "--"
        model.withdraw_max = "--"
        model.feeMin = "--"
        model.feeMax = "--"
        return model
    }
}

