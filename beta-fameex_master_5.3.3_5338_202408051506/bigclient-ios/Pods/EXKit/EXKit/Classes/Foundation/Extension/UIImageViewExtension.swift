//
//  UIImageViewExtension.swift
//  SDJG
//
//  Copyright ©2020年 sunlands. All rights reserved.
//

import UIKit
import YYWebImage

extension UIImageView {
    
    
    /**
     设置图片名称
     
     - parameter imageName: 图片名称
     */
    public final func extSetImageName(_ imageName : String){
        self.image = UIImage.init(named: imageName)
    }

    
    public func setImagePathOrFirstLetter(url:String,firstLetter:String,backgroundHex:String,size:CGFloat = 14,textFont:UIFont = UIFont.ThemeFont.SecondaryBold,placeHolder:String) {
        if firstLetter.count > 0 {
            let nameImg = UIImage.getTextImage(drawText: String(firstLetter.prefix(1)), size: CGSize(width: size, height: size),color: UIColor.extColorWithHex(backgroundHex),textFont: textFont)
            self.image = nameImg
        }else {
            self.yy_setImage(with: URL.init(string: url), placeholder:UIImage.themeImageNamedFromPod(imageName: placeHolder))
        }
    }
    
    public func setImageWithUrl(path:String,text:String,placeHolder:String = "") {
        if let url = URL.init(string: path){
            self.yy_setImage(with: url, placeholder:UIImage.themeImageNamedFromPod(imageName: placeHolder))
        }else{
            if text.count > 0 {
                let nameImg = UIImage.getTextImage(drawText: String(text.prefix(1)), size: CGSize(width: 26, height: 26))
                self.image = nameImg
            }else {
                self.image =  UIImage.themeImageNamedFromPod(imageName: "headportrait1")
            }
        }
    }

}
