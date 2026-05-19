//
//  EXAssetInfoCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/27.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXAssetInfoCell: UITableViewCell {
    
    @IBOutlet var topLabel: UILabel!
    @IBOutlet var topSubLabel: UILabel!
    @IBOutlet var infoView: EXMutiColumnView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        topLabel.textColor = UIColor.Ex.main4
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func getStyle()->ExThreeColumnStyle {
        let style = ExThreeColumnStyle()
        style.bottomLabelFont = self.themeHNMediumFont(size: 14)
        style.bottomLabelColor = UIColor.ThemeLabel.colorLite
        style.topLabelFont = UIFont.ThemeFont.SecondaryRegular
        return style
    }
    
    func bindExchangeInfo(_ model:EXAccountCoinMapItem, _ totalBalanceSymbol:String) {
        topLabel.text = model.coinName
        topSubLabel.isHidden = true
        
        let privacy = XUserDefault.assetPrivacyIsOn()
        let currency = EXAppMarketManager.sharedInstance.getCoinExchangeRate(model.coinName)
        let unit = EXAppMarketManager.sharedInstance.getFiatCoinSymbol()
        let modelA = ExThreeColumnDataModel()
        modelA.title = "assets_text_available".localized()
        modelA.content = !privacy ? model.normal_balance.formatAmount(model.coinName) : String.privacyString()
        modelA.aliment = .left
        modelA.style = self.getStyle()
        let modelm = ExThreeColumnDataModel()
        modelm.title = "assets_text_freeze".localized()
        modelm.content = !privacy ? model.lock_balance.formatAmount(model.coinName) : String.privacyString()
        modelm.style = self.getStyle()
        modelm.aliment = .center
        let modelr = ExThreeColumnDataModel()
        modelr.title = "assets_text_equivalence".localized() + "(\(unit))"
        modelr.content = !privacy ? model.total_balance.getCaculatePrice(forSymbol: model.coinName) : String.privacyString()
        modelr.style = self.getStyle()
        modelr.aliment = .right
        infoView.bindItems([modelA,modelm,modelr])
    }
    
    func bindOTCInfo(_ model:CoinMapItem, _ totalBalanceSymbol:String) {
        let unit = EXAppMarketManager.sharedInstance.getFiatCoinSymbol()
        topLabel.text = model.coinSymbol.aliasName()
        topSubLabel.isHidden = true
        let privacy = XUserDefault.assetPrivacyIsOn()
        let currency = EXAppMarketManager.sharedInstance.getCoinExchangeRate(model.coinSymbol)

        let modelA = ExThreeColumnDataModel()
        modelA.title = "assets_text_available".localized()
        modelA.content = !privacy ? model.normal.formatAmount(model.coinSymbol) : String.privacyString()
        modelA.aliment = .left
        modelA.style = self.getStyle()
        let modelm = ExThreeColumnDataModel()
        modelm.title = "assets_text_freeze".localized()
        modelm.content = !privacy ? model.lock.formatAmount(model.coinSymbol) : String.privacyString()
        modelm.style = self.getStyle()
        modelm.aliment = .center
        let modelr = ExThreeColumnDataModel()
        modelr.title = "assets_text_equivalence".localized() + "(\(unit))"
        modelr.content = !privacy ? model.btcValuation.getCaculatePrice(forSymbol:totalBalanceSymbol) : String.privacyString()
        modelr.style = self.getStyle()
        modelr.aliment = .right
        
        infoView.bindItems([modelA,modelm,modelr])
    }
    
    func bindContractHoldModel(_ model:EXContractHoldModel) {
        
        let privacy = XUserDefault.assetPrivacyIsOn()

        topLabel.text = model.contractSeries
        let sublabel = ContractPublicInfoManager.manager.getContractTimeRangeTitle(model.contractId)
        topSubLabel.text = sublabel + "(\(model.leverageLevel)x)"
        
        let modelA = ExThreeColumnDataModel()
        modelA.title = "contract_text_realisedPNL".localized()
        modelA.content = !privacy ? model.fmtRealisedAmount() : String.privacyString()
        modelA.style = self.getStyle()
        modelA.aliment = .left

        let modelm = ExThreeColumnDataModel()
        modelm.title = "contract_text_unrealisedPNL".localized()
        modelm.content =  !privacy ? model.fmtUnrealisedAmountMarket() : String.privacyString()
        modelm.style = self.getStyle()
        modelm.aliment = .center

        let modelr = ExThreeColumnDataModel()
        modelr.title = "contract_text_positionNumber".localized() + "(" + "contract_text_volumeUnit".localized() + ")"
        var volumeDesc = model.volume
     
        if model.side == "BUY" {
            modelr.style.bottomLabelColor = !privacy ? UIColor.ThemekLine.up : UIColor.ThemeLabel.colorLite
            volumeDesc = "+" + model.volume
        }else if model.side == "SELL" {
            modelr.style.bottomLabelColor = !privacy ? UIColor.ThemekLine.down : UIColor.ThemeLabel.colorLite
            volumeDesc = "-" + model.volume
        }
        modelr.content = !privacy ? volumeDesc : String.privacyString()
        modelr.aliment = .right
        infoView.bindItems([modelA,modelm,modelr])
    }
    
    func bindB2CInfo(_ model:B2CCoinMapItem, _ totalBalanceSymbol:String) {

        topLabel.text = model.symbol
        topSubLabel.isHidden = true
        let privacy = XUserDefault.assetPrivacyIsOn()
        let currency = EXAppMarketManager.sharedInstance.getCoinExchangeRate(model.symbol)
        let unit = EXAppMarketManager.sharedInstance.getFiatCoinSymbol()
        let modelA = ExThreeColumnDataModel()
        modelA.title = "assets_text_available".localized()
        modelA.content = !privacy ? model.normalBalance.formatAmount(model.symbol) : String.privacyString()
        modelA.aliment = .left
        modelA.style = self.getStyle()
        let modelm = ExThreeColumnDataModel()
        modelm.title = "assets_text_freeze".localized()
        modelm.content = !privacy ? model.lockBalance.formatAmount(model.symbol) : String.privacyString()
        modelm.style = self.getStyle()
        modelm.aliment = .center
        let modelr = ExThreeColumnDataModel()
        modelr.title = "assets_text_equivalence".localized() + "(\(unit))"
        modelr.content = !privacy ? model.btcValue.getCaculatePrice(forSymbol:totalBalanceSymbol) : String.privacyString()
        modelr.style = self.getStyle()
        modelr.aliment = .right
        
        infoView.bindItems([modelA,modelm,modelr])
    }
}
