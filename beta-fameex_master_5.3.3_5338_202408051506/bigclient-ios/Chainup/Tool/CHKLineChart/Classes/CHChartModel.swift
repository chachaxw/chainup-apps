//
//  CHChartModel.swift
//  CHKLineChart
//
//  Created by Chance on 2023/9/6.
//  Copyright © 2023年 Chance. All rights reserved.
//

import UIKit



/**
Change the trend direction of data
 
-Up: Up
-Down: Down
-Equal: Equal
 */
public enum CHChartItemTrend {
    case up
    case down
    case equal
}

/**
*Data Elements
 */
open class CHChartItem: NSObject {
    
    open var time: Int = 0
    open var openPrice: CGFloat = 0
    open var closePrice: CGFloat = 0
    open var lowPrice: CGFloat = 0
    open var highPrice: CGFloat = 0
    open var vol: CGFloat = 0
    open var value: CGFloat?
    open var extVal: [String: CGFloat] = [String: CGFloat]()        //Extended value, used to record various technical indicators
    
    open var trend: CHChartItemTrend {
        if closePrice == openPrice {
            return .equal
            
        }else{
            //Closing price lower than opening price
            if closePrice < openPrice {
                return .down
            } else {
                //Closing price higher than opening price
                return .up
            }
        }
    }
    
}

/**
*Define Chart Data Model
 */
open class CHChartModel {
    
    ///MARK: - Member variable
    
    //Color of liters
    open var upStyle: (color: UIColor, isSolid: Bool) = (.green, true)
    //Falling Color
    open var downStyle: (color: UIColor, isSolid: Bool) = (.red, true)
    open var titleColor = UIColor.ThemekLine.viewBg                  //The color of the title text
    open var datas: [CHChartItem] = [CHChartItem]()               //Data value
    open var decimal: Int = 2                                     //Length of decimal places
    open var showMaxVal: Bool = false                             //Display maximum value
    open var showMinVal: Bool = false                             //Display minimum value
    open var title: String = ""                                   //title
    open var useTitleColor = true
    open var key: String = ""                                     //The name of the key
    open var ultimateValueStyle: CHUltimateValueStyle = .none       //Max Min Display Style
    //Revised to 1.5
    open var lineWidth: CGFloat = 0.5                                     //line width 
    open var plotPaddingExt: CGFloat =  0.165                     //The proportion of point width occupied by discontinuities between points
  
    open var maxPlotWidth: CGFloat =  40
    open var normalPlotWidth: CGFloat =  10
    open var minDataCount : Int = 41
    
    open var rightOffset:CGFloat = 60

    weak var section: CHSection!
    
    convenience init(
        upStyle: (color: UIColor, isSolid: Bool),
        downStyle: (color: UIColor, isSolid: Bool),
        title: String = "",
        titleColor: UIColor,
        datas: [CHChartItem] = [CHChartItem](),
        decimal: Int = 2,
        plotPaddingExt: CGFloat =  0.165
        ) {
        
        self.init()
        self.upStyle = upStyle
        self.downStyle = downStyle
        self.titleColor = titleColor
        self.title = title
        self.datas = datas
        self.decimal = decimal
        self.plotPaddingExt = plotPaddingExt
    }
    
    /**
Draw dotted lines
     
-Parameter startIndex: Starting index
-Parameter endIndex: End index
-Parameter plotPaddingExt: The proportion of point width occupied by discontinuities between points
     */
    open func drawSerie(_ startIndex: Int, endIndex: Int) -> CAShapeLayer {
        return CAShapeLayer()
    }
}


/**
*Line point style model
 */
open class CHLineModel: CHChartModel {
    
    
    /**
Draw dotted lines
     
-Parameter startIndex: Starting index
-Parameter endIndex: End index
-Parameter plotPaddingExt: The proportion of point width occupied by discontinuities between points
     */
    
    private func RC_randomValueForColor() -> CGFloat {
        let random =  CGFloat(arc4random()).truncatingRemainder(dividingBy: 256) / 255.0
        return random
    }
    
    private func random () -> CGColor {
        return UIColor(red: RC_randomValueForColor(), green: RC_randomValueForColor(), blue: RC_randomValueForColor(), alpha: 1.0).cgColor
    }
    
    open override func drawSerie(_ startIndex: Int, endIndex: Int) -> CAShapeLayer {
        
        let serieLayer = CAShapeLayer()
        
        let modelLayer = CAShapeLayer()
        modelLayer.strokeColor = self.upStyle.color.cgColor
        modelLayer.fillColor = UIColor.clear.cgColor
        modelLayer.lineWidth = self.lineWidth
        modelLayer.lineCap = CAShapeLayerLineCap.round
        modelLayer.lineJoin = CAShapeLayerLineJoin.bevel
        
//        modelLayer.strokeColor = self.random()

        //Interval width of each point
        var plotWidth = (self.section.frame.size.width - self.section.padding.left - self.section.padding.right) / CGFloat(endIndex - startIndex)
        
//        let maxScrennWidth = Device_W - rightOffset
//        let overlapped = (plotWidth * CGFloat(self.datas.count) > maxScrennWidth)
        var hasLastOne = endIndex == self.datas.count

        if self.datas.count < minDataCount {
            plotWidth = normalPlotWidth
            hasLastOne = false
        }
        
        //Draw line segments using bezierPath
        let linePath = UIBezierPath()
        let maskPath = UIBezierPath()
        
        var maxValue: CGFloat = 0       //Item with maximum value
        var maxPoint: CGPoint?          //Coordinates where the maximum value is located
        var minValue: CGFloat = CGFloat.greatestFiniteMagnitude       //Minimum term
        var minPoint: CGPoint?          //Coordinate where the minimum value is located
        
        var finalPoint :CGPoint?
        var isStartDraw = false

        //Cycle start to end
        for i in stride(from: startIndex, to: endIndex, by: 1)    {
            
            //Starting point
            guard let value = self[i].value else {
                continue //Do not paint values that cannot be calculated
            }
            
            //Start X
//            let ix = self.section.frame.origin.x + self.section.padding.left + CGFloat(i - startIndex) * plotWidth
            //End X
            //            let iNx = self.section.frame.origin.x + self.section.padding.left + CGFloat(i + 1 - startIndex) * plotWidth
            let ix = self.section.frame.origin.x + self.section.padding.left + CGFloat(i - startIndex) * plotWidth - (hasLastOne ? rightOffset : 0)

            //Convert specific numerical values to y-values in the coordinate system
            let iys = self.section.getLocalY(value)
            //            let iye = self.section.getLocalY(valueNext!)
            let point = CGPoint(x: ix + plotWidth / 2, y: iys)
            //Start of the first point movement path
            if !isStartDraw {
                linePath.move(to: point)
                maskPath.move(to: CGPoint(x: point.x, y: section.frame.maxY))
                maskPath.addLine(to: point)
                isStartDraw = true
            } else {
                linePath.addLine(to: point)
                maskPath.addLine(to: point)
            }
            
            if i == endIndex {
                finalPoint = point
            }
            
            if i == datas.count - 1,self.key  == "Timeline_Timeline"{
                UIColor.ThemekLine.viewHighlight.setFill()
                let pointLayer = CAShapeLayer.init()
                pointLayer.frame = CGRect(x: point.x - 2 , y: point.y - 2 , width: 4, height: 4)
                pointLayer.cornerRadius = 2
                pointLayer.masksToBounds = true
                //                pointLayer.shadowColor
                pointLayer.backgroundColor = UIColor.ThemekLine.viewHighlight.cgColor
                serieLayer.addSublayer(pointLayer)
            }
            
            //Record maximum value information
            if value > maxValue {
                maxValue = value
                maxPoint = point
            }
            
            //Record minimum value information
            if value < minValue {
                minValue = value
                minPoint = point
            }
        }
        if let max = finalPoint  {
            maskPath.addLine(to: CGPoint(x: max.x, y: section.frame.maxY))
            maskPath.addLine(to: CGPoint(x: max.x, y: section.frame.maxY))
        }else {
            maskPath.addLine(to: CGPoint(x: section.frame.maxX - section.padding.right, y: section.frame.maxY))
            maskPath.addLine(to: CGPoint(x: section.frame.maxX - section.padding.right, y: section.frame.maxY))
        }
        modelLayer.path = linePath.cgPath
        serieLayer.addSublayer(modelLayer)
        
        if self.key  == "Timeline_Timeline" {
            let gradientLayer = CAGradientLayer.init()
            let maskLayer = CAShapeLayer()
            maskLayer.fillColor = UIColor.cyan.withAlphaComponent(0.5).cgColor
            maskLayer.strokeColor = UIColor.clear.cgColor
            maskLayer.lineCap = CAShapeLayerLineCap.round
            maskLayer.lineJoin = CAShapeLayerLineJoin.bevel
            maskLayer.lineWidth = self.lineWidth
            
            maskLayer.path = maskPath.cgPath
            
            gradientLayer.frame = CGRect(x: 0, y: 0, width: section.frame.size.width, height: section.frame.maxY)
            gradientLayer.mask = maskLayer
            gradientLayer.colors = [UIColor.ThemekLine.viewhighlight50.cgColor, UIColor.clear.cgColor]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0, y: 0.6)
            gradientLayer.opacity = 0.8
            serieLayer.addSublayer(gradientLayer)
   
        }

        //Display maximum and minimum values
        if self.showMaxVal && maxValue != 0 {
            let highPrice = maxValue.ch_toString(maxF: section.decimal)
            let maxLayer = self.drawGuideValue(value: highPrice, section: section, point: maxPoint!, trend: CHChartItemTrend.up)
            
            serieLayer.addSublayer(maxLayer)
        }
        
        //Display maximum and minimum values
        if self.showMinVal && minValue != CGFloat.greatestFiniteMagnitude {
            let lowPrice = minValue.ch_toString(maxF: section.decimal)
            let minLayer = self.drawGuideValue(value: lowPrice, section: section, point: minPoint!, trend: CHChartItemTrend.down)
            
            serieLayer.addSublayer(minLayer)
        }
        
        return serieLayer
    }
    
    
}

/**
*Candle Style Model
 */
open class CHCandleModel: CHChartModel {
    
    
    var drawShadow = true
    
    /**
Draw dotted lines
     
-Parameter startIndex: Starting index
-Parameter endIndex: End index
-Parameter plotPaddingExt: The proportion of point width occupied by discontinuities between points
     */
    open override func drawSerie(_ startIndex: Int, endIndex: Int) -> CAShapeLayer {
        
        let serieLayer = CAShapeLayer()
        
        let modelLayer = CAShapeLayer()
        
        //Interval width of each point
        var hasLastOne = endIndex == self.datas.count

        var plotWidth = (self.section.frame.size.width - self.section.padding.left - self.section.padding.right) / CGFloat(endIndex - startIndex)


        
//        let maxScrennWidth = Device_W - rightOffset
//        let overlapped = (plotWidth * CGFloat(self.datas.count) > maxScrennWidth)
//
        if self.datas.count < minDataCount {
//            if !overlapped {
//                plotWidth = normalPlotWidth
//            }
            plotWidth = normalPlotWidth
            hasLastOne = false
           
        }
//        print("CHCandleModel plotWidth = \(plotWidth)")
        var plotPadding = plotWidth * self.plotPaddingExt
        plotPadding = plotPadding < 0.25 ? 0.25 : plotPadding
//        print("CHCandleModel plotPadding = \(plotPadding)")
        var maxValue: CGFloat = 0       //Item with maximum value
        var maxPoint: CGPoint?          //Coordinates where the maximum value is located
        var minValue: CGFloat = CGFloat.greatestFiniteMagnitude       //Minimum term
        var minPoint: CGPoint?          //Coordinate where the minimum value is located
        //Cycle start to end
        for i in stride(from: startIndex, to: endIndex, by: 1) {
            
            if self.key != CHSeriesKey.candle {
                //Not a candle column type, specific values need to be read before drawing
                if self[i].value == nil {       //Read value
                    continue  //Do not paint values that cannot be calculated
                }
            }
            
            var isSolid = true
            let candleLayer = CAShapeLayer()
            var candlePath: UIBezierPath?
            let shadowLayer = CAShapeLayer()
            let shadowPath = UIBezierPath()
            shadowPath.lineWidth = 0
            
            let item = datas[i]
   
            //Start X
            
            let ix = self.section.frame.origin.x + self.section.padding.left + CGFloat(i - startIndex) * plotWidth - (hasLastOne ? rightOffset : 0)
//            print("CHCandleModel start:\(ix)")
            //End X
            let iNx = self.section.frame.origin.x + self.section.padding.left + CGFloat(i + 1 - startIndex) * plotWidth - (hasLastOne ? rightOffset : 0)
//            print("CHCandleModel end:\(iNx)")
            //Convert specific numerical values to y-values in the coordinate system
            let iyo = self.section.getLocalY(item.openPrice)
            let iyc = self.section.getLocalY(item.closePrice)
            let iyh = self.section.getLocalY(item.highPrice)
            let iyl = self.section.getLocalY(item.lowPrice)
            
            switch item.trend {
            case .equal:
                //If the opening and closing are the same, a horizontal line will be displayed
                shadowLayer.strokeColor = self.upStyle.color.cgColor
                isSolid = true
            case .up:
                //If the closing price is higher than the opening price, display the rising color
                shadowLayer.strokeColor = self.upStyle.color.cgColor
                candleLayer.strokeColor = self.upStyle.color.cgColor
                candleLayer.fillColor = self.upStyle.color.cgColor
    
                isSolid = self.upStyle.isSolid
            case .down:
                //If the closing price is lower than the opening price, the color of the decline will be displayed
                shadowLayer.strokeColor = self.downStyle.color.cgColor
                candleLayer.strokeColor = self.downStyle.color.cgColor
                candleLayer.fillColor = self.downStyle.color.cgColor
                isSolid = self.downStyle.isSolid
            }
            
            //1. Draw the lines for the highest and lowest prices first
            if self.drawShadow {
                shadowPath.move(to: CGPoint(x: ix + plotWidth / 2, y: iyh))
                shadowPath.addLine(to: CGPoint(x: ix + plotWidth / 2, y: iyl))
            }
            
            //2. Draw a rectangle for the candle column, with the hollow one covering the line on top
            switch item.trend {
            case .equal:
                //If the opening and closing are the same, a horizontal line will be displayed
                shadowPath.move(to: CGPoint(x: ix + plotPadding, y: iyo))
                shadowPath.addLine(to: CGPoint(x: iNx - plotPadding, y: iyo))
            case .up:
                //If the closing price is higher than the opening price, draw a rectangle downward from the closing Y value
                candlePath = UIBezierPath(rect: CGRect(x: ix + plotPadding, y: iyc, width: plotWidth - 2 * plotPadding, height: iyo - iyc))
                
            case .down:
                //If the closing price is lower than the opening price, draw a rectangle downward from the opening Y value
                candlePath = UIBezierPath(rect: CGRect(x: ix + plotPadding, y: iyo, width: plotWidth - 2 *  plotPadding, height: iyc - iyo))
            }
            
            shadowLayer.path = shadowPath.cgPath
            modelLayer.addSublayer(shadowLayer)
            
            if candlePath != nil {
                
                //If it is customized as hollow, the rectangle needs to be reduced by one circle of lineWidth.
                if isSolid {
                    candleLayer.lineWidth = self.lineWidth
                } else {
//                    candleLayer.fillColor = UIColor.clear.cgColor
                    candleLayer.lineWidth = self.lineWidth
                }
                
                candleLayer.path = candlePath!.cgPath
                modelLayer.addSublayer(candleLayer)
            }
            
            
            
            //Record maximum value information
            if item.highPrice > maxValue {
                maxValue = item.highPrice
                maxPoint = CGPoint(x: ix + plotWidth / 2, y: iyh)
//                print("CHCandleModel maxPoint :\(maxPoint)")
            }
            
            //Record minimum value information
            if item.lowPrice < minValue {
                minValue = item.lowPrice
                minPoint = CGPoint(x: ix + plotWidth / 2, y: iyl)
//                print("CHCandleModel minPoint :\(minPoint)")
            }
            
//            if i == self.datas.count - 1 {
//                let offsetLayer = CAShapeLayer()
//                offsetLayer.strokeColor = UIColor.clear.cgColor
//                offsetLayer.fillColor = UIColor.clear.cgColor
//
//                var offsetLayerPath = UIBezierPath()
//                offsetLayerPath = UIBezierPath(rect: CGRect(x: ix + plotPadding, y: iyo, width: plotWidth - 2 *  plotPadding + rightOffset, height: iyc - iyo))
//                offsetLayer.path = offsetLayerPath.cgPath
//                modelLayer.addSublayer(offsetLayer)
//            }
        }
        
        serieLayer.addSublayer(modelLayer)
        
        var newMinPoint = minPoint
        var newMaxPoint = maxPoint
        if hasLastOne {
            if let minPoint = minPoint,let maxPoint = maxPoint{
                //If sliding to the far left, recalculate the maximum value
                if minPoint.x < 0 || maxPoint.x < 0{ //Found value greater than maximum
                    if minPoint.x < 0{
                        minValue = CGFloat.greatestFiniteMagnitude
                    }
                    if maxPoint.x < 0{
                        maxValue = 0
                    }
                    
                    let offIndexs = ceil(rightOffset / plotWidth)
//                    print("CHCandleModel offIndexs = \(Int(offIndexs))")
                    var newStart =  startIndex + Int(offIndexs)
                    for i in stride(from: newStart, to: endIndex, by: 1){
                        let item = datas[i]
                        let ix = self.section.frame.origin.x + self.section.padding.left + CGFloat(i - newStart) * plotWidth
                        let iyh = self.section.getLocalY(item.highPrice)
                        let iyl = self.section.getLocalY(item.lowPrice)
                        //Record maximum value information
                        if maxPoint.x < 0 {
                            if item.highPrice > maxValue {
                                maxValue = item.highPrice
//                                print("CHCandleModel newHigh-\(maxValue)")
                                newMaxPoint = CGPoint(x: ix + plotWidth / 2, y: iyh)
//                                print("CHCandleModel newMaxPoint-\(newMaxPoint)")
                            }
                        }
                        
                        if minPoint.x < 0 {
                            //Record minimum value information
                            if item.lowPrice < minValue {
                                minValue = item.lowPrice
//                                print("CHCandleModel newHigh-\(minValue)")
                                newMinPoint = CGPoint(x: ix + plotWidth / 2, y: iyl)
//                                print("CHCandleModel newMaxPoint-\(newMinPoint)")
                            }
                        }
                        
                    }
                    
                }
            }
        }
        
        //Display maximum and minimum values
        if self.showMaxVal && maxValue != 0 {
            let highPrice = maxValue.ch_toString(maxF: section.decimal)
            let maxLayer = self.drawGuideValue(value: highPrice, section: section, point: newMaxPoint!, trend: CHChartItemTrend.up)
            serieLayer.addSublayer(maxLayer)
        }
        
        //Display maximum and minimum values
        if self.showMinVal && minValue != CGFloat.greatestFiniteMagnitude {
            let lowPrice = minValue.ch_toString(maxF: section.decimal)
            let minLayer = self.drawGuideValue(value: lowPrice, section: section, point: newMinPoint!, trend: CHChartItemTrend.down)
            serieLayer.addSublayer(minLayer)
        }
        
        return serieLayer
    }
    
}

/**
*Trading volume style model
 */
open class CHColumnModel: CHChartModel {
    
    /**
Draw dotted lines
     
-Parameter startIndex: Starting index
-Parameter endIndex: End index
-Parameter plotPaddingExt: The proportion of point width occupied by discontinuities between points
     */
    open override func drawSerie(_ startIndex: Int, endIndex: Int) -> CAShapeLayer {
        
        let serieLayer = CAShapeLayer()
        
        let modelLayer = CAShapeLayer()
        
        //Interval width of each point
        var hasLastOne = endIndex == self.datas.count
        var plotWidth = (self.section.frame.size.width - self.section.padding.left - self.section.padding.right) / CGFloat(endIndex - startIndex)
 
//        let maxScrennWidth = Device_W - rightOffset
//        let overlapped = (plotWidth * CGFloat(self.datas.count) > maxScrennWidth)
//
        if self.datas.count < minDataCount {
//            if !overlapped {
//                plotWidth = normalPlotWidth
//            }
            plotWidth = normalPlotWidth
            hasLastOne = false
        }

        var plotPadding = plotWidth * self.plotPaddingExt
        plotPadding = plotPadding < 0.25 ? 0.25 : plotPadding
        
        let iybase = self.section.getLocalY(section.yAxis.baseValue)

        //Cycle start to end
        for i in stride(from: startIndex, to: endIndex, by: 1) {
            
            if self.key != CHSeriesKey.volume {
                //Not a candle column type, specific values need to be read before drawing
                if self[i].value == nil {       //Read value
                    continue  //Do not paint values that cannot be calculated
                }
            }
            
            var isSolid = true

            let columnLayer = CAShapeLayer()
            
            let item = datas[i]
            //Start X
//            let ix = self.section.frame.origin.x + self.section.padding.left + CGFloat(i - startIndex) * plotWidth
            
            //Start X
            
            let ix = self.section.frame.origin.x + self.section.padding.left + CGFloat(i - startIndex) * plotWidth - (hasLastOne ? rightOffset : 0)
            
            //Convert specific numerical values to y-values in the coordinate system
            let iyv = self.section.getLocalY(item.vol)
            
            //If the closing price is lower than the opening price, the color of the decline will be displayed
            switch item.trend {
            case .up, .equal:
                //If the closing price is higher than the opening price, display the rising color
                columnLayer.strokeColor = self.upStyle.color.cgColor
                columnLayer.fillColor = self.upStyle.color.cgColor
                isSolid = self.upStyle.isSolid
            case .down:
                columnLayer.strokeColor = self.downStyle.color.cgColor
                columnLayer.fillColor = self.downStyle.color.cgColor
                isSolid = self.downStyle.isSolid
            }
            
            //Draw a rectangle for transaction volume
            var columnPath = UIBezierPath(rect: CGRect(x: ix + plotPadding, y: iyv, width: plotWidth - 2 * plotPadding, height: iybase - iyv))
            columnLayer.path = columnPath.cgPath
            
//            var columnPath = UIBezierPath(rect: CGRect(x: ix + plotPadding, y: iyv, width: 2, height: iybase - iyv))
//            columnLayer.path = columnPath.cgPath

            if isSolid {
                columnLayer.lineWidth = self.lineWidth   //Not set to 0 will cause it to become larger due to anti aliasing processing
            } else {
                columnLayer.fillColor = UIColor.clear.cgColor
                columnLayer.lineWidth = self.lineWidth
            }
            
            
            modelLayer.addSublayer(columnLayer)
        }
        
        serieLayer.addSublayer(modelLayer)
        
        return serieLayer
    }
    
}

/**
*Trading volume style model
 */
open class CHBarModel: CHChartModel {
    
    /**
Draw dotted lines
     
-Parameter startIndex: Starting index
-Parameter endIndex: End index
-Parameter plotPaddingExt: The proportion of point width occupied by discontinuities between points
     */
    open override func drawSerie(_ startIndex: Int, endIndex: Int) -> CAShapeLayer{
        
        let serieLayer = CAShapeLayer()
        
        let modelLayer = CAShapeLayer()
        
        var hasLastOne = endIndex == self.datas.count
        //Interval width of each point
        var plotWidth = (self.section.frame.size.width - self.section.padding.left - self.section.padding.right) / CGFloat(endIndex - startIndex)
        if plotWidth > maxPlotWidth {
            plotWidth = normalPlotWidth
            hasLastOne = false
        }
        var plotPadding = plotWidth * self.plotPaddingExt
        plotPadding = plotPadding < 0.25 ? 0.25 : plotPadding
        
        let iybase = self.section.getLocalY(section.yAxis.baseValue)
        
        //        let context = UIGraphicsGetCurrentContext()
        //        context?.setShouldAntialias(false)
        //        context?.setLineWidth(1)

        //Cycle start to end
        for i in stride(from: startIndex, to: endIndex, by: 1) {
            //            let value = self[i].value
            //
            //            if value == nil{
            //                continue  //Do not paint values that cannot be calculated
            //            }
            var isSolid = true
            let value = self[i].value           //Read value
            if value == nil {
                continue  //Do not paint values that cannot be calculated
            }
            
            let barLayer = CAShapeLayer()
            
            //Start X
//            let ix = self.section.frame.origin.x + self.section.padding.left + CGFloat(i - startIndex) * plotWidth
            let ix = self.section.frame.origin.x + self.section.padding.left + CGFloat(i - startIndex) * plotWidth - (hasLastOne ? rightOffset : 0)

            //Convert specific numerical values to y-values in the coordinate system
            let iyv = self.section.getLocalY(value!)
            
            //If the value is positive
            if value! > 0 {
                //If the closing price is higher than the opening price, display the rising color
                barLayer.strokeColor = self.upStyle.color.cgColor
                barLayer.fillColor = self.upStyle.color.cgColor
            } else {
                barLayer.strokeColor = self.downStyle.color.cgColor
                barLayer.fillColor = self.downStyle.color.cgColor
            }
            
            if i < endIndex - 1, let newValue = self[i + 1].value {
                if newValue >= value! {
                    isSolid = self.upStyle.isSolid
                } else {
                    isSolid = self.downStyle.isSolid
                }
                
            }
            
            if isSolid {
                barLayer.lineWidth = self.lineWidth      //Not set to 0 will cause it to become larger due to anti aliasing processing
            } else {
                barLayer.fillColor = section.backgroundColor.cgColor
                barLayer.lineWidth = self.lineWidth
            }
            
            //Draw a rectangle for transaction volume
            let barPath = UIBezierPath(rect: CGRect(x: ix + plotPadding, y: iyv, width: plotWidth - 2 * plotPadding, height: iybase - iyv))
            
            barLayer.path = barPath.cgPath
            
            
            modelLayer.addSublayer(barLayer)
        }
        
        serieLayer.addSublayer(modelLayer)
        
        return serieLayer
    }
    
}

/**
*Dot style model
 */
open class CHRoundModel: CHChartModel {
    
    
    /**
Draw dotted lines
     
-Parameter startIndex: Starting index
-Parameter endIndex: End index
-Parameter plotPaddingExt: The proportion of point width occupied by discontinuities between points
     */
    open override func drawSerie(_ startIndex: Int, endIndex: Int) -> CAShapeLayer {
        
        let serieLayer = CAShapeLayer()
        
        let modelLayer = CAShapeLayer()
        modelLayer.strokeColor = self.upStyle.color.cgColor
        modelLayer.fillColor = UIColor.clear.cgColor
        modelLayer.lineWidth = self.lineWidth
        modelLayer.lineCap = CAShapeLayerLineCap.round
        modelLayer.lineJoin = CAShapeLayerLineJoin.bevel
        
        //Interval width of each point
        let plotWidth = (self.section.frame.size.width - self.section.padding.left - self.section.padding.right) / CGFloat(endIndex - startIndex)
        var plotPadding = plotWidth * self.plotPaddingExt
        plotPadding = plotPadding < 0.25 ? 0.25 : plotPadding
        
        var maxValue: CGFloat = 0       //Item with maximum value
        var maxPoint: CGPoint?          //Coordinates where the maximum value is located
        var minValue: CGFloat = CGFloat.greatestFiniteMagnitude       //Minimum term
        var minPoint: CGPoint?          //Coordinate where the minimum value is located
        
        //Cycle start to end
        for i in stride(from: startIndex, to: endIndex, by: 1) {
            
            //Starting point
            guard let value = self[i].value else {
                continue //Do not paint values that cannot be calculated
            }
            
            let item = datas[i]
            
            //Start X
            let ix = self.section.frame.origin.x + self.section.padding.left + CGFloat(i - startIndex) * plotWidth
            
            //Convert specific numerical values to y-values in the coordinate system
            let iys = self.section.getLocalY(value)
            
            let roundLayer = CAShapeLayer()
            
            let roundPoint = CGPoint(x: ix + plotPadding, y: iys)
            let roundSize = CGSize(width: plotWidth - 2 * plotPadding, height: plotWidth - 2 * plotPadding)
            let roundPath = UIBezierPath(ovalIn: CGRect(origin: roundPoint, size: roundSize))
            
            roundLayer.lineWidth = self.lineWidth
            roundLayer.path = roundPath.cgPath
            
            //Closing price greater than guidance price
            var fillColor: (color: UIColor, isSolid: Bool)
            if item.closePrice > value {
                fillColor = self.upStyle
            } else {
                fillColor = self.downStyle
            }
            
            roundLayer.strokeColor = fillColor.color.cgColor
            roundLayer.fillColor = fillColor.color.cgColor
            
            //Set to Hollow
            if !fillColor.isSolid {
                roundLayer.fillColor = section.backgroundColor.cgColor
            }
            
            modelLayer.addSublayer(roundLayer)
            
            //Record maximum value information
            if value > maxValue {
                maxValue = value
                maxPoint = roundPoint
            }
            
            //Record minimum value information
            if value < minValue {
                minValue = value
                minPoint = roundPoint
            }
        }
        
        serieLayer.addSublayer(modelLayer)
        
        //Display maximum and minimum values
        if self.showMaxVal && maxValue != 0 {
            let highPrice = maxValue.ch_toString(maxF: section.decimal)
            let maxLayer = self.drawGuideValue(value: highPrice, section: section, point: maxPoint!, trend: CHChartItemTrend.up)
            
            serieLayer.addSublayer(maxLayer)
        }
        
        //Display maximum and minimum values
        if self.showMinVal && minValue != CGFloat.greatestFiniteMagnitude {
            let lowPrice = minValue.ch_toString(maxF: section.decimal)
            let minLayer = self.drawGuideValue(value: lowPrice, section: section, point: minPoint!, trend: CHChartItemTrend.down)
            
            serieLayer.addSublayer(minLayer)
        }
        
        return serieLayer
    }
    
    
}

//MARK: - Extend public methods
public extension CHChartModel {
    
    /**
Paint Max
     */
    public func drawGuideValue(value: String, section: CHSection, point: CGPoint, trend: CHChartItemTrend) -> CAShapeLayer {
        
        let guideValueLayer = CAShapeLayer()
        
        let fontSize = value.ch_sizeWithConstrained(section.labelFont)
        let arrowLineWidth: CGFloat = 10
        var isUp: CGFloat = -1
        var isLeft: CGFloat = -1
        var tagStartY: CGFloat = 0
        var isShowValue: Bool = true        //Whether to display values? The circular style can display only circles without displaying values
        var guideValueTextColor: UIColor = UIColor.ThemekLine.viewBg              //Display maximum and minimum text colors
        //Determine if the painting exceeds the limit when complete
        var maxPriceStartX = point.x + arrowLineWidth * 2
        var maxPriceStartY: CGFloat = 0
        
        if maxPriceStartX  > section.frame.width/2 {
            //Beyond the middle, draw in the opposite direction
            isLeft = -1
            maxPriceStartX = point.x + arrowLineWidth * isLeft * 2 - fontSize.width
        }else {
            isLeft = 1
        }
//        if maxPriceStartX + fontSize.width > section.frame.origin.x + section.frame.size.width - section.padding.right {
//            //If it exceeds the rightmost boundary, draw in the opposite direction
//            isLeft = -1
//            maxPriceStartX = point.x + arrowLineWidth * isLeft * 2 - fontSize.width
//        } else {
//            isLeft = 1
//        }
        
        
        //        context.setShouldAntialias(true)
        //        context.setStrokeColor(self.titleColor.cgColor)
        var fillColor: UIColor = self.upStyle.color
        switch trend {
        case .up:
            fillColor = self.upStyle.color
            isUp = -1
            tagStartY = point.y - (fontSize.height + arrowLineWidth)

            maxPriceStartY = point.y - (fontSize.height + arrowLineWidth / 2)
        case .down:
            fillColor = self.downStyle.color
            isUp = 1
            tagStartY = point.y
            maxPriceStartY = point.y + arrowLineWidth / 2
        default:break
        }
        
/******Draw based on style type******/
        
        switch self.ultimateValueStyle {
        case let .arrow(color):
            
//            let arrowPath = UIBezierPath()
//            let arrowLayer = CAShapeLayer()
//
//            guideValueTextColor = color
//            //Draw small arrows
//            arrowPath.move(to: CGPoint(x: point.x, y: point.y + arrowLineWidth * isUp))
//            arrowPath.addLine(to: CGPoint(x: point.x + arrowLineWidth * isLeft, y: point.y + arrowLineWidth * isUp))
//
//            arrowPath.move(to: CGPoint(x: point.x, y: point.y + arrowLineWidth * isUp))
//            arrowPath.addLine(to: CGPoint(x: point.x, y: point.y + arrowLineWidth * isUp * 2))
//
//            arrowPath.move(to: CGPoint(x: point.x, y: point.y + arrowLineWidth * isUp))
//            arrowPath.addLine(to: CGPoint(x: point.x + arrowLineWidth * isLeft, y: point.y + arrowLineWidth * isUp * 2))
//
//            arrowLayer.path = arrowPath.cgPath
//            arrowLayer.strokeColor = color.cgColor
//
//            guideValueLayer.addSublayer(arrowLayer)
            //Arrow redrawing
            guideValueTextColor = color
            let linePath = UIBezierPath()
            let lineLayer = CAShapeLayer()
            
            if isUp == 1 {
                linePath.move(to: CGPoint(x: point.x, y:(point.y - 1)))
                linePath.addLine(to: CGPoint(x: point.x + arrowLineWidth * isLeft, y: (point.y - 1)))
            }else {
                linePath.move(to: CGPoint(x: point.x, y:(point.y + 1)))
                linePath.addLine(to: CGPoint(x: point.x + arrowLineWidth * isLeft, y: (point.y + 1)))
            }
//            print("CHCandleModel 下划线 CGPoint(x: point.x) =\(point.x) arrowLineWidth = \(arrowLineWidth)")
//            print("CHCandleModel 下划线2 CGPoint(x: point.x) =\(point.x) arrowLineWidth = \(arrowLineWidth)")
            lineLayer.path = linePath.cgPath
            lineLayer.strokeColor = color.cgColor
            guideValueLayer.addSublayer(lineLayer)
        case let .tag(color):
            
            let tagLayer = CAShapeLayer()
            let arrowLayer = CAShapeLayer()
            
            guideValueTextColor = color
            
            let arrowPath = UIBezierPath()
            arrowPath.move(to: CGPoint(x: point.x, y: point.y + arrowLineWidth * isUp))
            arrowPath.addLine(to: CGPoint(x: point.x + arrowLineWidth * isLeft * 2, y: point.y + arrowLineWidth * isUp))
            arrowPath.addLine(to: CGPoint(x: point.x + arrowLineWidth * isLeft * 2, y: point.y + arrowLineWidth * isUp * 3))
            arrowPath.close()
            arrowLayer.path = arrowPath.cgPath
            arrowLayer.fillColor = fillColor.cgColor
            guideValueLayer.addSublayer(arrowLayer)
            
            let tagPath = UIBezierPath(
                roundedRect: CGRect(x: maxPriceStartX - arrowLineWidth, y: tagStartY, width: fontSize.width + arrowLineWidth * 2, height: fontSize.height + arrowLineWidth), cornerRadius: arrowLineWidth * 2)
            //            tagPath.fill()
            
            tagLayer.path = tagPath.cgPath
            tagLayer.fillColor = fillColor.cgColor
            
            guideValueLayer.addSublayer(tagLayer)
            
        case let .circle(color, show):
            
            let circleLayer = CAShapeLayer()
            
            guideValueTextColor = color
            isShowValue = show
            
            let circleWidth: CGFloat = 6
            let circlePoint = CGPoint(x: point.x - circleWidth / 2, y: point.y - circleWidth / 2)
            let circleSize = CGSize(width: circleWidth, height: circleWidth)
            let circlePath = UIBezierPath(ovalIn: CGRect(origin: circlePoint, size: circleSize))
            
            
            //            fillColor.set()
            //            circlePath.stroke()
            //
            //            self.section.backgroundColor.set()
            //            circlePath.fill()
            
            circleLayer.lineWidth = self.lineWidth
            circleLayer.path = circlePath.cgPath
            circleLayer.fillColor = self.section.backgroundColor.cgColor
            circleLayer.strokeColor = fillColor.cgColor
            
            guideValueLayer.addSublayer(circleLayer)
            
        default:
            isShowValue = false
            break
        }
        
        if isShowValue {
            //The text drawn is the height of the k line
            //Calculate the position of drawing text
            let point = CGPoint(x: maxPriceStartX, y: maxPriceStartY)
            let textSize = value.ch_sizeWithConstrained(section.labelFont)
//            let textSize = CGSize(width: Device_W - maxPriceStartX, height: 12)
            //Draw maximum number
            let valueText = CHTextLayer()
            //Originally point, now changed to+height, which block has not been changed correctly, todo is currently y
            var textOrigin = point
            if isUp == 1 {
                textOrigin = CGPoint(x: point.x, y: point.y - (textSize.height + 4))
            }else {
               textOrigin = CGPoint(x:point.x, y: (point.y + (textSize.height + 4)))
            }
            
            valueText.frame = CGRect(origin: textOrigin, size: textSize)
            
            valueText.string = value
            valueText.fontSize = section.labelFont.pointSize
            valueText.foregroundColor =  guideValueTextColor.cgColor
            valueText.backgroundColor = UIColor.clear.cgColor
            valueText.contentsScale = UIScreen.main.scale
            
            guideValueLayer.addSublayer(valueText)
            
            
            //            NSString(string: value)
            //                .draw(at: point,
            //                      withAttributes: fontAttributes)
            
        }
        
        
        return guideValueLayer
        //        context.setShouldAntialias(false)
        
    }
    
}

//MARK: - Factory method pattern
extension CHChartModel {
    
    //Generate a dotted line style
    class func getLine(_ color: UIColor, title: String, key: String) -> CHLineModel {
        let model = CHLineModel(upStyle: (color, true), downStyle: (color, true),
                                titleColor: color)
        model.title = title
        model.key = key
        return model
    }
    
    //Generate a candle style
    class func getCandle(upStyle: (color: UIColor, isSolid: Bool),
                         downStyle: (color: UIColor, isSolid: Bool),
                         titleColor: UIColor,
                         key: String = CHSeriesKey.candle) -> CHCandleModel {
        let model = CHCandleModel(upStyle: upStyle, downStyle: downStyle,
                                  titleColor: titleColor)
        model.key = key
        return model
    }
    
    //Generate a transaction volume style
    class func getVolume(upStyle: (color: UIColor, isSolid: Bool),
                         downStyle: (color: UIColor, isSolid: Bool),
                         key: String = CHSeriesKey.volume) -> CHColumnModel {
        let model = CHColumnModel(upStyle: upStyle, downStyle: downStyle,
                                  titleColor: UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1))
        model.title = NSLocalizedString("Vol", comment: "")
        model.key = key
        return model
    }
    
    //Generate a columnar style
    class func getBar(upStyle: (color: UIColor, isSolid: Bool),
                      downStyle: (color: UIColor, isSolid: Bool),
                      titleColor: UIColor, title: String, key: String) -> CHBarModel {
        let model = CHBarModel(upStyle: upStyle, downStyle: downStyle,
                               titleColor: titleColor)
        model.title = title
        model.key = key
        return model
    }
    
    //Generate a dot style
    class func getRound(upStyle: (color: UIColor, isSolid: Bool),
                        downStyle: (color: UIColor, isSolid: Bool),
                        titleColor: UIColor, title: String,
                        plotPaddingExt: CGFloat,
                        key: String) -> CHRoundModel {
        let model = CHRoundModel(upStyle: upStyle, downStyle: downStyle,
                                 titleColor: titleColor, plotPaddingExt: plotPaddingExt)
        model.title = title
        model.key = key
        return model
    }
}

//MARK: - Extended technical indicator formula
extension CHChartModel {
    
    public subscript (index: Int) -> CHChartItem {
        var value: CGFloat?
        let item = self.datas[index]
        value = item.extVal[self.key]
        item.value = value
        return item
    }
    
}

