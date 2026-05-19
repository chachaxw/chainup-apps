//
//  EXKLineSelectedInfoView.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/17.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXKLineSelectedInfoView: NibBaseView {
    
    var rowItems = ["kline_text_dealTime".localized(),
                    "kline_text_open".localized(),
                    "kline_text_high".localized(),
                    "kline_text_low".localized(),
                    "kline_text_close".localized(),
                    "kline_text_changeValue".localized(),
                    "kline_text_changeRate".localized(),
                    "kline_text_volume".localized()]
    var chartItem:CHChartItem = CHChartItem()
    @IBOutlet var titles: [UILabel]!
    @IBOutlet var contents: [UILabel]!
    
    override func onCreate() {
        for (idx, tlabel) in titles.enumerated() {
            tlabel.text = rowItems[idx]
            tlabel.minimumRegular()
        }
        
        for clabel in contents {
            clabel.minimumRegular()
        }
    }
        
    func updateItems(item:CHChartItem,priceDecimal:String,volumeDecimal:String) {
        self.chartItem = item
        let closePrice = item.closePrice.ch_toString()
        let openPrice = item.openPrice.ch_toString()
        let changeValue = closePrice.bigSub(openPrice).formatAmountUseDecimal(priceDecimal)
        for (idx, clabel)  in contents.enumerated() {
            if idx == 0 {
                var menuModel = EXMenuSelectionModel.init()
                clabel.text = Date.klineTimeFormat(item.time, timekey:menuModel.scaleKey)
                //DateTools.dateToString(TimeInterval.init(item.time), dateFormat: "yy-MM-dd HH:mm")
            }else if (idx == 1) {
                clabel.text = item.openPrice.ch_toString().formatAmountUseDecimal(priceDecimal)
            }else if (idx == 2) {
                clabel.text = item.highPrice.ch_toString().formatAmountUseDecimal(priceDecimal)
            }else if (idx == 3) {
                clabel.text = item.lowPrice.ch_toString().formatAmountUseDecimal(priceDecimal)
            }else if (idx == 4) {
                clabel.text = item.closePrice.ch_toString().formatAmountUseDecimal(priceDecimal)
            }else if (idx == 5) {
                if changeValue.greaterThanOrEqual("0") {
                    clabel.textColor = UIColor.ThemekLine.up
                    clabel.text = "+" + changeValue
                }else {
                    clabel.textColor = UIColor.ThemekLine.down
                    clabel.text = changeValue
                }
            }else if (idx == 6) {
                let changeRate = changeValue.bigDiv(closePrice).bigMul("100").formatAmountUseDecimal("2")
                if changeRate.greaterThanOrEqual("0") {
                    clabel.textColor = UIColor.ThemekLine.up
                    clabel.text = "+" + changeRate + "%"
                }else {
                    clabel.textColor = UIColor.ThemekLine.down
                    clabel.text = changeRate + "%"
                }
            }else if (idx == 7) {
                clabel.text = item.vol.ch_toString().formatAmountUseDecimal(volumeDecimal)
            }
        }
    }

}

