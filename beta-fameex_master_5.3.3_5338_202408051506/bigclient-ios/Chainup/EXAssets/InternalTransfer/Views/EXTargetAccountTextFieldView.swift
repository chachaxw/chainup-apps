//
//  EXTargetAccountTextFieldView.swift
//  Chainup
//
//  Created by chainup on 2023/7/6.
//  Copyright © 2023 chainup. All rights reserved.
//

import UIKit
import EXKit
class EXTargetAccountTextFieldView: NibBaseView {
    @IBOutlet var targetAccountField: EXTextField!

    override func onCreate() {
        targetAccountField.enableTitleModel = true
        targetAccountField.setTitle(title:"internalTransfer_text_address".localized())
        targetAccountField.setPlaceHolder(placeHolder:"common_tip_targetAccount".localized())
    }
}
