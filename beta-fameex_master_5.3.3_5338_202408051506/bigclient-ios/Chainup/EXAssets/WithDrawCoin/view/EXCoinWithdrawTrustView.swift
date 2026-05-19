//
//  EXCoinWithdrawTrustView.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/10.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXCoinWithdrawTrustView: NibBaseView {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var trustSwitch: EXSwitch!
    @IBOutlet var contentLabel: UILabel!
    
    override func onCreate() {
        titleLabel.textColor = UIColor.ThemeLabel.colorLite
        titleLabel.font = UIFont.ThemeFont.BodyMedium
        contentLabel.textColor = UIColor.ThemeLabel.colorMedium
        contentLabel.font = UIFont.ThemeFont.SecondaryMedium
        
        titleLabel.text = "withdraw_action_trustAddress".localized()
        contentLabel.text = "withdraw_tip_trustDesc".localized()
    }
}
