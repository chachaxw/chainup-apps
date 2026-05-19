//
//  EXPersentageBottomView.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/7.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXPersentageBottomView: UIView {
    
    var selectIdx:Int = -1 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    
    override func draw(_ rect: CGRect) {
        let width = rect.size.width
        let height = rect.size.height
        let stepWidth = width/4
//        let path = UIBezierPath()
//        path.move(to: CGPoint(x: 0, y: 0))
//        path.addLine(to: CGPoint(x: 0, y: height))
//        path.move(to: CGPoint(x: 0, y: height))
//        path.addLine(to: CGPoint(x:width, y:height))
//        path.move(to: CGPoint(x: width, y: height))
//        path.addLine(to: CGPoint(x:width, y:0))
//        UIColor.ThemeView.border .setStroke()
//        path.stroke()
        
//        let path = UIBezierPath.init(roundedRect: rect, byRoundingCorners:[.bottomLeft, .bottomRight],
//                                     cornerRadii: CGSize(width: 2, height: 2))
//        path.lineWidth = 1/UIScreen.main.scale
//        UIColor.ThemeView.border .setStroke()
//        path.stroke()
        
        for idx in 1...3 {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: stepWidth*CGFloat(idx), y: 0))
            path.addLine(to:CGPoint(x:stepWidth*CGFloat(idx), y:height))
            path.lineWidth = 0.5
            if selectIdx  >= 0 {
                if selectIdx == 0 {
                    if idx == 1 {
                        self.setClearColor()
                    }else {
                        self.setBorderColor()
                    }
                }else if selectIdx == 1 {
                    if idx == 1 || idx == 2 {
                        self.setClearColor()
                    }else {
                        self.setBorderColor()
                    }
                }else if selectIdx == 2 {
                    if idx == 2 || idx == 3 {
                        self.setClearColor()
                    }else {
                        self.setBorderColor()
                    }
                }else {
                    if idx == 3 {
                        self.setClearColor()
                    }else {
                        self.setBorderColor()
                    }
                }
            }else {
                self.setBorderColor()
            }
            path.stroke()
        }
    }
    
    func setClearColor() {
        UIColor.clear.setStroke()
    }
    
    func setBorderColor(){
        UIColor.ThemeView.border .setStroke()
    }
}
