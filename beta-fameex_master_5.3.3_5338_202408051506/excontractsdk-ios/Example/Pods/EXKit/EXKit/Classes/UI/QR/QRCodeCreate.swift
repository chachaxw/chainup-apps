//
//  QRCodeCreate.swift
//  Chainup
//
//  Created by zewu wang on 2018/8/23.
//  Copyright © 2018年 zewu wang. All rights reserved.
//

import UIKit

public class QRCodeCreate: NSObject {
    
    public func creteScancode(_ str : String , size : CGFloat = 128,level:String = "H") -> UIImage{
        
        //1.创建滤镜
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        
        //2.还原滤镜默认属性
        
        filter?.setDefaults()
        
        //3设置需要生产二维码的数据到滤镜中
        
        filter?.setValue(str.data(using: .utf8), forKey: "inputMessage")
        
        filter?.setValue(level, forKey: "inputCorrectionLevel")
        
        //4.从滤镜中取生产好的图片
        
        guard let ciImage = filter?.outputImage
            
            else {
                
                return UIImage()
                
        }
        
        let QRCodeImage = createNonInterpolatedUIImageFormCIImage(image: ciImage, size: size)
        
//        let bgIcon = UIImage(named: "tabbar_compose_lbs")
        
//        let customImage = creatImage(bgImage: QRCodeImage, iconImage: bgIcon!)
        
        return QRCodeImage
    }
    
    //MARK: - 根据CIImage生成指定大小的高清UIImage
    
    public func createNonInterpolatedUIImageFormCIImage(image: CIImage, size: CGFloat) -> UIImage {
        
        //CIImage没有frame与bounds属性,只有extent属性
        
        let ciextent: CGRect = image.extent.integral
        
        let scale: CGFloat = min(size/ciextent.width, size/ciextent.height)
        
        let context = CIContext(options: nil)  //创建基于GPU的CIContext对象,性能和效果更好
        
        let bitmapImage: CGImage = context.createCGImage(image, from: ciextent)! //CIImage->CGImage
        
        let width = ciextent.width * scale
        
        let height = ciextent.height * scale
        
        let cs: CGColorSpace = CGColorSpaceCreateDeviceGray() //灰度颜色通道
        
        let info_UInt32 = CGImageAlphaInfo.none.rawValue
        
        let bitmapRef = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: info_UInt32)! //图形上下文，画布
        
        bitmapRef.interpolationQuality = CGInterpolationQuality.none //写入质量
        
        bitmapRef.scaleBy(x: scale, y: scale) //调整“画布”的缩放
        
        bitmapRef.draw(bitmapImage, in: ciextent) //绘制图片
        if bitmapRef.makeImage() != nil{
            let scaledImage: CGImage = bitmapRef.makeImage()! //保存
            return UIImage(cgImage: scaledImage)
        }
        return UIImage()
        
    }
    
    //MARK: - 根据背景图片和头像合成头像二维码
    
    public func creatImage(bgImage: UIImage, iconImage:UIImage) -> UIImage{
        
        //开启图片上下文
        
        UIGraphicsBeginImageContext(bgImage.size)
        
        //绘制背景图片
        
        bgImage.draw(in: CGRect(origin: CGPoint.zero, size: bgImage.size))
        
        //绘制头像
        
        let width: CGFloat = 50
        
        let height: CGFloat = width
        
        let x = (bgImage.size.width - width) * 0.5
        
        let y = (bgImage.size.height - height) * 0.5
        
        iconImage.draw(in: CGRect(x: x, y: y, width: width, height: height))
        
        //取出绘制好的图片
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        //关闭上下文
        
        UIGraphicsEndImageContext()
        
        //返回合成好的图片
        if newImage == nil{
            return UIImage()
        }
        return newImage!
        
    }

}
