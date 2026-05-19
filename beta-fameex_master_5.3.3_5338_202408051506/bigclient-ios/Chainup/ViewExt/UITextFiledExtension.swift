//
//  UITextFiledExtension.swift
//  Chainup
//
//  Created by zewu wang on 2018/8/22.
//  Copyright © 2018年 zewu wang. All rights reserved.
//

import UIKit

extension UITextField{
    
    //Set rich text for placeHolder
    func setPlaceHolderAtt(_ str : String , color : UIColor = UIColor.ThemeLabel.colorDark , font : CGFloat = 14){
//        let placeHolderAtt = NSMutableAttributedString().add(string: str, attrDic: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: font) , NSAttributedStringKey.foregroundColor : color])
//        self.attributedPlaceholder = placeHolderAtt
        setPlaceHolderAtt(str, color: color, font: font, weight: .regular)
    }
    
    func setPlaceHolderAtt(_ str : String , color : UIColor = UIColor.ThemeLabel.colorDark , font : CGFloat = 14, weight: UIFont.Weight){
        let placeHolderAtt = NSMutableAttributedString().add(string: str, attrDic: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: font, weight: weight), NSAttributedStringKey.foregroundColor : color])
        self.attributedPlaceholder = placeHolderAtt
    }
    
}

