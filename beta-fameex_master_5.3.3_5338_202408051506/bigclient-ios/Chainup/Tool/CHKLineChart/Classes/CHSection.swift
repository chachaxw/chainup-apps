//
//  CHSection.swift
//  CHKLineChart
//
//  Created by Chance on 2023/8/31.
//  Copyright © 2023年 Chance. All rights reserved.
//

import UIKit

///Partition Map Type
public enum CHSectionValueType {
    case master              //Main image
    case assistant             //Subplot
}


/**
*The area of the K line
 */
open class CHSection: NSObject {
    
    ///MARK: - Member variable
    open var upColor: UIColor = UIColor.green     //Color of liters
    open var downColor: UIColor = UIColor.red     //Falling Color
    open var titleColor: UIColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1) //Text color
    open var labelFont = UIFont.systemFont(ofSize: 8)
    open var valueType: CHSectionValueType = CHSectionValueType.master
    open var key = ""
    open var name: String = ""                              //The name of the region
    open var hidden: Bool = false
    open var paging: Bool = false
    open var selectedIndex: Int = 0
    open var padding: UIEdgeInsets = UIEdgeInsets.zero
    open var series = [CHSeries]()                          //Each partition contains multiple sets of series, and each series contains multiple dotted line models
    open var tickInterval: Int = 0
    open var title: String = ""                                      //title
    open var titleShowOutSide: Bool = false                          //Is the title displayed outside
    open var showTitle: Bool = true                                 //Show Title Text
    open var decimal: Int = 2                                       //Length of decimal places
    open var ratios: Int = 0                                         //Proportion of area occupied
    open var fixHeight: CGFloat = 0                                 //Fixed height, if it is 0, calculate the height through ratio
    open var frame: CGRect = CGRect.zero
    open var yAxis: CHYAxis = CHYAxis()                           //Y-axis parameters
    open var xAxis: CHXAxis = CHXAxis()                             //X-axis parameters
    open var backgroundColor: UIColor = UIColor.black
    open var index: Int = 0
    var titleLayer: CHShapeLayer = CHShapeLayer()                           //Display the layer of title content
    var sectionLayer: CHShapeLayer = CHShapeLayer()                 //The drawing layer of the partition
    var titleView: UIView?                                      //User Defined View
    var logo:String?
    ///Initialize partition
    ///
    ///- Parameter valueType: Partition type
    convenience init(valueType: CHSectionValueType, key: String = "") {
        self.init()
        self.valueType = valueType
        self.key = key
    }
    
    
    
}


//MARK: - Internal method
extension CHSection {
    
    ///Clear sub layers of the chart
    func removeLayerView() {
        _ = self.sectionLayer.sublayers?.map { $0.removeFromSuperlayer() }
        self.sectionLayer.sublayers?.removeAll()
        
        _ = self.titleLayer.sublayers?.map { $0.removeFromSuperlayer() }
        self.titleLayer.sublayers?.removeAll()
    }
    
    
    /**
Establish the object on the left side of the Y-axis, from the start position to the end position
     */
    func buildYAxisPerModel(_ model: CHChartModel, startIndex: Int, endIndex: Int) {
        //        print("============ buildYAxisPerModel")
        let datas = model.datas
        if datas.count == 0 {
            return  //No data returned
        }
        
        if !self.yAxis.isUsed {
            self.yAxis.decimal = self.decimal
            
            self.yAxis.max = 0
            self.yAxis.min = CGFloat.greatestFiniteMagnitude
            self.yAxis.isUsed = true
        }
        
        
        for i in stride(from: startIndex, to: endIndex, by: 1) {
            
            
            let item = datas[i]
            
            switch model {
            case is CHCandleModel:
                
                let high = item.highPrice
                let low = item.lowPrice
                
                //Determine each price in the dataset and set the maximum and minimum values to the y-axis object
                if high > self.yAxis.max {
                    self.yAxis.max = high
                }
                if low < self.yAxis.min {
                    self.yAxis.min = low
                }
                
            case is CHLineModel, is CHBarModel:
                
                let value = model[i].value
                
                if value == nil{
                    continue  //Do not paint values that cannot be calculated
                }
                
                //Determine each price in the dataset and set the maximum and minimum values to the y-axis object
                if value! > self.yAxis.max {
                    self.yAxis.max = value!
                }
                if value! < self.yAxis.min {
                    self.yAxis.min = value!
                }
                
            case is CHColumnModel:
                
                let value = item.vol
                
                //Determine each price in the dataset and set the maximum and minimum values to the y-axis object
                if value > self.yAxis.max {
                    self.yAxis.max = value
                }
                if value < self.yAxis.min {
                    self.yAxis.min = value
                }
            default:break
                
            }
        }
        if self.yAxis.max == self.yAxis.min { //when high = low, Dealing with the issue of top edging
            self.yAxis.max = self.yAxis.max * (1 + 0.3)
            self.yAxis.min = self.yAxis.min * 0.7
        }
        if self.yAxis.max == 0 && self.yAxis.min == 0 {
            self.yAxis.max = 1000
        }
#if DEBUG
//        print("section = \(self.key) ")
//        print("=====maxYaxis\(self.yAxis.max)")
//        print("=====minYaxis\(self.yAxis.min)")
#endif
        
    }
    
    ///Draw title information on the header
    ///
    ///- Parameter title: Title content
    func drawTitleForHeader(title: NSAttributedString) {
        
        guard self.showTitle else {
            return
        }
        
        _ = self.titleLayer.sublayers?.map { $0.removeFromSuperlayer() }
        self.titleLayer.sublayers?.removeAll()
        
        var yPos: CGFloat = 0
        var containerWidth: CGFloat = 0
        let font = self.themeHNFont(size: 10)
        let textSize = title.string.ch_sizeWithConstrained(font, constraintRect: CGSize(width: self.frame.width, height: CGFloat.greatestFiniteMagnitude))
        
        if titleShowOutSide {
//            yPos = (self.frame.origin.y - textSize.height)/2
            yPos = 9
            containerWidth = self.frame.width
        } else {
            yPos = self.frame.origin.y + 2
            containerWidth = self.frame.width - self.padding.left - self.padding.right
        }
        
        let startX = self.frame.origin.x + self.padding.left + 2
        
        let point = CGPoint(x: 5, y: yPos)
        
        let titleText = CHTextLayer()
        titleText.frame = CGRect(origin: point, size: CGSize(width: containerWidth, height: textSize.height + 20))
        titleText.string = title
        titleText.fontSize = font.pointSize
        //        titleText.foregroundColor =  self.titleColor.cgColor
        titleText.backgroundColor = UIColor.clear.cgColor
        titleText.contentsScale = UIScreen.main.scale
        titleText.isWrapped = true
        
        self.titleLayer.addSublayer(titleText)
    }
    
    //Switch to the next series display
    func nextPage() {
        if(self.selectedIndex < self.series.count - 1){
            self.selectedIndex += 1
        } else {
            self.selectedIndex = 0
        }
    }
}


//MARK: - Public Method
extension CHSection {
    
    
    ///Establish the numerical range of the Y-axis
    ///
    /// - Parameters:
    ///- startIndex: The starting data point of the calculation range
    ///- endIndex: The end data point of the calculation range
    ///- data: data set
    public func buildYAxis(startIndex: Int,
                           endIndex: Int,
                           datas: [CHChartItem])
    {
        self.yAxis.isUsed = false
        var baseValueSticky = false
        var symmetrical = false
        if self.paging {     //If pagination occurs, calculate the currently selected series as the data source for the coordinate system
            //Establish a coordinate system for each line in the partition
            let serie = self.series[self.selectedIndex]
            baseValueSticky = serie.baseValueSticky
            symmetrical = serie.symmetrical
            for serieModel in serie.chartModels {
                serieModel.datas = datas
                self.buildYAxisPerModel(serieModel,
                                        startIndex: startIndex,
                                        endIndex: endIndex)
            }
        } else {
            for serie in self.series {   //Calculate all series as coordinate system data sources without pagination
                
                //Hidden Not Calculated
                if serie.hidden {
                    continue
                }
                
                baseValueSticky = serie.baseValueSticky
                symmetrical = serie.symmetrical
                for serieModel in serie.chartModels {
                    serieModel.datas = datas
                    self.buildYAxisPerModel(serieModel,
                                            startIndex: startIndex,
                                            endIndex: endIndex)
                }
            }
        }
        
        //Let the boundary overflow a bit so that the chart does not fill the screen
        //        self.yAxis.max += (self.yAxis.max - self.yAxis.min) * self.yAxis.ext
        //        self.yAxis.min -= (self.yAxis.max - self.yAxis.min) * self.yAxis.ext
        
        if !baseValueSticky {        //Do not use fixed base values
            if self.yAxis.max >= 0 && self.yAxis.min >= 0 {
                self.yAxis.baseValue = self.yAxis.min
            } else if self.yAxis.max < 0 && self.yAxis.min < 0 {
                self.yAxis.baseValue = self.yAxis.max
            } else {
                self.yAxis.baseValue = 0
            }
        } else {                                //Using fixed base values
            if self.yAxis.baseValue < self.yAxis.min {
                self.yAxis.min = self.yAxis.baseValue
            }
            
            if self.yAxis.baseValue > self.yAxis.max {
                self.yAxis.max = self.yAxis.baseValue
            }
        }
        
        //If using horizontal symmetry to display the y-axis, calculate the upper and lower boundary values based on the fundamental values
        if symmetrical {
            if self.yAxis.baseValue > self.yAxis.max {
                self.yAxis.max = self.yAxis.baseValue + (self.yAxis.baseValue - self.yAxis.min)
            } else if self.yAxis.baseValue < self.yAxis.min {
                self.yAxis.min =  self.yAxis.baseValue - (self.yAxis.max - self.yAxis.baseValue)
            } else {
                if (self.yAxis.max - self.yAxis.baseValue) > (self.yAxis.baseValue - self.yAxis.min) {
                    self.yAxis.min = self.yAxis.baseValue - (self.yAxis.max - self.yAxis.baseValue)
                } else {
                    self.yAxis.max = self.yAxis.baseValue + (self.yAxis.baseValue - self.yAxis.min)
                }
            }
        }
    }
    
    
    /**
Obtain the y-value corresponding to the label value on the y-axis in the coordinate system
     
-Parameter val: label value
     
-Returns: The actual y-value in the coordinate system
     */
    public func getLocalY(_ val: CGFloat) -> CGFloat {
        let max = self.yAxis.max
        let min = self.yAxis.min
        
        if (max == min) {
            return 0
        }
        
        /*
Calculation formula:
The height of the interval with values on the y-axis=the height of the entire partition - (paddingTop+paddingBottom)
The proportion of the position where the current y value is located=(current value - y minimum value)/(y maximum value - y minimum value)
The actual height of the interval with values relative to the y-axis of the current y-value=the proportion of the position where the current y-value is located * the height of the interval with values on the y-axis
The actual coordinates of the current y-value=partition height+partition y-coordinate - paddingBottom - the actual relative height of the current y-value to the height of the interval with values on the y-axis
         */
        let baseY = self.frame.size.height + self.frame.origin.y - self.padding.bottom - (self.frame.size.height - self.padding.top - self.padding.bottom) * (val - min) / (max - min)
        //        NSLog("baseY(val) = \(baseY)(\(val))")
        //        NSLog("fra.size.height = \(self.frame.size.height)");
        //        NSLog("max = \(max)");
        //        NSLog("min = \(min)");
        return baseY
    }
    
    /**
Obtain the y value corresponding to the y coordinate in the coordinate system
     
     - parameter y:
     
     - returns:
     */
    public func getRawValue(_ y: CGFloat) -> CGFloat {
        let max = self.yAxis.max
        let min = self.yAxis.min
        
        let ymax = self.getLocalY(self.yAxis.min)       //The maximum value of y corresponds to the highest point on the y-axis, then the minimum value
        let ymin = self.getLocalY(self.yAxis.max)       //The minimum value of y corresponds to the lowest point on the y-axis, then the maximum value
        
        if (max == min) {
            return 0
        }
        
        let value = (y - ymax) / (ymin - ymax) * (max - min) + min
        
        return value
    }
    
    /**
Draw the title of the partition
     */
    public func drawTitle(_ chartSelectedIndex: Int) {
        
        guard self.showTitle else {
            return
        }
        
        if chartSelectedIndex == -1 {
            return       //No data returned
        }
        
        if self.paging {     //If pagination
            let series = self.series[self.selectedIndex]
            if let attributes = self.getTitleAttributesByIndex(chartSelectedIndex, series: series) {
                self.setHeader(titles: attributes)
            }
            
            
        } else {
            var titleAttr = [(title: String, color: UIColor)]()
            for serie in self.series {   //No pagination
                if let attributes = self.getTitleAttributesByIndex(chartSelectedIndex, series: serie) {
                    titleAttr.append(contentsOf: attributes)
                }
            }
            
            self.setHeader(titles: titleAttr)
        }
        
        
    }
    
    
    ///Add a user-defined View layer to the main page
    ///
    ///- Parameter view: user-defined view
    public func addCustomView(_ view: UIView, inView mainView: UIView) {
        
        if self.titleView !== view {
            
            //Remove previous views
            self.titleView?.removeFromSuperview()
            self.titleView = nil
            
            var yPos: CGFloat = 0
            var containerWidth: CGFloat = 0
            if titleShowOutSide {
                yPos = self.frame.origin.y - self.padding.top
                containerWidth = self.frame.width
            } else {
                yPos = self.frame.origin.y
                containerWidth = self.frame.width - self.padding.left - self.padding.right
            }
            
            let startX = self.frame.origin.x + self.padding.left
            containerWidth = self.frame.width - self.padding.left - self.padding.right
            
            var frame = view.frame
            frame.origin.x = startX
            frame.origin.y = yPos
            frame.size.width = containerWidth
            view.frame = frame
            
            self.titleView = view
            mainView.addSubview(view)
            
        }
        
        mainView.bringSubviewToFront(self.titleView!)
        
    }
    
    ///Set the display content of partition header text
    ///
    /// - Parameters:
    ///- titles: Text content and color tuples
    public func setHeader(titles: [(title: String, color: UIColor)])  {
        
        var start = 0
        let titleString = NSMutableAttributedString()
        for (title, color) in titles {
            titleString.append(NSAttributedString(string: title))
            let range = NSMakeRange(start, title.ch_length)
            //            NSLog("title = \(title)")
            //            NSLog("range = \(range)")
            let colorAttribute = [NSAttributedString.Key.foregroundColor: color]
            titleString.addAttributes(colorAttribute, range: range)
            start += title.ch_length
        }
        
        self.drawTitleForHeader(title: titleString)
    }
    
    ///Obtain the numerical title of the line segment based on the seriesKey
    ///
    public func getTitleAttributesByIndex(_ chartSelectedIndex: Int, seriesKey: String) -> [(title: String, color: UIColor)]? {
        guard let series = self.getSeries(key: seriesKey) else {
            return nil
        }
        return self.getTitleAttributesByIndex(chartSelectedIndex, series: series)
    }
    
    ///Get Title Attribute Tuple
    ///
    /// - Parameters:
    ///- chartSelectedIndex: Chart selected position
    ///- series: lines
    ///- Returns: Title attribute
    public func getTitleAttributesByIndex(_ chartSelectedIndex: Int, series: CHSeries) -> [(title: String, color: UIColor)]? {
        
        if series.hidden {
            return nil
        }
        
        guard series.showTitle else {
            return nil
        }
        
        if chartSelectedIndex == -1 {
            return nil      //No data returned
        }
        
        var titleAttr = [(title: String, color: UIColor)]()
        
        if !series.title.isEmpty {
            let seriesTitle = series.title + "  "
            
            titleAttr.append((title: seriesTitle, color: self.titleColor))
            
        }
        
        for model in series.chartModels {
            var title = ""
            var textColor: UIColor
            let item = model[chartSelectedIndex]
            switch model {
            case is CHCandleModel:
                
                if model.key != CHSeriesKey.candle {
                    continue  //Unlimited candle column
                }
                
                //amplitude
                var amplitude: CGFloat = 0
                if item.openPrice > 0 {
                    amplitude = (item.closePrice - item.openPrice) / item.openPrice * 100
                }
                
//                
//                title += NSLocalizedString("O", comment: "") + ": " +
//                    item.openPrice.ch_toString(maxF: self.decimal) + "  "   //start
//                title += NSLocalizedString("H", comment: "") + ": " +
//                    item.highPrice.ch_toString(maxF: self.decimal) + "  "   //highest
//                title += NSLocalizedString("L", comment: "") + ": " +
//                    item.lowPrice.ch_toString(maxF: self.decimal) + "  "    //minimum
//                title += NSLocalizedString("C", comment: "") + ": " +
//                    item.closePrice.ch_toString(maxF: self.decimal) + "  "  //Closing
//                title += NSLocalizedString("R", comment: "") + ": " +
//                    amplitude.ch_toString(maxF: self.decimal) + "%   "        //amplitude
                
            case is CHColumnModel:
                
                if model.key != CHSeriesKey.volume {
                    continue  //Not a measuring line
                }
                let str = "\(item.vol)"
                title += model.title + ": " + str.decimalString1(self.decimal) + "  "
//                title += model.title + ": " + item.vol.ch_toString(maxF: self.decimal) + "  "
            default:
                if item.value != nil {
                    let str = "\(item.value!)"
                    title += model.title + ": " + str.decimalString1(self.decimal) + "  "

//                    title += model.title + ": " + item.value!.ch_toString(maxF: self.decimal) + "  "
                }  else {
                    title += model.title + ": --  "
                }
                
            }
            
            if model.useTitleColor {    //Do you want to use title color
                textColor = model.titleColor
            } else {
                switch item.trend {
                case .up, .equal:
                    textColor = model.upStyle.color
                case .down:
                    textColor = model.downStyle.color
                }
            }
            
            titleAttr.append((title: title, color: textColor))
            
        }
        
        return titleAttr
    }
    
    
    ///Find Line Segment Objects
    ///
    ///- Parameter key: unique key for line segments
    ///- Returns: line segment object
    public func getSeries(key: String) -> CHSeries? {
        var series: CHSeries?
        for s in self.series {
            if s.key == key {
                series = s
                break
            }
        }
        return series
    }
    
    
    ///Delete Line Segments
    ///
    ///- Parameter key: segment primary key name
    public func removeSeries(key: String) {
        for (index, s) in self.series.enumerated() {
            if s.key == key {
                self.series.remove(at: index)
                break
            }
        }
    }
}

