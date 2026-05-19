//
//  EXCoinBorrowRecordSectionHeaderView.swift
//  Chainup
//
//  Created by ljw on 2023/11/5.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXCoinBorrowRecordSectionHeaderView: UIView,NibLoadable {

    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var historyBtn: UIButton!
   
    @IBOutlet weak var line: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.ThemeView.bg
        titleLab.extSetText("leverage_current_borrow".localized(), textColor: UIColor.ThemeLabel.colorLite, fontSize: 16)
        titleLab.font = UIFont.init(name: "PingFangSC-Semibold", size: 16)
        historyBtn.extSetTitle("asset_lever_history".localized(), 14, UIColor.ThemeLabel.colorMedium, UIControl.State.normal)
         var img = UIImage.themeImageNamed(imageName: "fiat_order")
        img = img.yy_imageByResize(to: CGSize.init(width: 12, height: 12.8), contentMode: UIView.ContentMode.center) ?? UIImage.init()
        
        historyBtn.setImage(img, for: UIControl.State.normal)
        line.backgroundColor = UIColor.ThemeView.seperator
    }
}
