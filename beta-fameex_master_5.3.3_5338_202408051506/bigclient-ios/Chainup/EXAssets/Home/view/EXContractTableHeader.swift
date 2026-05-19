//
//  EXContractTableHeader.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/27.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXContractTableHeader: NibBaseView {

    @IBOutlet var toolBar: EXAssetToolBar!
    @IBOutlet var balanceLabel: UILabel!
    @IBOutlet var marginLabel: UILabel!
    @IBOutlet var positionMargin: UILabel!
    
    @IBOutlet var balanceValue: UILabel!
    @IBOutlet var marginValue: UILabel!
    @IBOutlet var positionValue: UILabel!
    var accountModel:EXContractAccountModel = EXContractAccountModel()
    
    override func onCreate() {
        
        balanceLabel.textColor = UIColor.ThemeLabel.colorMedium
        marginLabel.textColor = UIColor.ThemeLabel.colorMedium
        positionMargin.textColor = UIColor.ThemeLabel.colorMedium

        balanceValue.textColor = UIColor.ThemeLabel.colorLite
        marginValue.textColor = UIColor.ThemeLabel.colorLite
        positionValue.textColor = UIColor.ThemeLabel.colorLite
        
        balanceLabel.text = "withdraw_text_available".localized()
        marginLabel.text = "contract_text_orderMargin".localized()
        positionMargin.text = "contract_text_positionMargin".localized()

    }
    
    func reloadHeader() {
        let privacy = XUserDefault.assetPrivacyIsOn()
        balanceValue.text = !privacy ? accountModel.canUseBalance.formatAmount("BTC") + " BTC" : String.privacyString()
        marginValue.text = !privacy ? accountModel.orderMargin.formatAmount("BTC") + " BTC" : String.privacyString()
        positionValue.text = !privacy ? accountModel.positionMargin.formatAmount("BTC") + " BTC" : String.privacyString()
    }
    
    func bindHeaderModel(_ model:EXContractAccountModel) {
        self.accountModel = model
        self.reloadHeader()
    }
    
}
