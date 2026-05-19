//
//  UILabelExt.swift
//  AppProject
//
//  Created by zewu wang on 2018/8/4.
//  Copyright © 2018年 zewu wang. All rights reserved.
//

import UIKit
import YYText
import RxSwift
import RxCocoa
extension UILabel{
    
    
    public var rx_text: ControlProperty<String> {
        //Observe text
        let source: Observable<String> = self.rx.observe(String.self, "text").map { $0 ?? "" }
        let setter: (UILabel, String) -> Void = { $0.text = $1 }
        let bindingObserver = UIBindingObserver(UIElement: self, binding: setter)
        return ControlProperty<String>(values: source, valueSink: bindingObserver)
    }
    
}

extension UILabel{
    
    //Set Currency Pairs
    func setCoinMap(_ name : String ,
                    leftColor : UIColor = UIColor.ThemeLabel.colorLite ,
                    leftFont : UIFont =  UIFont().themeHNBoldFont(size: 16) ,
                    rightColor : UIColor = UIColor.ThemeLabel.colorMedium ,
                    rightFont : UIFont = UIFont.ThemeFont.SecondaryRegular,
                    handleKern:CGFloat = 0) {
        let array = name.components(separatedBy: "/")
        if array.count >= 2{
            self.setCoinMapWith(array[0], leftColor: leftColor, leftFont: leftFont, rightStr: array[1], rightColor: rightColor, rightFont: rightFont,kern: handleKern)
        }else{
            self.setCoinMapWith(name, leftColor: leftColor, leftFont: leftFont, rightStr: "", rightColor: rightColor, rightFont: rightFont,kern: handleKern)
        }
    }
    
    func setCoinMapWith(_ leftStr : String ,
                        leftColor : UIColor = UIColor.ThemeLabel.colorLite ,
                        leftFont : UIFont = UIFont.ThemeFont.HeadBold,
                        rightStr : String ,
                        rightColor : UIColor = UIColor.ThemeLabel.colorMedium,
                        rightFont : UIFont = UIFont.ThemeFont.SecondaryRegular,
                        kern:CGFloat)
    {
        var att = NSMutableAttributedString().add(string: leftStr,
                                                  attrDic:[
                                                    NSAttributedStringKey.foregroundColor : leftColor,
                                                    NSAttributedStringKey.font : leftFont
                                                  ])
        if rightStr != ""{
            att = att.add(string: "/\(rightStr)",
                          attrDic: [NSAttributedStringKey.foregroundColor : rightColor,
                                    NSAttributedStringKey.font : rightFont])
            if kern > 0 {
                att.addAttribute(NSAttributedStringKey.kern, value: 2, range: .init(location: leftStr.count - 1, length: 1))
            }
        }
        self.attributedText = att
    }
}

extension String {
    
    static func getCoinMapAttr(_ name:String ,
                         leftColor:UIColor = UIColor.ThemeLabel.colorLite,
                         leftFont: UIFont = UIFont().themeHNFont(size: 16),
                         rightColor:UIColor = UIColor.ThemeLabel.colorMedium,
                         rightFont:UIFont = UIFont.ThemeFont.SecondaryRegular) -> NSMutableAttributedString
     {
         let array = name.components(separatedBy: "/")
         if array.count >= 2{
             return self.getCoinMapWith(array[0], leftColor: leftColor, leftFont: leftFont, rightStr: array[1], rightColor: rightColor, rightFont: rightFont)
         }else{
             return self.getCoinMapWith(name, leftColor: leftColor, leftFont: leftFont, rightStr: "", rightColor: rightColor, rightFont: rightFont)
         }
     }
     
     static func getCoinMapWith(_ leftStr : String ,
                         leftColor : UIColor = UIColor.ThemeLabel.colorLite ,
                         leftFont : UIFont = UIFont.ThemeFont.HeadBold,
                         rightStr : String , rightColor : UIColor = UIColor.ThemeLabel.colorMedium,
                         rightFont : UIFont = UIFont.ThemeFont.SecondaryRegular) -> NSMutableAttributedString{
         var att = NSMutableAttributedString().add(string: leftStr, attrDic: [NSAttributedStringKey.foregroundColor : leftColor,NSAttributedStringKey.font : leftFont])
         if rightStr != ""{
             att = att.add(string: "/\(rightStr)", attrDic: [NSAttributedStringKey.foregroundColor : rightColor,NSAttributedStringKey.font : rightFont])
         }
         return att
     }
}

