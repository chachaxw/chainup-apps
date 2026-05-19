//
//  EXHorizontalTopRight.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/13.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXHorizontalTopRight: NibBaseView {
    @IBOutlet var labels: [EXSideBySideLabel]!
    
    override func onCreate() {
        
    }
    
    func titles()->[String] {
        return ["kline_text_high".localized(),"kline_text_low".localized(),"common_text_dayVolume".localized()]
    }
    
    func updatePrices(item:TickItem,basicSymbol:String) {
        let values = [item.high,item.low,item.vol]
        for (idx,label) in labels.enumerated() {
            label.leftSideLabel.text = titles()[idx]
            let value = values[idx]
            label.rightSideLabel.text = value.formatAmount(basicSymbol)
        }
    }
    
    func updatePrices(item:TickItem) {
        let values = [item.high,item.low,item.vol]
        for (idx,label) in labels.enumerated() {
            label.leftSideLabel.text = titles()[idx]
            label.rightSideLabel.text = values[idx]
        }
    }
}

