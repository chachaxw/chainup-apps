//
//  EXLabel.swift
//  Blueprints
//
//  Created by youbin on 2023/6/16.
//

import UIKit

open class EXLabel: UILabel {
    
    /// padding for display text
    open var edgeInset: UIEdgeInsets = .zero
    
    // hide padding when the text is empty
    open var isHideEdgeWithEmptyText: Bool = false

    private var _edgeInset: UIEdgeInsets {
        if let _text = text?.trimmingCharacters(in: .whitespacesAndNewlines),
           _text.count > 0  {
            return edgeInset
        }
        return isHideEdgeWithEmptyText ? .zero : edgeInset
    }
    
    open override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width  += _edgeInset.left + _edgeInset.right
        size.height += _edgeInset.top + _edgeInset.bottom
        return size
    }
    
    

    open override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: _edgeInset))
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
