//
//  UILabelExtension.swift
//  SDJG
//
//  Created by 王俊 on 16/4/19.
//  Modify  by 王俊 on 17/6/5. swift3.0
//  Copyright © 2016年 sunlands. All rights reserved.
//

import UIKit
import SnapKit
extension UILabel {
    
    /**
     设置颜色 字体大小
     
     - parameter textColor: 字体颜色
     - parameter fontSize:  字体大小
     */
    public final func extSetTextColor(_ textColor : UIColor , fontSize : CGFloat){
        
        self.textColor = textColor;
        self.setFont(fontSize: fontSize)
    }
    
    /**
     设置颜色 字体大小
     
     - parameter textColor: 字体颜色
     - parameter fontSize:  字体大小
     - parameter textAlignment : 文字对齐方式
     */
    public final func extSetTextColor(_ textColor : UIColor , fontSize : CGFloat , textAlignment : NSTextAlignment , isBold : Bool = false , numberOfLines : Int = 1){
        
        self.textColor = textColor;
        self.setFont(fontSize: fontSize,bold: isBold)
        
        self.numberOfLines = numberOfLines
        self.textAlignment = textAlignment
    }
    
    
    /**
     设置内容 颜色 字体大小
     
     - parameter text:      内容
     - parameter textColor: 字体颜色
     - parameter fontSize:  字体大小
     */
    public final func extSetText(_ text : String , textColor : UIColor , fontSize : CGFloat){
        
        self.extSetTextColor(textColor, fontSize: fontSize)
        self.text = text;
        
    }
    
    /**
     设置内容 颜色 字体大小 对齐方式
     
     - parameter text:      内容
     - parameter textColor: 字体颜色
     - parameter fontSize:  字体大小
     - parameter textAlignment:  对齐方式
     */
    public final func extSetText(_ text : String , textColor : UIColor , fontSize : CGFloat , textAlignment : NSTextAlignment){
        
        self.extSetText(text, textColor: textColor, fontSize: fontSize)
        self.textAlignment = textAlignment
        
    }
    
//    //老类,有90多处调用,先这么处理字体.
    public final func setFont(fontSize:CGFloat,bold:Bool = false ) {
        self.font = UIFont.ThemeFont.getFont(size: fontSize, aweight: bold ? .medium : .medium)
    }

}


extension UILabel{
    
    public convenience init(text: String? = nil, frame: CGRect = .zero, font: UIFont?, textColor: UIColor?, alignment: NSTextAlignment = .left, numberOfLines:Int? = nil) {
        self.init()
        
        self.text = text
        self.frame = frame
        self.font = font
        self.textColor = textColor
        self.textAlignment = alignment
        if let numberOfLines = numberOfLines {
            self.numberOfLines = numberOfLines
        }
    }
    //设置币对
    public func setCoinMap(_ name : String ,
                    leftColor : UIColor = UIColor.ThemeLabel.colorLite ,
                           leftFont : UIFont =  UIFont.ThemeFont.HeadBold ,
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
    
    public func setCoinMapWith(_ leftStr : String ,
                        leftColor : UIColor = UIColor.ThemeLabel.colorLite ,
                        leftFont : UIFont = UIFont.ThemeFont.HeadBold,
                        rightStr : String ,
                        rightColor : UIColor = UIColor.ThemeLabel.colorMedium,
                        rightFont : UIFont = UIFont.ThemeFont.SecondaryRegular,
                        kern:CGFloat)
    {
        var att = NSMutableAttributedString().add(string: leftStr,
                                                  attrDic:[
                                                    NSAttributedString.Key.foregroundColor : leftColor,
                                                    NSAttributedString.Key.font : leftFont
                                                  ])
        if rightStr != ""{
            att = att.add(string: "/\(rightStr)",
                          attrDic: [NSAttributedString.Key.foregroundColor : rightColor,
                                    NSAttributedString.Key.font : rightFont])
            if kern > 0 {
                att.addAttribute(NSAttributedString.Key.kern, value: 2, range: .init(location: leftStr.count - 1, length: 1))
            }
        }
        self.attributedText = att
    }
}
public extension UILabel{
    //只有标题重新适应
    func titleResizeSize(topAndBottom: CGFloat = 1,leftRight: CGFloat = 4) {
    //        let title = self.text ?? " "
    //        let font = self.font ?? UIFont.ThemeFont.BodyRegular
        let size = self.intrinsicContentSize//
        let newSize = CGSize(width: size.width + leftRight * 2, height: size.height + topAndBottom * 2)
        if let text = self.text {
            attributedText = text.ex_toNSAttributedString(font: font, textColor: textColor).ex_mutableCopy().ex_baselineOffset(NSNumber(value: font.lineHeight - size.height))
        }
        self.snp.updateConstraints { make in
            make.width.equalTo(newSize.width)
            make.height.equalTo(newSize.height)
        }
    }

}
