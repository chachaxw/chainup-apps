////
////  EXEmptyDataSetable.swift
////  Chainup
////
////  Created by liuxuan on 2023/4/12.
////  Copyright © 2023 zewu wang. All rights reserved.
////
//
//import UIKit
////import DZNEmptyDataSet
//
//public protocol EXSEmptyDataSetable {
//    
//}
//
//public enum EXSEmptyDataSetAttributeKeyType {
//    /// 纵向偏移(-50)  CGFloat English: /Vertical offset (-50) CGFloat
//    case verticalOffset
//    /// 提示语(暂无数据)  String English: /Prompt language (currently no data available) String
//    case tipStr
//    /// 提示语的font(system15)  UIFont English: /Font (system 15) UIFont for prompt language
//    case tipFont
//    /// 提示语颜色(D2D2D2)  UIColor English: /Prompt language color (D2D2D2) UIColor
//    case tipColor
//    /// 提示图(LXFEmptyDataPic) UIImage English: /LXFEmptyDataPic UIImage
//    case tipImage
//    /// 允许滚动(true) Bool English: /Allow scrolling (true) Bool
//    case allowScroll
//}
//
//extension UIScrollView {
//    
//    private struct AssociatedKeys {
//        static var exemptyAttributeDict:[EXSEmptyDataSetAttributeKeyType : Any]?
//    }
//    /// 属性字典 English: /Attribute Dictionary
//    var exemptyAttributeDict: [EXSEmptyDataSetAttributeKeyType : Any]? {
//        get {
//            return objc_getAssociatedObject(self, &AssociatedKeys.exemptyAttributeDict) as? [EXSEmptyDataSetAttributeKeyType : Any]
//        }
//        set {
//            objc_setAssociatedObject(self, &AssociatedKeys.exemptyAttributeDict, newValue as [EXSEmptyDataSetAttributeKeyType : Any]?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//    }
//}
//
//public extension EXSEmptyDataSetable where Self : UIViewController {
//    func exEmptyDataSet(_ scrollView: UIScrollView, attributeBlock: (()->([EXSEmptyDataSetAttributeKeyType : Any]))? = nil) {
//        scrollView.exemptyAttributeDict = attributeBlock != nil ? attributeBlock!() : nil
////        scrollView.emptyDataSetDelegate = self
////        scrollView.emptyDataSetSource = self
//    }
//}
//
//extension NSObject  {
//    
//    public func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
//        // 返回提示图片 English: Return prompt image
//        guard let tipImg = scrollView.exemptyAttributeDict?[.tipImage] as? UIImage else {
//            return UIImage.exs_themeImageNamed(imageName: "norecords")
//        }
//        return tipImg
//    }
//    
//    public func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
//        
//        var text = "cp_extra_text52".ex_localized()
//        if let tipStr = scrollView.exemptyAttributeDict?[.tipStr] as? String {
//            text = tipStr
//        }
//
//        let attributeText = NSMutableAttributedString.init(string: text)
//        let count = text.count
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.alignment = .center      //文本对齐方向 English: Text alignment direction
//        var font = UIFont.ThemeFont.HeadRegular
//    
//        if let tipFont = scrollView.exemptyAttributeDict?[.tipFont] as? UIFont {
//            font = tipFont
//        }
//        
//        attributeText.addAttributes([kCTFontAttributeName as NSAttributedString.Key: font], range: NSMakeRange(0, count))
//        
//        var color = UIColor.ThemeLabel.colorMedium
//        if let tipColor = scrollView.exemptyAttributeDict?[.tipColor] as? UIColor {
//            color = tipColor
//        }
//        attributeText.addAttributes([NSAttributedString.Key.foregroundColor as NSAttributedString.Key:color], range: NSMakeRange(0, count))
//        return attributeText
//    }
//    
//    public func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
//        
//        guard let offset = scrollView.exemptyAttributeDict?[.verticalOffset] as? CGFloat else {
//            return 0
//        }
//        return offset
//    }
//    
//    public func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
//        guard let scrollable = scrollView.exemptyAttributeDict?[.allowScroll] as? Bool else {
//            return true
//        }
//        return scrollable
//    }
//}

