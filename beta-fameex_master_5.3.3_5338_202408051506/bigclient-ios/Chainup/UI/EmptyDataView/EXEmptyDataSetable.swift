//
//  EXEmptyDataSetable.swift
//  Chainup
//
//  Created by liuxuan on 2019/4/12.
//  Copyright © 2019 zewu wang. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import EXKit

public protocol EXEmptyDataSetable {
    
}

public enum EXEmptyDataSetAttributeKeyType {
    ///Vertical Offset (-50) CGFloat
    case verticalOffset
    ///Reminder (currently no data) String
    case tipStr
    ///Font (system15) UIFont for prompt language
    case tipFont
    ///Reminder color (D2D2D2) UIColor
    case tipColor
    ///LXFEmptyDataPic UIImage
    case tipImage
    ///Allow scrolling (true) Bool
    case allowScroll
}

extension UIScrollView {
    
    private struct AssociatedKeys {
        static var exemptyAttributeDict:[EXEmptyDataSetAttributeKeyType : Any]?
    }
    ///Attribute Dictionary
    var exemptyAttributeDict: [EXEmptyDataSetAttributeKeyType : Any]? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.exemptyAttributeDict) as? [EXEmptyDataSetAttributeKeyType : Any]
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.exemptyAttributeDict, newValue as [EXEmptyDataSetAttributeKeyType : Any]?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

public extension EXEmptyDataSetable where Self : UIViewController {
    func exEmptyDataSet(_ scrollView: UIScrollView, attributeBlock: (()->([EXEmptyDataSetAttributeKeyType : Any]))? = nil) {
        scrollView.exemptyAttributeDict = attributeBlock != nil ? attributeBlock!() : nil
        scrollView.emptyDataSetDelegate = self
        scrollView.emptyDataSetSource = self
    }
}

public extension UIView {
    private struct AssociatedKey {
        static var fromKline: String = "fromKline"
    }
    
    public var fromKline: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.fromKline) as? Bool ?? false
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.fromKline, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}

extension NSObject : DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    public func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        //Return to prompt image
        guard let tipImg = scrollView.exemptyAttributeDict?[.tipImage] as? UIImage else {
            return UIImage.themeImageNamed(imageName: "norecords",kline: scrollView.fromKline)
        }
        return tipImg
    }
    
    public func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        
        var text = "common_tip_nodata".localized()
        if let tipStr = scrollView.exemptyAttributeDict?[.tipStr] as? String {
            text = tipStr
        }

        let attributeText = NSMutableAttributedString.init(string: text)
        let count = text.count
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center      //Text alignment direction
        var font = UIFont.ThemeFont.SecondaryRegular
    
        if let tipFont = scrollView.exemptyAttributeDict?[.tipFont] as? UIFont {
            font = tipFont
        }
        
        attributeText.addAttributes([kCTFontAttributeName as NSAttributedStringKey: font], range: NSMakeRange(0, count))
        
        var color = scrollView.fromKline ? UIColor.ThemekLine.labcolorDark : UIColor.ThemeLabel.colorDark
        if let tipColor = scrollView.exemptyAttributeDict?[.tipColor] as? UIColor {
            color = tipColor
        }
        attributeText.addAttributes([NSAttributedStringKey.foregroundColor as NSAttributedStringKey:color], range: NSMakeRange(0, count))
        return attributeText
    }
    
    public func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        
        guard let offset = scrollView.exemptyAttributeDict?[.verticalOffset] as? CGFloat else {
            return 0
        }
        return offset
    }
    
    public func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        guard let scrollable = scrollView.exemptyAttributeDict?[.allowScroll] as? Bool else {
            return true
        }
        return scrollable
    }
}

