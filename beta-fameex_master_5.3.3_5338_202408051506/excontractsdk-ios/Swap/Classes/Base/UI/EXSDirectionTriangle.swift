//
//  EXDirectionTriangle.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/14.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXSDirectionTriangle: UIView {
    
    var fillColor:UIColor = UIColor.ThemeView.bgIcon
    var highlight:UIColor = UIColor.ThemeLabel.colorLite
    var triangleWidth :CGFloat = 8
    var triangleHeight :CGFloat = 5
    
    var doubleTriangleStyleHeight :CGFloat = 4
    var doubleTriangleGap :CGFloat = 2
    
    var highlightIdx:Int = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }

    var doubleTriangleStyle:Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var isChecked:Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        config()
    }
    
    func config(){
        self.backgroundColor = UIColor.clear
    }
    
    func setDoubleTriangleTapped() {
        highlightIdx += 1
        if highlightIdx > 2 {
            highlightIdx = 0
        }
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        
        fillColor .setFill()
        
        if doubleTriangleStyle {
            let center = CGPoint(x:(self.bounds.size.width - triangleWidth)+triangleWidth/2, y: (self.bounds.size.height)/2)
            self.drawDoubleTriangle(center: center)
        }else {
            let center = CGPoint(x:(self.bounds.size.width - triangleWidth)+triangleWidth/2, y: (self.bounds.size.height - triangleHeight)/2)
            
            self.drawTriangle(upSideDown: isChecked,center:center)
        }
    }
    
    
    func drawTriangle(upSideDown:Bool,center:CGPoint){
        fillColor.setFill()
        let trianglePath = self.trainglePathWithCenter(center: center, checked:upSideDown)
        trianglePath.fill()
    }
    
    func trainglePathWithCenter(center: CGPoint, checked: Bool) -> UIBezierPath {
        let path = UIBezierPath()
        if checked {
            let startX = center.x
            let startY = center.y
            path.move(to: CGPoint(x: startX, y: startY))
            path.addLine(to: CGPoint(x: startX - triangleWidth/2, y: startY+triangleHeight))
            
            path.addLine(to: CGPoint(x:startX + triangleWidth/2, y: startY+triangleHeight))
        }else {
            let startX = center.x - triangleWidth/2
            let startY = center.y
            path.move(to: CGPoint(x: startX, y: startY))
            path.addLine(to: CGPoint(x: startX + triangleWidth/2, y: startY+triangleHeight))
            path.addLine(to: CGPoint(x: startX + triangleWidth, y: startY))
        }
        path.close()
        
        return path
    }
    
    
    func drawDoubleTriangle(center:CGPoint,style:Int = 0) {
        
        let fullheight = doubleTriangleStyleHeight * 2 + doubleTriangleGap
        let path = UIBezierPath()
        let upTriangleX = center.x
        let upTriangleY = center.y - fullheight/2
        path.move(to: CGPoint(x: upTriangleX, y: upTriangleY))
        
        path.addLine(to: CGPoint(x: upTriangleX - triangleWidth/2, y: upTriangleY + doubleTriangleStyleHeight))
        path.addLine(to: CGPoint(x: upTriangleX + triangleWidth/2, y: upTriangleY + doubleTriangleStyleHeight))
        path.close()
        if highlightIdx == 1 {
            highlight.setFill()
        }else {
            fillColor.setFill()
        }
        path.fill()
        
        let downPath = UIBezierPath()
        let downTriangleX = center.x
        let downTriangleY = center.y + fullheight/2
        downPath.move(to: CGPoint(x: downTriangleX, y: downTriangleY))
        
        downPath.addLine(to: CGPoint(x: downTriangleX - triangleWidth/2, y: downTriangleY - doubleTriangleStyleHeight))
        downPath.addLine(to: CGPoint(x: downTriangleX + triangleWidth/2, y: downTriangleY - doubleTriangleStyleHeight))
        downPath.close()
        if highlightIdx == 2 {
            highlight.setFill()
        }else {
            fillColor.setFill()
        }
        downPath.fill()
    }
    

}
