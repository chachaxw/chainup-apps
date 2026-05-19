//
//  EXStepBg.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/7.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXStepBg: UIView {

    override func draw(_ rect: CGRect) {
        let height = rect.size.height
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.lineWidth = 1/UIScreen.main.scale
        UIColor.ThemeView.border .setStroke()
        path.stroke()
    }
}

class EXStepLBg: UIView {
    
    override func draw(_ rect: CGRect) {
        let height = rect.size.height
        let path = UIBezierPath()
        let lineWidth = 1/UIScreen.main.scale
        path.move(to: CGPoint(x: rect.width - lineWidth, y: 0))
        path.addLine(to: CGPoint(x: rect.width - lineWidth, y: height))
        path.lineWidth = lineWidth
        UIColor.ThemeView.border .setStroke()
        path.stroke()
    }
}
