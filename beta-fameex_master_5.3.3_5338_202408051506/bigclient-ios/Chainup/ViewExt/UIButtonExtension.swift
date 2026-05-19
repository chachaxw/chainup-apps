//
//  UIButtonExtension.swift
//  SDJG
//
//  Created by 王俊 on 16/4/19.
//Modify by Wang Jun on 17/6/5 Swift3.0
//  Copyright © 2016年 sunlands. All rights reserved.
//

import UIKit

extension UIButton  {
    
    /**
Set the title color status, event responder response method name, default click event title font size, default 18, background color, default white, tag value, default 0, no background color
     
-Parameter titles: array of titles
-Parameter titleColors: Array of title colors
-Parameter controllStates: State array
-Parameter target: event responder
-Parameter selectName: Response method name
-Parameter fontSize: title The default font size is 18, which can be ignored
-Parameter backgroundColor: The default background color is white and cannot be transmitted
-Parameter tag: The tag value defaults to 0 and cannot be passed
     */
    public final func extSetTitles(_ titles : [String] , titleColors : [UIColor] , controlStates : [UIControlState] , target : AnyObject  , selector : Selector , fontSize : CGFloat = 18.0 , backgroundColor : UIColor = UIColor.ThemeLabel.colorLite , tag : Int = 0  ){
        
        self.backgroundColor = backgroundColor
        self.tag = tag
        for i in 0..<titles.count  {
            
            
            self.setTitle(titles[i], for: controlStates[i])
            self.setTitleColor(titleColors[i], for: controlStates[i])
            
            
        }
        
        self.titleLabel!.font = UIFont.systemFont(ofSize: fontSize)
        
        self.addTarget(target, action: selector, for: UIControlEvents.touchUpInside)
        
    }
    
    
    
    
    /**
Set image display status
     
-Parameter images: images
-Parameter controllStates: State array
     
     */
    public final func extSetImages(_ images : [UIImage] , controlStates : [UIControlState] ){
        
        for i in 0..<images.count  {
            
            self.setImage(images[i] , for: controlStates[i])
            
        }
        
    }
    
    
    /**
Set Image Display Status Event Responder Response Method Name Default Click Event
     
-Parameter images: images
-Parameter controllStates: State array
-Parameter target: event responder
-Parameter selectName: Response method name
     */
    public final func extSetImageNameSelector(_ images : [UIImage] , controlStates : [UIControlState] , target : AnyObject  , selector : Selector  , tag : Int = 0 ){
        
        for i in 0..<images.count  {
            
            self.setImage(images[i], for: controlStates[i])
            
        }
        
        self.tag = tag
        
        self.addTarget(target, action: selector, for: UIControlEvents.touchUpInside)
        
    }
    
    /**
Set image and text style buttons, text size, color, and text image margins
     
-Parameter title: Title
-Parameter titleColor: Title color
-Parameter imageName: Image name
-Parameter fontSize: The default size of the title is 18, but it cannot be transmitted
-Parameter imageEdgeInsets: The default inner margin of the image is 0 0 0 0, which can be ignored
-Parameter titleEdgeInsets: The default inner margin of the title is 0 0 0 0, which can be left blank
-Parameter tag: The tag value defaults to 0 and cannot be passed
     */
    public final func extSetTitle(_ title : String , titleColor : UIColor ,  imageName : String , fontSize : CGFloat = 18.0 , imageEdgeInsets : UIEdgeInsets = UIEdgeInsets.zero, titleEdgeInsets : UIEdgeInsets = UIEdgeInsets.zero , tag : Int = 0 ,target : AnyObject? = nil  , selector : Selector){
        
        self.setTitle(title, for: UIControlState.normal)
        self.setTitleColor(titleColor, for: UIControlState.normal)
        self.setImage(UIImage.init(named: imageName), for: UIControlState.normal)
        self.titleLabel!.font = UIFont.systemFont(ofSize: fontSize)
        self.imageEdgeInsets = imageEdgeInsets
        self.titleEdgeInsets = titleEdgeInsets
        self.tag = tag
        
        if target != nil{
            
            self.addTarget(target, action: selector, for: UIControlEvents.touchUpInside)
            
        }
        
    }
    
    public final func extSetAddTarget(_ target : Any ,_ selector : Selector , _ event : UIControlEvents = UIControlEvents.touchUpInside){
        self.addTarget(target, action: selector, for: event)
    }
    
    public final func extSetTitle(_ title : String , _ titleFont : CGFloat , _ titleColor : UIColor , _ state : UIControlState){
        self.setTitle(title, for: state)
        self.titleLabel?.font = UIFont.systemFont(ofSize: titleFont)
        self.setTitleColor(titleColor, for: state)
    }
    
    /**
Set image and text style buttons, text size, color, and text image margins
     
-Parameter title: Title
-Parameter titleColor: Title color
-Parameter imageName: Image name
-Parameter fontSize: The default size of the title is 18, but it cannot be transmitted
-Parameter imageEdgeInsets: The default inner margin of the image is 0 0 0 0, which can be ignored
-Parameter titleEdgeInsets: The default inner margin of the title is 0 0 0 0, which can be left blank
-Parameter tag: The tag value defaults to 0 and cannot be passed
     */
    public final func extSetTitle(_ title : String , titleColor : UIColor , fontSize : CGFloat = 18.0){
        
        self.setTitle(title, for: UIControlState.normal)
        self.setTitleColor(titleColor, for: UIControlState.normal)
        self.titleLabel!.font = UIFont.systemFont(ofSize: fontSize)
    }
    
    /**
Set image and text style buttons, text size, color, and text image margins
     
-Parameter title: Title
-Parameter titleColor: Title color
-Parameter image: image
-Parameter fontSize: The default size of the title is 18, but it cannot be transmitted
-Parameter imageEdgeInsets: The default inner margin of the image is 0 0 0 0, which can be ignored
-Parameter titleEdgeInsets: The default inner margin of the title is 0 0 0 0, which can be left blank
-Parameter tag: The tag value defaults to 0 and cannot be passed
     */
    public final func extSetTitle(_ title : String , titleColor : UIColor ,  image : UIImage , fontSize : CGFloat = 18.0 , imageEdgeInsets : UIEdgeInsets = UIEdgeInsets.zero, titleEdgeInsets : UIEdgeInsets = UIEdgeInsets.zero , tag : Int = 0 ,target : AnyObject? = nil  , selector : Selector){
        
        self.setTitle(title, for: UIControlState.normal)
        self.setTitleColor(titleColor, for: UIControlState.normal)
        self.setImage(image, for: UIControlState.normal)
        self.titleLabel!.font = UIFont.systemFont(ofSize: fontSize)
        self.imageEdgeInsets = imageEdgeInsets
        self.titleEdgeInsets = titleEdgeInsets
        self.tag = tag
        
        if target != nil{
            
            self.addTarget(target, action: selector, for: UIControlEvents.touchUpInside)
            
        }
        
    }
    
    /**
Set image and text style buttons, text size, color, and text image margins
     
-Parameter title: Title
-Parameter titleColor: Title color
-Parameter imageName: Image name
-Parameter selectImageName
-Parameter fontSize: The default size of the title is 18, but it cannot be transmitted
-Parameter imageEdgeInsets: The default inner margin of the image is 0 0 0 0, which can be ignored
-Parameter titleEdgeInsets: The default inner margin of the title is 0 0 0 0, which can be left blank
-Parameter tag: The tag value defaults to 0 and cannot be passed
     */
    public final func extSetTitle(_ title : String , titleColor : UIColor ,  imageName : String , selectImageName : String , fontSize : CGFloat = 18.0 , imageEdgeInsets : UIEdgeInsets = UIEdgeInsets.zero, titleEdgeInsets : UIEdgeInsets = UIEdgeInsets.zero , tag : Int = 0 ,target : AnyObject? = nil  , selector : Selector){
        
        self.setTitle(title, for: UIControlState.normal)
        self.setTitleColor(titleColor, for: UIControlState.normal)
        self.setImage(UIImage.init(named: imageName), for: UIControlState.normal)
        self.setImage(UIImage.init(named: selectImageName), for: UIControlState.selected)
        self.titleLabel!.font = UIFont.systemFont(ofSize: fontSize)
        self.imageEdgeInsets = imageEdgeInsets
        self.titleEdgeInsets = titleEdgeInsets
        self.tag = tag
        
        if target != nil{
            
            self.addTarget(target, action: selector, for: UIControlEvents.touchUpInside)
            
        }
        
    }
    
    
    /**
Set image and text style buttons, text size, color, and text image margins
     
-Parameter title: Title
-Parameter titleColor: Title color
-Parameter image: image
-Parameter selectImage
-Parameter fontSize: The default size of the title is 18, but it cannot be transmitted
-Parameter imageEdgeInsets: The default inner margin of the image is 0 0 0 0, which can be ignored
-Parameter titleEdgeInsets: The default inner margin of the title is 0 0 0 0, which can be left blank
-Parameter tag: The tag value defaults to 0 and cannot be passed
     */
    public final func extSetTitle(_ title : String , titleColor : UIColor ,  image : UIImage , selectImage : UIImage , fontSize : CGFloat = 18.0 , imageEdgeInsets : UIEdgeInsets = UIEdgeInsets.zero, titleEdgeInsets : UIEdgeInsets = UIEdgeInsets.zero , tag : Int = 0 ,target : AnyObject? = nil  , selector : Selector){
        
        self.setTitle(title, for: UIControlState.normal)
        self.setTitleColor(titleColor, for: UIControlState.normal)
        self.setImage(image, for: UIControlState.normal)
        self.setImage(selectImage, for: UIControlState.selected)
        self.titleLabel!.font = UIFont.systemFont(ofSize: fontSize)
        self.imageEdgeInsets = imageEdgeInsets
        self.titleEdgeInsets = titleEdgeInsets
        self.tag = tag
        
        if target != nil{
            
            self.addTarget(target, action: selector, for: UIControlEvents.touchUpInside)
            
        }
        
    }
    
    /**
The state of the button changes
     */
    public final func extChangeBtnSelect(){
        
        self.isSelected = self.isSelected == true ? false : true
        
    }
    
    /**
Change the backgroundColor of btn based on the given color
     */
    public final func extsetBackgroundColor(backgroundColor : UIColor,state : UIControlState){
        
        //        self.setBackgroundImage(nil, forState: state)
        
        self.setBackgroundImage(self.imageWithColor(backgroundColor), for: state)
        
    }
    
    public final func imageWithColor(_ color : UIColor) -> UIImage {
        
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image!
        
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
    public final func setEnlargeEdgeWithTop(_ top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        
        objc_setAssociatedObject(self, &AssociatedKeys.topNameKey, NSNumber.init(value: Float(top)), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        
        objc_setAssociatedObject(self, &AssociatedKeys.leftNameKey, NSNumber.init(value: Float(left)), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        
        objc_setAssociatedObject(self, &AssociatedKeys.bottomNameKey, NSNumber.init(value: Float(bottom)), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        
        objc_setAssociatedObject(self, &AssociatedKeys.rightNameKey, NSNumber.init(value: Float(right)), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        
    }
    
    /**
Set the click range to size
     
-Parameter size: The size of the adjusted click range
     */
    public final func setTouchAreaToSize(_ size: CGSize) {
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
    
    public final func enlargedRect() -> CGRect {
        
        let topEdge = objc_getAssociatedObject(self, &AssociatedKeys.topNameKey) as? NSNumber
        let rightEdge = objc_getAssociatedObject(self, &AssociatedKeys.rightNameKey) as? NSNumber
        let bottomEdge = objc_getAssociatedObject(self, &AssociatedKeys.bottomNameKey) as? NSNumber
        let leftEdge = objc_getAssociatedObject(self, &AssociatedKeys.leftNameKey) as? NSNumber
        
        if topEdge != nil && rightEdge != nil && bottomEdge != nil && leftEdge != nil {
            
            return CGRect(x :self.bounds.origin.x - CGFloat.init(truncating:leftEdge!),
                          y :self.bounds.origin.y - CGFloat.init(truncating:topEdge!),
                          width: self.bounds.size.width + CGFloat.init(truncating:leftEdge!) + CGFloat.init(truncating:rightEdge!),
                          height:self.bounds.size.height + CGFloat.init(truncating:topEdge!) + CGFloat.init(truncating:bottomEdge!))
        } else {
            return self.bounds
        }
    }
    
    //Countdown, btn's type needs to be custom
    public func countdown(_ num : Int ,unit : String = "s" ,defaultValue : String = "" , complete : (() -> ())? = nil){
        if num >= 0{
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.setTitle("\(num)" + unit, for: UIControlState.normal)
                self.countdown(num - 1,defaultValue:defaultValue,complete : complete)
            }
            self.isEnabled = false
        }else{
            self.setTitle(defaultValue, for: UIControlState.normal)
            self.isEnabled = true
            if complete != nil{
                complete!()
            }
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
    
    //Set left text and right image
    func setLeftTextAndRightImg(){
        //        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -btn.imageView.size.width, 0, btn.imageView.size.width)];
        //        [btn setImageEdgeInsets:UIEdgeInsetsMake(0, btn.titleLabel.bounds.size.width, 0, -btn.titleLabel.bounds.size.width)];
        self.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: -(self.imageView?.image?.size.width)!, bottom: 0, right: (self.imageView?.image?.size.width)!)
        self.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: (self.titleLabel?.bounds.size.width)! + 3, bottom: 0, right: -(self.titleLabel?.bounds.size.width)!)
    }
    
    
}

extension UIButton {
    
    func centerVertically(spacing: CGFloat, imageTop: Bool = true) {
        guard let imageSize = self.imageView?.image?.size,
              let text = self.titleLabel?.text,
              let font = self.titleLabel?.font
        else {
            return
        }
        let labelString = NSString(string: text)
        let titleSize = labelString.size(withAttributes: [NSAttributedStringKey.font: font])
        
        let imageVerticalOffset = (titleSize.height + spacing)/2
        let titleVerticalOffset = (imageSize.height + spacing)/2
        let imageHorizontalOffset = (titleSize.width)/2
        let titleHorizontalOffset = (imageSize.width)/2
        let sign: CGFloat = imageTop ? 1 : -1
        
        imageEdgeInsets = UIEdgeInsets(top: -imageVerticalOffset * sign,
                                       left: imageHorizontalOffset,
                                       bottom: imageVerticalOffset * sign,
                                       right: -imageHorizontalOffset)
        titleEdgeInsets = UIEdgeInsets(top: titleVerticalOffset * sign,
                                       left: -titleHorizontalOffset,
                                       bottom: -titleVerticalOffset * sign,
                                       right: titleHorizontalOffset)
        
        // increase content height to avoid clipping
        let edgeOffset = (min(imageSize.height, titleSize.height) + spacing)/2
        contentEdgeInsets = UIEdgeInsets(top: edgeOffset, left: 0, bottom: edgeOffset, right: 0)
    }
}

