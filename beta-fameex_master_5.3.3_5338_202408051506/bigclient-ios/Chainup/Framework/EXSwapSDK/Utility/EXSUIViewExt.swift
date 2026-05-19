//
//  EXSUIViewExt.swift
//  CoNetworkTest
//
//  Created by ZYJ on 2021/1/13.
//

import UIKit
import EXKit
import SwiftUI
import Moya

extension UIView {
    ///Vibration feedback after iOS10
     func feedbackGenerator() {
         let gen = UIImpactFeedbackGenerator.init(style: .light);//The strength of the light vibration effect
         gen.prepare();//Minimize feedback delay
         gen.impactOccurred()//Trigger effect
     }
    //Dealing with the issue of keyboard bounce failure added to keyWindow
    func showInWindow(){
        let bg = UIView()
        bg.backgroundColor = UIColor.ThemeView.mask
        bg.addSubview(self)
        bg.frame = UIApplication.shared.keyWindow!.bounds
        bg.tag = 6666
        UIApplication.shared.keyWindow?.rootViewController?.view.addSubview(bg)
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(removeFromWindow))
//        bg.addGestureRecognizer(tap)
//        bg.isUserInteractionEnabled = true
    }
    
    func getWindowMask() -> UIView?{
        if let sviews = UIApplication.shared.keyWindow?.rootViewController?.view.subviews {
            for v in sviews{
                if v.tag == 6666 {
                 return v
                }
            }
        }
        return nil
    }
    @objc func removeFromWindow(){
        if let sviews = UIApplication.shared.keyWindow?.rootViewController?.view.subviews {
            for v in sviews{
                if v.tag == 6666 {
                    v.removeFromSuperview()
                    break
                }
            }
        }
    }
    
    
    
    
//        EXWindowNormal.shared.show(view: sheet)
    //MARK: Add a view to self.view and pass an array
    public func exs_addSubViews(_ views : [UIView]){
        for view in views{
            self.addSubview(view)
        }
    }
    
    public func drawDashLine(color: UIColor = UIColor.ThemeLabel.colorMedium){
        self.drawDashLine(lineLength: 4, lineSpacing: 2, lineColor:color)
    }
    //LineLength: Dash length lineSpacing: Spacing between dashes
    public func drawDashLine(lineLength: Int ,lineSpacing : Int,lineColor : UIColor){
        let shapeLayer = CAShapeLayer()
        shapeLayer.bounds = self.bounds
        shapeLayer.anchorPoint = CGPoint(x: 0, y: 0)
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.lineWidth = 1 //The line width used when tracing the path. The default is 1.
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = [NSNumber(value: lineLength),NSNumber(value: lineSpacing)]
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
        var w = Int(self.bounds.size.width)
        if w%lineLength != 0 {
            w += lineLength
        }
        path.addLine(to: CGPoint(x: w, y: 0))
        shapeLayer.path = path
        self.layer.addSublayer(shapeLayer)
    }
    /**
Enable automatic layout
     */
    public final func ext_UseAutoLayout(){
//        self.extSetBorderWidth(1, color: UIColor.green)
        self.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    func exs_roundCorners(corners: UIRectCorner, radius: CGFloat) {
        UIColor.clear.setFill()
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        path.fill()
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
extension UIImage{
    func newAsImage() -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        print("rect = \(rect)")
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 10)
        if let img = TMOCutImageManager.sharedInstance.clipWithPath(path: path, image: self){
            return img
        }
        return UIImage()

    }
}
extension UIView {
    //Convert the current view to UIImage
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        let mask = layer.mask
        layer.mask = nil
        let image = renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
        layer.mask = mask
        return image
    }
    
    
    func findController() -> UIViewController! {
        return self.findControllerWithClass(UIViewController.self)
    }
    
    func findNavigator() -> UINavigationController! {
        return self.findControllerWithClass(UINavigationController.self)
    }
    
    func findControllerWithClass<T>(_ clzz: AnyClass) -> T? {
        var responder = self.next
        while(responder != nil) {
            if (responder!.isKind(of: clzz)) {
                return responder as? T
            }
            responder = responder?.next
        }
        return nil
    }
}
class TMOCutImageManager: NSObject {
   
   static let sharedInstance = TMOCutImageManager()
   
    
   ///Based on the coordinate points, produce the Bess curve
   ///- Parameter array: All CGPoint point arrays
   ///- Returns: returns the path
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
   
   ///Cut the image according to the path
   /// - Parameters:
   ///- path: Bayesian curve
   ///- image: Original image
   ///- rect: The size of the drawn interval
   ///- Returns: Returns the cropped image
   func clipWithPath(path:UIBezierPath,image:UIImage)->UIImage?{
       
       let newImage = image
       
       //Start drawing pictures
       UIGraphicsBeginImageContextWithOptions(image.size, false, UIScreen.main.scale)
       
       if let  contextRef:CGContext = UIGraphicsGetCurrentContext(),
          let cgImage = newImage.cgImage{
           
           let clipPath:UIBezierPath = path
           
           contextRef.addPath(clipPath.cgPath)
           contextRef.closePath()
           contextRef.clip()
           
           //Coordinate System Conversion
           contextRef.translateBy(x: 0, y: newImage.size.height)
           contextRef.scaleBy(x: 1, y: -1)
           
           let drawRect = CGRect(x: 0, y: 0, width: newImage.size.width, height: newImage.size.height)
           contextRef.draw(cgImage, in: drawRect)
           
           let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
           UIGraphicsEndImageContext()//End painting
           
           return croppedImage
       }
       return nil
   }
   
   
   
   ///Cropping through CGImage or CIImage
   /// - Parameters:
   ///- image: original image
   ///- rect: Crop region
   ///- Returns: Returns the cropped image
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
   
   
   ///Cropping through Bitmap
   /// - Parameters:
   ///- image: original image
   ///- rect: Crop region
   ///- Returns: Returns the cropped image
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

extension UIButton {
    @IBInspectable var ex_htitleC: String? {
        set {
            guard let newValue = newValue else { return }
            setTitleColor(.themeColor(keyPath: newValue), for: .highlighted)
        }
        get {
            return ""
        }
    }
    @IBInspectable var ex_titleC: String? {
        set {
            guard let newValue = newValue else { return }
            setTitleColor(.themeColor(keyPath: newValue), for: .normal)
        }
        get {
            return ""
        }
    }
}

extension UIView {
    //Set the view background color
    @IBInspectable var exs_themebg: String? {
        set {
            guard let newValue = newValue else { return }
            if newValue == kline_up_key {
                let isGreen = EXKLineManager.isGreen()
                if !isGreen {
                    backgroundColor = .themeColor(keyPath: kline_down_key)
                    return
                }
            }
            if newValue == kline_down_key {
                let isGreen = EXKLineManager.isGreen()
                if !isGreen {
                    backgroundColor = .themeColor(keyPath: kline_up_key)
                    return
                }
            }
            backgroundColor = UIColor.themeColor(keyPath: newValue)
        }
        get {
            return ""
        }
    }

    //Borderwidth can be set
    @IBInspectable var ex_borderW: CGFloat {
        get {
            return layer.borderWidth
        }
        
        set {
            layer.borderWidth = newValue
        }
    }
  
    //Set bordercolor
    @IBInspectable var ex_borderC: String? {
        set {
            guard let newValue = newValue else { return }
            layer.borderColor = UIColor.themeColor(keyPath: newValue).cgColor
        }
        get {
            return ""
        }
    }
}
extension UILabel {
    @IBInspectable var exs_themeTxtColor: String? {
    
        set {
            guard let newValue = newValue else { return }
            textColor = UIColor.themeColor(keyPath: newValue)
        }
        get {
            return ""
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
    
    func exs_CenterPlaceHolderAtt(_ str : String , color : UIColor = UIColor.ThemeLabel.colorDark , font : UIFont = UIFont.ThemeFont.BodyRegular){
        let parg = NSMutableParagraphStyle()
        parg.alignment = .center
        let placeHolderAtt = NSMutableAttributedString().exs_add(string: str, attrDic: [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor : color,NSAttributedString.Key.paragraphStyle: parg
        ]
        )
        self.attributedPlaceholder = placeHolderAtt
    }
    //Set rich text for placeHolder
    func exs_setPlaceHolderAtt(_ str : String , color : UIColor = UIColor.ThemeLabel.colorDark , font : CGFloat = 14){
//        let placeHolderAtt = NSMutableAttributedString().add(string: str, attrDic: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: font) , NSAttributedString.Key.foregroundColor : color])
//        self.attributedPlaceholder = placeHolderAtt
        exs_setPlaceHolderAtt(str, color: color, font: font, weight: .regular)
    }
    
    func exs_setPlaceHolderAtt(_ str : String , color : UIColor = UIColor.ThemeLabel.colorDark , font : CGFloat = 14, weight: UIFont.Weight){
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
    
    ///Add a clear button to UITextField
    func exs_setModifyClearButton() {
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(UIImage.exs_themeImageNamed(imageName: "delete"), for: .normal)
        clearButton.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        clearButton.contentMode = .scaleAspectFit
        clearButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 19, bottom: 0, right: 0)
        clearButton.addTarget(self, action: #selector(UITextField.exs_clear(sender:)), for: .touchUpInside)
        let container = UIView(frame: clearButton.frame)
        container.backgroundColor = .clear
        container.addSubview(clearButton)
        
        self.rightView = container
        self.rightViewMode = .whileEditing
    }
    
    ///Click the clear button to clear the content
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


