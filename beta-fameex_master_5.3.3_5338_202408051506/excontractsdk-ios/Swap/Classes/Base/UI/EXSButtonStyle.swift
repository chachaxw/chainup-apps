////
////  EXSButtonStyle.swift
////  Chainup
////
////  Created by liuxuan on 2023/3/7.
////  Copyright © 2023 zewu wang. All rights reserved.
////
//
////TODO:暂时这样 English: TODO: For now
//
//import UIKit
//import EXKit
//enum EXSButtonStyles:Int {
//    // 只能在尾部增加 English: Can only be added at the tail end
//    case defultColor                        = 0     // 只有文字 灰色 English: Only text gray
//    case up                                 = 1
//    case down                               = 2
//    case blueColor                          = 3
//    case defultColorBlueLine                = 4     // 文字蓝 边线蓝,6.0改为灰色 English: Text blue border blue, changed from 6.0 to gray
//    case lightColor                         = 5     // 文字灰 背景浅 English: Text gray background light
//    case lightBlueColor                     = 6     // 文字蓝 背景浅 English: Text blue background light
//    case clearBlueColor                     = 7     // 文字默认灰选中蓝 背景透明 English: Text default gray selected, blue background transparent
//    case blueTextColor                     = 8     // 文字蓝 背景透明 English: Text with a transparent blue background
//    
//    var color:UIColor{
//        switch self{
//        case .up:  if EXKLineManager.isGreen(){return EXSButtonColor.greenColor}else {return EXSButtonColor.redColor}
//        case .down:if EXKLineManager.isGreen(){return EXSButtonColor.redColor  }else {return EXSButtonColor.greenColor}
//        case .blueColor:                            return EXSButtonColor.blueColor
//        case .defultColorBlueLine:                  return UIColor.ThemeView.card2
//        case .defultColor:                          return UIColor.ThemeView.bg
//        case .lightColor,.lightBlueColor:           return UIColor.ThemeBtn.normal
//        case .clearBlueColor,.blueTextColor:                       return UIColor.clear
//        }
//    }
//    
//    var highlightedColor:UIColor{
//        switch self{
//        case .up:  if EXKLineManager.isGreen() {return EXSButtonColor.highlightedGreenColor} else {return EXSButtonColor.highlightedRedColor}
//        case .down:if EXKLineManager.isGreen() {return EXSButtonColor.highlightedRedColor}   else {return EXSButtonColor.highlightedGreenColor}
//        case .blueColor:                            return EXSButtonColor.highlightedBlueColor
//            
//        case .defultColor:                          return UIColor.ThemeView.bg
//        case .defultColorBlueLine:
//            return UIColor.ThemeView.bgTab
//        case .lightColor:
//            return UIColor.ThemeBtn.touch
//        case .lightBlueColor:  return UIColor.ThemeBtn.highlight
//        case .clearBlueColor,.blueTextColor:                       return UIColor.clear
//        }
//    }
//    var selectedColor:UIColor{
//        return highlightedColor
//    }
//    
//    var titleColor:UIColor {
//        switch self{
//        case .up,.down,.blueColor:
//            return UIColor.white
//        case .defultColorBlueLine:
//            return UIColor.ThemeLabel.colorLite
//        case .lightBlueColor,.blueTextColor:  return EXSButtonColor.blueColor
//        default :                                   return UIColor.ThemeBtn.title
//        }
//    }
//    var titleSelectColor:UIColor {
//        switch self{
//        case .clearBlueColor:                       return UIColor.ThemeLabel.colorHighlight
//        default :                                   return titleColor
//        }
//    }
//    var disabledColor:UIColor{
//        switch self{
//        default : return UIColor.ThemeBtn.disable
//        }
//    }
//    var cornerRadius:CGFloat{
//        switch self{
//        default : return 4
//        }
//    }
//    var borderWidth:CGFloat{
//        switch self{
////        case .defultColorBlueLine:return 1
//        default : return 0
//        }
//    }
//    var borderColor:UIColor?{
//        switch self{
////        case .defultColorBlueLine:return EXSButtonColor.blueColor
//        default : return nil
//        }
//    }
//    
//    static func buttonImage(
//        color: UIColor,
//        shadowHeight: CGFloat,
//        shadowColor: UIColor,
//        cornerRadius: CGFloat) -> UIImage {
//        
//        return buttonImage(color: color, shadowHeight: shadowHeight, shadowColor: shadowColor, cornerRadius: cornerRadius, frontImageOffset: 0)
//    }
//    
//    static func highlightedButtonImage(
//        color: UIColor,
//        shadowHeight: CGFloat,
//        shadowColor: UIColor,
//        cornerRadius: CGFloat,
//        buttonPressDepth: Double) -> UIImage {
//        
//        return buttonImage(color: color, shadowHeight: shadowHeight, shadowColor: shadowColor, cornerRadius: cornerRadius, frontImageOffset: shadowHeight * CGFloat(buttonPressDepth))
//    }
//    
//    static func buttonImage(
//        color: UIColor,
//        shadowHeight: CGFloat,
//        shadowColor: UIColor,
//        cornerRadius: CGFloat,
//        frontImageOffset: CGFloat) -> UIImage {
//        
//        // Create foreground and background images
//        let width = max(1, cornerRadius * 2 + shadowHeight)
//        let height = max(1, cornerRadius * 2 + shadowHeight)
//        let size = CGSize(width: width, height: height)
//        
//        let frontImage = image(color: color, size: size, cornerRadius: cornerRadius)
//        var backImage: UIImage? = nil
//        if shadowHeight != 0 {
//            backImage = image(color: shadowColor, size: size, cornerRadius: cornerRadius)
//        }
//        
//        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height + shadowHeight)
//        
//        // Draw background image then foreground image
//        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
//        backImage?.draw(at: CGPoint(x: 0, y: shadowHeight))
//        frontImage.draw(at: CGPoint(x: 0, y: frontImageOffset))
//        let nonResizableImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        // Create resizable image
//        let capInsets = UIEdgeInsets(top: cornerRadius + frontImageOffset, left: cornerRadius, bottom: cornerRadius + shadowHeight - frontImageOffset, right: cornerRadius)
//        let resizableImage = nonResizableImage?.resizableImage(withCapInsets: capInsets, resizingMode: .stretch)
//        
//        return resizableImage ?? UIImage()
//    }
//    
//    static func image(color: UIColor, size: CGSize, cornerRadius: CGFloat) -> UIImage {
//        
//        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
//        
//        // Create a non-rounded image
//        UIGraphicsBeginImageContextWithOptions(size, false, 0)
//        let context = UIGraphicsGetCurrentContext()
//        context?.setFillColor(color.cgColor)
//        context?.fill(rect)
//        let nonRoundedImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        // Clip it with a bezier path
//        UIGraphicsBeginImageContextWithOptions(size, false, 0)
//        UIBezierPath(
//            roundedRect: rect,
//            cornerRadius: cornerRadius
//            ).addClip()
//        nonRoundedImage?.draw(in: rect)
//        
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        return image ?? UIImage()
//    }
//}
//
