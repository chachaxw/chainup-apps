//
//  EXPersentageTopView.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/7.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXCOPersentageTopView: UIView {
    
    var highlightMode :Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to:CGPoint(x:rect.width, y:rect.height))
        path.lineWidth = 0.5
        UIColor.ThemeView.border .setStroke()
        path.stroke()

//        let path = UIBezierPath.init(roundedRect: rect, byRoundingCorners:[.topRight, .topLeft],
//            cornerRadii: CGSize(width: 2, height: 2))
//        path.lineWidth = 1/UIScreen.main.scale
//        if highlightMode {
//            UIColor.ThemeView.highlight .setStroke()
//        }else {
//            UIColor.ThemeView.border .setStroke()
//        }
//        path.stroke()
    }

}
