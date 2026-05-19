//
//  EXCoinWithdrawAmountView.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/5.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXCoinWithdrawAmountView: NibBaseView {

    @IBOutlet var amountInputView: EXWithDrawAmountField!
    var allBalance = ""
    
    override func onCreate() {
        amountInputView.setTitle(title: "charge_text_volume".localized())
        amountInputView.setPlaceHolder(placeHolder: "common_text_limitMin".localized())
        amountInputView.amountLabel.text = "withdraw_text_available".localized() + ":"
        amountInputView.rightSendAllLabel.text = "common_action_sendall".localized()
    }
    
    func setLimit(_ limit:String,_ balance:String,_ symbol:String,holdzero: Bool = true) {
        allBalance = balance
        let minum = "withdraw_text_minimumVolume".localized()
        let avalible = "withdraw_text_available".localized() + ": "
        amountInputView.symbol = symbol
        amountInputView.leftSymbolLabel.text = symbol
        amountInputView.setPlaceHolder(placeHolder: minum + " \(limit)")
        amountInputView.setAmount(amount: balance,title:avalible,holdzero: false)
//        amountInputView.amountLabel.text = avalible + " " + "\(balance) \(symbol)"
    }
}
