//
//  QRCodeCreate.swift
//  Chainup
//
//  Created by zewu wang on 2018/8/23.
//  Copyright © 2018年 zewu wang. All rights reserved.
//

import UIKit

class QRCodeCreate: NSObject {
    
    func creteScancode(_ str : String , size : CGFloat = 128) -> UIImage{
        
        //1. Create a filter
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        
        //2. Restore filter default attributes
        
        filter?.setDefaults()
        
        //3. Set the data that needs to produce QR codes into the filter
        
        filter?.setValue(str.data(using: .utf8), forKey: "inputMessage")
        
        filter?.setValue("H", forKey: "inputCorrectionLevel")
        
        //4. Take the produced image from the filter
        
        guard let ciImage = filter?.outputImage
            
            else {
                
                return UIImage()
                
        }
        
        let QRCodeImage = createNonInterpolatedUIImageFormCIImage(image: ciImage, size: size)
        
//        let bgIcon = UIImage(named: "tabbar_compose_lbs")
        
//        let customImage = creatImage(bgImage: QRCodeImage, iconImage: bgIcon!)
        
        return QRCodeImage
    }
    
    //MARK: - Generate high-definition UIImage of specified size based on CIImage
    
    func createNonInterpolatedUIImageFormCIImage(image: CIImage, size: CGFloat) -> UIImage {
        
        //CImage does not have frame and bounds attributes, only the extension attribute
        
        let ciextent: CGRect = image.extent.integral
        
        let scale: CGFloat = min(size/ciextent.width, size/ciextent.height)
        
        let context = CIContext(options: nil)  //Creating a GPU based CIContext object for better performance and effectiveness
        
        let bitmapImage: CGImage = context.createCGImage(image, from: ciextent)! //CIImage->CGImage
        
        let width = ciextent.width * scale
        
        let height = ciextent.height * scale
        
        let cs: CGColorSpace = CGColorSpaceCreateDeviceGray() //Grayscale Color Channel
        
        let info_UInt32 = CGImageAlphaInfo.none.rawValue
        
        let bitmapRef = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: info_UInt32)! //Graphic Context, Canvas
        
        bitmapRef.interpolationQuality = CGInterpolationQuality.none //Write quality
        
        bitmapRef.scaleBy(x: scale, y: scale) //Adjusting the Scale of the Canvas
        
        bitmapRef.draw(bitmapImage, in: ciextent) //Draw Picture
        if bitmapRef.makeImage() != nil{
            let scaledImage: CGImage = bitmapRef.makeImage()! //preserve
            return UIImage(cgImage: scaledImage)
        }
        return UIImage()
        
    }
    
    //MARK: - Compose avatar QR code based on background image and avatar
    
    func creatImage(bgImage: UIImage, iconImage:UIImage) -> UIImage{
        
        //Enable image context
        
        UIGraphicsBeginImageContext(bgImage.size)
        
        //Draw background image
        
        bgImage.draw(in: CGRect(origin: CGPoint.zero, size: bgImage.size))
        
        //Draw a avatar
        
        let width: CGFloat = 50
        
        let height: CGFloat = width
        
        let x = (bgImage.size.width - width) * 0.5
        
        let y = (bgImage.size.height - height) * 0.5
        
        iconImage.draw(in: CGRect(x: x, y: y, width: width, height: height))
        
        //Take out the drawn image
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        //Close Context
        
        UIGraphicsEndImageContext()
        
        //Return to the synthesized image
        if newImage == nil{
            return UIImage()
        }
        return newImage!
        
    }

}

