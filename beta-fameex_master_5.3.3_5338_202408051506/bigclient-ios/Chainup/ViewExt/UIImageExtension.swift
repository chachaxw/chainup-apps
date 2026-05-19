//
//  UIImageExtensiom.swift
//  SDJG
//
//  Created by wangzewu on 16/6/6.
//Modify by Wang Jun on 17/6/5 Swift3.0
//  Copyright © 2016年 sunland. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    public func cornerRadius(_ bounds: CGRect) -> UIImage{
        //Start Graph Context
        UIGraphicsBeginImageContextWithOptions(CGSize(width: bounds.size.width, height: bounds.size.height), false, UIScreen.main.scale)
        //Get Graph Context
        let ctx = UIGraphicsGetCurrentContext()
        if ctx == nil {
            return self
        }
        //Create an ellipse based on a rect
        ctx!.addEllipse(in: bounds)
        //Cropping
        ctx!.clip()
        //Draw the original photo into the graphic context
        self.draw(in: bounds)
        //Obtain cropped photos from context
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        //Close Context
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    //Image compression logic
    public func compressImage() -> Data{
        let imageSize = UIImageJPEGRepresentation(self, 1)!.count/1024
        var myImage = self
        if imageSize < 500{
            //If it is less than 500k, upload directly
            return UIImageJPEGRepresentation(myImage, 1)!
        }else{
            //Take Short Edge
            let width = myImage.size.width > myImage.size.height ? myImage.size.height:myImage.size.width
            if width <= 1080{
                //If it is greater than 500k and the short side is less than 1080, it can be directly uploaded
                return UIImageJPEGRepresentation(myImage, 1)!
            }else{
                //Size to be compressed
                let size: CGSize?
                //If width is greater than height
                if myImage.size.width > myImage.size.height{
                    size = CGSize.init(width: myImage.size.width*(1080/myImage.size.height), height: 1080)
                }else{
                    size = CGSize.init(width: 1080, height: myImage.size.height*(1080/myImage.size.width))
                }
                //Size compression
                UIGraphicsBeginImageContext(size!)
                myImage.draw(in: CGRect.init(x: 0, y: 0, width: size!.width, height: size!.height))
                myImage = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
                
                if UIImageJPEGRepresentation(myImage, 1)!.count/1024 >= 500{
                    //After compression, the size is still greater than 500k
                    for index in 1...5{
                        let rate = CGFloat(1) - 0.1*CGFloat(index)
                        let count = UIImageJPEGRepresentation(myImage, rate)!.count/1024
                        if count <= 500{
                            return UIImageJPEGRepresentation(myImage, rate)!
                        }
                        //The coefficient of 0.5 is still greater than 500k for uploading
                        if index == 5{
                            return UIImageJPEGRepresentation(myImage, rate)!
                        }
                    }
                }else{
                    //Less than 500k after size compression
                    
                    return UIImageJPEGRepresentation(myImage, 1)!
                }
            }
        }
        return UIImageJPEGRepresentation(myImage, 1)!
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
    
    public static func getTextImage(drawText: String,size: CGSize) -> UIImage {
        let color = UIColor.ThemeLabel.colorDark
        let img = self.getImageWithColor(color: color, size: size)
        
        // Setup the font specific variables
        let textColor = UIColor.white
        let textFont = UIFont.ThemeFont.BodyBold
        // Setup the image context using the passed image
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(img.size, false, scale)
        
        // Setup the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSAttributedStringKey.font: textFont,
            NSAttributedStringKey.foregroundColor: textColor,
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
    
    ///Change Picture Color
    func imageWithTintColor(color : UIColor) -> UIImage{
        UIGraphicsBeginImageContext(self.size)
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
*Reset Picture Size
     */
    func  reSizeImage(reSize: CGSize )-> UIImage  {
        //UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions (reSize, false , UIScreen .main.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height))
        let  reSizeImage: UIImage  =  UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext ();
        return  reSizeImage
    }
    
    /**
*Proportional scaling
     */
    func scaleImage(scaleSize: CGFloat )-> UIImage  {
        let reSize = CGSize(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
        return  reSizeImage(reSize: reSize)
    }

    //
    //Given the specified width, return the resulting image
    func scaleImageToWidth(_ width: CGFloat) -> UIImage {
         //1. Calculate the height of equal scaling
        let height = width * size.height / size.width
        //2. Context of images
        let s = CGSize(width: width, height: height)
        //3. Reminder: Once the context is enabled, all drawings are in the current context
        UIGraphicsBeginImageContext(s)
        //4. Zoom and draw the complete image in the designated area
        draw(in: CGRect(origin: CGPoint.zero, size: s))
       //5. Obtain drawing results
        let result = UIGraphicsGetImageFromCurrentImageContext()
         UIGraphicsEndImageContext()
        //7. Return Results
        return result!
    }
}


