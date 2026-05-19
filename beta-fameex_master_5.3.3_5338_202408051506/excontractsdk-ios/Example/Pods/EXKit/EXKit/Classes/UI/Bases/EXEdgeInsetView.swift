//
//  EXEdgeInsetView.swift
//  EXKit
//
//  Created by zq on 2023/4/10.
//

import UIKit
import SnapKit

public class EXInsetLabel: UILabel {
    public var edgeInset:UIEdgeInsets = .zero {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public convenience init(frame:CGRect = .zero, edgeInset:UIEdgeInsets = .zero) {
        self.init(frame: frame)
        self.edgeInset = edgeInset
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        if size.width > 0, size.height > 0 {
            size.width += edgeInset.left + edgeInset.right
            size.height += edgeInset.top + edgeInset.bottom
        }
        return size
    }
    
    public override func drawText(in rect: CGRect) {
        let newRect = rect.inset(by: edgeInset)
        super.drawText(in: newRect)
    }
    
    public override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var boundingRect = bounds
        boundingRect.origin.x += leftInset
        boundingRect.origin.y += topInset
        boundingRect.size.width -= leftInset + rightInset
        let height = boundingRect.size.height + topInset + bottomInset
        if !height.isInfinite { boundingRect.size.height = height }
        return super.textRect(forBounds: boundingRect, limitedToNumberOfLines: numberOfLines)
    }
}

extension EXInsetLabel {
    @IBInspectable private var leftInset:CGFloat {
        get { edgeInset.left }
        set { edgeInset.left = newValue }
    }
    @IBInspectable private var rightInset:CGFloat {
        get { edgeInset.right }
        set { edgeInset.right = newValue }
    }
    @IBInspectable private var topInset:CGFloat {
        get { edgeInset.top }
        set { edgeInset.top = newValue }
    }
    @IBInspectable private var bottomInset:CGFloat {
        get { edgeInset.bottom }
        set { edgeInset.bottom = newValue }
    }
}
