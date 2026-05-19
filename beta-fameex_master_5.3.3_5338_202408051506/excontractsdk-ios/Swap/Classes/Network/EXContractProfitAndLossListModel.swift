//
//  EXContractProfitAndLossListModel.swift
//  Chainup
//
//  Created by ZYJ on 2023/11/1.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXContractProfitAndLossListModel: EXCOBaseModel {

    var takeProfitList = [EXContractOrderModel]()
    var stopLossList = [EXContractOrderModel]()
    
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["takeProfitList":EXContractOrderModel.self,
                "stopLossList":EXContractOrderModel.self]
    }

}

