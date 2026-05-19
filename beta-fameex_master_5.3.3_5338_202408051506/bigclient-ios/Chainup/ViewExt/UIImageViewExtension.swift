//
//  UIImageViewExtension.swift
//  SDJG
//
//  Created by 王俊 on 16/4/19.
//Modify by Wang Jun on 17/6/5 Swift3.0
//  Copyright © 2016年 sunlands. All rights reserved.
//

import UIKit

extension UIImageView {
    
    
    /**
Set Picture Name
     
-Parameter imageName: Image name
     */
    public final func extSetImageName(_ imageName : String){
        
        self.image = UIImage.init(named: imageName)
        
    }
    
    private struct AssociatedKeys {
        static var topNameKey = "topNameKey"
        static var leftNameKey = "leftNameKey"
        static var bottomNameKey = "bottomNameKey"
        static var rightNameKey = "rightNameKey"
    }
    
    /**
Expand button click range
     
-Parameter top: How much does the top expand
-Parameter left: How much does the left side expand
-Parameter bottom: How much does the bottom expand
-Parameter right: How much does the right side expand
     */
    public func setEnlargeEdgeWithTop(_ top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        
        objc_setAssociatedObject(self, &AssociatedKeys.topNameKey, NSNumber.init(value: Float(top)), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        
        objc_setAssociatedObject(self, &AssociatedKeys.leftNameKey, NSNumber.init(value: Float(left)), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        
        objc_setAssociatedObject(self, &AssociatedKeys.bottomNameKey, NSNumber.init(value: Float(bottom)), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        
        objc_setAssociatedObject(self, &AssociatedKeys.rightNameKey, NSNumber.init(value: Float(right)), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        
    }
    
    /**
Set the click range to size
     
-Parameter size: The size of the adjusted click range
     */
    public func setTouchAreaToSize(_ size: CGSize) {
        var top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0
        if size.width > self.frame.size.width {
            left = (size.width - self.frame.size.width) / 2
            right = left
        }
        
        if (size.height > self.frame.size.height) {
            top = (size.height - self.frame.size.height) / 2
            bottom = top
        }
        setEnlargeEdgeWithTop(top, left: left, bottom: bottom, right: right)
    }
    
    public func enlargedRect() -> CGRect {
        
        let topEdge = objc_getAssociatedObject(self, &AssociatedKeys.topNameKey) as? NSNumber
        let rightEdge = objc_getAssociatedObject(self, &AssociatedKeys.rightNameKey) as? NSNumber
        let bottomEdge = objc_getAssociatedObject(self, &AssociatedKeys.bottomNameKey) as? NSNumber
        let leftEdge = objc_getAssociatedObject(self, &AssociatedKeys.leftNameKey) as? NSNumber
        
        if topEdge != nil && rightEdge != nil && bottomEdge != nil && leftEdge != nil {
            return
                CGRect(x:self.bounds.origin.x - CGFloat.init(truncating: leftEdge!),
                       y:self.bounds.origin.y - CGFloat.init(truncating: topEdge!),
                       width:self.bounds.size.width + CGFloat.init(truncating:leftEdge!) + CGFloat.init(truncating:rightEdge!),
                       height:self.bounds.size.height + CGFloat.init(truncating:topEdge!) + CGFloat.init(truncating:bottomEdge!))
        } else {
            return self.bounds
        }
    }
    
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let rect = self.enlargedRect()
        if rect.equalTo(self.bounds) || self.isHidden {
            return super.hitTest(point, with: event)
        }
        if rect.contains(point) {
            return self
        } else {
            return nil
        }
    }
    
    //MARK: Crop imageView based on the shape of the image
    func cutOutTriangleImgV(_ originImageView : UIImageView , _ accordImage : UIImage , _ edgeInset : UIEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)){
        //Create a new layer
        let layer = CALayer()
        
        var img = accordImage
        img = img.resizableImage(withCapInsets: edgeInset)
        
        //Set the displayed content of the layer to stretched MaskImgae
        layer.contents = img.cgImage
        //        layer.contents = UIImage.init(mNamed: "talkmessage/talkmessage_message_whiteMessageBox")?.cgImage
        
        //Set the stretching range (note: here, the CGRect of contentsCenter is proportional (not absolute coordinates))
        layer.contentsCenter = self.CGRectCenterRectForResizableImage(img)
        
        //Set the layer size to be the same as chatImgView
        layer.frame = CGRect(x: 0, y: 0, width: originImageView.bounds.width, height: originImageView.bounds.height)
        
        //Set Scale
        layer.contentsScale = UIScreen.main.scale
        
        //Set Opacity
        layer.opacity = 1
        
        //Set Crop Range
        originImageView.layer.mask = layer
        
        //Set to crop out excess areas
        originImageView.layer.masksToBounds = true
        
    }
    
    func CGRectCenterRectForResizableImage(_ image: UIImage) -> CGRect{
        
        return CGRect(x: image.capInsets.left / image.size.width,y: image.capInsets.top / image.size.height,width: (image.size.width - image.capInsets.right - image.capInsets.left) / image.size.width,height: (image.size.height - image.capInsets.bottom - image.capInsets.top) / image.size.height)
    }
    
    func setImageWithUrl(path:String,text:String) {
        
        if let url = URL.init(string: path){
            self.yy_setImage(with: url, placeholder:nil)
        }else{
            if text.count > 0 {
                let nameImg = UIImage.getTextImage(drawText: String(text.prefix(1)), size: CGSize(width: 26, height: 26))
                self.image = nameImg
            }else {
                self.image =  UIImage.themeImageNamed(imageName: "headportrait")
            }
        }
    }

}

