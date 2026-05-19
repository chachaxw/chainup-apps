//
//  EXFiatFilterView.swift
//  Chainup
//
//  Created by liuxuan on 2023/7/19.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXFiatFilterView: NibBaseView {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var containerView: UIView!
    @IBOutlet var selectLabel: UILabel!
    @IBOutlet var expandBtn: UIButton!
    var selectedItemValue:String = ""
    let column:Int = 3
    
    var showMoreCallback : ExpandCallback?
    typealias ExpandCallback = (Bool) -> ()
    
    var onFiatCallback :ActionBtnCallback?
    typealias ActionBtnCallback = (String) -> ()
    
    var showModel:[OTCPaymentModel] = []
    var hideModel:[OTCPaymentModel] = []

    var models:[EXFilterItem] = []
    var btnsAry:[EXTextButton] = []
    
    var isExpand:Bool = false

    override func onCreate() {
        titleLabel.text = "filter_fold_currencyType".localized()
    }

    func clearData() {
        for btn in btnsAry {
            btn.removeFromSuperview()
        }
        btnsAry.removeAll()
    }
    
    func handleFilterModels() {
        self.showModel.removeAll()
        self.hideModel.removeAll()
        
        let payCoins = OTCPulbicManager.sharedInstance.getOtcPaycoins()
        for payCoin in payCoins {
            if payCoin.hide == "1" {
                self.hideModel.append(payCoin)
            }else if payCoin.hide == "0" {
                self.showModel.append(payCoin)
            }
        }
    }
    
    func getShowedCoinItems() -> [EXFilterItem] {
        self.handleFilterModels()
        var titles:[String] = []
        var valueKeys:[String] = []
        for coin in self.showModel {
            titles.append(coin.title)
            valueKeys.append(coin.key)
        }
        
        if isExpand {
            for coin in self.hideModel {
                titles.append(coin.title)
                valueKeys.append(coin.key)
            }
            titles.append("common_action_hideMore".localized())
            valueKeys.append("expand")
        }else {
            titles.append("common_action_showMore".localized())
            valueKeys.append("expand")
        }
        
        let coinitems = EXFilterItem.getItem(titles: titles, valueKeys: valueKeys)
        return coinitems
    }
    
    func bindFoldHeader(_ expand:Bool) {
        self.clearData()
        self.isExpand = expand
        self.models = self.getShowedCoinItems()
        
        let btnHeight = 36
        let horizonGap = SCREEN_WIDTH * 0.06
        let btnWidth = (SCREEN_WIDTH - 30 - horizonGap*2)/3
        let ygap = 15
        let startX = 15
        let startY = 0
        
        for (idx,item) in models.enumerated() {
            
            let cellItem = EXTextButton.init(type:.custom)
            cellItem.setFont(font: UIFont.ThemeFont.BodyRegular)
            cellItem.supportCheckHighlight = true
            if self.selectedItemValue.isEmpty {
                if idx == 0 {
                    selectLabel.text = item.text
                }
                cellItem.isSelected = (idx == 0)
            }else {
                if item.valueKey == self.selectedItemValue {
                    cellItem.isSelected = true
                }else {
                    cellItem.isSelected = false
                }
            }
            cellItem.setColor(color:  UIColor.ThemeView.bgTab)
            cellItem.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
            cellItem.setTitleColor(UIColor.ThemeLabel.colorLite, for: .selected)
            
            cellItem.setTitle(item.text, for: .normal)
            cellItem.addTarget(self, action: #selector(itemDidTapAction(sender:)), for: .touchUpInside)
            
            containerView.addSubview(cellItem)
            let col = idx %  EXFoldFilterCell.column
            let row = idx / EXFoldFilterCell.column
            let xPosition = (btnWidth + horizonGap)*CGFloat(col)
            let yPosition = (btnHeight + ygap)*(row)
            let px = CGFloat(startX) + xPosition
            let py = startY + yPosition
            cellItem.frame = CGRect(x: px, y: CGFloat(py), width: btnWidth, height: CGFloat(btnHeight))
            cellItem.tag = idx
            btnsAry.append(cellItem)
        }
    }
    
    
    func getPayCoinHeight() -> CGFloat {
        return 100
    }
    
    @objc func itemDidTapAction(sender:UIButton) {
        //Expand more on the last one
        if sender.tag == btnsAry.count - 1 {
            self.isExpand = !self.isExpand
            self.showMoreCallback?(isExpand)
            self.bindFoldHeader(isExpand)
        }else {
            for btn in btnsAry {
                if btn == sender {
                    btn.isSelected = true
                }else {
                    btn.isSelected = false
                }
            }
            let model = self.models[sender.tag]
            selectLabel.text = model.text
            selectedItemValue = model.valueKey
            onFiatCallback?(model.valueKey)
        }
    }
    
    func getHeight(expand:Bool = false) -> CGFloat{
        let models =  self.getShowedCoinItems()
        
        var quotient = 1
        var remainder = 0
        
        quotient = models.count/self.column
        remainder = models.count%self.column
 
        if remainder > 0 {
            remainder = 1
        }
        let rowHeight = (quotient + remainder)*36
        let gapHeight = (quotient + remainder - 1)*15
        return CGFloat(rowHeight + gapHeight + 15 + 44)
    }
    
}

