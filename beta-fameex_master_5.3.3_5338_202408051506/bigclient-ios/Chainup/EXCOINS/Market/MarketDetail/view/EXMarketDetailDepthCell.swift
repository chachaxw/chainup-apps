//
//  EXMarketDetailDepthCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/30.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXMarketDetailDepthCell: UITableViewCell {
    @IBOutlet var klineDepthView: EXKlineDepthView!
    @IBOutlet var titleBar: UIView!
    @IBOutlet var leftTitle: UILabel!
    @IBOutlet var middleTitle: UILabel!
    @IBOutlet var rightTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.ThemekLine.viewBg
        contentView.backgroundColor =  UIColor.ThemekLine.viewBg 
        titleBar.backgroundColor = UIColor.ThemekLine.viewBg
        leftTitle.text = "charge_text_volume".localized()
        middleTitle.text = "contract_text_price".localized()
        rightTitle.text = "charge_text_volume".localized()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateItems(depthItems:[CHKDepthChartItem],max:Float,price:String ,entity : CoinMapEntity) {
        if price != ""{
            klineDepthView.updatedepthData(models: depthItems, maxAmount: max, price: price , entity : entity)
        }else {
            klineDepthView.updatedepthData(models: depthItems, maxAmount: max, price:"--" , entity : entity)

        }
    }
    
}
