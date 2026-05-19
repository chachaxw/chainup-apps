//
//  EXLeverageHistoryTC.swift
//  Chainup
//
//  Created by zewu wang on 2023/11/7.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXLeverageHistoryTC: EXHistoryEntrustTC {

    
    func setLeverCell(_ entity : EXLeverageHistoryDetailModel){
        let symbol = entity.baseCoin.lowercased() + entity.countCoin.lowercased()
        let coinmap = EXAppMarketManager.sharedInstance.getCoinMapEntityBySymbol(symbol)
        if entity.side == "BUY"{//buy
            buytypeLabel.textColor = UIColor.ThemekLine.up
            buytypeLabel.text = LanguageTools.getString(key: "otc_text_tradeObjectBuy")
        }else{
            buytypeLabel.textColor = UIColor.ThemekLine.down
            buytypeLabel.text = LanguageTools.getString(key: "otc_text_tradeObjectSell")
        }
        
        nameLabel.text = entity.getShowName()
        typeLabel.text = entity.status_text

        timeView.setName("charge_text_date".localized())
        timeView.setVolum(DateTools.strToTimeString(entity.time_long, dateFormat: "MM-dd HH:mm:ss"))

        volumView.setName(LanguageTools.getString(key: "charge_text_volume") + "(\(entity.baseCoin.aliasName()))")
        volumView.setVolum(entity.volume.formatAmountUseDecimal(coinmap.volume))
        
        priceView.setName(LanguageTools.getString(key: "contract_text_price") + "(\(entity.countCoin.aliasName()))")
        if entity.type == "2"{//market price
            priceView.setVolum(LanguageTools.getString(key: "contract_action_marketPrice"))
        }else{
            priceView.setVolum(entity.price.formatAmountUseDecimal(coinmap.price))
        }
        
        dealView.setName(LanguageTools.getString(key: "contract_text_dealDone") + "(\(entity.baseCoin.aliasName()))")
        dealView.setVolum(entity.deal_volume.formatAmountUseDecimal(coinmap.volume))
        
        averageView.setName(LanguageTools.getString(key: "contract_text_dealAverage") + "(\(entity.countCoin.aliasName()))")
        averageView.setVolum(entity.avg_price.formatAmountUseDecimal(coinmap.price))
        
        dealTotalAmountView.setName(LanguageTools.getString(key: "noun_order_GMV") + "(\(entity.countCoin.aliasName()))")
        dealTotalAmountView.setVolum(entity.deal_money.formatAmountUseDecimal("8"))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

