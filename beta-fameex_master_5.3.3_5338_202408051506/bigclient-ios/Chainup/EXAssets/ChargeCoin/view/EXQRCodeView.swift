//
//  EXQRCodeView.swift
//  Chainup
//
//  Created by liuxuan on 2019/4/29.
//  Copyright © 2019 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXQRCodeView: NibBaseView {
    
    var didTapedSaveImage: (() -> ())?
    
    @IBOutlet var qrImage: UIImageView!
    @IBOutlet var saveBtn: EXButton!
    @IBOutlet weak var btnContainerView: UIView!
    
    override func onCreate() {
        saveBtn.clearColors()
        saveBtn.setTitleColor(UIColor.ThemeView.highlight, for: .normal)
        saveBtn.titleLabel?.font = UIFont.ThemeFont.BodyMedium
        saveBtn.setTitle("charge_action_saveQR".localized(), for: .normal)
    }
    
    @IBAction func saveImg(_ sender: Any) {
        
        if let action = didTapedSaveImage {
            action()
        }
        else {
            if let img = qrImage.image {
                UIImageWriteToSavedPhotosAlbum(img, self, #selector(self.saveImg(image:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
        
        
    }
    
    @objc func saveImg(image:UIImage,didFinishSavingWithError error:NSError?,contextInfo:AnyObject) {
        if error != nil{
            EXAlert.showFail(msg: "common_tip_saveImgFail".localized())
            return
        }
        EXAlert.showSuccess(msg: "common_tip_saveImgSuccess".localized())
    }

}
