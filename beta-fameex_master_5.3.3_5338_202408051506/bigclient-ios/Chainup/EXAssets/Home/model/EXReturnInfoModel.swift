//
//  EXReturnInfoModel.swift
//  Chainup
//
//  Created by ljw on 2023/11/12.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXReturnInfoModel: EXBaseModel {
    var financeList = [EXReturnInfoListModel]()
    var count = ""
    var pageSize = ""
    override func mj_keyValuesDidFinishConvertingToObject() {
        self.financeList = EXReturnInfoListModel.mj_objectArray(withKeyValuesArray: self.financeList).copy() as! [EXReturnInfoListModel]
    }
}
class EXReturnInfoListModel: EXBaseModel {
    var repaymentTime = ""
    var coin = ""
    var returnMoney = ""
    var type = ""//Return type: 1 principal, 2 interest, 3 principal+interest
}

