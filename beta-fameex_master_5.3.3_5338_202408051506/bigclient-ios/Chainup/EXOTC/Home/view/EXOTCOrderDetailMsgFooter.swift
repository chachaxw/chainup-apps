//
//  EXOTCOrderDetailMsgFooter.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/13.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXOTCOrderDetailMsgFooter: NibBaseView {

    @IBOutlet var msgLabel: UILabel!
    
    override func onCreate() {
        msgLabel.font = UIFont.ThemeFont.SecondaryRegular
        msgLabel.textColor = UIColor.ThemeState.warning
    }
    

}
