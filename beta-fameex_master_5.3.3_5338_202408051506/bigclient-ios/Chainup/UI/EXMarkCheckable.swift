//
//  EXMarkCheckable.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/14.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

enum CheckStyle {
    case checkMark //Show checkmarks
    case checkMarkBig //Display large checkmarks
    case xMark //Show forks
    case xMarkBig //Display large checkmarks

}

class CheckMarkView :UIView {
    var style:CheckStyle = .checkMark
    var presenter:MarkCheckable!
    var highlightColor:UIColor = UIColor.ThemeView.highlight
    var unCheckColor:UIColor = UIColor.ThemeTab.icon
    var checkstrokeColor:UIColor = UIColor.white
    var uncheckstrokeColor:UIColor = UIColor.white
    var checkIcon:UIImageView = UIImageView()
    
    var checkstrokeWidth:CGFloat = 3 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var bgLayer = CAShapeLayer.init()
    var markLayer = CAShapeLayer.init()
    var checked:Bool = false {
        didSet {
            if style != .checkMarkBig {
                checkIcon.isHidden = !checked
            }
            self.setNeedsDisplay()
        }
    }

    required init(style:CheckStyle,isChecked:Bool,presenter:MarkCheckable) {
        super.init(frame: CGRect.zero)
        self.style = style
        self.checked = isChecked
        self.presenter = presenter
        config()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        config()
    }
    
    func config() {
        self.backgroundColor = UIColor.clear
        bgLayer.lineWidth = 0
        bgLayer.strokeColor = checkstrokeColor.cgColor
        bgLayer.fillColor = highlightColor.cgColor
        self.layer .addSublayer(bgLayer)
        self.addSubview(checkIcon)

        if style == .checkMark {
            checkIcon.image = UIImage.themeImageNamed(imageName:"fiat_checkmark")
            checkIcon.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-1)
                make.top.equalToSuperview().offset(4)
            }
        }else if style == .checkMarkBig {
            checkIcon.image = UIImage.themeImageNamed(imageName: "quotes_checkmark_big")
            checkIcon.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(7)
                make.right.equalToSuperview().offset(-4)
            }
        }else if style == .xMark {
            checkIcon.image = UIImage.themeImageNamed(imageName:"fiat_delete")
            checkIcon.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-4)
                make.top.equalToSuperview().offset(6)
            }
        }else if style == .xMarkBig {
            checkIcon.image = UIImage.themeImageNamed(imageName:"personal_delete")
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
    
    @objc func tapped(){
        self.checked = !self.checked
        self.presenter.didTapped(isCheck: self.checked)
    }
    
    override func draw(_ rect: CGRect) {
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

protocol MarkCheckable {
    var checkMarkView:CheckMarkView {get}
    func didTapped(isCheck:Bool)
//    func setCheck(isCheck:Bool)
}

extension MarkCheckable where Self :UIView {
    
    func didTapped(isCheck:Bool) {
        checkMarkView.checked = isCheck
    }
}

