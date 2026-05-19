//
//  EXOrderBookModel.swift
//  Chainup
//
//  Created by ZYJ on 2023/11/30.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXOrderBookModel: EXCOBaseModel {
    var instrument_id = 0
    var key = 0;
    var px = "";
    var qty = ""
    var max_volume = "";
    var way = "";
    var shouldTip = false
}
class EXDepthModel: EXCOBaseModel {
    
    var sells = [EXOrderBookModel]()
    var buys = [EXOrderBookModel]()
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["sells":EXOrderBookModel.self,
                "buys":EXOrderBookModel.self]
    }
}
