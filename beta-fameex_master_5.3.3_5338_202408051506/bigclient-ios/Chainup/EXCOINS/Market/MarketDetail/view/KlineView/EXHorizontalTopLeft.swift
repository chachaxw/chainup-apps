//
//  EXHorizontalTopLeft.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/13.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXHorizontalTopLeft: NibBaseView {

    @IBOutlet var symbolLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var rmbLabel: UILabel!
    @IBOutlet var changeLabel: UILabel!
    
    override func onCreate() {
        symbolLabel.font = self.themeHNBoldFont(size: 16)
        priceLabel.font =  self.themeHNBoldFont(size: 16)
        rmbLabel.textColor = UIColor.ThemekLine.labcolorMedium
        rmbLabel.font = self.themeHNFont(size: 12)
        changeLabel.font = self.themeHNFont(size: 12)
        self.backgroundColor = UIColor.ThemekLine.navBg
    }
    
    func updatePrices(item:TickItem,title:String) {
        symbolLabel.text = title
        let color =  item.roseTxtColor
        priceLabel.text = item.close
        priceLabel.textColor = color
        changeLabel.textColor = color
        changeLabel.text = item.rose + "%"
        let array = title.components(separatedBy: "/")
        if array.count == 2 {
            
            let t = EXAppMarketManager.sharedInstance.getCoinExchangeRate(array[1])
            if let rmb = NSString.init(string: String(describing: item.close)).multiplyingBy1(t.1, decimals: t.2){
                rmbLabel.text = "≈\(t.0)" + rmb
            }
        }
        
    }
    
//    func updatePrices(model: EXSwapItemModel) {
//        symbolLabel.text = model.ex_contractInfo?.showName()
//          let color = (model.trendType() == .up) ? UIColor.ThemekLine.up : UIColor.ThemekLine.down
//        priceLabel.text = model.last_px.toPricePrecision(withContractID:model.instrument_id)
//          priceLabel.textColor = color
//          changeLabel.textColor = color
//          changeLabel.text = model.change_rate.count > 0 ? model.change_rate.toPercentString(2) : "--"
//      }
}
