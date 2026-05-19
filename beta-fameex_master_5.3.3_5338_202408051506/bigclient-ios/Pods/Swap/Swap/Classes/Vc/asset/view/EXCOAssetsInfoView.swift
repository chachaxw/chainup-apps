//
//  EXAssetsInfoView.swift
//  Chainup
//
//  Created by wangdong on 2023/9/9.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import EXKit

class EXCOAssetsInfoView: EXSNibBaseView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var assetsLabel: UILabel!
    @IBOutlet weak var assetsSubLabel: UILabel!
    @IBOutlet weak var pieChartButton: UIButton!
    @IBOutlet var earningsView: UIView!
    @IBOutlet var earningTitle: UILabel!
    @IBOutlet var earningAlertBtn: UIButton!
    @IBOutlet var earnings: UIButton!
    
    override func onCreate() {
        earningsView.isHidden = true
        pieChartButton.isHidden = true
        assetsLabel.font = UIFont.ThemeFont.H3Medium
        assetsSubLabel.font = UIFont.ThemeFont.SecondaryRegular
        
    }
    
    //MARK: fix 修改 English: MARK: fix modification
    func bindAssetModel(_ assetModel: EXContractBlance) {
        let privacy = EXStoreData.assetPrivacyIsOn()
        titleLabel.text = assetModel.title
        assetsLabel.text = !privacy ? assetModel.btcAccount : String.privacyString()
        assetsSubLabel.text = !privacy ? assetModel.rmbAccount : String.privacyString()
    }
}

