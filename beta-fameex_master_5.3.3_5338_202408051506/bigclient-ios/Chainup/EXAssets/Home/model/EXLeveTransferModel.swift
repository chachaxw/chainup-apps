

//
//  EXLeveTransferModel.swift
//  Chainup
//
//  Created by ljw on 2023/11/12.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit


class EXLeveTransferModel: EXBaseModel {
    var financeList = [EXLeveTransferListModel]()
    var count = ""
    var pageSize = ""
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.financeList = EXLeveTransferListModel.mj_objectArray(withKeyValuesArray: self.financeList).copy() as! [EXLeveTransferListModel]
    }
}

class SLSwapTransferModel: EXBaseModel {
    var financeList = [SLSwapTransferListModel]()
    var count = ""
    var pageSize = ""
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.financeList = SLSwapTransferListModel.mj_objectArray(withKeyValuesArray: self.financeList).copy() as! [SLSwapTransferListModel]
    }
}

class SLSwapTransferListModel: EXBaseModel {
    var createTime = ""
    var createdAtTime = ""
    var amount = ""//quantity
    var coinSymbol = ""//currency
    var status_text = ""
    var status = ""//1. Currency to contract, 2. Contract to currency
    
    func setStatusText() {
        if status == "1" {
            status_text = "contract_assets_record_transfer_from_swap_account".localized()
        }
        if status == "2" {
            status_text = "contract_assets_record_transfer_to_swap_account".localized()
        }
    }
    
    func setCreatAtTime() {
        createTime = DateTools.strToTimeString(createdAtTime)
    }
}

class EXLeveTransferListModel: EXBaseModel {
    var createTime = ""
    var amount = ""//quantity
    var symbol = ""//Currency pair
    var coinSymbol = ""//currency
    var showName = ""
    var transferType = ""//1. Transfer lever, 2. Transfer lever
}

