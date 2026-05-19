////
////  EXSUIButtonExt.swift
////  CoNetworkTest
////
////  Created by ZYJ on 2023/1/13.
////
//
//import UIKit
//import EXKit
//extension UIButton {
//    
//    private struct AssociatedKeys {
//        static var topNameKey = "topNameKey"
//        static var leftNameKey = "leftNameKey"
//        static var bottomNameKey = "bottomNameKey"
//        static var rightNameKey = "rightNameKey"
//    }
//    //只有标题重新适应 English: Only the title can be adapted again
//    func titleResizeSize(topAndBottom: CGFloat = 4,leftRight: CGFloat = 8,btnImageSpace: CGFloat = 5,hasImage: Bool = false) -> CGSize{
//        let title = self.titleLabel?.text ?? " "
//        let font = self.titleLabel?.font ?? UIFont.ThemeFont.BodyRegular
//        var size = title.ext_textSizeWithFont(font, width: Device_W)
//        if hasImage {
//            size.width += self.imageView?.width ?? 0
//            size.width += btnImageSpace
//        }
//        return CGSize(width: size.width + leftRight * 2, height: size.height + topAndBottom * 2)
////        return size
//    }
//    //设置左文字右图片 English: Set left text and right image
//    func exs_setLeftTextAndRightImg(){
////        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -btn.imageView.size.width, 0, btn.imageView.size.width)];
////        [btn setImageEdgeInsets:UIEdgeInsetsMake(0, btn.titleLabel.bounds.size.width, 0, -btn.titleLabel.bounds.size.width)];
//        self.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: -(self.imageView?.image?.size.width)!, bottom: 0, right: (self.imageView?.image?.size.width)!)
//        self.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: (self.titleLabel?.bounds.size.width)! + 3, bottom: 0, right: -(self.titleLabel?.bounds.size.width)!)
//    }
//    //设置左文字右图片 English: Set left text and right image
//    func exs_setLeftTextAndRightImg(btnImageSpace: CGFloat = 4){
////        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -btn.imageView.size.width, 0, btn.imageView.size.width)];
////        [btn setImageEdgeInsets:UIEdgeInsetsMake(0, btn.titleLabel.bounds.size.width, 0, -btn.titleLabel.bounds.size.width)];
//        self.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: -(self.imageView?.image?.size.width)!, bottom: 0, right: (self.imageView?.image?.size.width)!)
//        self.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: (self.titleLabel?.bounds.size.width)! + btnImageSpace, bottom: 0, right: -(self.titleLabel?.bounds.size.width)!)
//    }
//    public final func ext_SetAddTarget(_ target : Any ,_ selector : Selector , _ event : UIControl.Event = UIControl.Event.touchUpInside){
//        self.addTarget(target, action: selector, for: event)
//    }
//    /**
//     扩大按钮点击范围 English: Expand button click range
//     
//     - parameter top:    顶部扩大多少 English: -Parameter top: How much does the top expand
//     - parameter left:   左边扩大多少 English: -Parameter left: How much does the left side expand
//     - parameter bottom: 底部扩大多少 English: -Parameter bottom: How much does the bottom expand
//     - parameter right:  右边扩大多少 English: -Parameter right: How much does the right side expand
//     */
//    public final func exs_setEnlargeEdgeWithTop(_ top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
//        
//        objc_setAssociatedObject(self, &AssociatedKeys.topNameKey, NSNumber.init(value: Float(top)), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
//        
//        objc_setAssociatedObject(self, &AssociatedKeys.leftNameKey, NSNumber.init(value: Float(left)), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
//        
//        objc_setAssociatedObject(self, &AssociatedKeys.bottomNameKey, NSNumber.init(value: Float(bottom)), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
//        
//        objc_setAssociatedObject(self, &AssociatedKeys.rightNameKey, NSNumber.init(value: Float(right)), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
//        
//    }
//    
//    /**
//     设置 标题 标题颜色 状态 事件响应者 响应方法名 默认单击事件 title字体大小 默认18可不传 背景色 默认白色 可不传 tag值 默认0 可不传 English: Set the title color, status, event responder, response method name, default click event title font size, default 18, can be left blank for background color, default white, can be left blank for tag value, default 0, can be left blank for tag value
//     
//     - parameter titles:        标题数组 English: -Parameter titles: array of titles
//     - parameter titleColors:   标题颜色数组 English: -Parameter titleColors: Array of title colors
//     - parameter controlStates: 状态数组 English: -Parameter controllStates: State array
//     - parameter target:       事件响应者 English: -Parameter target: Event responder
//     - parameter selectName:   响应方法名 English: -Parameter selectName: Response method name
//     - parameter fontSize:   title字体大小 默认18可不传 English: -Parameter fontSize: title The default font size is 18, which can be omitted
//     - parameter backgroundColor:   背景色 默认白色 可不传 English: -Parameter backgroundColor: The default background color is white and cannot be transmitted
//     - parameter tag:   tag值 默认0 可不传 English: -Parameter tag: The tag value defaults to 0 and cannot be passed
//     */
//    public final func ext_SetTitles(_ titles : [String] , titleColors : [UIColor] , controlStates : [UIControl.State] , target : AnyObject  , selector : Selector , fontSize : CGFloat = 18.0 , backgroundColor : UIColor = UIColor.ThemeLabel.colorLite , tag : Int = 0  ){
//        
//        self.backgroundColor = backgroundColor
//        self.tag = tag
//        for i in 0..<titles.count  {
//
//        
//            self.setTitle(titles[i], for: controlStates[i])
//            self.setTitleColor(titleColors[i], for: controlStates[i])
//            
//    
//        }
//        
//        self.titleLabel!.font = UIFont.systemFont(ofSize: fontSize)
//        
//        self.addTarget(target, action: selector, for: UIControl.Event.touchUpInside)
//    
//    }
//    /**
//     根据给的颜色更改btn的backgroundColor English: Change the backgroundColor of btn based on the given color
//    */
//    public final func ext_setBackgroundColor(backgroundColor : UIColor,state : UIControl.State){
//    
////        self.setBackgroundImage(nil, forState: state)
//        
//        self.setBackgroundImage(self.exs_imageWithColor(backgroundColor), for: state)
//    
//    }
//    
//     private func exs_imageWithColor(_ color : UIColor) -> UIImage {
//        
//        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
//        UIGraphicsBeginImageContext(rect.size)
//        let context = UIGraphicsGetCurrentContext()
//        context!.setFillColor(color.cgColor)
//        context!.fill(rect)
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        
//        UIGraphicsEndImageContext()
//        
//        return image!
//        
//    }
//    
//    /**
//     设置 图片 显示状态 English: Set image display status
//     
//     - parameter images:    图片 English: -Parameter images: images
//     - parameter controlStates: 状态数组 English: -Parameter controllStates: State array
//    
//     */
//    public final func ext_SetImages(_ images : [UIImage] , controlStates : [UIControl.State] ){
//        
//        for i in 0..<images.count  {
//            
//            self.setImage(images[i] , for: controlStates[i])
//            
//        }
//    
//    }
//    public final func ext_SetTitle(_ title : String , _ titleFont : CGFloat , _ titleColor : UIColor , _ state : UIControl.State){
//        self.setTitle(title, for: state)
//        self.titleLabel?.font = UIFont.systemFont(ofSize: titleFont)
//        self.setTitleColor(titleColor, for: state)
//    }
//}

