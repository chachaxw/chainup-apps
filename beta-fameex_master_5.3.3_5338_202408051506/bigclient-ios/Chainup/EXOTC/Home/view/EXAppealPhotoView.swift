//
//  EXAppealPhotoView.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/16.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXAppealPhotoView: NibBaseView {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var upLoadImg: UIButton!
    @IBOutlet var tipMsgLabel: UILabel!
    @IBOutlet var tipMsgContentLabel: UILabel!
    @IBOutlet var photoImg: EXPhotoUploadView!
    
    let msgContent = "appeal_explain_warning".localized()
    
    override func onCreate() {
        titleLabel.textColor = UIColor.ThemeLabel.colorMedium
        tipMsgLabel.textColor = UIColor.ThemeLabel.colorDark
        tipMsgContentLabel.textColor = UIColor.ThemeLabel.colorMedium
        
        titleLabel.font = UIFont.ThemeFont.BodyRegular
        tipMsgLabel.font = UIFont.ThemeFont.SecondaryRegular
        tipMsgContentLabel.font = UIFont.ThemeFont.SecondaryRegular
        
        titleLabel.text = "appeal_action_uploadImg".localized()
        tipMsgLabel.text = "otc_tip_tradeHintTitle".localized()
        tipMsgContentLabel.text = msgContent
    }
    
    func setImg(icon:UIImage) {
        photoImg.updateImg(icon)
    }
    
    func setImgUrl(iconUrl:String) {
        photoImg.updateImgUrl(iconUrl)
    }
    
    func getHeight() -> CGFloat {
        let msgHeight = msgContent.textSizeWithFont(UIFont.ThemeFont.SecondaryRegular, width: SCREEN_WIDTH - 30).height
        return msgHeight + 156
    }

}
