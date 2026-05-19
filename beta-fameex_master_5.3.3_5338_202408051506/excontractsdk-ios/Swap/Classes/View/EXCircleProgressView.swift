//
//  EXCircleProgressView.swift
//  Chainup
//
//  Created by cwd on 2022/11/9.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import EXKit
class EXCircleProgressView: UIView {
    var textColor: UIColor = UIColor.ThemekLine.up
    // 灰色静态圆环 English: Grey static circular ring
    var staticLayer: CAShapeLayer!
    // 进度可变圆环 English: Progress Variable Circle
    var arcLayer: CAShapeLayer!
    
    var textLayer: CATextLayer!
    // 为了显示更精细，进度范围设置为 0 ~ 100 English: For more detailed display, the progress range is set to 0~100
    var progress: CGFloat = 0
    override init(frame: CGRect) {
        super.init(frame: frame)
//        debugPrint(#function)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
//        debugPrint(#function)
    }
    
    func setProgress(_ progress: CGFloat) {
        self.progress = progress
        if self.progress >= 100 {
            self.progress = 100
        }
        
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
//        debugPrint(#function)
        if textLayer == nil{
            textLayer = CATextLayer()
            let progerssShow = "\(self.progress)".exs_decimalString(0) + "%"
            textLayer.string = progerssShow //"\(self.progress)%"
            let font = UIFont.ThemeFont.SecondaryRegular
            let fontRef = CGFont.init(font.fontName as CFString)
            textLayer.font = fontRef
            textLayer.fontSize = font.pointSize
            textLayer.contentsScale = UIScreen.main.scale//文字清晰点 English: Clear text points
            textLayer.alignmentMode = .center
            textLayer.backgroundColor = UIColor.ThemeView.bg.cgColor
            textLayer.foregroundColor = self.textColor.cgColor //UIColor.red.cgColor
            let size = CGSize(width: 35, height: 16)
            let x = (self.bounds.width - size.width) * 0.5
            let y = (self.bounds.height - size.height) * 0.5
            let point = CGPoint(x: x, y: y)
            //print("self.bounds = \(self.bounds)")
            //print("point = \(point)")
            textLayer.frame = CGRect(origin:point, size: size)
            self.layer.addSublayer(textLayer)
        }else{
            let progerssShow = "\(self.progress)".exs_decimalString(0) + "%"
            textLayer.string = progerssShow //"\(self.progress)%"
            textLayer.foregroundColor = self.textColor.cgColor
        }
        if staticLayer == nil {
            staticLayer = createLayer(100, UIColor.ThemeView.card2)
            self.layer.addSublayer(staticLayer)
        }
        
        if arcLayer != nil {
            arcLayer.removeFromSuperlayer()
        }
        arcLayer = createLayer(self.progress,self.textColor)
        self.layer.addSublayer(arcLayer)
    }
    
    private func createLayer(_ progress: CGFloat, _ color: UIColor) -> CAShapeLayer {
        let endAngle = -CGFloat.pi / 2 + (CGFloat.pi * 2) * CGFloat(progress) /  100.0
        let layer = CAShapeLayer()
        layer.lineWidth = 4.4
        layer.strokeColor = color.cgColor
        layer.fillColor = UIColor.clear.cgColor
        let radius = self.bounds.width / 2 - layer.lineWidth
        let path = UIBezierPath.init(arcCenter: CGPoint(x: bounds.width / 2, y: bounds.height / 2), radius: radius, startAngle: -CGFloat.pi / 2, endAngle: endAngle, clockwise: true)
        layer.path = path.cgPath
        return layer
    }

}

