//
//  EXLeverageAssetListCell.swift
//  Chainup
//
//  Created by ljw on 2023/11/4.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXLeverageAssetListCell: UITableViewCell {
    @IBOutlet weak var topTitleLab: UILabel!//BTC/USDT
    @IBOutlet weak var symbolLab: UILabel!//currency
    @IBOutlet weak var availableLab: UILabel!//available
    @IBOutlet weak var borrowLab: UILabel!//Borrowed
    @IBOutlet weak var topSymbolLab: UILabel!
    @IBOutlet weak var topAvailableLab: UILabel!
    @IBOutlet weak var topBorrowLab: UILabel!
    @IBOutlet weak var bottomSymbolLab: UILabel!
    @IBOutlet weak var bottomAvaiableLab: UILabel!
    @IBOutlet weak var bottomBorrowLab: UILabel!
    @IBOutlet weak var convertLab: UILabel!
    var totalBalanceSymbol = "BTC"
    
    var currentModel = EXLeverageCoinMapItem()
    
    @IBOutlet weak var line: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = UIColor.ThemeView.bg
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        topTitleLab.extSetTextColor(UIColor.Ex.main4, fontSize: 16, textAlignment: NSTextAlignment.left, isBold: true, numberOfLines: 1)
        symbolLab.extSetText("common_text_coinsymbol".localized(), textColor: UIColor.ThemeLabel.colorDark, fontSize: 12, textAlignment: NSTextAlignment.left)
        availableLab.extSetText("assets_text_available".localized(), textColor: symbolLab.textColor, fontSize: symbolLab.font.pointSize, textAlignment: NSTextAlignment.left)
        borrowLab.extSetText("leverage_have_borrowed".localized(), textColor: symbolLab.textColor, fontSize: symbolLab.font.pointSize, textAlignment: NSTextAlignment.right)
        topSymbolLab.extSetTextColor(UIColor.ThemeLabel.colorMedium, fontSize: 14, textAlignment: NSTextAlignment.left, isBold: false, numberOfLines: 1)
        
        
        bottomSymbolLab.extSetTextColor(UIColor.ThemeLabel.colorMedium, fontSize: 14, textAlignment: NSTextAlignment.left, isBold: false, numberOfLines: 1)
        
        
        topAvailableLab.extSetTextColor(UIColor.ThemeLabel.colorLite, fontSize: 14, textAlignment: NSTextAlignment.left, isBold: false, numberOfLines: 1)
        topAvailableLab.font = self.themeHNMediumFont(size: 14)
        
        bottomAvaiableLab.extSetTextColor(UIColor.ThemeLabel.colorLite, fontSize: 14, textAlignment: NSTextAlignment.left, isBold: false, numberOfLines: 1)
        bottomAvaiableLab.font = topAvailableLab.font
        
        topBorrowLab.extSetTextColor(UIColor.ThemeLabel.colorLite, fontSize: 14, textAlignment: NSTextAlignment.right, isBold: false, numberOfLines: 1)
        topBorrowLab.font = topAvailableLab.font
        
        bottomBorrowLab.extSetTextColor(UIColor.ThemeLabel.colorLite, fontSize: 14, textAlignment: NSTextAlignment.right, isBold: false, numberOfLines: 1)
        bottomBorrowLab.font = topAvailableLab.font
        convertLab.extSetTextColor(UIColor.ThemeLabel.colorMedium, fontSize: 14, textAlignment: NSTextAlignment.left, isBold: false, numberOfLines: 1)
        
        
        line.backgroundColor = UIColor.ThemeView.seperator
    }
    func setModel(model : EXLeverageCoinMapItem) {
        currentModel = model
        let privacy = XUserDefault.assetPrivacyIsOn()
        topTitleLab.text = model.name.aliasCoinMapName()
        topSymbolLab.text = model.baseCoin.aliasName()
        topAvailableLab.text = !privacy ? model.baseNormalBalance.formatAmount(model.baseCoin,isLeverage: true) : String.privacyString()
        topBorrowLab.text = !privacy ? model.baseBorrowBalance.formatAmount(model.baseCoin,isLeverage: true) : String.privacyString()
        
        bottomSymbolLab.text = model.quoteCoin.aliasName()
        bottomAvaiableLab.text = !privacy ? model.quoteNormalBalance.formatAmount(model.quoteCoin,isLeverage: true) : String.privacyString()
        bottomBorrowLab.text = !privacy ? model.quoteBorrowBalance.formatAmount(model.quoteCoin,isLeverage: true) : String.privacyString()
        
        convertLab.text = !privacy ? getCaculatePrice() : String.privacyString()
    }
    func getCaculatePrice()->String {
        //Exchange rate of btc
        let currency = EXAppMarketManager.sharedInstance.getCoinExchangeRate(totalBalanceSymbol)
        let unit = EXAppMarketManager.sharedInstance.getFiatCoinSymbol() // currency.0
        let rate = currency.1
        let decimal = currency.2
        let balance = self.currentModel.symbolBalance as NSString
        if let rst =  balance.multiplying(by: rate, decimals: decimal,holdZeor: true) {
            return "assets_text_equivalence".localized() + rst + unit
        }else {
            return "assets_text_equivalence".localized() + "0" + unit
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

