//
//  UIButtonExtension.swift
//  SDJG
//
//  Copyright ©2020年 sunlands. All rights reserved.
//

import UIKit

extension UIButton  {

    
    /**
     设置 图片 显示状态
     
     - parameter images:    图片
     - parameter controlStates: 状态数组
     
     */
    public final func extSetImages(_ images : [UIImage] , controlStates : [UIControl.State] ){
        
        for i in 0..<images.count  {
            
            self.setImage(images[i] , for: controlStates[i])
            
        }
        
    }
    
    
    /**
     设置 图片 显示状态 事件响应者 响应方法名 默认单击事件
     
     - parameter images:    图片
     - parameter controlStates: 状态数组
     - parameter target:       事件响应者
     - parameter selectName:   响应方法名
     */
    public final func extSetImageNameSelector(_ images : [UIImage] , controlStates : [UIControl.State] , target : AnyObject  , selector : Selector  , tag : Int = 0 ){
        
        for i in 0..<images.count  {
            
            self.setImage(images[i], for: controlStates[i])
            
        }
        
        self.tag = tag
        
        self.addTarget(target, action: selector, for: UIControl.Event.touchUpInside)
        
    }
    
    /**
     设置图片以及文字样式按钮、文字大小、颜色、以及文字图片内边距
     
     - parameter title:           标题
     - parameter titleColor:      标题颜色
     - parameter imageName:       图片名
     - parameter fontSize:        标题大小 默认18 可不传
     - parameter imageEdgeInsets: 图片内边距 默认 0 0 0 0 可不传
     - parameter titleEdgeInsets: 标题内边距 默认 0 0 0 0 可不传
     - parameter tag:             tag值 默认0 可不传
     */
    public final func extSetTitle(_ title : String , titleColor : UIColor ,  imageName : String , fontSize : CGFloat = 18.0 , imageEdgeInsets : UIEdgeInsets = UIEdgeInsets.zero, titleEdgeInsets : UIEdgeInsets = UIEdgeInsets.zero , tag : Int = 0 ,target : AnyObject? = nil  , selector : Selector){
        
        self.setTitle(title, for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.setImage(UIImage.init(named: imageName), for: .normal)
        self.titleLabel!.font = UIFont.systemFont(ofSize: fontSize)
        self.imageEdgeInsets = imageEdgeInsets
        self.titleEdgeInsets = titleEdgeInsets
        self.tag = tag
        
        if target != nil{
            
            self.addTarget(target, action: selector, for: UIControl.Event.touchUpInside)
            
        }
        
    }
    
    public final func extSetAddTarget(_ target : Any ,_ selector : Selector , _ event : UIControl.Event = .touchUpInside){
        self.addTarget(target, action: selector, for: event)
    }
    
    public final func extSetTitle(_ title : String , _ titleFont : CGFloat , _ titleColor : UIColor , _ state : UIControl.State){
        self.setTitle(title, for: state)
        self.titleLabel?.font = UIFont.systemFont(ofSize: titleFont)
        self.setTitleColor(titleColor, for: state)
    }
    
    /**
     设置图片以及文字样式按钮、文字大小、颜色、以及文字图片内边距
     
     - parameter title:           标题
     - parameter titleColor:      标题颜色
     - parameter imageName:       图片名
     - parameter fontSize:        标题大小 默认18 可不传
     - parameter imageEdgeInsets: 图片内边距 默认 0 0 0 0 可不传
     - parameter titleEdgeInsets: 标题内边距 默认 0 0 0 0 可不传
     - parameter tag:             tag值 默认0 可不传
     */
    public final func extSetTitle(_ title : String , titleColor : UIColor , fontSize : CGFloat = 18.0){
        
        self.setTitle(title, for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.titleLabel!.font = UIFont.systemFont(ofSize: fontSize)
    }
    
    /**
     设置图片以及文字样式按钮、文字大小、颜色、以及文字图片内边距
     
     - parameter title:           标题
     - parameter titleColor:      标题颜色
     - parameter image:       图片
     - parameter fontSize:        标题大小 默认18 可不传
     - parameter imageEdgeInsets: 图片内边距 默认 0 0 0 0 可不传
     - parameter titleEdgeInsets: 标题内边距 默认 0 0 0 0 可不传
     - parameter tag:             tag值 默认0 可不传
     */
    public final func extSetTitle(_ title : String , titleColor : UIColor ,  image : UIImage , fontSize : CGFloat = 18.0 , imageEdgeInsets : UIEdgeInsets = UIEdgeInsets.zero, titleEdgeInsets : UIEdgeInsets = UIEdgeInsets.zero , tag : Int = 0 ,target : AnyObject? = nil  , selector : Selector){
        
        self.setTitle(title, for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.setImage(image, for: .normal)
        self.titleLabel!.font = UIFont.systemFont(ofSize: fontSize)
        self.imageEdgeInsets = imageEdgeInsets
        self.titleEdgeInsets = titleEdgeInsets
        self.tag = tag
        
        if target != nil{
            
            self.addTarget(target, action: selector, for: UIControl.Event.touchUpInside)
            
        }
        
    }
    
    /**
     设置图片以及文字样式按钮、文字大小、颜色、以及文字图片内边距
     
     - parameter title:           标题
     - parameter titleColor:      标题颜色
     - parameter imageName:       图片名
     - parameter selectImageName  选中图片名
     - parameter fontSize:        标题大小 默认18 可不传
     - parameter imageEdgeInsets: 图片内边距 默认 0 0 0 0 可不传
     - parameter titleEdgeInsets: 标题内边距 默认 0 0 0 0 可不传
     - parameter tag:             tag值 默认0 可不传
     */
    public final func extSetTitle(_ title : String , titleColor : UIColor ,  imageName : String , selectImageName : String , fontSize : CGFloat = 18.0 , imageEdgeInsets : UIEdgeInsets = UIEdgeInsets.zero, titleEdgeInsets : UIEdgeInsets = UIEdgeInsets.zero , tag : Int = 0 ,target : AnyObject? = nil  , selector : Selector){
        
        self.setTitle(title, for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.setImage(UIImage.init(named: imageName), for: .normal)
        self.setImage(UIImage.init(named: selectImageName), for:.selected)
        self.titleLabel!.font = UIFont.systemFont(ofSize: fontSize)
        self.imageEdgeInsets = imageEdgeInsets
        self.titleEdgeInsets = titleEdgeInsets
        self.tag = tag
        
        if target != nil{
            
            self.addTarget(target, action: selector, for: UIControl.Event.touchUpInside)
            
        }
        
    }
    
    public final func extSetTitle(_ title : String , font : UIFont = .systemFont(ofSize: 14),
                                  titleEdgeInsets : UIEdgeInsets = UIEdgeInsets.zero,
                                  titleColor : UIColor ,  selectedTitleColor : UIColor ,
                                  backgroundColor : UIColor , selectedBackgroundColor : UIColor ,
                                  tag : Int = 0 ,target : AnyObject? = nil  , selector : Selector){
        self.titleEdgeInsets = titleEdgeInsets
        self.titleLabel!.font = font
       
        self.setTitle(title, for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.setTitleColor(selectedTitleColor, for: .selected)
        self.setBackgroundImage(self.imageWithColor(backgroundColor), for: .normal)
        self.setBackgroundImage(self.imageWithColor(backgroundColor), for: .selected)
        
        self.tag = tag
        if target != nil{
            self.addTarget(target, action: selector, for: UIControl.Event.touchUpInside)
        }
        
    }
    
    
    /**
     设置图片以及文字样式按钮、文字大小、颜色、以及文字图片内边距
     
     - parameter title:           标题
     - parameter titleColor:      标题颜色
     - parameter image:           图片
     - parameter selectImage      选中图片
     - parameter fontSize:        标题大小 默认18 可不传
     - parameter imageEdgeInsets: 图片内边距 默认 0 0 0 0 可不传
     - parameter titleEdgeInsets: 标题内边距 默认 0 0 0 0 可不传
     - parameter tag:             tag值 默认0 可不传
     */
    public final func extSetTitle(_ title : String , titleColor : UIColor ,  image : UIImage , selectImage : UIImage , fontSize : CGFloat = 18.0 , imageEdgeInsets : UIEdgeInsets = UIEdgeInsets.zero, titleEdgeInsets : UIEdgeInsets = UIEdgeInsets.zero , tag : Int = 0 ,target : AnyObject? = nil  , selector : Selector){
        
        self.setTitle(title, for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.setImage(image, for: .normal)
        self.setImage(selectImage, for:.selected)
        self.titleLabel!.font = UIFont.systemFont(ofSize: fontSize)
        self.imageEdgeInsets = imageEdgeInsets
        self.titleEdgeInsets = titleEdgeInsets
        self.tag = tag
        
        if target != nil{
            
            self.addTarget(target, action: selector, for: UIControl.Event.touchUpInside)
            
        }
        
    }
    
    /**
     按钮的状态改变
     */
    public final func extChangeBtnSelect(){
        
        self.isSelected = self.isSelected == true ? false : true
        
    }
    
    /**
     根据给的颜色更改btn的backgroundColor
     */
    public final func extsetBackgroundColor(backgroundColor : UIColor,state : UIControl.State){
        
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
     扩大按钮点击范围
     
     - parameter top:    顶部扩大多少
     - parameter left:   左边扩大多少
     - parameter bottom: 底部扩大多少
     - parameter right:  右边扩大多少
     */
    public final func setEnlargeEdgeWithTop(_ top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        
        objc_setAssociatedObject(self, &AssociatedKeys.topNameKey, NSNumber.init(value: Float(top)), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        
        objc_setAssociatedObject(self, &AssociatedKeys.leftNameKey, NSNumber.init(value: Float(left)), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        
        objc_setAssociatedObject(self, &AssociatedKeys.bottomNameKey, NSNumber.init(value: Float(bottom)), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        
        objc_setAssociatedObject(self, &AssociatedKeys.rightNameKey, NSNumber.init(value: Float(right)), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        
    }
    //
    public func enlargeInteractionEdge(with inset:CGFloat) {
        enlargeInteractionEdge(with:UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset))
    }
    //
    public func enlargeInteractionEdge(with inset:UIEdgeInsets) {
        setEnlargeEdgeWithTop(inset.top, left: inset.left, bottom: inset.bottom, right: inset.right)
    }
    /**
     把点击范围设置成size大小
     
     - parameter size: 调整后的点击范围的大小
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
    
    //倒计时，btn的type需要为custom
    public func countdown(_ num : Int ,unit : String = "s" ,defaultValue : String = "" , complete : (() -> ())? = nil){
        if num >= 0{
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.setTitle("\(num)" + unit, for: .normal)
                self.countdown(num - 1,defaultValue:defaultValue,complete : complete)
            }
            self.isEnabled = false
        }else{
            self.setTitle(defaultValue, for: .normal)
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
    
    //设置左文字右图片
    public func setLeftTextAndRightImg(){
        //        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -btn.imageView.size.width, 0, btn.imageView.size.width)];
        //        [btn setImageEdgeInsets:UIEdgeInsetsMake(0, btn.titleLabel.bounds.size.width, 0, -btn.titleLabel.bounds.size.width)];
        self.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: -(self.imageView?.image?.size.width)!, bottom: 0, right: (self.imageView?.image?.size.width)!)
        self.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: (self.titleLabel?.bounds.size.width)! + 3, bottom: 0, right: -(self.titleLabel?.bounds.size.width)!)
    }
    
}

extension UIButton {
    
    public func centerVertically(spacing: CGFloat, imageTop: Bool = true) {
        guard let imageSize = self.imageView?.image?.size,
              let text = self.titleLabel?.text,
              let font = self.titleLabel?.font
        else {
            return
        }
        let labelString = NSString(string: text)
        let titleSize = labelString.size(withAttributes: [NSAttributedString.Key.font: font])
        
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

public extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        self.clipsToBounds = true  // add this to maintain corner radius
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.setBackgroundImage(colorImage, for: forState)
        }
    }
    
    func newTitleResizeSize(topAndBottom: CGFloat = 4,leftRight: CGFloat = 8,btnImageSpace: CGFloat = 5,hasImage: Bool = false, maxWidth: CGFloat =  Device_W * 0.5){
        let title = self.titleLabel?.text ?? " "
        let font = self.titleLabel?.font ?? UIFont.ThemeFont.BodyRegular
        var size = title.textSizeWithFont(font, width: Device_W)
        if hasImage {
            size.width += self.imageView?.width ?? 0
            size.width += btnImageSpace
        }
        
        var w = size.width
        if w > maxWidth {
            w = maxWidth
        }
        let newsize = CGSize(width: w + leftRight * 2, height: size.height + topAndBottom * 2)
        self.snp.updateConstraints { make in
            make.width.equalTo(w)
            make.height.equalTo(newsize.height)
        }
    }
}

open class RepeatButton: UIButton {
    private var lastClickTime: TimeInterval = 0
    public var interval: TimeInterval = 1
    
    open override func sendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
        let now = Date().timeIntervalSince1970
        if now - lastClickTime > interval {
            lastClickTime = now
            super.sendAction(action, to: target, for: event)
        }
    }
}



public extension UIButton {
    //只有标题重新适应
    func titleResizeSize(topAndBottom: CGFloat = 4,leftRight: CGFloat = 8,btnImageSpace: CGFloat = 5,hasImage: Bool = false) -> CGSize{
        let title = self.titleLabel?.text ?? " "
        let font = self.titleLabel?.font ?? UIFont.ThemeFont.BodyRegular
        var size = title.ext_textSizeWithFont(font, width: Device_W)
        if hasImage {
            size.width += self.imageView?.width ?? 0
            size.width += btnImageSpace
        }
        return CGSize(width: size.width + leftRight * 2, height: size.height + topAndBottom * 2)
//        return size
    }
    //设置左文字右图片
    func exs_setLeftTextAndRightImg(btnImageSpace: CGFloat = 4){
//        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -btn.imageView.size.width, 0, btn.imageView.size.width)];
//        [btn setImageEdgeInsets:UIEdgeInsetsMake(0, btn.titleLabel.bounds.size.width, 0, -btn.titleLabel.bounds.size.width)];
        self.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: -(self.imageView?.image?.size.width)!, bottom: 0, right: (self.imageView?.image?.size.width)!)
        self.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: (self.titleLabel?.bounds.size.width)! + btnImageSpace, bottom: 0, right: -(self.titleLabel?.bounds.size.width)!)
    }
    public final func ext_SetAddTarget(_ target : Any ,_ selector : Selector , _ event : UIControl.Event = UIControl.Event.touchUpInside){
        self.addTarget(target, action: selector, for: event)
    }
    /**
     扩大按钮点击范围

     - parameter top:    顶部扩大多少
     - parameter left:   左边扩大多少
     - parameter bottom: 底部扩大多少
     - parameter right:  右边扩大多少
     */
    public final func exs_setEnlargeEdgeWithTop(_ top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
       setEnlargeEdgeWithTop(top, left: left, bottom: bottom, right: right)

    }

    /**
     设置 标题 标题颜色 状态 事件响应者 响应方法名 默认单击事件 title字体大小 默认18可不传 背景色 默认白色 可不传 tag值 默认0 可不传

     - parameter titles:        标题数组
     - parameter titleColors:   标题颜色数组
     - parameter controlStates: 状态数组
     - parameter target:       事件响应者
     - parameter selectName:   响应方法名
     - parameter fontSize:   title字体大小 默认18可不传
     - parameter backgroundColor:   背景色 默认白色 可不传
     - parameter tag:   tag值 默认0 可不传
     */
    public final func ext_SetTitles(_ titles : [String] , titleColors : [UIColor] , controlStates : [UIControl.State] , target : AnyObject  , selector : Selector , fontSize : CGFloat = 18.0 , backgroundColor : UIColor = UIColor.ThemeLabel.colorLite , tag : Int = 0  ){

        self.backgroundColor = backgroundColor
        self.tag = tag
        for i in 0..<titles.count  {
            self.setTitle(titles[i], for: controlStates[i])
            self.setTitleColor(titleColors[i], for: controlStates[i])
        }

        self.titleLabel!.font = UIFont.systemFont(ofSize: fontSize)

        self.addTarget(target, action: selector, for: UIControl.Event.touchUpInside)

    }
    /**
     根据给的颜色更改btn的backgroundColor
    */
    public final func ext_setBackgroundColor(backgroundColor : UIColor,state : UIControl.State){
        self.setBackgroundColor(color: backgroundColor, forState: state)
    }

    /**
     设置 图片 显示状态

     - parameter images:    图片
     - parameter controlStates: 状态数组

     */
    public final func ext_SetImages(_ images : [UIImage] , controlStates : [UIControl.State] ){

        for i in 0..<images.count  {

            self.setImage(images[i] , for: controlStates[i])

        }

    }
    public final func ext_SetTitle(_ title : String , _ titleFont : CGFloat , _ titleColor : UIColor , _ state : UIControl.State){
        self.setTitle(title, for: state)
        self.titleLabel?.font = UIFont.systemFont(ofSize: titleFont)
        self.setTitleColor(titleColor, for: state)
    }
}
/*
枚举 设置 图片的位置
*/
public enum ButtonImagePosition : Int{

    case PositionTop = 0
    case Positionleft
    case PositionBottom
    case PositionRight
}

public extension UIButton {
/**
imageName:图片的名字
title：button 的名字
type ：image 的位置
Space ：图片文字之间的间距
*/
    func setImageAndTitle(type:ButtonImagePosition,Space space:CGFloat)  {

//        self.setTitle(title, for: .normal)
//        self.setImage(UIImage(named:imageName), for: .normal)

        let imageWith :CGFloat = (self.imageView?.frame.size.width)!;
        let imageHeight :CGFloat = (self.imageView?.frame.size.height)!;

        var labelWidth :CGFloat = 0.0;
        var labelHeight :CGFloat = 0.0;

        labelWidth = CGFloat(self.titleLabel!.intrinsicContentSize.width);
        labelHeight = CGFloat(self.titleLabel!.intrinsicContentSize.height);

        var  imageEdgeInsets :UIEdgeInsets = UIEdgeInsets();
        var  labelEdgeInsets :UIEdgeInsets = UIEdgeInsets();

        switch type {
        case .PositionTop:
            imageEdgeInsets = UIEdgeInsets(top: -labelHeight - space/2.0, left: 0, bottom: 0, right: -labelWidth);
            labelEdgeInsets = UIEdgeInsets(top: 0, left: -imageWith, bottom: -imageHeight-space/2.0, right: 0);
            break;
        case .Positionleft:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -space/2.0, bottom: 0, right: space/2.0);
            labelEdgeInsets = UIEdgeInsets(top: 0, left: space/2.0, bottom: 0, right: -space/2.0);
            break;
        case .PositionBottom:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: -labelHeight-space/2.0, right: -labelWidth);
            labelEdgeInsets = UIEdgeInsets(top: -imageHeight-space/2.0, left: -imageWith, bottom: 0, right: 0);
            break;
        case .PositionRight:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: labelWidth+space/2.0, bottom: 0, right: -labelWidth-space/2.0);
            labelEdgeInsets = UIEdgeInsets(top: 0, left: -imageWith-space/2.0, bottom: 0, right: imageWith+space/2.0);
            break;
        }

        // 4. 赋值
        self.titleEdgeInsets = labelEdgeInsets;
        self.imageEdgeInsets = imageEdgeInsets;
    }
}


import RxCocoa

extension UIButton {
    public convenience init(buttonType: UIButton.ButtonType = .custom, backgroundColor:UIColor? = nil, title: String? = nil, titleFont: UIFont?, titleColor: UIColor?, action:((Void)->Void)? = nil) {
        self.init(type: buttonType)
        if let backgroundColor = backgroundColor {
            self.backgroundColor = backgroundColor
        }
        if title != nil {
            self.setTitle(title, for: .normal)
        }
        if titleFont != nil {
            self.titleLabel?.font = titleFont
        }
        if titleColor != nil {
            self.setTitleColor(titleColor, for: .normal)
        }
        if let action = action {
            rx.tap.subscribe(onNext: action).disposed(by: disposeBag)
        }
    }
    
    public convenience init(buttonType: UIButton.ButtonType = .custom, backgroundColor:UIColor? = nil, image: UIImage?, hightlightedImage: UIImage? = nil, imageContentMode: UIView.ContentMode = .scaleAspectFit, action:((Void)->Void)? = nil) {
        self.init(type: buttonType)
        if let backgroundColor = backgroundColor {
            self.backgroundColor = backgroundColor
        }
        if image != nil {
            self.setImage(image, for: .normal)
        }
        if hightlightedImage != nil {
            self.setImage(hightlightedImage, for: .highlighted)
        }
        self.imageView?.contentMode = imageContentMode
        if let action = action {
            rx.tap.subscribe(onNext: action).disposed(by: disposeBag)
        }
    }
}
