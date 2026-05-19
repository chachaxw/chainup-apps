//
//  EXCurrentLine.swift
//  Chainup
//
//  Created by wangdong on 2023/8/31.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import EXKit
class EXCurrentLine: NibBaseView {

    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var arrowImageView: UIImageView!
    
    
    override func onCreate() {
        containerView.layer.borderColor = UIColor.ThemekLine.viewbgIcon.cgColor
        arrowImageView.image = UIImage.themeImageNamed(imageName: "right")
        valueLabel.textColor = UIColor.ThemekLine.labcolorMedium
        containerView.backgroundColor = UIColor.ThemekLine.viewBg
    }
}
