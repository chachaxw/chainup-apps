//
//  UIImageExtensiom.swift
//  SDJG
//
//  Copyright ©2020年 sunland. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    public func cornerRadius(_ bounds: CGRect) -> UIImage{
        //开始图形上下文
        UIGraphicsBeginImageContextWithOptions(CGSize(width: bounds.size.width, height: bounds.size.height), false, UIScreen.main.scale)
        //获取图形上下文
        let ctx = UIGraphicsGetCurrentContext()
        if ctx == nil {
            return self
        }
        //根据一个rect创建一个椭圆
        ctx!.addEllipse(in: bounds)
        //裁剪
        ctx!.clip()
        //将原照片画到图形上下文
        self.draw(in: bounds)
        //从上下文上获取剪裁后的照片
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        //关闭上下文
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    //图片压缩逻辑
    public func compressImage() -> Data{
        let imageSize = self.jpegData(compressionQuality: 1)!.count/1024
        var myImage = self
        if imageSize < 500{
            //如果小于500k,直接上传
            return myImage.jpegData(compressionQuality: 1)!
        }else{
            //取短边
            let width = myImage.size.width > myImage.size.height ? myImage.size.height:myImage.size.width
            if width <= 1080{
                //大于500k短边小于1080，直接上传
                return myImage.jpegData(compressionQuality: 1)!
            }else{
                //待压缩的Size
                let size: CGSize?
                //如果宽大于高
                if myImage.size.width > myImage.size.height{
                    size = CGSize.init(width: myImage.size.width*(1080/myImage.size.height), height: 1080)
                }else{
                    size = CGSize.init(width: 1080, height: myImage.size.height*(1080/myImage.size.width))
                }
                //尺寸压缩
                UIGraphicsBeginImageContext(size!)
                myImage.draw(in: CGRect.init(x: 0, y: 0, width: size!.width, height: size!.height))
                myImage = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
                
                if myImage.jpegData(compressionQuality: 1)!.count/1024 >= 500{
                    //尺寸压缩后还大于500k
                    for index in 1...5{
                        let rate = CGFloat(1) - 0.1*CGFloat(index)
                        let count = myImage.jpegData(compressionQuality: rate)!.count/1024
                        if count <= 500{
                            return myImage.jpegData(compressionQuality: rate)!
                        }
                        //系数0.5仍然大于500k上传
                        if index == 5{
                            return myImage.jpegData(compressionQuality: rate)!
                        }
                    }
                }else{
                    //尺寸压缩后还小于500k
                    
                    return myImage.jpegData(compressionQuality: 1)!
                }
            }
        }
        return myImage.jpegData(compressionQuality: 1)!
    }
    
    public static func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x:0, y: 0,  width:size.width,height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return image
        }else {
            return UIImage()
        }
    }
    
    public static func getTextImage(drawText: String,size: CGSize,color:UIColor = UIColor.ThemeLabel.colorDark,textFont:UIFont = UIFont.ThemeFont.BodyBold) -> UIImage {
        let img = self.getImageWithColor(color: color, size: size)
        
        // Setup the font specific variables
        let textColor = UIColor.white
        // Setup the image context using the passed image
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(img.size, false, scale)
        
        // Setup the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
            ]
        
        // Put the image into a rectangle as large as the original image
        img.draw(in: CGRect(x:0, y:0, width:img.size.width, height:img.size.height))
        
        let textSize = drawText.textSizeWithFont(textFont, width: img.size.width)
        
        // Create a point within the space that is as bit as the image
        let rect = CGRect(x:(img.size.width - textSize.width)/2, y:(img.size.height - textSize.height)/2, width:img.size.width, height:img.size.height)
        
        // Draw the text into an image
        drawText.draw(in: rect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        if let newImage = UIGraphicsGetImageFromCurrentImageContext() {
            
            // End the context now that we have the image we need
            UIGraphicsEndImageContext()
            return newImage
        }else {
            return UIImage()
        }
    }
    
    /// 更改图片颜色
    public func imageWithTintColor(color : UIColor) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
    
        color.setFill()
        let bounds = CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height)
        UIRectFill(bounds)
        self.draw(in: bounds, blendMode: CGBlendMode.destinationIn, alpha: 1.0)
        
        if let tintedImage = UIGraphicsGetImageFromCurrentImageContext(){
            UIGraphicsEndImageContext()
            return tintedImage
        }
        return self
    }
    
    
    /**
     *  重设图片大小
     */
    public func  reSizeImage(reSize: CGSize )-> UIImage  {
        //UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions (reSize, false , UIScreen .main.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height))
        let  reSizeImage: UIImage  =  UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext ();
        return  reSizeImage
    }
    
    /**
     *  等比率缩放
     */
    public func scaleImage(scaleSize: CGFloat )-> UIImage  {
        let reSize = CGSize(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
        return  reSizeImage(reSize: reSize)
    }

    //
    // 给定指定宽度，返回结果图像
    public func scaleImageToWidth(_ width: CGFloat) -> UIImage {
         // 1. 计算等比例缩放的高度
        let height = width * size.height / size.width
        // 2. 图像的上下文
        let s = CGSize(width: width, height: height)
        // 3.提示：一旦开启上下文，所有的绘图都在当前上下文中
        UIGraphicsBeginImageContext(s)
        // 4.在制定区域中缩放绘制完整图像
        draw(in: CGRect(origin: CGPoint.zero, size: s))
       // 5. 获取绘制结果
        let result = UIGraphicsGetImageFromCurrentImageContext()
         UIGraphicsEndImageContext()
        // 7. 返回结果
        return result!
    }
    
    
    /// imageBase64 -> UIImage
    /// - Parameter base64: imageBase64
    /// - Returns: the instance of UIImage
    public class func imageBy(base64: String?) -> UIImage? {
         guard let base64 = base64, !base64.isEmpty else { return nil }
         let array = base64.components(separatedBy: ",")
         guard let imgBase64 = array.count == 2 ? array[1] : array.first else { return nil }
         guard let imgData = Data(base64Encoded: imgBase64, options: .ignoreUnknownCharacters)  else { return nil }
         guard let image = UIImage(data: imgData) else { return  nil }
         return image
     }
}
