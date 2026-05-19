//
//  EXAttributedString.swift
//  EXUIKit
//
//  Created by zq on 2023/2/1.
//

import UIKit
import YYText

public extension UILabel {
    @objc func ex_NSAttributedString() -> NSAttributedString? {
        return attributedText ?? text?.ex_toNSAttributedString(font: font, textColor: textColor).ex_alignment(textAlignment)
    }
}

public extension String {
    func ex_toNSAttributedString(attributes:[NSAttributedString.Key:Any]?) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: self, attributes:attributes)
    }
    func ex_toNSAttributedString(font:UIFont?,textColor:UIColor?) -> NSMutableAttributedString {
        var attributes: [NSAttributedString.Key:Any] = [:]
        if let font = font { attributes[.font] = font }
        if let textColor = textColor { attributes[.foregroundColor] = textColor }
        return ex_toNSAttributedString(attributes: attributes)
    }
}

public extension NSAttributedString {
    @objc var ex_attributes: [Key:Any]? { ex_attributes(at: 0) }
    @objc func ex_attributes(at index:Int) -> [Key:Any]? {
        if index >= self.length || index < 0 || self.length == 0 { return nil }
        return attributes(at: index, effectiveRange: nil)
    }
    @objc func ex_attribute(_ name:Key, at index:Int) -> Any? {
        if index >= self.length || self.length == 0 { return nil }
        return attribute(name, at: index, effectiveRange: nil)
    }
    ///
    @objc var ex_rangeOfAll:NSRange { NSRange(location: 0, length: length) }
    ///
    @objc var ex_font: UIFont? { ex_attribute(.font, at: 0) as? UIFont }
    @objc var ex_textColor: UIColor? { ex_attribute(.foregroundColor, at: 0) as? UIColor }
    @objc var ex_backgroundColor: UIColor? { ex_attribute(.backgroundColor, at: 0) as? UIColor }
    @objc var ex_kern: NSNumber? { ex_attribute(.kern, at: 0) as? NSNumber }
    @objc var ex_baselineOffset: NSNumber? { ex_attribute(.baselineOffset, at: 0) as? NSNumber }
    @objc var ex_paragraphStyle: NSParagraphStyle {
        (ex_attribute(.paragraphStyle, at: 0) as? NSParagraphStyle) ?? NSParagraphStyle.default.copy() as! NSParagraphStyle
    }
    ///
    @objc var ex_alignment: NSTextAlignment { ex_paragraphStyle.alignment }
    @objc var ex_lineBreakMode: NSLineBreakMode { ex_paragraphStyle.lineBreakMode }
    @objc var ex_lineHeightMultiple: CGFloat { ex_paragraphStyle.lineHeightMultiple }
    @objc var ex_minimumLineHeight: CGFloat { ex_paragraphStyle.minimumLineHeight }
    @objc var ex_maximumLineHeight: CGFloat { ex_paragraphStyle.maximumLineHeight }
    @objc var ex_lineSpacing      : CGFloat { ex_paragraphStyle.lineSpacing }
    @objc var ex_paragraphSpacing : CGFloat { ex_paragraphStyle.paragraphSpacing }
    ///
    @objc func ex_mutableCopy() -> NSMutableAttributedString { mutableCopy() as! NSMutableAttributedString }
}

public extension NSMutableAttributedString {
    @discardableResult
    func append(_ string:String,font:UIFont?,textColor:UIColor?) -> NSMutableAttributedString {
        var attributes: [NSAttributedString.Key:Any] = [:]
        if let font = font { attributes[.font] = font }
        if let textColor = textColor { attributes[.foregroundColor] = textColor }
        return append(string, attributes: attributes)
    }
    @discardableResult
    func append(_ string:String,attributes:[Key:Any]? = nil) -> NSMutableAttributedString {
        append(string.ex_toNSAttributedString(attributes: attributes ?? ex_attributes))
        return self
    }
    @discardableResult
    func ex_set(_ attrbutes:[NSAttributedString.Key:Any]?, range:NSRange? = nil) -> NSMutableAttributedString {
        setAttributes(attrbutes, range: range ?? ex_rangeOfAll)
        return self
    }
    @discardableResult
    func ex_font(_ font:UIFont?, range:NSRange? = nil) -> NSMutableAttributedString {
        return ex_addAttribute(.font, value: font, range:range)
    }
    @discardableResult
    func ex_textColor(_ color:UIColor?, range:NSRange? = nil) -> NSMutableAttributedString {
        return ex_addAttribute(.foregroundColor, value: color, range:range)
    }
    @discardableResult
    func ex_backgroundColor(_ color:UIColor?, range:NSRange? = nil) -> NSMutableAttributedString {
        return ex_addAttribute(.backgroundColor, value: color, range:range)
    }
    @discardableResult
    func ex_kern(_ value:NSNumber?, range:NSRange? = nil) -> NSMutableAttributedString {
        return ex_addAttribute(.kern, value: value, range:range)
    }
    @discardableResult
    func ex_baselineOffset(_ value:NSNumber?, range:NSRange? = nil) -> NSMutableAttributedString {
        return ex_addAttribute(.baselineOffset, value: value, range:range)
    }
    @discardableResult
    func ex_paragraphStyle(_ value:NSParagraphStyle?, range:NSRange? = nil) -> NSMutableAttributedString {
        return ex_addAttribute(.paragraphStyle, value: value, range:range)
    }
    //
    @discardableResult
    func ex_alignment(_ value:NSTextAlignment, range:NSRange? = nil) -> NSMutableAttributedString {
        return ex_setParagraphStyle(range) { style in
            if style.alignment == value { return false }
            style.alignment = value
            return true
        }
    }
    @discardableResult
    func ex_minimumLineHeight(_ value:CGFloat, range:NSRange? = nil) -> NSMutableAttributedString {
        return ex_setParagraphStyle(range) { style in
            if style.minimumLineHeight == value { return false }
            style.minimumLineHeight = value
            return true
        }
    }
    @discardableResult
    func ex_maximumLineHeight(_ value:CGFloat, range:NSRange? = nil) -> NSMutableAttributedString {
        return ex_setParagraphStyle(range) { style in
            if style.maximumLineHeight == value { return false }
            style.maximumLineHeight = value
            return true
        }
    }
    @discardableResult
    func ex_lineHeightMultiple(_ value:CGFloat, range:NSRange? = nil) -> NSMutableAttributedString {
        return ex_setParagraphStyle(range) { style in
            if style.lineHeightMultiple == value { return false }
            style.lineHeightMultiple = value
            return true
        }
    }
    
    @discardableResult
    func ex_lineHeight(_ value:CGFloat? = nil, font:UIFont? = nil, range:NSRange? = nil) -> NSMutableAttributedString {
        var value = value
        if value == nil {
            var font = font
            if font == nil, let range = range  {
                guard let obj = ex_attribute(.font, at: range.location) as? UIFont else { return self }
                font = obj
            }
            guard let font = font ?? ex_font else { return self }
            value = font.pointSize + 6
        }
        guard let value = value else { return self }
        return ex_setParagraphStyle(range) { style in
            if style.minimumLineHeight == value && style.maximumLineHeight == value { return false }
            style.minimumLineHeight = value
            style.maximumLineHeight = value
            return true
        }
    }
    @discardableResult
    func ex_lineSpacing(_ value:CGFloat, range:NSRange? = nil) -> NSMutableAttributedString {
        return ex_setParagraphStyle(range) { style in
            if style.lineSpacing == value { return false }
            style.lineSpacing = value
            return true
        }
    }
    
    @discardableResult
    func ex_lineBreakMode(_ value:NSLineBreakMode, range:NSRange? = nil) -> NSMutableAttributedString {
        return ex_setParagraphStyle(range) { style in
            if style.lineBreakMode == value { return false }
            style.lineBreakMode = value
            return true
        }
    }
    
    func ex_paragraphSpacing(_ value:CGFloat, range:NSRange? = nil) -> NSMutableAttributedString {
        return ex_setParagraphStyle(range) { style in
            if style.paragraphSpacing == value { return false }
            style.paragraphSpacing = value
            return true
        }
    }
    @discardableResult
    func ex_setParagraphStyle(_ range:NSRange? = nil, set:((NSMutableParagraphStyle)->(Bool))) -> NSMutableAttributedString {
        enumerateAttribute(.paragraphStyle, in: range ?? ex_rangeOfAll) { value, subRange, stop in
            var style:NSMutableParagraphStyle? = nil
            if let value = value as? NSMutableParagraphStyle {
                style = value
            }else if let value = value as? NSParagraphStyle {
                style = (value.mutableCopy() as! NSMutableParagraphStyle)
            }
            if style == nil {
                style = (NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle)
            }
            guard let style = style else { return }
            if !set(style) { return }
            ex_addAttribute(.paragraphStyle, value: style, range: subRange)
        }
        return self
    }
    
    @discardableResult
    func ex_addAttribute(_ attrName:NSAttributedString.Key, value:Any?, range:NSRange? = nil) -> NSMutableAttributedString {
        let _range = range ?? ex_rangeOfAll
        if value == nil {
            removeAttribute(attrName, range: _range)
        }else{
            addAttribute(attrName, value: value!, range: _range)
        }
        return self
    }
    
    @discardableResult
    func ex_addAttributes(_ attrs: [NSAttributedString.Key : Any], range: NSRange? = nil) -> NSMutableAttributedString {
        guard !attrs.isEmpty else { return self }
        let _range = range ?? ex_rangeOfAll
        addAttributes(attrs, range: _range)
        return self
    }
    
}

// YYText
public extension YYLabel {
    @objc func ex_NSAttributedString() -> NSAttributedString? {
        return attributedText ?? text?.ex_toNSAttributedString(font: font, textColor: textColor).ex_alignment(textAlignment)
    }
}
public extension NSMutableAttributedString {
    @discardableResult
    func ex_yyStrikethrough(_ value:YYTextDecoration = YYTextDecoration(style: .single, width: nil, color: .Ex.text3), range:NSRange? = nil) -> NSMutableAttributedString {
        return ex_addAttributes([.init(YYTextStrikethroughAttributeName):value], range: range)
    }
    @discardableResult
    func ex_setYYHighlight(_ highlight:YYTextHighlight, range:NSRange? = nil) -> NSMutableAttributedString {
        yy_setTextHighlight(highlight, range: range ?? ex_rangeOfAll)
        return self
    }
    @discardableResult
    func ex_setYYTapAction(range:NSRange? = nil, tapAction: @escaping (()->Void)) -> NSMutableAttributedString {
        yy_setTextHighlight(range ?? ex_rangeOfAll, color: nil, backgroundColor: nil) { _, _, _, _ in tapAction() }
        return self
    }
}

public extension YYTextHighlight {
    ///
    convenience init(font:UIFont? = nil,
                     textColor:UIColor? = nil,
                     strokeColor:UIColor? = nil,
                     strokeWidth:CGFloat? = nil,
                     shadow:YYTextShadow? = nil,
                     innerShadow:YYTextShadow? = nil,
                     underLine:YYTextDecoration? = nil,
                     strikethrough:YYTextDecoration? = nil,
                     backgroundColor:UIColor? = nil,
                     backgroundBorder:YYTextBorder? = nil,
                     border:YYTextBorder? = nil,
                     attachment:YYTextAttachment? = nil,
                     userInfo:[AnyHashable:Any]? = nil,
                     tapAction:YYTextAction? = nil,
                     longPressAction:YYTextAction? = nil) {
        self.init()
        if let backgroundBorder = backgroundBorder {
            setBackgroundBorder(backgroundBorder)
        }else if let backgroundColor = backgroundColor {
            let backgroundBorder = YYTextBorder(fill: backgroundColor, cornerRadius: 3)
            backgroundBorder.insets = UIEdgeInsets(top: -2, left: -1, bottom: -2, right: -1)
            setBackgroundBorder(backgroundBorder)
        }
        self.userInfo = userInfo
        self.tapAction = tapAction
        self.longPressAction = longPressAction
        ///
        [#selector(YYTextHighlight.setFont(_:)):font as Any?,
         #selector(YYTextHighlight.setColor(_:)):textColor as Any?,
         #selector(YYTextHighlight.setStroke(_:)):strokeColor as Any?,
         #selector(YYTextHighlight.setStrokeWidth(_:)):strokeWidth as Any?,
         #selector(YYTextHighlight.setShadow(_:)):shadow as Any?,
         #selector(YYTextHighlight.setInnerShadow(_:)):innerShadow as Any?,
         #selector(YYTextHighlight.setUnderline(_:)):underLine as Any?,
         #selector(YYTextHighlight.setStrikethrough(_:)):strikethrough as Any?,
         #selector(YYTextHighlight.setAttachment(_:)):attachment as Any?,
        ].forEach({
            if let value = $0.value  {
                perform($0.key, with: $0.value)
            }
        })
    }
}

public extension NSMutableParagraphStyle {
    static func style(alignment: NSTextAlignment? = nil,
                      lineSpacing: CGFloat? = nil,
                      lineHeight: CGFloat? = nil,
                      paragraphSpacing: CGFloat? = nil) -> NSMutableParagraphStyle {
        let style = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        if let alignment = alignment {
            style.alignment = alignment
        }
        if let lineSpacing = lineSpacing {
            style.lineSpacing = lineSpacing
        }
        if let lineHeight = lineHeight {
            style.minimumLineHeight = lineHeight
            style.maximumLineHeight = lineHeight
        }
        if let paragraphSpacing = paragraphSpacing {
            style.paragraphSpacing = paragraphSpacing
        }
        return style
    }
}
