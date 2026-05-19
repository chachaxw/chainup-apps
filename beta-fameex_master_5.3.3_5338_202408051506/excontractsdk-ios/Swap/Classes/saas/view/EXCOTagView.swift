//
//  EXTagView.swift
//  Chainup
//
//  Created by liuxuan on 2023/2/10.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXCOTagView: UIButton {
    
    static func commonTagView() -> EXCOTagView {
        let view = EXCOTagView.init(title: "")
        view.paddingX = 2
        view.textColor = UIColor.ThemeView.highlight
        view.textFont = UIFont.ThemeFont.TagRegular
        view.tagBackgroundColor = UIColor.ThemeView.highlight15
        view.cornerRadius = 2
        view.contentEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
//        view.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        return view
    }
        
    func commonTagWidth(titleStr:String) -> CGFloat {
        let tagWidth = ceilf(Float(titleStr.textSizeWithFont(self.textFont, width: CGFloat.greatestFiniteMagnitude).width + self.paddingX*2))
        return CGFloat(tagWidth)
    }
    
    static func getTagWidth(tag:String,font:UIFont,padding:CGFloat) ->CGFloat  {
        let tagWidth = ceilf(Float(tag.textSizeWithFont(font, width: CGFloat.greatestFiniteMagnitude).width + padding*2))
        return CGFloat(tagWidth)
    }
    
    @IBInspectable open var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable open var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable open var borderColor: UIColor? {
        didSet {
            reloadStyles()
        }
    }
    
    @IBInspectable open var textColor: UIColor = UIColor.white {
        didSet {
            reloadStyles()
        }
    }
    
    @IBInspectable open var selectedTextColor: UIColor = UIColor.white {
        didSet {
            reloadStyles()
        }
    }
    
    @IBInspectable open var titleLineBreakMode: NSLineBreakMode = .byTruncatingMiddle {
        didSet {
            titleLabel?.lineBreakMode = titleLineBreakMode
        }
    }
    
    @IBInspectable open var paddingY: CGFloat = 2 {
        didSet {
            titleEdgeInsets.top = paddingY
            titleEdgeInsets.bottom = paddingY
        }
    }
    
    @IBInspectable open var paddingX: CGFloat = 4 {
        didSet {
        }
    }

    @IBInspectable open var tagBackgroundColor: UIColor = UIColor.ThemeView.highlight25 {
        didSet {
            reloadStyles()
        }
    }
    
    @IBInspectable open var highlightedBackgroundColor: UIColor? {
        didSet {
            reloadStyles()
        }
    }
    
    @IBInspectable open var selectedBorderColor: UIColor? {
        didSet {
            reloadStyles()
        }
    }
    
    @IBInspectable open var selectedBackgroundColor: UIColor? {
        didSet {
            reloadStyles()
        }
    }
    
    @IBInspectable open var textFont: UIFont =  UIFont.ThemeFont.MinimumRegular {
        didSet {
            titleLabel?.font = textFont
        }
    }
    
    private func reloadStyles() {
        if isHighlighted {
            if let highlightedBackgroundColor = highlightedBackgroundColor {
                // For highlighted, if it's nil, we should not fallback to backgroundColor.
                // Instead, we keep the current color.
                backgroundColor = highlightedBackgroundColor
            }
        }
        else if isSelected {
            backgroundColor = selectedBackgroundColor ?? tagBackgroundColor
            layer.borderColor = selectedBorderColor?.cgColor ?? borderColor?.cgColor
            setTitleColor(selectedTextColor, for: UIControl.State())
        }
        else {
            backgroundColor = tagBackgroundColor
            layer.borderColor = borderColor?.cgColor
            setTitleColor(textColor, for: UIControl.State())
        }
    }
    
    override open var isHighlighted: Bool {
        didSet {
            reloadStyles()
        }
    }
    
    override open var isSelected: Bool {
        didSet {
            reloadStyles()
        }
    }
    
    /// Handles Tap (TouchUpInside)
    open var onTap: ((EXCOTagView) -> Void)?
    open var onLongPress: ((EXCOTagView) -> Void)?
    
    // MARK: - init
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    public init(title: String) {
        super.init(frame: CGRect.zero)
        setTitle(title, for: UIControl.State())
        
        setupView()
    }
    
    private func setupView() {
        titleLabel?.lineBreakMode = titleLineBreakMode
        frame.size = intrinsicContentSize
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress))
        self.addGestureRecognizer(longPress)
    }
    
    @objc func longPress() {
        onLongPress?(self)
    }
    
    // MARK: - layout
    override open var intrinsicContentSize: CGSize {
        var size = titleLabel?.text?.size(withAttributes: [NSAttributedString.Key.font: textFont]) ?? CGSize.zero
        size.height = textFont.pointSize + paddingY * 2
        size.width += paddingX * 2
        if size.width < size.height {
            size.width = size.height
        }
        return size
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
    }
}
