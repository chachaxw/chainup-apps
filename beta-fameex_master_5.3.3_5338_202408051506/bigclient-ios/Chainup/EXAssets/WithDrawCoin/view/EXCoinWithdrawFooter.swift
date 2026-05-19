//
//  EXCoinWithdrawFooter.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/5.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXCoinWithdrawFooter: NibBaseView {
    @IBOutlet var footerTitle: UILabel!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var confirmBtn: EXButton!
    
    override func onCreate() {
        backgroundColor = .Ex.fill2
        nibView.backgroundColor = .clear
        footerTitle.text = "withdraw_text_moneyWithoutFee".localized()
        footerTitle.font = .Ex.regular(14)
        amountLabel.text = ""
        amountLabel.font = .Ex.medium(14)
        confirmBtn.setTitle("common_text_btnConfirm".localized(), for: .normal)
    }
    
    func hideFooterTitle() {
        footerTitle.isHidden = true
    }

    static func getHeight()->CGFloat {
        return 112
    }
}
