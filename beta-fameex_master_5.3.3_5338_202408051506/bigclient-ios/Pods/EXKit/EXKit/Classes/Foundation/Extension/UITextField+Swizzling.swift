//
//  UITextFiledExtension.swift
//  Chainup
//
//  Created by zewu wang on 2018/8/22.
//  Copyright © 2018年 zewu wang. All rights reserved.
//

import UIKit

public protocol SelfAware: AnyObject {
    static func awake()
    static func swizzlingForClass(_ forClass: AnyClass, originalSelector: Selector, swizzledSelector: Selector)
}
 extension SelfAware {
    
      public static func swizzlingForClass(_ forClass: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
        let originalMethod = class_getInstanceMethod(forClass, originalSelector)
        let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector)
        guard (originalMethod != nil && swizzledMethod != nil) else {
            return
        }
        if class_addMethod(forClass, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!)) {
            class_replaceMethod(forClass, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        } else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        }
    }
}

class NothingToSeeHere {
    static func harmlessFunction() {
        let typeCount = Int(objc_getClassList(nil, 0))
        let types = UnsafeMutablePointer<AnyClass>.allocate(capacity: typeCount)
        let autoreleasingTypes = AutoreleasingUnsafeMutablePointer<AnyClass>(types)
        objc_getClassList(autoreleasingTypes, Int32(typeCount))
        for index in 0 ..< typeCount {
            (types[index] as? SelfAware.Type)?.awake()
        }
        types.deallocate()
    }
}
extension UIApplication {
    private static let runOnce: Void = {
        NothingToSeeHere.harmlessFunction()
    }()
    override open var next: UIResponder? {
        UIApplication.runOnce
        return super.next
    }
}
/*
 处理一些欧洲国家键盘小数点为逗号的情况,提交数据异常
 显示不处理,只有提交数据时处理
 如果是数字键盘,当提交数据时将逗号统一替换为小数点
 */
extension UITextField:SelfAware{
    public static func awake() {
        swizzleMethod
//        print("更换成功")
    }
    
    private static let swizzleMethod: Void = {
        
        let originalSelector = #selector(getter: text)
        let swizzledSelector = #selector(swizzled_text)
            swizzlingForClass(UITextField.self, originalSelector: originalSelector, swizzledSelector: swizzledSelector)
        }()
        
        @objc func swizzled_text() -> String?{
            if self.keyboardType == .decimalPad{
                if let t = self.swizzled_text() {
                    return t.replacingOccurrences(of: ",", with: ".")
                }
            }
            return self.swizzled_text()
        }
    
}
