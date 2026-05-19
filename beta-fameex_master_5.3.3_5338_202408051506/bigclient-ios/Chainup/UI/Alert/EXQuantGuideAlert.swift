//
//  EXQuantGuideAlert.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/30.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
import YYText
let comImageUrl = "https://chainup-test.s3.ap-northeast-1.amazonaws.com/app_img/"

class EXQuantGuideAlert: NibBaseView {
    let imagesNames = ["greatepolicy","policyrun","policystop"]
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bgScroll: UIScrollView!
    @IBOutlet var okBtn: EXButton!
    @IBOutlet var nextBtn: EXButton!
    lazy var imageContentView = UIView()
    var images:[UIImage] = []
    var currentIdx:Int = 0
    
    override func onCreate() {
        bgScroll.addSubview(imageContentView)
        imageContentView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
        }
        titleLabel.textColor = UIColor.ThemeLabel.colorLite
        titleLabel.font = .Ex.medium(17)
        okBtn.setTitle("alert_common_i_understand".localized(), for: .normal)
        okBtn.backgroundColor = UIColor.ThemeView.card2
        okBtn.setTitleColor(UIColor.ThemeLabel.colorLite, for: .normal)
        nextBtn.setTitle("common_action_next".localized(), for: .normal)
        nextBtn.color = UIColor.ThemeLabel.colorHighlight
//        bgScroll.backgroundColor = UIColor.ThemeView.bg
//        self.backgroundColor = UIColor.ThemeView.alertBg
        bgScroll.backgroundColor = .Ex.fill6
        self.backgroundColor = .Ex.fill6
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners(corners: [.allCorners], radius: 4)
    }
    
    func updateImgs(guideImageNames:[String],title:String) {
        self.titleLabel.text = title
        self.images = self.imagesNames.map({ name -> UIImage in
            let imageName = self.getQuantGuideImageName(name: name,defaultEn_Us: true)
            return UIImage(named: imageName) ?? UIImage()
        })
        configImage(indx: 0)
    }
    
    var currentIndex:Int?
    func configImg(palceHoderImage:UIImage, imgeUrl: String?, index:Int) {
        currentIndex = index
        let imgv = UIImageView()
        imageContentView.addSubview(imgv)
        updateImageView(with: imgv, image: palceHoderImage)
        if let imgeUrl = imgeUrl, let url = URL(string: imgeUrl) {
            imgv.yy_setImage(with: url,placeholder: palceHoderImage) {[weak self, weak imgv] image, _, _, _, error in
                guard let imgv = imgv, let image = image, self?.currentIdx == index else { return }
                self?.updateImageView(with: imgv, image: image)
            }
        }
    }
    
    func updateImageView(with imageView:UIImageView?, image:UIImage) {
        guard let imageView = imageView else { return }
        imageView.image = image
        let imageSize = YYTextCGSizePixelCeil(CGSize(width: Device_W - 64, height: image.size.height * (Device_W - 64) / image.size.width))
        imageView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
            make.size.equalTo(imageSize)
        }
        self.snp.remakeConstraints { (make) in
            make.height.equalTo(min(imageSize.height + 137, TABBAR_CONTENTVIEW_HEIGHT))
        }
    }
    
    @IBAction func clickClose(_ sender: Any) {
        EXAlert.dismiss()
    }
    
    @IBAction func clickNext(_ sender: Any) {
        currentIdx += 1
        if images.count > currentIdx {
            
            imageContentView.subviews.forEach { (v) in
                v.removeFromSuperview()
            }
            configImage(indx: currentIdx)
            if currentIdx == images.count - 1 {
                okBtn.clearColors()
                okBtn.backgroundColor = UIColor.ThemeView.highlight
                okBtn.setTitleColor(UIColor.white, for: .normal)
                nextBtn.isHidden = true
            }
        }else {
            EXAlert.dismiss()
        }
    }
    
    
    
    func configImage(indx: Int) {
        //    greatepolicy_el_GR_dark
        //    greatepolicy_el_GR_light
        //    policyrun_el_GR_dark
        //    policystop_el_GR_dark
//    https://chainup-test.s3.ap-northeast-1.amazonaws.com/app_img/greatepolicy_el_GR_dark.png
//        if LanguageTools.isHan(){
//
//        }else{
//
//        }
        
        let image = self.images[indx]
        let imageName = self.imagesNames[indx]
        let newImageName = self.getQuantGuideImageName(name: imageName)
        var imageUrl: String? = comImageUrl + newImageName
        
        
//        if LanguageHandler.priviatePhoneLanguage == "en_US" {
//            imageUrl = nil
//        }
//        print(imageUrl)
        configImg(palceHoderImage: image, imgeUrl: imageUrl, index: indx)
        
    }

    
    func getQuantGuideImageName(name: String,defaultEn_Us: Bool = false) -> String{
        
         //    greatepolicy_el_GR_dark
         //    greatepolicy_el_GR_light
         //    policyrun_el_GR_dark
         //    policystop_el_GR_dark
        var lan  = LanguageHandler.priviatePhoneLanguage
        if defaultEn_Us {
           lan = "en_US"
        }
        let sunfix = EXTheme.current == .dark ? "dark" : "light"
        let imgName = name + "_" + lan + "_" + sunfix + ".png"
        print("imgName = \(imgName)")
        return imgName
    }
}


