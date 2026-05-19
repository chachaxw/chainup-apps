//
//  EXCoinWithDrawEmptyTagView.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/9.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXCoinWithDrawEmptyTagView: NibBaseView {
    @IBOutlet var tagView: EXTextField!
    
    override func onCreate() {
        tagView.enableTitleModel = true
        tagView.setPlaceHolder(placeHolder: "withdraw_tip_tagEmpty".localized())
        tagView.setTitle(title: "charge_text_tagAddress".localized())
    }

    func setEmpty() {
        tagView.setText(text: "")
    }
}
