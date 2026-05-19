//
//  EXPaymentUploadView.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/16.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXPaymentUploadView: NibBaseView {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var photoImg: EXPhotoUploadView!
    
    typealias UploadImgRemoved = () -> ()
    var onImageRemovedCallback : UploadImgRemoved?
    
    
    override func onCreate() {
        photoImg.onImgDeletedCallback = {[weak self] in
            self?.onImageRemovedCallback?()
        }
        titleLabel.textColor = UIColor.ThemeLabel.colorMedium
        titleLabel.font = UIFont.ThemeFont.BodyRegular
    }
    
    func setUserEnabled(_ enabled:Bool) {
        self.isUserInteractionEnabled = enabled
//        photoImg.hideCheckMarkView(!enabled)
    }
    
    func setImgUrl(iconUrl:String) {
        photoImg.updateImgUrl(iconUrl)
    }
    
    func setImg(icon:UIImage) {
        photoImg.updateImg(icon)
    }
    
    func setTitle(_ title:String){
        titleLabel.text = title
    }
}
