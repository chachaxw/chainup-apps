//
//  EXAssetsInfoView.swift
//  Chainup
//
//  Created by wangdong on 2023/9/9.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import EXKit
class EXLayoutConstraint: NSLayoutConstraint {
    override func awakeFromNib() {
        if self.constant == 1 {
            constant = 1 / UIScreen.main.scale
        }
    }
}

class EXAssetsInfoView: NibBaseView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var assetsLabel: UILabel!
    @IBOutlet weak var assetsSubLabel: UILabel!
    @IBOutlet weak var pieChartButton: UIButton!
    
    override func onCreate() {
        pieChartButton.isHidden = true
        pieChartButton.setImage(UIImage.themeImageNamed(imageName: "assets_distribution"), for: .normal)
        assetsLabel.font = UIFont.ThemeFont.H3Medium
    }
    
    func bindAssetModel(_ assetModel:EXCommonAssetModel) {
        let privacy = XUserDefault.assetPrivacyIsOn()
        if assetModel.totalBalanceSymbol.count > 0 {
            titleLabel.text = assetModel.title + " (\(assetModel.totalBalanceSymbol))"
        }else {
            titleLabel.text = assetModel.title
        }
        assetsLabel.text = !privacy ? assetModel.totalBalance.formatAmount(assetModel.totalBalanceSymbol,isLeverage:assetModel.assetType == .leverage) : String.privacyString()
        assetsSubLabel.text = !privacy ? assetModel.getCaculatePrice() : String.privacyString()
    }
}
