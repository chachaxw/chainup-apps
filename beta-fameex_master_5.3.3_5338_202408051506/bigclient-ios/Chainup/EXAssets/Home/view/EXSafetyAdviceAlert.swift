//
//  EXSafetyAdviceAlert.swift
//  Chainup
//
//  Created by wangdong on 2020/9/9.
//  Copyright © 2020 ChainUP. All rights reserved.
//

import UIKit
import EXKit
class EXSafetyAdviceAlert: NibBaseView {
    @IBOutlet weak var imageBgView: UIView!
    
    @IBOutlet weak var tipImage: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var checkboxButton: UIButton!
    @IBOutlet weak var contentLabel1: UILabel!
    @IBOutlet weak var contentLabel2: UILabel!
    @IBOutlet weak var contentLabel3: UILabel!
//    @IBOutlet var iconImg: UIImageView!
    
//    @IBOutlet var iconBg: UIView!
    var didClose: ((Bool) -> ())?
    
    override func onCreate() {
        imageBgView.backgroundColor = .clear
        tipImage.image = EXKitBundle.svgImage(named: "img_prompt")
        tipImage.contentMode = .scaleAspectFill
        checkboxButton.setEnlargeEdgeWithTop(30, left: 30, bottom: 30, right: 30)
        
        checkboxButton.setImage(UIImage.themeImageNamed(imageName: "stop_noml_daytime"), for: .normal)
        checkboxButton.setImage(UIImage.themeImageNamed(imageName: "stop_seletecd"), for: .selected)
//        iconBg.backgroundColor = UIColor.ThemeView.bgTab
//        iconImg.image = UIImage.themeImageNamed(imageName: "assets_safetyadvice")
        contentLabel1.attributedText = "assets_security_advice_tips1".localized().lineSpacingString(font: UIFont.systemFont(ofSize: 14, weight: .medium), color: UIColor.ThemeLabel.colorLite, lineSpacing: 10, textAligment: .left)
    
        contentLabel2.attributedText = "assets_security_advice_tips2".localized().lineSpacingString(font: UIFont.systemFont(ofSize: 14, weight: .medium), color: UIColor.ThemeLabel.colorLite, lineSpacing: 10, textAligment: .left)
        
        contentLabel3.attributedText = "assets_security_advice_tips3".localized().lineSpacingString(font: UIFont.systemFont(ofSize: 14, weight: .medium), color: UIColor.ThemeLabel.colorLite, lineSpacing: 10, textAligment: .left)
    }
    
    @IBAction func onCloseAction(_ sender: Any) {
        EXAlert.dismissEnd {
            self.didClose?(self.checkboxButton.isSelected)
        }
    }
    
    @IBAction func onCheckboxAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
}
