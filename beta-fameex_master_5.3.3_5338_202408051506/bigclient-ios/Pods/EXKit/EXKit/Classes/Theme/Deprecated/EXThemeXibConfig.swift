//
//  EXThemeXibConfig.swift
//  Chainup
//
//  Created by liuxuan on2020/1/15.
//  Copyright ©2020 zewu wang. All rights reserved.
//

import Foundation


extension UIColor {
    public static func themeColor(keyPath:String) -> UIColor{
        let module:UIColor.Ex = keyPath.hasPrefix("kline.") ? .kLine : .global
        return Ex.named(keyPath, color: module.color)
    }
}

extension UIView {
    //设置view背景色
    @IBInspectable public var themebg: String? {
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
            backgroundColor = .themeColor(keyPath: newValue)
        }
        get {
            return ""
        }
    }
    //可设置view圆角
     @IBInspectable public var corneradius : CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0.0
        }
    }
    //可设置borderwidth
    @IBInspectable public var borderW: CGFloat {
        get {
            return layer.borderWidth
        }
        
        set {
            layer.borderWidth = newValue
        }
    }
    //设置bordercolor
    @IBInspectable public var borderC: String? {
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
    @IBInspectable public var themeTxtColor: String? {
    
        set {
            guard let newValue = newValue else { return }
            textColor = .themeColor(keyPath: newValue)
        }
        get {
            return ""
        }
    }
}

extension UIImageView {
    
    @IBInspectable public var themeIcon: String? {
        set {
            guard let newValue = newValue else { return }
            self.image  = .themeImageNamed(imageName: newValue)
        }
        get {
            return ""
        }
    }
}

extension UIButton {
    @IBInspectable public var htitleC: String? {
        set {
            guard let newValue = newValue else { return }
            setTitleColor(.themeColor(keyPath: newValue), for: .highlighted)
        }
        get {
            return ""
        }
    }
    
    @IBInspectable public var titleC: String? {
        set {
            guard let newValue = newValue else { return }
            setTitleColor(.themeColor(keyPath: newValue), for: .normal)
        }
        get {
            return ""
        }
    }
    
    @IBInspectable public var themeIcon: String? {
        set {
            guard let newValue = newValue else { return }
            setImage(UIImage.themeImageNamed(imageName: newValue), for: .normal)
        }
        get {
            return ""
        }
    }
}

extension UITextField {
    @IBInspectable public var titleC: String? {
        set {
            guard let newValue = newValue else { return }
            textColor = .themeColor(keyPath: newValue)
        }
        get {
            return ""
        }
    }
}

extension NSLayoutConstraint {
    /**
     Change multiplier constraint
     
     - parameter multiplier: CGFloat
     - returns: NSLayoutConstraint
     */
    public func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
        
        NSLayoutConstraint.deactivate([self])
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem!,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}


