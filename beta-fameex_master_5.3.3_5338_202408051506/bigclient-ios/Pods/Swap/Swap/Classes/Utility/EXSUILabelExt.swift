//
//  EXSUILabelExt.swift
//  Chainup
//
//  Created by ZYJ on 2023/11/10.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
extension EXSTools {
    
   static func decimalValue(px_unit:String?) -> Int {
        
        if px_unit != nil {
            let px_string = px_unit?.newString()
            if px_string!.contains("."){
                let pointRange = (px_string! as NSString).range(of: ".")
                let subSting = (px_string! as NSString).substring(from: pointRange.location)
                
                let retValue = subSting.count - 1
                if retValue <= 0 {
                   return 1
                }
                return retValue
            }
        }
        return 0
    }
    
    static func colorWithUpAndDownText(_ intext:String) -> UIColor? {
        if intext.lessThan(BTZERO) {
            return UIColor.ThemekLine.down
        } else if intext.greaterThan(BTZERO) {
            return UIColor.ThemekLine.up
        }
        return UIColor.ThemeLabel.colorMedium
    }

}

extension UILabel {

    func setUpAndDownText(_ intext:String) {
         
        if let color = EXSTools.colorWithUpAndDownText(intext) {
            self.textColor = color
        }
        if !intext.hasPrefix("+")  {
            self.text = intext.upAndDownText()
        }else{
            self.text = intext
        }
        
    }
    func set_TextColor(_ intext:String){
        if let color = EXSTools.colorWithUpAndDownText(intext) {
            self.textColor = color
        }
    }
}

//extension UILabel {
//    public convenience init(text: String?, font: UIFont?, textColor: UIColor?, alignment: NSTextAlignment) {
//        self.init(text: text, frame: CGRect.zero, font: font, textColor: textColor, alignment: alignment)
//    }
//
//    public convenience init(text: String?, frame: CGRect, font: UIFont?, textColor: UIColor?, alignment: NSTextAlignment) {
//        self.init()
//
//        self.text = text
//        self.frame = frame
//        self.font = font
//        self.textColor = textColor
//        self.textAlignment = alignment
//    }
//}

