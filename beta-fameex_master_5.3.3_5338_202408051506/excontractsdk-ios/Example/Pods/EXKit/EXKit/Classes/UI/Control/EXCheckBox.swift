//
//  EXCheckBox.swift
//  Chainup
//
//  Created by liuxuan on 2019/3/10.
//  Copyright © 2019 zewu wang. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit

public enum CheckBoxIconStyle {
    case squareDot //方形的点
    case circleCheck //圆形对勾
    case squareCheck //方形对勾
}

@IBDesignable
open class EXCheckBox: UIControl {
    
    public var checkEnabled:Bool = true
    public var isChecked:Bool = false
    public var text:String = ""
    public var checkIcon:UIImageView = UIImageView()
    public var fillColor:UIColor = UIColor.clear
    public var updateStateWhenTracking:Bool = true
    public var normalColor:UIColor = .ThemeLabel.colorMedium {
        didSet {
            updateTilteColor(select: isChecked)
        }
    }
    public var checkColor :UIColor = UIColor.ThemeView.highlight {
        didSet {
            updateTilteColor(select: isChecked)
        }
    }
    public var checkLabel :UILabel = UILabel.init()
    public let checkBoxLineWidth:CGFloat = 2
    public var iconStyle:CheckBoxIconStyle
    private var spacingConstraint:Constraint!
    public var spacing:CGFloat = 4 {
        didSet {
            spacingConstraint.update(offset: spacing)
            invalidateIntrinsicContentSize()
        }
    }
    public var customIconSize:CGSize? {
        didSet {
            configIcon()
        }
    }
    private var internalIconSize:CGSize = .zero
    
    public override var intrinsicContentSize: CGSize {
        var height = self.internalIconSize.height
        height = max(checkLabel.intrinsicContentSize.height, height)
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }
    public var iconVerticalOffset:CGFloat = 0 {
        didSet {
            configIcon()
        }
    }
    public var iconVerticalAlignment: UIControl.ContentVerticalAlignment = .center {
        didSet {
            configIcon()
        }
    }
    public typealias CheckBoxValueChanged = (Bool) -> ()
    public var checkCallback : CheckBoxValueChanged?
    
    public override var isSelected: Bool {
        didSet {
            self.checked(check: isSelected)
        }
    }
    
    public func updateTilteColor(select: Bool){
        let color = select ? checkColor : normalColor
        self.checkLabel.textColor = color
    }
    
    public func checked(check:Bool){
        self.isChecked = check
        configIcon()
        sendActions(for: .valueChanged)
    }
    
    public func text(content:String) {
        checkLabel.text = content
        invalidateIntrinsicContentSize()
        self.setNeedsDisplay()
    }
    
    public func attributeText(content:NSAttributedString) {
        checkLabel.attributedText = content
        invalidateIntrinsicContentSize()
        self.setNeedsDisplay()
    }

    public override init(frame: CGRect) {
        self.iconStyle = .squareDot
        super.init(frame: frame)
        config()
    }
    
    public required init(frame: CGRect,style:CheckBoxIconStyle = .squareDot) {
        self.iconStyle = style
        super.init(frame: frame)
        config()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.iconStyle = .squareDot
        super.init(coder: aDecoder)
        config()
    }
        
    open func config(){
        self.backgroundColor = UIColor.clear
        self.addSubview(checkLabel)
        self.addSubview(checkIcon)
        configIcon()
        checkLabel.numberOfLines = 0
        checkLabel.secondaryRegular()
        checkLabel.textColor = UIColor.ThemeLabel.colorMedium
        checkLabel.snp.makeConstraints { (make ) in
            self.spacingConstraint = make.left.equalTo(checkIcon.snp.right).offset(4).constraint
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }

    }
    
    open func configIcon() {
        var width = 16
        //圆的
        var select = EXKitBundle.svgImage(named: "public_selected_square")
        var unselect = EXKitBundle.image(named: "public_unselected")
        switch iconStyle {
        case .squareDot:
            //? "fiat_selected" : "fiat_unchecked")
            width = 14
        case .circleCheck:
            select = EXKitBundle.svgImage(named: "public_checked")
            unselect = EXKitBundle.image(named: "quotes_unselected")
          // isChecked ? "quotes_checked" : "quotes_unselected")
        case .squareCheck:
            break
//             select = EXKitBundle.svgImage(named: "public_selected_square")
//             unselect = EXKitBundle.image(named: "public_unselected")
            // "public_selected" : "public_unselected")
        }
        
        checkIcon.image = isChecked ? select : unselect
        checkIcon.snp.remakeConstraints { (make) in
            make.left.equalToSuperview()
            switch self.iconVerticalAlignment {
                case .top:
                    make.top.equalToSuperview().offset(iconVerticalOffset)
                case .bottom:
                    make.bottom.equalToSuperview().offset(iconVerticalOffset)
                case .center,.fill:
                    make.centerY.equalToSuperview().offset(iconVerticalOffset)
                @unknown default:
                    make.centerY.equalToSuperview().offset(iconVerticalOffset)
            }
            if let size = self.customIconSize {
                make.size.equalTo(size)
                self.internalIconSize = size
            }else{
                make.width.height.equalTo(width)
                self.internalIconSize = CGSize(width: width, height: width)
            }
        }
        invalidateIntrinsicContentSize()
    }
    
    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        guard updateStateWhenTracking else { return true }
        checked(check: !isChecked)
        checkCallback?(self.isChecked)
        sendActions(for: .valueChanged)
        return true
    }
}


extension Reactive where Base: EXCheckBox {
    public var checkState: ControlProperty<Bool> {
        return base.rx.controlProperty(editingEvents: .valueChanged,
                                       getter: { customView in
                                        return  customView.isChecked},
                                       setter: { (customView, newValue) in
                                        customView.isChecked = newValue})
    }
    
}
