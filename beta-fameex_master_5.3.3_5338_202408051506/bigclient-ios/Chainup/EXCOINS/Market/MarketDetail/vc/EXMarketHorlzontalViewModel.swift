//
//  EXMarketHorlzontalViewModel.swift
//  Chainup
//
//  Created by ZYJ on 2023/11/19.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import Swap
class EXMarketHorlzontalViewModel {
    var itemModel: EXSwapItemModel?
    
    func handleContractPrice(item:TickItem) -> TickItem {
        let copyItem = item
        if let info = itemModel?.ex_contractInfo {
            
            itemModel?.qty24 = item.vol
            copyItem.vol = itemModel?.qty24VolumeDisplay ?? ""
            copyItem.high = item.high.toPricePrecision(withContractID: info.instrument_id)
            copyItem.low = item.low.toPricePrecision(withContractID: info.instrument_id)
        }
        return copyItem
    }

}
