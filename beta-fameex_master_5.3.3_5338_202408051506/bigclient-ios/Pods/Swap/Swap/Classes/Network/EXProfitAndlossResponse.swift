//
//  EXProfiAndlossResponse.swift
//  Chainup
//
//  Created by ZYJ on 2023/11/8.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXProfitAndlossResponseItem: EXCOBaseModel {

    var code = ""
    var msg = ""
    var data = ""
    var succ = false
}

class EXProfitAndlossResponse: EXCOBaseModel {

    var respList = [EXProfitAndlossResponseItem]()
    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["respList":EXProfitAndlossResponseItem.self]
    }
}
