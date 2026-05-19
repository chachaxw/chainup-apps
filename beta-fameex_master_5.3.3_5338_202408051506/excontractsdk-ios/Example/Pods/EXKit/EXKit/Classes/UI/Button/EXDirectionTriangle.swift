//
//  EXDirectionTriangle.swift
//  Chainup
//
//  Created by liuxuan on 2019/3/14.
//  Copyright © 2019 zewu wang. All rights reserved.
//

import UIKit

public class EXDirectionTriangle: UIView {
    
    public var fillColor:UIColor = UIColor.ThemeView.bgIcon
    public var highlight:UIColor = UIColor.ThemeLabel.colorLite
    public var triangleWidth :CGFloat = 8
    public var triangleHeight :CGFloat = 5
    
    public var doubleTriangleStyleHeight :CGFloat = 4
    public var doubleTriangleGap :CGFloat = 2
    
    public var highlightIdx:Int = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }

    public var doubleTriangleStyle:Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public var isChecked:Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        config()
    }
    
    public func config(){
        self.backgroundColor = UIColor.clear
    }
    
    public func setDoubleTriangleTapped() {
        highlightIdx += 1
        if highlightIdx > 2 {
            highlightIdx = 0
        }
        self.setNeedsDisplay()
    }
    
    public override func draw(_ rect: CGRect) {
        
        fillColor .setFill()
        
        if doubleTriangleStyle {
            let center = CGPoint(x:(self.bounds.size.width - triangleWidth)+triangleWidth/2, y: (self.bounds.size.height)/2)
            self.drawDoubleTriangle(center: center)
        }else {
            let center = CGPoint(x:(self.bounds.size.width - triangleWidth)+triangleWidth/2, y: (self.bounds.size.height - triangleHeight)/2)
            
            self.drawTriangle(upSideDown: isChecked,center:center)
        }
    }
    
    
    public func drawTriangle(upSideDown:Bool,center:CGPoint){
        fillColor.setFill()
        let trianglePath = self.trainglePathWithCenter(center: center, checked:upSideDown)
        trianglePath.fill()
    }
    
    public func trainglePathWithCenter(center: CGPoint, checked: Bool) -> UIBezierPath {
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
    
    
    public func drawDoubleTriangle(center:CGPoint,style:Int = 0) {
        
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
