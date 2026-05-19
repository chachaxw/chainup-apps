//
//  EXAddressTrustView.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/14.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXAddressTrustView: NibBaseView {
    @IBOutlet var didTrustView: UIView!
    @IBOutlet var needTrustView: UIView!
    @IBOutlet var tipMsgLabel: UILabel!
    @IBOutlet var didTrustTitle: UILabel!
    @IBOutlet var trustTitle: UILabel!
    @IBOutlet var trustSwitch: EXSwitch!
    
    override func onCreate() {
        didTrustTitle.text = "withdraw_text_trustAddress".localized()
        trustTitle.text = "withdraw_action_trustAddress".localized()
        tipMsgLabel.text = "withdraw_tip_trustDesc".localized()
        self.trustSwitch.snp_remakeConstraints { make in
            make.width.equalTo(60)
            make.height.equalTo(40)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
        }
    }
    
    func isTrusted(_ istrust:Bool) {
        if istrust {
            needTrustView.isHidden = true
        }else {
            didTrustView.isHidden = true
        }
    }

}
