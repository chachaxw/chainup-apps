//
//  EXLabel.swift
//  Blueprints
//
//  Created by youbin on 2023/6/16.
//

import UIKit
import YYText
import SnapKit

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

open class EXAttributedTextLabel: UIView {
    
    open var attributedText: NSAttributedString? {
        didSet {
            innerLabel.attributedText = attributedText
            updateLayout()
        }
    }
    
    /// padding for yylabel
    open var edgeInset: UIEdgeInsets = .zero
    
    // hide padding when the attributedText.string is empty
    open var isHideEdgeWithEmptyText: Bool = false
    
    fileprivate lazy var innerLabel: YYLabel = {
        let v = YYLabel()
        v.numberOfLines = 0
        return v
    }()
    
    fileprivate var _edgeInset: UIEdgeInsets {
        if let _text = attributedText?.string.trimmingCharacters(in: .whitespacesAndNewlines),
           _text.count > 0  {
            return edgeInset
        }
        return isHideEdgeWithEmptyText ? .zero : edgeInset
    }
    
    fileprivate func updateLayout() {
        self.insetConstraint?.update(inset: _edgeInset)
        self.innerLabel.layoutIfNeeded()
        guard let attributedText = attributedText else { return }
        let innerWidth = self.innerLabel.frame.width
        if innerWidth <= 0 { return }
        let textLayout = YYTextLayout.init(containerSize: CGSize(width: innerWidth, height: CGFLOAT_MAX), text: attributedText)
        guard let height = textLayout?.textBoundingSize.height else { return }
        self.innerLabel.snp.makeConstraints { make in
            make.height.equalTo(height)
        }
    }
    
    fileprivate var insetConstraint: Constraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        onCreate()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onCreate() {
        backgroundColor = .Ex.warning1.withAlphaComponent(0.1)
        addSubview(innerLabel)
        innerLabel.snp.makeConstraints { make in
            self.insetConstraint = make.edges.equalToSuperview().inset(_edgeInset).constraint
        }
    }
    
    open override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width  += _edgeInset.left + _edgeInset.right
        size.height += _edgeInset.top + _edgeInset.bottom
        return size
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
