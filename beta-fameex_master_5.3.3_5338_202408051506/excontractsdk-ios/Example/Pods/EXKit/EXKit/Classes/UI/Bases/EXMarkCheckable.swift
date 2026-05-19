//
//  EXMarkCheckable.swift
//  Chainup
//
//  Created by liuxuan on 2019/3/14.
//  Copyright © 2019 zewu wang. All rights reserved.
//

import UIKit

public enum CheckStyle {
    case checkMark // 展示对勾
    case checkMarkBig // 展示大对勾
    case xMark // 展示叉子
    case xMarkBig // 展示大对勾

}

public class CheckMarkView :UIView {
    public var style:CheckStyle = .checkMark
    public var presenter:MarkCheckable!
    public var highlightColor:UIColor = UIColor.ThemeView.highlight
    public var unCheckColor:UIColor = UIColor.ThemeTab.icon
    public var checkstrokeColor:UIColor = UIColor.white
    public var uncheckstrokeColor:UIColor = UIColor.white
    public var checkIcon:UIImageView = UIImageView()
    
    public var checkstrokeWidth:CGFloat = 3 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public var bgLayer = CAShapeLayer.init()
    public var markLayer = CAShapeLayer.init()
    public var checked:Bool = false {
        didSet {
            if style != .checkMarkBig {
                checkIcon.isHidden = !checked
            }
            self.setNeedsDisplay()
        }
    }

    public required init(style:CheckStyle,isChecked:Bool,presenter:MarkCheckable) {
        super.init(frame: CGRect.zero)
        self.style = style
        self.checked = isChecked
        self.presenter = presenter
        config()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        config()
    }
    
    public func config() {
        self.backgroundColor = UIColor.clear
        bgLayer.lineWidth = 0
        bgLayer.strokeColor = checkstrokeColor.cgColor
        bgLayer.fillColor = highlightColor.cgColor
        self.layer .addSublayer(bgLayer)
        self.addSubview(checkIcon)

        if style == .checkMark {
            checkIcon.image = UIImage.themeImageNamedFromPod(imageName:"fiat_checkmark")
            checkIcon.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-1)
                make.top.equalToSuperview().offset(4)
            }
        }else if style == .checkMarkBig {
            checkIcon.image = UIImage.themeImageNamedFromPod(imageName: "quotes_checkmark_big")
            checkIcon.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(7)
                make.right.equalToSuperview().offset(-4)
            }
        }else if style == .xMark {
            checkIcon.image = UIImage.themeImageNamedFromPod(imageName:"fiat_delete")
            checkIcon.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-4)
                make.top.equalToSuperview().offset(6)
            }
        }else if style == .xMarkBig {
            checkIcon.image = UIImage.themeImageNamedFromPod(imageName:"personal_delete")
            checkIcon.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-11)
                make.top.equalToSuperview().offset(14)
            }
        }
        
        markLayer.strokeColor = checkstrokeColor.cgColor
        markLayer.fillColor = UIColor.clear.cgColor
//        self.layer .addSublayer(markLayer)
        
        let tapGesture = UITapGestureRecognizer.init()
        tapGesture.numberOfTapsRequired = 1
        tapGesture.addTarget(self, action: #selector(tapped))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc public func tapped(){
        self.checked = !self.checked
        self.presenter.didTapped(isCheck: self.checked)
    }
    
    public override func draw(_ rect: CGRect) {
        markLayer.lineWidth = checkstrokeWidth
        bgLayer.fillColor = checked ? highlightColor.cgColor : unCheckColor.cgColor
        markLayer.strokeColor = checked ? checkstrokeColor.cgColor : uncheckstrokeColor.cgColor
        let path = UIBezierPath.init()
        let startPoint = CGPoint(x:CGFloat(0), y: CGFloat(0))
        let secondPoint = CGPoint(x: self.bounds.size.width, y: self.bounds.size.height)
        let thirdPoind = CGPoint(x: self.bounds.size.width, y: CGFloat(0))
        path.move(to:startPoint)
        path.addLine(to:secondPoint)
        path.addLine(to: thirdPoind)
        path.addLine(to: startPoint)
        bgLayer.path = path.cgPath
        
//        if self.style == .checkMark,self.checked == true {
//
//            let checkPath = UIBezierPath.init()
//            checkPath.lineWidth = checkstrokeWidth
//            let startPoint = CGPoint(x: rect.size.width * 0.9 , y: rect.size.height * 0.2)
//            let secondPoint = CGPoint(x: rect.size.width * 0.7, y: rect.size.height * 0.5)
//            let endPoint = CGPoint(x: rect.size.width * 0.55, y: rect.height * 0.35)
//            checkPath.move(to: startPoint)
//            checkPath.addLine(to: secondPoint)
//            checkPath.addLine(to: endPoint)
//            markLayer.path = checkPath.cgPath
//        }else if self.style == .xMark, self.checked == true {
//
//            let checkPath = UIBezierPath.init()
//            checkPath.lineWidth = checkstrokeWidth
//            let startPoint = CGPoint(x: rect.size.width * 0.87 , y: rect.size.height * 0.19)
//            let secondPoint = CGPoint(x: rect.size.width * 0.61, y: rect.size.height * 0.45)
//            checkPath.move(to: startPoint)
//            checkPath.addLine(to: secondPoint)
//
//            let secondStartPoint = CGPoint(x: rect.size.width * 0.61, y: rect.size.height * 0.19)
//            let endPoint = CGPoint(x: rect.size.width * 0.87, y: rect.size.height * 0.45)
//
//            checkPath.move(to: secondStartPoint)
//            checkPath.addLine(to: endPoint)
//            markLayer.path = checkPath.cgPath
//        }
    }
}

public protocol MarkCheckable {
    var checkMarkView:CheckMarkView {get}
    func didTapped(isCheck:Bool)
//    func setCheck(isCheck:Bool)
}

public extension MarkCheckable where Self :UIView {
    
    func didTapped(isCheck:Bool) {
        checkMarkView.checked = isCheck
    }
}
