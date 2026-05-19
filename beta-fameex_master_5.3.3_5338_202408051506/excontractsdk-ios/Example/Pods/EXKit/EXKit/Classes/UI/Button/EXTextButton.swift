//
//  EXTextButton.swift
//  Chainup
//
//  Created by liuxuan on 2019/3/23.
//  Copyright © 2019 zewu wang. All rights reserved.
//

import UIKit

public class EXTextButton: EXButton {
    
    public var bgLayer = CAShapeLayer.init()
    public var markLayer = CAShapeLayer.init()
    public var highlightColor:UIColor = UIColor.ThemeView.highlight
    public var unCheckColor:UIColor = UIColor.clear
    public var checkstrokeColor:UIColor = UIColor.white
    public var uncheckstrokeColor:UIColor = UIColor.clear
//    var checkIcon:UIImageView = UIImageView()

    public var supportCheckHighlight :Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public var checkstrokeWidth:CGFloat = 1 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public var normalTextColor:UIColor = UIColor.ThemeLabel.colorMedium {
        didSet {
            self.setTitleColor(normalTextColor, for: .normal)
        }
    }
    
    public var highlighTextColor:UIColor = UIColor.ThemeLabel.colorLite {
        didSet {
            self.setTitleColor(highlighTextColor, for: .highlighted)
            self.setTitleColor(highlighTextColor, for: .selected)
        }
    }
    
    public func setFont(font:UIFont) {
        self.titleLabel?.font = font
    }
    
    public func setColor(color:UIColor) {
        self.color = color
        setNeedsDisplay()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        setNeedsDisplay()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
        setNeedsDisplay()
    }
    
    public override var isSelected: Bool {
        didSet {
            if supportCheckHighlight {
                self.layer.borderColor = highlightColor.cgColor
                self.layer.borderWidth = isSelected ? 0.5 : 0
                self.layer.cornerRadius = 4
                super.setNeedsDisplay()
                setNeedsDisplay()
            }
        }
    }
    
    fileprivate func configure() {
        self.layer.cornerRadius = 4
        self.clearColors()
        self.setTitleColor(normalTextColor, for: .normal)
        self.setTitleColor(highlighTextColor, for: .highlighted)
        self.setTitleColor(highlighTextColor, for: .selected)
        
        bgLayer.lineWidth = 0
        bgLayer.strokeColor = checkstrokeColor.cgColor
        bgLayer.fillColor = highlightColor.cgColor
        self.layer .addSublayer(bgLayer)
        
//        markLayer.strokeColor = checkstrokeColor.cgColor
//        markLayer.fillColor = UIColor.clear.cgColor
//        self.layer .addSublayer(markLayer)
        
//        checkIcon.image = UIImage.themeImageNamed(imageName: "fiat_checkmark")
//        self.addSubview(checkIcon)
     
        self.clipsToBounds = true
        adjustsImageWhenDisabled = false
        adjustsImageWhenHighlighted = false
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
//        checkIcon.snp.makeConstraints { (make) in
//            make.right.equalTo(-1)
//            make.width.equalTo(7)
//            make.height.equalTo(6)
//            make.top.equalTo(4)
//        }
    }
    
    public override func draw(_ rect: CGRect) {
//        checkIcon.isHidden = true
        if supportCheckHighlight {
//            checkIcon.isHidden = !isSelected
//            markLayer.lineWidth = checkstrokeWidth
//            bgLayer.fillColor = self.isSelected ? highlightColor.cgColor : unCheckColor.cgColor
//
//            let minHeight = min(rect.height, 40)
//
//            let checkStartX = self.bounds.size.width - CGFloat(minHeight/2)
//            let checkStartY = CGFloat(0)
//            let checkHeight = CGFloat(minHeight/2)
//
//            let path = UIBezierPath.init()
//            let startPoint = CGPoint(x:checkStartX, y: checkStartY)
//            let secondPoint = CGPoint(x: self.bounds.size.width, y: checkHeight)
//            let thirdPoind = CGPoint(x: self.bounds.size.width, y: CGFloat(0))
//            path.move(to:startPoint)
//            path.addLine(to:secondPoint)
//            path.addLine(to: thirdPoind)
//            path.addLine(to: startPoint)
//            bgLayer.path = path.cgPath
        }
    }
}
