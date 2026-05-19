//
//  EXOTCOrderInfoDisplayTitle.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/28.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXOTCOrderInfoDisplayTitle: NibBaseView {

    @IBOutlet var gapHeight: NSLayoutConstraint!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
    @IBOutlet var copyBtn: UIButton!
    
    var showTopGap:Bool = false {
        didSet {
            gapHeight.constant = showTopGap ? 10 : 0
        }
    }
    
    override func onCreate() {
        self.showTopGap = false
        copyBtn.setImage(UIImage.themeImageNamed(imageName: "trade_compared"), for: UIControl.State.normal)
    }
    
    @IBAction func btnClicked(_ sender: Any) {
        if let value = titleLabel.text,value.count > 0 {
            UIPasteboard.general.string = value
            EXAlert.showSuccess(msg: "common_tip_copySuccess".localized())
        }
    }
    
    func bindModel(model:OTCOrderInfoModel?) {
        guard let detailModel = model else {
            return
        }
        titleLabel.text = detailModel.title
        valueLabel.text = detailModel.value
    }
}
