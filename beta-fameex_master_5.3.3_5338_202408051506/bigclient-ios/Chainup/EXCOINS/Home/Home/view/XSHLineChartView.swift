//
//  XSHLineChartView.swift
//  XSHLineChart
//
//  Created by 宋莹 on 2023/6/28.
//  Copyright © 2023 Abner. All rights reserved.
//

import UIKit

class XSHLineChartView: UIView {
    
    var granLayer = CAGradientLayer()//Gradient color
    
    var maskLayer = CAShapeLayer()//Fill color
    
    var shapeLayer = CAShapeLayer()//Polyline

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        initLayer()
        addLayer()
    }
    
    func initLayer(){
        granLayer = {//Gradient color
            let tempGranLayer = CAGradientLayer()
            tempGranLayer.colors = [UIColor.ThemeView.highlight.cgColor,UIColor.ThemeView.bg.cgColor]
            tempGranLayer.startPoint = CGPoint(x: 0, y: 0)
            tempGranLayer.endPoint = CGPoint(x: 0, y: 1)
            tempGranLayer.locations = [0.0,1.0]
            tempGranLayer.frame = bounds
            return tempGranLayer
        }()
        maskLayer = {//Fill color
            let tempMask = CAShapeLayer()
            tempMask.fillColor = UIColor.ThemeView.highlight.withAlphaComponent(0.5).cgColor
            tempMask.frame = granLayer.bounds
            return tempMask
        }()
        shapeLayer = {//Polyline
            let tempLayer = CAShapeLayer()
            tempLayer.strokeColor = UIColor.ThemeView.highlight.cgColor
            tempLayer.lineWidth = 0.5
            tempLayer.fillColor = UIColor.clear.cgColor
            tempLayer.frame = bounds
            return tempLayer
        }()
    }
    
    func addLayer(){
        layer.addSublayer(granLayer)
        granLayer.mask = maskLayer
        layer.addSublayer(shapeLayer)
    }
    
    func setLayerFrame(){
        granLayer.frame = bounds
        shapeLayer.frame = bounds
        maskLayer.frame = granLayer.bounds
    }
    
    func setColor(_ color : UIColor){
        granLayer.colors = [color.cgColor , UIColor.ThemeView.bg.cgColor]
        maskLayer.fillColor = color.withAlphaComponent(0.5).cgColor
        shapeLayer.strokeColor = color.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        fatalError("init(coder:) has not been implemented")
    }
    
}

/**Computational drawing*/
extension XSHLineChartView{
    func creatLineChart(XDatasArr:[CGFloat],YDatasArr:[CGFloat]) {
        //1. Remove old view
        self.layer.sublayers?.forEach({ (sublayer) in
            sublayer.removeFromSuperlayer()
        })
        
        //Add New View
        initLayer()
        addLayer()
        
        //2 Calculation
        var minY : CGFloat = CGFloat(MAXFLOAT)
        var maxY : CGFloat = 0
        for i in 0...YDatasArr.count-1 {
            if minY >= YDatasArr[i]{
                minY = YDatasArr[i]
            }
            if maxY <= YDatasArr[i]{
                maxY = YDatasArr[i]
            }
        }
        let YMaxHeight = maxY - minY
        if  YMaxHeight <= 0{return}
        let XMargin:CGFloat = self.frame.size.width/CGFloat(XDatasArr.count - 1)
        let YMargin:CGFloat = self.frame.size.height/YMaxHeight
        
        //3 Draw lines
        let bezierPath = UIBezierPath.init()
        bezierPath.move(to: CGPoint(x: 0, y: (maxY - YDatasArr[0])*YMargin))
        for i in 0...XDatasArr.count-1 {
            let addPoint = CGPoint(x: CGFloat(i)*XMargin, y: (maxY - YDatasArr[i])*YMargin)
            bezierPath.addLine(to: addPoint)
        }
        self.shapeLayer.path = bezierPath.cgPath
        
        //4 Color filling
        bezierPath.addLine(to: CGPoint(x: CGFloat(XDatasArr.count-1)*XMargin, y: self.frame.size.height))
        bezierPath.addLine(to: CGPoint(x: 0, y: self.frame.size.height))
        self.maskLayer.path = bezierPath.cgPath
        
        
        
    }
}

