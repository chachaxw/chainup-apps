//
//  EXPhotoUploadView.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/17.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import YYWebImage
import EXKit
class EXPhotoUploadView: NibBaseView{
    
    typealias ImgDidTapped = () -> ()
    var imgTapCallback : ImgDidTapped?
    
    typealias ImgDidDelete = () -> ()
    var onImgDeletedCallback : ImgDidDelete?
    
    @IBOutlet var iconView: UIImageView!
    @IBOutlet var tapBtn: UIButton!
    var needHideCheckMark:Bool = false
    
    internal lazy var checkMarkView : CheckMarkView = {
        let check =  CheckMarkView.init(style:.xMark, isChecked:true, presenter:self)
        check.checkstrokeWidth = 1.26
        return check
    }()
    
    override func onCreate() {
        iconView.backgroundColor = UIColor.ThemeView.bgGap
        iconView.contentMode = UIView.ContentMode.scaleAspectFit
        self.backToNormalImg()
        self.configCheckMarkView()
    }
    
    func backToNormalImg() {
        iconView.image = EXKitBundle.svgImage(named:"assets_addingpaymentmethod")
        onImgDeletedCallback?()
    }
    
    func hideCheckMarkView(_ hide:Bool) {
        checkMarkView.isHidden = hide
        needHideCheckMark = hide
    }
    
    func configCheckMarkView(){
        self.checkMarkView.isHidden = true
        self.addSubview(self.checkMarkView)
        self.checkMarkView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.width.height.equalTo(32)
        }
    }
    
    @IBAction func didTapped(_ sender: Any) {
        imgTapCallback?()
    }
    
    func updateImg(_ uploadedImg:UIImage) {
        self.checkMarkView.isHidden = needHideCheckMark
        checkMarkView.checked = true
        iconView.image = uploadedImg
    }
    
    func updateImgUrl(_ url:String) {
        if let imgUrl = URL.init(string: url) {
            YYWebImageManager.shared()
                .requestImage(with:imgUrl,
                              options:YYWebImageOptions.setImageWithFadeAnimation, progress: nil, transform: nil){[weak self] (image, url , type, stage, err) in
                                guard let `self` = self else {return}
                                DispatchQueue.main.async(execute: {
                                    if let downloadedImg = image {
                                        self.checkMarkView.isHidden = self.needHideCheckMark
                                        self.checkMarkView.checked = true
                                        self.iconView.image = downloadedImg
                                    }
                                })
            }
        }
    }
}

extension EXPhotoUploadView : MarkCheckable {
    func didTapped(isCheck: Bool) {
        self.checkMarkView.isHidden = true
        self.backToNormalImg()
    }
}
