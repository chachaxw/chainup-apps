//
//  EXAssetsAttectionAlert.swift
//  Chainup
//
//  Created by wangdong on 2023/9/9.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import EXKit
class EXAssetsAttectionAlert: NibBaseView {

    @IBOutlet weak var tipimage: UIImageView!
    @IBOutlet weak var contentBg: UIView!
    
    @IBOutlet weak var contentLabel: UILabel!
    @IBAction func onCloseAction(_ sender: Any) {
        EXAlert.dismiss()
    }
    override func onCreate(){
        self.backgroundColor = UIColor.ThemeView.alertBg
        self.contentBg.backgroundColor = UIColor.ThemeView.alertBg
        self.tipimage.image = EXKitBundle.svgImage(named: "img_optional")
        self.tipimage.contentMode = .scaleAspectFill
    }
}
