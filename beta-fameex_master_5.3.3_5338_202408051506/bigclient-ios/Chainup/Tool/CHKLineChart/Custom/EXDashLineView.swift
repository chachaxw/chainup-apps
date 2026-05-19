//
//  EXDashLineView.swift
//  Chainup
//
//  Created by wangdong on 2023/8/31.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit

class EXDashLineView: UIView {

    override func draw(_ rect: CGRect) {
        let context:CGContext = UIGraphicsGetCurrentContext()!
        
        context.setLineCap(CGLineCap.square)
        let lengths:[CGFloat] = [3, 3]
        
        context.setStrokeColor(UIColor.ThemekLine.viewbgIcon.cgColor)
        context.setLineWidth(1)
        context.setLineDash(phase: 0, lengths: lengths)
        context.move(to: CGPoint(x: 0, y: 0))
        context.addLine(to: CGPoint(x: rect.width, y: 0))
        context.strokePath()
    }

}
