//
//  EXOTCHistoryListCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/4.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXOTCHistoryListCell: UITableViewCell{
    @IBOutlet var tradeSideTitle: UILabel!
    @IBOutlet var tradeSymbol: UILabel!
    @IBOutlet var stateLabel: UILabel!
    @IBOutlet var infoView: EXThreeColumnView!
    @IBOutlet var enterIcon: UIImageView!
    @IBOutlet var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        enterIcon.image = EXKitBundle.image(named: "public_positions_arrow_right")
        enterIcon.contentMode = .scaleAspectFit
        // Initialization code
        tradeSideTitle.font = UIFont.ThemeFont.HeadBold
        stateLabel.font = UIFont.ThemeFont.HeadBold
        tradeSymbol.font =  UIFont.ThemeFont.HeadBold
        timeLabel.font = UIFont.ThemeFont.SecondaryRegular
        stateLabel.font = UIFont.ThemeFont.SecondaryRegular
    }
    
    func bindItem(historyListItem :EXOTCHistoryListItem) {
        
        if historyListItem.side == OTCTradeSideKey.otcBuy.rawValue {
            tradeSideTitle.textColor = UIColor.ThemekLine.up
            tradeSideTitle.text = "otc_text_tradeObjectBuy".localized()
        }else {
            tradeSideTitle.textColor = UIColor.ThemekLine.down
            tradeSideTitle.text = "otc_text_tradeObjectSell".localized()
        }
        timeLabel.text = historyListItem.getOrderTime()
        tradeSymbol.text  = historyListItem.coinSymbol.aliasName()
        stateLabel.text = historyListItem.status_text
        let model = ExThreeColumnDataModel()
        model.style.bottomLabelColor = .Ex.text1
        model.title = "otc_text_price".localized() + "(\(historyListItem.paySymbol))"
        model.content = historyListItem.price.formatCurrencyMoney(historyListItem.paySymbol,format:.fiatFormat)
        let modelm = ExThreeColumnDataModel()
        modelm.style.bottomLabelColor = .Ex.text1
        modelm.title = "charge_text_volume".localized() + "(\(historyListItem.coinSymbol.aliasName()))"
        modelm.content = historyListItem.fmtVolumeBalance()
        let modelr = ExThreeColumnDataModel()
        modelr.style.bottomLabelColor = .Ex.text1
        modelr.title = "otc_text_orderTotal".localized() + "(\(historyListItem.paySymbol))"
        modelr.content = historyListItem.totalPrice.formatCurrencyMoney(historyListItem.paySymbol,format: .fiatFormat)
        infoView.bindItems(with: [model,modelm,modelr])
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    var criditRecord: EXPayRecord? {
        didSet{
            guard let m = criditRecord else {return}
//            if historyListItem.side == OTCTradeSideKey.otcBuy.rawValue {
//                tradeSideTitle.textColor = UIColor.ThemekLine.up
//                tradeSideTitle.text = "otc_text_tradeObjectBuy".localized()
//            }else {
//                tradeSideTitle.textColor = UIColor.ThemekLine.down
//                tradeSideTitle.text = "otc_text_tradeObjectSell".localized()
//            }
            if let time = Double(m.ctime){
                timeLabel.text = DateTools.timeStampToString(time)
            }
            tradeSymbol.text  = m.coinSymbol
            stateLabel.text = m.status_text
            let model = ExThreeColumnDataModel()
            model.title = "otc_text_price".localized() + "(\(m.payCoin))"
            model.content = m.price.formatCurrencyMoney(m.payCoin,format:.fiatFormat)
            let modelm = ExThreeColumnDataModel()
            modelm.title = "charge_text_volume".localized() + "(\(m.coinSymbol))"
            modelm.content = m.volume
            let modelr = ExThreeColumnDataModel()
            modelr.title = "otc_text_orderTotal".localized() + "(\(m.payCoin))"
            modelr.content = m.totalPrice
                //.formatCurrencyMoney(historyListItem.paySymbol,format: .fiatFormat)
            infoView.bindItems(with: [model,modelm,modelr])
        }
    }
}
