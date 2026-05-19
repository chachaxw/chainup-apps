//
//  EXAvatarView.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/19.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXAvatarView: NibBaseView {
    @IBOutlet var tapBtn: UIButton!
    @IBOutlet var avatarIcon: UIImageView!
    @IBOutlet var avatarName: UILabel!
    @IBOutlet var onlineStatusView: UIView!
    
    override func onCreate() {
        onlineStatusView.isHidden = true
        avatarName.font = UIFont.ThemeFont.BodyBold
        self.backgroundColor = UIColor.ThemeView.bg
    }
    
    func bindAvatarInfo(name:String,avatarImg:String,userOnline:Bool) {
        onlineStatusView.isHidden = false
        onlineStatusView.backgroundColor = userOnline ? UIColor.ThemeState.success : UIColor.ThemeLabel.colorDark
        avatarName.text = name
        avatarIcon.setImageWithUrl(path: avatarImg, text: name)
    }

}
