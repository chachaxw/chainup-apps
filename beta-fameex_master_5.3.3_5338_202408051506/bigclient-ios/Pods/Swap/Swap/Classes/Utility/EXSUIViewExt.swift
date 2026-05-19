//
//  EXSUIViewExt.swift
//  CoNetworkTest
//
//  Created by ZYJ on 2023/1/13.
//

import UIKit

import EXKit
import SwiftUI
import Moya


extension UIImage{
    func newAsImage() -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        //print("rect = \(rect)")
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 10)
        if let img = TMOCutImageManager.sharedInstance.clipWithPath(path: path, image: self){
            return img
        }
        return UIImage()

    }
}

class TMOCutImageManager: NSObject {
   
   static let sharedInstance = TMOCutImageManager()
   
    
   /// 根据坐标点，生产贝斯曲线 English: /Based on the coordinate points, produce a Bayesian curve
   /// - Parameter array: 所有CGPoint点数组 English: /- Parameter array: All CGPoint point arrays
   /// - Returns: 返回path English: /- Returns: returns the path
   func creatBezierPath(array:[CGPoint])->UIBezierPath{
       let path:UIBezierPath = UIBezierPath()
       
       if array.count > 0{
           for (index, point) in array.enumerated() {
               if index == 0 {
                   path.move(to: point)
               }else{
                   path.addLine(to: point)
               }
           }
           path.close()
       }
       return  path
   }
   
   /// 根据path切割图片 English: /Cut the image according to the path
   /// - Parameters:
   ///   - path: 贝斯曲线 English: /- path: Bayesian curve
   ///   - image: 原来图片 English: /- Image: Original image
   ///   - rect: 绘制后区间大小 English: /- rect: Draw the size of the interval after drawing
   /// - Returns: 返回裁剪好的图片 English: /- Returns: returns the cropped image
   func clipWithPath(path:UIBezierPath,image:UIImage)->UIImage?{
       
       let newImage = image
       
       //开始绘制图片 English: Start drawing image
       UIGraphicsBeginImageContextWithOptions(image.size, false, UIScreen.main.scale)
       
       if let  contextRef:CGContext = UIGraphicsGetCurrentContext(),
          let cgImage = newImage.cgImage{
           
           let clipPath:UIBezierPath = path
           
           contextRef.addPath(clipPath.cgPath)
           contextRef.closePath()
           contextRef.clip()
           
           //坐标系转换 English: Coordinate system conversion
           contextRef.translateBy(x: 0, y: newImage.size.height)
           contextRef.scaleBy(x: 1, y: -1)
           
           let drawRect = CGRect(x: 0, y: 0, width: newImage.size.width, height: newImage.size.height)
           contextRef.draw(cgImage, in: drawRect)
           
           let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
           UIGraphicsEndImageContext()//结束绘画 English: End painting
           
           return croppedImage
       }
       return nil
   }
   
   
   
   /// 通过 CGImage 或 CIImage 裁剪 English: /Cropping through CGImage or CIImage
   /// - Parameters:
   ///   - image: 原图 English: /- Image: Original image
   ///   - rect: 裁剪区域 English: /- rect: Crop region
   /// - Returns: 返回裁剪后的图片 English: /- Returns: returns the cropped image
   func imagecutWithOriginalImage(image:UIImage,rect:CGRect)->UIImage?{
       if let cgImage = image.cgImage,
          let croppedCgImage = cgImage.cropping(to: rect) {
           return UIImage(cgImage: croppedCgImage)
       } else if let ciImage = image.ciImage {
           let croppedCiImage = ciImage.cropped(to: rect)
           return UIImage(ciImage: croppedCiImage)
       }
       return nil
   }
   
   
   /// 通过位图(Bitmap)裁剪 English: /Crop through Bitmap
   /// - Parameters:
   ///   - image: 原图 English: /- Image: Original image
   ///   - rect: 裁剪区域 English: /- rect: Crop region
   /// - Returns: 返回裁剪后的图片 English: /- Returns: returns the cropped image
   func cropImage(_ image: UIImage, withRect rect: CGRect) -> UIImage? {
       UIGraphicsBeginImageContext(rect.size)
       guard let context = UIGraphicsGetCurrentContext() else { return nil }
       context.translateBy(x: -rect.minX, y: -rect.minY)
       image.draw(at: .zero)
       let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
       UIGraphicsEndImageContext()
       return croppedImage
   }
}


extension UIView {

    //可设置borderwidth English: Borderwidth can be set
    @IBInspectable var ex_borderW: CGFloat {
        get {
            return layer.borderWidth
        }
        
        set {
            layer.borderWidth = newValue
        }
    }
}

extension UIView {
    func ex_viewController() -> UIViewController? {
        var view:UIView? = self
        
        while view?.superview != nil {
            let nextResponder = view?.next
            if ((nextResponder as? UIViewController) != nil) {
                return nextResponder as? UIViewController
            }
            view = view?.superview
        }
        return nil;
    }
    var exs_viewContainingController: UIViewController? {
        var nextResponder:UIResponder? = self
        while nextResponder != nil {
            if nextResponder!.isKind(of: UIViewController.self) {
                return (nextResponder as! UIViewController)
            }
            nextResponder = nextResponder?.next
        }
        return nil
    }
}
extension UITextField{
    
    public func exs_CenterPlaceHolderAtt(_ str : String , color : UIColor = UIColor.ThemeLabel.colorDark , font : UIFont = UIFont.ThemeFont.BodyRegular){
        let parg = NSMutableParagraphStyle()
        parg.alignment = .center
        let placeHolderAtt = NSMutableAttributedString().exs_add(string: str, attrDic: [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor : color,NSAttributedString.Key.paragraphStyle: parg
        ]
        )
        self.attributedPlaceholder = placeHolderAtt
    }
    //设置placeHolder的富文本 English: Set rich text for placeHolder
    public func exs_setPlaceHolderAtt(_ str : String , color : UIColor = UIColor.ThemeLabel.colorDark , font : CGFloat = 14){
//        let placeHolderAtt = NSMutableAttributedString().add(string: str, attrDic: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: font) , NSAttributedString.Key.foregroundColor : color])
//        self.attributedPlaceholder = placeHolderAtt
        exs_setPlaceHolderAtt(str, color: color, font: font, weight: .regular)
    }
    
    public func exs_setPlaceHolderAtt(_ str : String , color : UIColor = UIColor.ThemeLabel.colorDark , font : CGFloat = 14, weight: UIFont.Weight){
        let placeHolderAtt = NSMutableAttributedString().exs_add(string: str, attrDic: [NSAttributedString.Key.font :  UIFont.ThemeFont.getFont(size: font, aweight: weight), NSAttributedString.Key.foregroundColor : color])
        self.attributedPlaceholder = placeHolderAtt
    }
   
    
}

extension UIColor{
   static func getConfigBg() -> UIColor {
        var bgColor = UIColor.ThemeView.card2
        if EXThemeManager.isNight() == false{
            bgColor = UIColor.ThemeView.newbg
        }
        return bgColor
    }
}
extension UITextField {
    
    ///给UITextField添加一个清除按钮 English: /Add a clear button to UITextField
    func exs_setModifyClearButton() {
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(UIImage.exs_themeImageNamed(imageName: "public_deleteall"), for: .normal)
        clearButton.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        clearButton.contentMode = .scaleAspectFit
        clearButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 19, bottom: 0, right: 0)
        clearButton.addTarget(self, action: #selector(UITextField.exs_clear(sender:)), for: .touchUpInside)
        let container = UIView(frame: clearButton.frame)
        container.backgroundColor = .clear
        container.addSubview(clearButton)
        
        self.rightView = container
//        self.rightViewMode = .whileEditing
    }
    
    /// 点击清除按钮，清空内容 English: /Click the clear button to clear the content
    @objc func exs_clear(sender: AnyObject) {
        self.text = ""
        self.sendActions(for: .valueChanged)
    }
    
}
extension UIStackView {
    func exs_removeAllArrangedSubviews() {
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        // Deactivate all constraints
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))
        // Remove the views from self
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}

extension UIImage {
   class func exs_imageWithColor(_ color:UIColor) -> UIImage? {
        return exs_imageWithColor(color, size: CGSize(width: 1, height: 1))
    }
   class func exs_imageWithColor(_ color:UIColor,size:CGSize) -> UIImage? {
        if ( size.width <= 0 || size.height <= 0) {return nil};
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0);
        if let context = UIGraphicsGetCurrentContext() {
            
            context.setFillColor(color.cgColor);
            context.fill(rect);
            let image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            return image;
        }
        return nil
    }
}


