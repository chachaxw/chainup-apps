//
//  CHDepthChartView.swift
//  CHKLineChart
//
//  Created by Chance on 2023/6/26.
//  Copyright © 2023年 bitbank. All rights reserved.
//

import UIKit
import EXKit

///Deep data item type
///
///- bid: buyer's depth
///- ask: seller depth
public enum CHKDepthChartItemType {
    case bid
    case ask
}

///Purchase Order Location Type
///
///- left: Left
///- right: Right
public enum CHKDepthChartOnDirection {
    case left
    case right
}

/**
*Depth Data Element
 */
open class CHKDepthChartItem: NSObject {
    
    open var value: CGFloat = 0                              //numerical value
    open var amount: CGFloat = 0                             //quantity
    open var depthAmount: CGFloat = 0                        //Calculated depth
    open var type: CHKDepthChartItemType = .bid               //data type
  
}

/**
*Deep Chart Data Source Proxy
 */
@objc public protocol CHKDepthChartDelegate: class {
    
    /**
Total number of data sources
     
     - parameter chart:
     
     - returns:
     */
    func numberOfPointsInDepthChart(chart: CHDepthChartView) -> Int
    
    /**
The data source index is the corresponding object
     
     - parameter chart:
-Parameter index: index bit
     
-Returns: K-line data object
     */
    func depthChart(chart: CHDepthChartView, valueForPointAtIndex index: Int) -> CHKDepthChartItem
    
    /**
Obtain the display content of the Y-axis of the chart
     
     - parameter chart:
-Parameter value: The calculated y value
     
     - returns:
     */
    @objc func depthChart(chart: CHDepthChartView, labelOnYAxisForValue value: CGFloat) -> String
    
    
    ///The base value displayed on the y-axis
    ///Users can customize the display of values for the y-axis labels by implementing the method of incrementValueForYAxis,
    ///To achieve a better user experience, for example, if baseValue=0 and incrementValue=10, the y-axis will be displayed as 0, 10, 20, 30, 40...<max
    ///- Parameter depthChart: Chart
    ///- Returns: The value displayed at the beginning
    @objc optional func baseValueForYAxisInDepthChart(in depthChart: CHDepthChartView) -> Double
    
    
    ///The added value of each segment on the y-axis
    ///For example, if baseValue=0 and incrementValue=10, the y-axis will be displayed as 0, 10, 20, 30, 40...<max
    ///- Parameter depthChart: Chart
    ///- Returns: Incremental
    @objc optional func incrementValueForYAxisInDepthChart(in depthChart: CHDepthChartView) -> Double
    
    /**
Obtain the display content of the X-axis of the chart
     
     - parameter chart:
-Parameter index: index bit
     
     - returns:
     */
    @objc optional func depthChart(chart: CHDepthChartView, labelOnXAxisForIndex index: Int) -> String
    
    /**
Complete drawing chart
     
     */
    @objc optional func didFinishDepthChartRefresh(chart: CHDepthChartView)
    
    ///Set the width of the y-axis label
    ///
    /// - parameter chart:
    ///
    /// - returns:
    @objc optional func widthForYAxisLabelInDepthChart(in depthChart: CHDepthChartView) -> CGFloat
    
    
    ///Click on the chart column to respond to the method
    ///
    /// - Parameters:
    ///- chart: chart
    ///- point: The location of the click
    ///- item: data object
    @objc optional func depthChart(chart: CHDepthChartView,Selected item: CHKDepthChartItem,At point:CGPoint)
    
    
    ///Layout height of the X-axis
    ///
    ///- Parameter chart: Chart
    ///- Returns: Returns the customized height
    @objc optional func heightForXAxisInDepthChart(in depthChart: CHDepthChartView) -> CGFloat
    
    /**
Decimal length of price
     
     - parameter chart:
     
     - returns:
     */
    @objc func depthChartOfDecimal(chart: CHDepthChartView) -> Int
    
    /**
Decimal length of quantity
     
     - parameter chart:
     
     - returns:
     */
    @objc func depthChartOfVolDecimal(chart: CHDepthChartView) -> Int
    
    /**
Custom click to display information view
     - parameter chart:
     
     - returns:
     */
    @objc optional func depthChartShowItemView(chart: CHDepthChartView,Selected item: CHKDepthChartItem) -> UIView?
    
    /**
Custom click to select view
     - parameter chart:
     
     - returns:
     */
    @objc optional func depthChartTagView(chart: CHDepthChartView,Selected item: CHKDepthChartItem) -> UIView?
    @objc optional func depthChartOfNeedCalculateDepth(chart:CHDepthChartView) -> Bool
}

open class CHDepthChartView: UIView {
    
    ///MARK: - Constant
    public let kYAxisLabelWidth: CGFloat = 46        //Default width
    public let kXAxisHegiht: CGFloat = 16        //The height of the default X coordinate
    
    ///MARK: - Member variable
    open var bidColor: (stroke: UIColor, fill: UIColor, lineWidth: CGFloat) = (.green, .green, 1)
    open var askColor: (stroke: UIColor, fill: UIColor, lineWidth: CGFloat) = (.red, .red, 1)
    @IBInspectable open var labelFont = UIFont.systemFont(ofSize: 10)
    @IBInspectable open var lineColor: UIColor = UIColor(white: 0.2, alpha: 1) //line color
    @IBInspectable open var textColor: UIColor = UIColor(white: 0.8, alpha: 1) //Text color
    @IBInspectable open var xAxisPerInterval: Int = 4                        //Number of discontinuities on the x-axis
    
    open var yAxis: CHYAxis = CHYAxis()                           //Y-axis parameters
    open var xAxis: CHXAxis = CHXAxis()                             //X-axis parameters
    open var yAxisLabelWidth: CGFloat = 0                    //Width of Y-axis
    
    ///Decimal Digits of Price
    private var decimal: Int = 2
    
    ///Quantity decimal places
    private var numDecimal:Int = 4
    
    ///Inner margin
    open var padding: UIEdgeInsets = UIEdgeInsets.zero
    
    ///Display the position of y, default to the right
    open var showYAxisLabel = CHYAxisShowPosition.right
    
    ///Is the y-coordinate embedded in the chart
    open var isInnerYAxis: Bool = false
    
    ///The bill is on the right
    open var bidChartOnDirection: CHKDepthChartOnDirection = .right
    
    ///Display X-axis labels
    open var showXAxisLabel: Bool = true
    
    ///Proxy
    @IBOutlet open weak var delegate: CHKDepthChartDelegate?
    
    //Can I click to select
    open var enableTap: Bool = true
    
    ///Show edges with upper and lower left edges
    open var borderWidth: (top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) = (0.25, 0.25, 0.25, 0.25)
    
    var lineWidth: CGFloat = 0.5
    
    ///Number of gears
    var plotCount: Int = 0
    
    open var labelSize = CGSize(width: 40, height: 16)
    
    ///Click on the selected point
    var selectedPoint: CGPoint = CGPoint.zero
    
    ///Click on the selected marker graphic
    var selectedTagGraphslayer:CHShapeLayer?
    
    //Mark the shape of the selected center
    var selectedTagCenterlayer:CHShapeLayer?
    
    ///Click on the selected data point to view
    var selectedItemInfoLayer:CHShapeLayer?
    
    //X-axis
    var selectedItemXLayer:CHShapeLayer?
    
    //Y-axis
    var selectedItemYLayer:CHShapeLayer?
    
    
    //Can it slide
    var enablePan = true
    
    //Interval width of each point
    var plotWidth: CGFloat {
        if self.plotCount > 0 {
            return (self.bounds.size.width - self.padding.left - self.padding.right) / CGFloat(self.plotCount)
        } else {
            return 0
        }
    }
    
    ///Buyer Deep Data
    open var bidItems = [CHKDepthChartItem]()
    
    ///Seller's Deep Data
    open var askItems = [CHKDepthChartItem]()
    
    ///Layer used for charts
    var drawLayer: CHShapeLayer = CHShapeLayer()
    
    open var style: CHKLineChartStyle! {           //Display Style
        didSet {
            //Reconfigure Style
            self.backgroundColor = self.style.backgroundColor
            self.padding = self.style.padding
            self.lineColor = self.style.lineColor
            self.textColor = self.style.textColor
            self.labelFont = self.style.labelFont
            self.showYAxisLabel = self.style.showYAxisLabel
            self.isInnerYAxis = self.style.isInnerYAxis
            self.enableTap = self.style.enableTap
            self.showXAxisLabel = self.style.showXAxisLabel
            self.borderWidth = self.style.borderWidth
            self.bidColor = self.style.bidColor
            self.askColor = self.style.askColor
            self.bidChartOnDirection = self.style.bidChartOnDirection
            self.enablePan = self.style.enablePan
        }
        
    }
    
    var showInfo = false
    
    //MARK: - Initialize
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initUI()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //self.initUI()
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.initUI()
    }
    
    
    /**
Initialize UI
     
     - returns:
     */
    fileprivate func initUI() {
        
        //Paint Layer
        self.layer.addSublayer(self.drawLayer)
        
        
        //Click gesture operation
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(doTapAction(_:)))
        tap.delegate = self
        self.addGestureRecognizer(tap)
        
        let long = UILongPressGestureRecognizer.init(target: self, action: #selector(doLongAction))
        long.delegate = self
        self.addGestureRecognizer(long)
        
        //Initial data
        self.resetData()
        
    }
    
    //MARK: - Internal method
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        //Layout complete redraw
        self.drawLayerView()
    }
    
    /**
Initialize data
     */
    fileprivate func resetData() {
        self.bidItems.removeAll()
        self.askItems.removeAll()
        self.plotCount = self.delegate?.numberOfPointsInDepthChart(chart: self) ?? 0
        self.decimal = self.delegate?.depthChartOfDecimal(chart: self) ?? 4
        self.numDecimal = self.delegate?.depthChartOfVolDecimal(chart: self) ?? 4
        
        if plotCount > 0 {
            
            //Obtain the data source on the agent
            for i in 0...self.plotCount - 1 {
                guard let item = self.delegate?.depthChart(chart: self, valueForPointAtIndex: i) else {
                    continue
                }
                switch item.type {
                case .bid:
                    self.bidItems.append(item)
                case .ask:
                    self.askItems.append(item)
                }
            }
            
            //Calculate depth quantity
            self.computeDepthValue(for: self.bidItems, type: .bid)
            self.computeDepthValue(for: self.askItems, type: .ask)
            
        }
    }
    
    
    ///Calculate the depth of each element based on the dataset
    ///
    ///- Parameter item: Dataset
    fileprivate func computeDepthValue(for items: [CHKDepthChartItem], type: CHKDepthChartItemType) {
        
        var depth: CGFloat = 0
        var start = 0, end = 0, step = 1
        if self.style.bidChartOnDirection == .left{
            if type == .bid {
                //The depth of the purchase order is accumulated from high to low prices
                start = items.count - 1
                end = 0
                step = -1
            } else {
                //The depth of selling orders accumulates from the highest to lowest price
                start = 0
                end = items.count - 1
                step = 1
            }
        }else{
            if type == .ask {
                //The depth of selling orders accumulates from the highest to lowest price
                start = items.count - 1
                end = 0
                step = -1
            } else {
                //The depth of the purchase order is accumulated from high to low prices
                start = 0
                end = items.count - 1
                step = 1
            }
        }
        
        if self.delegate?.depthChartOfNeedCalculateDepth?(chart: self) == false {return}
        for i in stride(from: start, through: end, by: step) {
            let item = items[i]
            let amount = item.amount
            depth = depth + amount
            item.depthAmount = depth
            
        }
    }
    
    
    /**
Set selected data points
     
     - parameter point:
     */
    func setSelectedIndexByPoint(_ point: CGPoint) {
        
        
        guard self.enableTap || self.enablePan else {
            return
        }
        
        guard self.plotCount > 0 else {
            return
        }
        
        if point.equalTo(CGPoint.zero) {
            return
        }
        
        //Left spacing
        let leftPadding = self.bounds.origin.x + self.padding.left
        
        //Calculate whether the clicked points are on the depth map, and clicking the edges on both sides is not included in the clicked range
        if (point.x - leftPadding) <= 0 || (point.x - (self.plotWidth * CGFloat(self.plotCount)) - leftPadding >= 0){
            return
        }
        
        self.selectedPoint = point
        
        //Click Range
        let xRange:CGFloat = point.x - leftPadding
        
        //Data subscript
        var index = -1
        
        //Obtain the remainder and use it to locate which data is the first
        let remainder = xRange.truncatingRemainder(dividingBy: self.plotWidth)
        
        if remainder != 0{
            index = Int(xRange / self.plotWidth) + 1
        }else{
            index = Int(xRange / self.plotWidth)
        }
//Print ("Click depth index= (index)")
        
        //Click on the selected item
        var selectedItem:CHKDepthChartItem?
        //Determine whether to pay or sell the bill
        if self.bidChartOnDirection == .left{
            if index <= self.bidItems.count{
                selectedItem = self.bidItems[index - 1]
            }else{
                selectedItem = self.askItems[index - self.bidItems.count - 1]
            }
        }else{
            if index <= self.askItems.count{
                selectedItem = self.askItems[index - 1]
            }else{
                selectedItem = self.bidItems[index - self.askItems.count - 1]
            }
        }
        
        guard let item = selectedItem else{
            return
        }
        
        //Obtain y based on value
        let y = self.getLocalY(item.depthAmount)
//Print ("Click depth y== (y)")
        
        //Select the coordinates of the marked graphic
        let tagGraphsPoint:CGPoint = CGPoint(x: point.x, y: y)
        
        //Draw a checkmark graphic
        self.drawTagGraph(point: tagGraphsPoint,item:item)
        
        //Draw X-axis information
        self.drawItemInfoX(point: tagGraphsPoint, item: item)
        //Draw Y-axis information
        self.drawItemInfoY(point: tagGraphsPoint, item: item)
//        //Draw display information
//        self.drawItemInfo(point: tagGraphsPoint,item:item)
        
        
    }
    
    /**
Obtain the y-value corresponding to the label value on the y-axis in the coordinate system
     
-Parameter val: label value
     
-Returns: The actual y-value in the coordinate system
     */
    func getLocalY(_ val: CGFloat) -> CGFloat {
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
        let baseY = self.bounds.maxY - self.padding.bottom - (self.bounds.size.height - self.padding.top - self.padding.bottom) * (val - min) / (max - min)
        //        NSLog("self.bounds.size.height - self.padding.top - self.padding.bottom = \(self.bounds.size.height - self.padding.top - self.padding.bottom)")
        //        NSLog("fra.size.height = \(self.bounds.size.height)");
        //        NSLog("self.bounds.maxY = \(self.bounds.maxY)");
        //        NSLog("(self.padding.bottom) = \(self.padding.bottom)");
        //        NSLog("(val - min) = \((val - min))");
        //        NSLog("max - min = \(max - min)");
        //        NSLog("max = \(max)");
        //        NSLog("min = \(min)");
        //        NSLog("baseY = \(baseY)");
        return baseY
    }
    
    /**
Obtain the y value corresponding to the y coordinate in the coordinate system
     
     - parameter y:
     
     - returns:
     */
    func getRawValue(_ y: CGFloat) -> CGFloat {
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
    
}

//MARK: - Drawing related methods
extension CHDepthChartView {
    
    
    ///Clear sub layers of the chart
    func removeLayerView() {
        _ = self.drawLayer.sublayers?.map { $0.removeFromSuperlayer() }
        self.drawLayer.sublayers?.removeAll()
        //        _ = self.bidsLayer.sublayers?.map { $0.removeFromSuperlayer() }
        //        self.bidsLayer.sublayers?.removeAll()
        //        _ = self.asksLayer.sublayers?.map { $0.removeFromSuperlayer() }
        //        self.asksLayer.sublayers?.removeAll()
    }
    
    ///Drawing charts through CALayer
    func drawLayerView() {
        
        //Clear the layer first
        self.removeLayerView()
        
        
        ///X coordinate label to be drawn
        var xAxisToDraw = [(CGRect, String)]()
        
        //Draw Chart Frame
        self.drawChartFrame()
        
        //Initial Y-axis data
        self.initXYAxis()
        
        //Draw the Y-axis coordinate system, but the final y-axis label is not made until the line segment is drawn
        let yAxisToDraw = self.drawYAxis()
        self.drawXAxis()
        //Draw the X-axis coordinate system, first draw the auxiliary line, record the label position,
        //Return and finally draw on the partition that needs to be displayed
        //        xAxisToDraw = self.drawXAxis(section)
        
        //Draw dotted lines for charts
        xAxisToDraw = self.drawChart()
        
        //Draw labels on Y-axis coordinates
        self.drawYAxisLabel(yAxisToDraw)
        
        //Draw X-axis coordinates below the partition
        self.drawXAxisLabel(xAxisToDraw: xAxisToDraw)
        
        //Redisplay the coordinates selected by clicking
        self.setSelectedIndexByPoint(self.selectedPoint)
        
        self.delegate?.didFinishDepthChartRefresh?(chart: self)
        
    }
    
    
    /**
Draw Chart Box
     
-Returns: Whether to initialize data
     */
    fileprivate func drawChartFrame() {
        
        let backgroundLayer = CHShapeLayer()
        let backgroundPath = UIBezierPath(rect: self.bounds)
        backgroundLayer.path = backgroundPath.cgPath
        backgroundLayer.fillColor = self.backgroundColor?.cgColor
        self.drawLayer.addSublayer(backgroundLayer)
        
        if EXThemeManager.isNight() {
            let gradLayer = CAGradientLayer()
            gradLayer.frame = self.bounds
            gradLayer.colors = [
                UIColor.extColorWithHex("#010101").cgColor,
                UIColor.extColorWithHex("#111111").cgColor,
            ]
            self.drawLayer.addSublayer(gradLayer)
        }
        
        self.yAxisLabelWidth = self.delegate?.widthForYAxisLabelInDepthChart?(in: self) ?? self.kYAxisLabelWidth
        
        //Label display orientation on the y-axis
        switch self.showYAxisLabel {
        case .left:         //Left display
            self.padding.left = self.isInnerYAxis ? self.padding.left : self.yAxisLabelWidth
            self.padding.right = 0
        case .right:        //Display on the right
            self.padding.left = 0
            self.padding.right = self.isInnerYAxis ? self.padding.right : self.yAxisLabelWidth
        case .none:         //Not displayed
            self.padding.left = 0
            self.padding.right = 0
        }
        
        let borderPath = UIBezierPath()
        
        //Draw lower edge lines
        if self.borderWidth.bottom > 0 {
            
            borderPath.append(UIBezierPath(rect: CGRect(x: self.bounds.origin.x + self.padding.left, y: self.bounds.size.height + self.bounds.origin.y, width: self.bounds.size.width - self.padding.left, height: self.borderWidth.bottom)))
            
        }
        
        //Draw top edge line
        if self.borderWidth.top > 0 {
            
            borderPath.append(UIBezierPath(rect: CGRect(x: self.bounds.origin.x + self.padding.left, y: self.bounds.origin.y, width: self.bounds.size.width - self.padding.left, height: self.borderWidth.top)))
            
        }
        
        
        //Draw left line
        if self.borderWidth.left > 0 {
            
            borderPath.append(UIBezierPath(rect: CGRect(x: self.bounds.origin.x + self.padding.left, y: self.bounds.origin.y, width: self.borderWidth.left, height: self.bounds.size.height)))
            
        }
        
        
        //Draw right line
        if self.borderWidth.right > 0 {
            
            borderPath.append(UIBezierPath(rect: CGRect(x: self.bounds.origin.x + self.bounds.size.width - self.padding.right, y: self.bounds.origin.y, width: self.borderWidth.left, height: self.bounds.size.height)))
            
        }
        
        //Add to Layer
        let borderLayer = CHShapeLayer()
        borderLayer.lineWidth = self.lineWidth
        borderLayer.path = borderPath.cgPath  //Obtaining Shape from Bezier Curve
        borderLayer.fillColor = self.lineColor.cgColor //Color of closed-loop filling
        self.drawLayer.addSublayer(borderLayer)
        
        
    }
    
    
    /**
Initialize the value of the XY axis on the partition
     */
    fileprivate func initXYAxis() {
        
        //Add deep data
        var datas = [CHKDepthChartItem]()
        datas.append(contentsOf: self.bidItems)
        datas.append(contentsOf: self.askItems)
        
        guard datas.count > 0 else {
            return  //No data returned
        }
        
        //Calculate the maximum and minimum values of the y-axis
        //Calculate the maximum and minimum values of the x-axis
        self.yAxis.decimal = self.decimal
        self.yAxis.max = 0
        //        self.yAxis.min = CGFloat.greatestFiniteMagnitude
        self.yAxis.min = 0
        
        
        //Calculate minimum and maximum values
        for item in datas {
            
            //Determine each price in the dataset and set the maximum and minimum values to the y-axis object
            if item.depthAmount > self.yAxis.max {
                self.yAxis.max = item.depthAmount
            }
            if item.depthAmount < self.yAxis.min {
                self.yAxis.min = item.depthAmount
            }
        }
        
        //If there is a basic value
        guard let baseValue = self.delegate?.baseValueForYAxisInDepthChart?(in: self) else {
            return
        }
        
        self.yAxis.baseValue = CGFloat(baseValue)
        if self.yAxis.baseValue < self.yAxis.min {
            self.yAxis.min = self.yAxis.baseValue
        }
        
        if self.yAxis.baseValue > self.yAxis.max {
            self.yAxis.max = self.yAxis.baseValue
        }
        
    }
    
    
    fileprivate func drawXAxis() {
        
        var showYAxisReference: Bool = true
        let stepWidth: CGFloat = self.frame.size.width/5       //Incremental value
        let steps:Int = 4
        let startY:CGFloat = self.bounds.minY
        
        //Execute drawing
        for step in 0...steps {
            //Draw dashed lines and Y label values
            let referencePath = UIBezierPath()
            let referenceLayer = CHShapeLayer()
            referenceLayer.lineWidth = self.lineWidth
            
            //Working with Guide Styles
            switch self.yAxis.referenceStyle {
            case let .dash(color: dashColor, pattern: pattern):
                referenceLayer.strokeColor = dashColor.cgColor
                referenceLayer.lineDashPattern = pattern
                showYAxisReference = true
            case let .solid(color: solidColor):
                referenceLayer.strokeColor = solidColor.cgColor
                showYAxisReference = true
            default:
                showYAxisReference = false
            }
            
            if showYAxisReference {
                
                referencePath.move(to: CGPoint(x: self.bounds.origin.x + self.padding.left + stepWidth*CGFloat(step), y: startY))
                referencePath.addLine(to: CGPoint(x: self.bounds.origin.x + self.padding.left + stepWidth*CGFloat(step), y: self.bounds.maxY - self.padding.bottom))
                
                referenceLayer.path = referencePath.cgPath
                self.drawLayer.addSublayer(referenceLayer)
            }
        }
    }
    
    /**
Draw the left side of the Y-axis
     
-Parameter section: partition
     */
    fileprivate func drawYAxis() -> [(CGRect, String)] {
        
        var yAxisToDraw = [(CGRect, String)]()
        var valueToDraw = Set<CGFloat>()
        
        var startX: CGFloat = 0, startY: CGFloat = self.padding.top, extrude: CGFloat = 0
        var showYAxisLabel: Bool = true
        var showYAxisReference: Bool = true
        
        //The labels of each y-axis dashed line and y-axis in the partition
        //Control whether the label of the y-axis is displayed on the left or right
        switch self.showYAxisLabel {
        case .left:
            startX = self.bounds.origin.x - 3 * (self.isInnerYAxis ? -1 : 1)
            extrude = self.bounds.origin.x + self.padding.left - 2
        case .right:
            startX = self.bounds.maxX - self.yAxisLabelWidth + 3 * (self.isInnerYAxis ? -1 : 1)
            extrude = self.bounds.origin.x + self.padding.left + self.bounds.size.width - self.padding.right
            
        case .none:
            showYAxisLabel = false
        }
        
        
        var yaxis = self.yAxis
        var step: CGFloat = 0       //Incremental value
        //Calculate y-axis discontinuous increment
        if let increaseValue = self.delegate?.incrementValueForYAxisInDepthChart?(in: self) {
            
            step = CGFloat(increaseValue)
            
        } else {
            
            //Maintain even number of Y-axis labels displayed
            if (yaxis.tickInterval % 2 == 1) {
                yaxis.tickInterval += 1
            }
            
            //Calculate how many segments the y-axis labels and dashed lines are divided into
            step = (yaxis.max - yaxis.min) / CGFloat(yaxis.tickInterval)
            
        }
        
        
        
        //Draw the Y-axis label from the base value to the maximum value, and record the y-axis value that needs to be drawn
        var yVal = yaxis.baseValue
        while yVal <= yaxis.max * 1.2 && step > 0 {
            
            valueToDraw.insert(yVal)
            
            //Increment Next
            yVal = yVal + step
        }
        
        //Execute drawing
        for yVal in valueToDraw {
            
            
            //Draw dashed lines and Y label values
            let iy = self.getLocalY(yVal)
            
            if self.isInnerYAxis {
                //The y-axis label is displayed inward, so to avoid blocking the auxiliary line, the numerical position of the y-axis is moved up a bit
                startY = iy - 14
            } else {
                startY = iy - 7
            }
            
            let referencePath = UIBezierPath()
            let referenceLayer = CHShapeLayer()
            referenceLayer.lineWidth = self.lineWidth
            
            //Working with Guide Styles
            switch self.yAxis.referenceStyle {
            case let .dash(color: dashColor, pattern: pattern):
                referenceLayer.strokeColor = dashColor.cgColor
                referenceLayer.lineDashPattern = pattern
                showYAxisReference = true
            case let .solid(color: solidColor):
                referenceLayer.strokeColor = solidColor.cgColor
                showYAxisReference = true
            default:
                showYAxisReference = false
                startY = iy - 7
            }
            
            if showYAxisReference {
                
                //Highlighted line segments are only drawn when the y-axis is displayed outward
                if !self.isInnerYAxis {
                    referencePath.move(to: CGPoint(x: extrude, y: iy))
                    referencePath.addLine(to: CGPoint(x: extrude + 2, y: iy))
                }
                
                referencePath.move(to: CGPoint(x: self.bounds.origin.x + self.padding.left, y: iy))
                referencePath.addLine(to: CGPoint(x: self.bounds.origin.x + self.bounds.size.width - self.padding.right, y: iy))
                
                referenceLayer.path = referencePath.cgPath
                self.drawLayer.addSublayer(referenceLayer)
            }
            
            if showYAxisLabel {
                
                //Obtain the label string value of the caller callback
                let strValue = self.delegate?.depthChart(chart: self, labelOnYAxisForValue: yVal) ?? ""
                
                let yLabelRect = CGRect(x: startX,
                                        y: startY,
                                        width: yAxisLabelWidth,
                                        height: 12
                )
                
                yAxisToDraw.append((yLabelRect, strValue))
                
            }
            
        }
        
        return yAxisToDraw
    }
    
    
    ///Draw labels on y-axis coordinates
    ///
    /// - Parameter yAxisToDraw:
    fileprivate func drawYAxisLabel(_ yAxisToDraw: [(CGRect, String)]) {
        
        var alignmentMode = CATextLayerAlignmentMode.left
        //The labels of each y-axis dashed line and y-axis in the partition
        //Control whether the label of the y-axis is displayed on the left or right
        switch self.showYAxisLabel {
        case .left:
            alignmentMode = self.isInnerYAxis ? CATextLayerAlignmentMode.left : CATextLayerAlignmentMode.right
        case .right:
            alignmentMode = self.isInnerYAxis ? CATextLayerAlignmentMode.right : CATextLayerAlignmentMode.left
        case .none:
            alignmentMode = CATextLayerAlignmentMode.left
        }
        
        for (yLabelRect, strValue) in yAxisToDraw {
            
            let yAxisLabel = CHTextLayer()
            yAxisLabel.frame = yLabelRect
            yAxisLabel.string = NumberHandler.privateDealDataFormate(strValue)
            yAxisLabel.fontSize = self.labelFont.pointSize
            yAxisLabel.foregroundColor =  self.textColor.cgColor
            yAxisLabel.backgroundColor = UIColor.clear.cgColor
            yAxisLabel.alignmentMode = alignmentMode
            yAxisLabel.contentsScale = UIScreen.main.scale
            
            self.drawLayer.addSublayer(yAxisLabel)
            
        }
    }
    
    
    /**
Draw labels on the X-axis
     
-Parameter padding: inner margin
-Parameter width: total width
     
     fileprivate func drawXAxis(_ section: CHSection) -> [(CGRect, String)] {
     
     var xAxisToDraw = [(CGRect, String)]()
     
     let xAxis = CHShapeLayer()
     
     var startX: CGFloat = section.frame.origin.x + section.padding.left
     let endX: CGFloat = section.frame.origin.x + section.frame.size.width - section.padding.right
     let secWidth: CGFloat = section.frame.size.width
     let secPaddingLeft: CGFloat = section.padding.left
     let secPaddingRight: CGFloat = section.padding.right
     
     //The x-axis is divided into an average of 4 discontinuities, displaying 5 x-axis coordinates. Calculate the number of discontinuities based on the number of values in the chart
     let dataRange = self.rangeTo - self.rangeFrom
     let xTickInterval: Int = dataRange / self.xAxisPerInterval
     
     //Draw x-axis labels
     //Interval width of each point
     let perPlotWidth: CGFloat = (secWidth - secPaddingLeft - secPaddingRight) / CGFloat(self.rangeTo - self.rangeFrom)
     let startY = section.frame.maxY
     var k: Int = 0
     var showXAxisReference = false
     //Equivalent to for var i=self. rangeFrom; I<self. rangeTo; I=i+xTickInterval
     for i in stride(from: self.rangeFrom, to: self.rangeTo, by: xTickInterval) {
     
     let xLabel = self.delegate?.kLineChart?(chart: self, labelOnXAxisForIndex: i) ?? ""
     var textSize = xLabel.ch_sizeWithConstrained(self.labelFont)
     textSize.width = textSize.width + 4
     var xPox = startX - textSize.width / 2 + perPlotWidth / 2
     //Calculate the leftmost and rightmost x-axis labels without crossing the boundary
     if (xPox < 0) {
     xPox = startX
     } else if (xPox + textSize.width > endX) {
     xPox = xPox - (xPox + textSize.width - endX)
     }
     //        NSLog(@"xPox = %f", xPox)
     //        NSLog(@"textSize.width = %f", textSize.width)
     let barLabelRect = CGRect(x: xPox, y: startY, width: textSize.width, height: textSize.height)
     
     //Record the text to be drawn
     xAxisToDraw.append((barLabelRect, xLabel))
     
     //Draw Guides
     let referencePath = UIBezierPath()
     let referenceLayer = CHShapeLayer()
     referenceLayer.lineWidth = self.lineWidth
     
     //Working with Guide Styles
     switch section.xAxis.referenceStyle {
     case let .dash(color: dashColor, pattern: pattern):
     referenceLayer.strokeColor = dashColor.cgColor
     referenceLayer.lineDashPattern = pattern
     showXAxisReference = true
     case let .solid(color: solidColor):
     referenceLayer.strokeColor = solidColor.cgColor
     showXAxisReference = true
     default:
     showXAxisReference = false
     }
     
     //Need to draw auxiliary lines on the x-axis
     if showXAxisReference {
     referencePath.move(to: CGPoint(x: xPox + textSize.width / 2, y: section.frame.minY))
     referencePath.addLine(to: CGPoint(x: xPox + textSize.width / 2, y: section.frame.maxY))
     referenceLayer.path = referencePath.cgPath
     xAxis.addSublayer(referenceLayer)
     }
     
     
     k = k + xTickInterval
     startX = perPlotWidth * CGFloat(k)
     }
     
     self.drawLayer.addSublayer(xAxis)
     
     return xAxisToDraw
     }*/
    
    
    ///Draw X-coordinate labels
    ///
    /// - Parameters:
    ///- section: Which partition is drawn
    ///- xAxisToDraw: The content to be drawn
    fileprivate func drawXAxisLabel(xAxisToDraw: [(CGRect, String)]) {
        
        guard self.showXAxisLabel else {
            return
        }
        
        guard xAxisToDraw.count > 0 else {
            return
        }
        
        let xAxis = CHShapeLayer()
        var alignment = CATextLayerAlignmentMode.center
        //Originally self. boundaries. maxY, I don't understand why I need to draw outside
        
        let startY = self.bounds.maxY - self.padding.bottom
        //The partition that needs to display the name of the x-coordinate label is displayed at the bottom
        //Draw an x coordinate label, and calculate the position of x by drawing an auxiliary line
        for (index,(var barLabelRect, xLabel)) in xAxisToDraw.enumerated() {
            if index == 0 || index == 2{
                alignment = CATextLayerAlignmentMode.left
            }else if index == 3 || index == 1{
                alignment = CATextLayerAlignmentMode.right
            }
            barLabelRect.origin.y = startY + 2
            //Draw Text
            let xLabelText = CHTextLayer()
            xLabelText.frame = barLabelRect
            xLabelText.string = xLabel
            xLabelText.alignmentMode = alignment
            xLabelText.fontSize = self.labelFont.pointSize
            xLabelText.foregroundColor =  self.textColor.cgColor
            xLabelText.backgroundColor = UIColor.clear.cgColor
            xLabelText.contentsScale = UIScreen.main.scale
            xAxis.addSublayer(xLabelText)
            
        }
        
        self.drawLayer.addSublayer(xAxis)
        //        context?.strokePath()
    }
    
    /**
Draw a click and select marker graphic
     - parameter section:
     */
    func drawTagGraph(point:CGPoint,item:CHKDepthChartItem){
        guard showInfo else{return}
        
        if self.selectedTagGraphslayer == nil{
            self.selectedTagGraphslayer = CHShapeLayer()
        }
        
        if self.selectedTagCenterlayer == nil{
            self.selectedTagCenterlayer = CHShapeLayer()
        }
        
        if let view = self.delegate?.depthChartTagView?(chart: self, Selected: item){
            let size = view.frame.size
            let frame:CGRect = CGRect(x: point.x - size.width / 2, y: point.y - size.height / 2, width: size.width, height: size.height)
            _ = self.selectedTagGraphslayer!.sublayers?.map { $0.removeFromSuperlayer() }
            self.selectedTagGraphslayer!.frame = frame
            self.selectedTagGraphslayer!.addSublayer(view.layer)
        }else{
            
            drawSelectedTagGraphslayer(point: point, item: item)
            drawSelectedTagCenterlayer(point: point, item: item)
        }
        
        self.drawLayer.addSublayer(self.selectedTagGraphslayer!)
        self.drawLayer.addSublayer(self.selectedTagCenterlayer!)
        
    }
    
    func drawSelectedTagGraphslayer(point:CGPoint,item:CHKDepthChartItem){
        //radius
        let radius:CGFloat = 8
        let frame:CGRect = CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)
        self.selectedTagGraphslayer!.frame = frame
        if item.type == .bid{
            self.selectedTagGraphslayer!.backgroundColor = UIColor.ThemekLine.up15.cgColor
        }else{
            self.selectedTagGraphslayer!.backgroundColor = UIColor.ThemekLine.down15.cgColor
        }
        self.selectedTagGraphslayer!.cornerRadius = radius
    }
    
    func drawSelectedTagCenterlayer(point:CGPoint,item:CHKDepthChartItem){
        //radius
        let radius:CGFloat = 4
        let frame:CGRect = CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)
        self.selectedTagCenterlayer!.frame = frame
        if item.type == .bid{
            self.selectedTagCenterlayer!.backgroundColor = UIColor.ThemekLine.up.cgColor
        }else{
            self.selectedTagCenterlayer!.backgroundColor = UIColor.ThemekLine.down.cgColor
        }
        self.selectedTagCenterlayer!.cornerRadius = radius
    }
    
    //X Display Price
    func drawItemInfoX(point: CGPoint,item:CHKDepthChartItem){
        guard showInfo else{return}
        if self.selectedItemXLayer == nil{
            self.selectedItemXLayer = CHShapeLayer()
        }
        let value = NSString.init(string: "\(item.value)".decimalNumberWithDouble()).decimalString1(decimal) as String
        let textWidth = value.textHeightSizeWithFont(UIFont.ThemeFont.MinimumRegular, height: 10).width
        let width : CGFloat = textWidth + 20
        let height : CGFloat = 20
        var itemX : CGFloat = point.x - width / 2
        if itemX < 0{
            itemX = 0
        }
        if SCREEN_WIDTH - (point.x + width / 2) < 0{
            itemX = SCREEN_WIDTH - width
        }
        selectedItemXLayer?.frame = CGRect.init(x: itemX, y: self.bounds.origin.y + self.bounds.size.height - 40, width: width, height: height)
        selectedItemXLayer?.cornerRadius = 2
        selectedItemXLayer?.backgroundColor = UIColor.ThemekLine.viewBg.cgColor
        selectedItemXLayer?.borderWidth = 0.5
        selectedItemXLayer?.borderColor = UIColor.ThemekLine.viewSeperator.cgColor
        
        //price
        let pricelayer = CHTextLayer()
        pricelayer.string = value
//            .ch_toString(maxF:self.decimal)//String(Double(iteme.value))
        pricelayer.frame = CGRect(x: 10, y: 5, width: textWidth, height: 10)
        pricelayer.alignmentMode = CATextLayerAlignmentMode.center
        pricelayer.fontSize = UIFont.ThemeFont.MinimumRegular.pointSize
        pricelayer.foregroundColor =  UIColor.ThemeLabel.colorLite.cgColor
        pricelayer.backgroundColor = UIColor.clear.cgColor
        pricelayer.contentsScale = UIScreen.main.scale
        //Remove previous layers before adding
        _ = self.selectedItemXLayer!.sublayers?.map { $0.removeFromSuperlayer() }
        
        self.selectedItemXLayer!.addSublayer(pricelayer)
        self.drawLayer.addSublayer(self.selectedItemXLayer!)
    }
    
    //Y display quantity
    func drawItemInfoY(point: CGPoint,item:CHKDepthChartItem){
        guard showInfo else{return}
        if self.selectedItemYLayer == nil{
            self.selectedItemYLayer = CHShapeLayer()
        }
        let textWidth = NumberHandler.dealVolumFormate("\(item.depthAmount)") .textHeightSizeWithFont(UIFont.ThemeFont.MinimumRegular, height: 10).width
        let width : CGFloat = textWidth + 20
        let height : CGFloat = 20
        var itemY : CGFloat = point.y - height / 2
        if itemY < 0{
            itemY = 0
        }
        if self.bounds.origin.y + self.bounds.size.height - (point.y + height / 2) - 40 < 0{
            itemY = self.bounds.origin.y + self.bounds.size.height - height - 40
        }
        selectedItemYLayer?.frame = CGRect.init(x: SCREEN_WIDTH - width, y: itemY, width: width, height: height)
        selectedItemYLayer?.cornerRadius = 2
        selectedItemYLayer?.backgroundColor = UIColor.ThemekLine.viewBg.cgColor
        selectedItemYLayer?.borderWidth = 0.5
        selectedItemYLayer?.borderColor = UIColor.ThemekLine.viewSeperator.cgColor
        
        //price
        let amountlayer = CHTextLayer()
        amountlayer.string = NumberHandler.dealVolumFormate("\(item.depthAmount)")
        //            .ch_toString(maxF:self.decimal)//String(Double(iteme.value))
        amountlayer.frame = CGRect(x: 10, y: 5, width: textWidth, height: 10)
        amountlayer.alignmentMode = CATextLayerAlignmentMode.center
        amountlayer.fontSize = UIFont.ThemeFont.MinimumRegular.pointSize
        amountlayer.foregroundColor =  UIColor.ThemeLabel.colorLite.cgColor
        amountlayer.backgroundColor = UIColor.clear.cgColor
        amountlayer.contentsScale = UIScreen.main.scale
        //Remove previous layers before adding
        _ = self.selectedItemYLayer!.sublayers?.map { $0.removeFromSuperlayer() }
        
        self.selectedItemYLayer!.addSublayer(amountlayer)
        self.drawLayer.addSublayer(self.selectedItemYLayer!)
        
    }
    
    
    /**
Draw, click, select, and display data points
     - parameter section:
     */
    func drawItemInfo(point: CGPoint,item:CHKDepthChartItem){
        //Length, width, and height
        var width:CGFloat = 70
        var height:CGFloat = 55
        
        if let selectedView = self.delegate?.depthChartShowItemView?(chart: self, Selected: item){
            width = selectedView.frame.size.width
            height = selectedView.frame.size.height
        }
        
        //At the beginning, it was centered upwards
        var frame:CGRect = CGRect(x: point.x - width / 2, y: point.y - height - 10, width: width, height: height)
        //Process the displayed positions according to different situations (six situations)
        //1. Up not enough left enough (facing down) 2. Up not enough left enough (facing down right) 3. Up not enough left enough (facing up right) 4. Up not enough right enough (facing down) 5. Up not enough right enough (facing up left) 6. Up not enough right enough (facing down left)
        //Is it on the left or right first
        if point.x > (self.plotWidth * CGFloat(self.plotCount)) / 2{
            if (self.plotWidth * CGFloat(self.plotCount)) - point.x > width / 2 && point.y < (height + 10){
                frame.origin.y = point.y + 10
            }else if (self.plotWidth * CGFloat(self.plotCount)) - point.x < width / 2 && point.y < (height + 10){
                frame.origin.x = point.x - width - 10
                frame.origin.y = point.y
            }else if (self.plotWidth * CGFloat(self.plotCount)) - point.x < width / 2 && point.y > (height + 10) {
                frame.origin.x = point.x - width - 10
            }
        }else{
            if point.x >= width / 2  && point.y < (height + 10){
                frame.origin.y = point.y + 10
            }else if point.x < width / 2 && point.y < (height + 10){
                frame.origin.x = point.x + 10
                frame.origin.y = point.y
            }else if point.x < width / 2 && point.y > (height + 10){
                frame.origin.x = point.x + 10
            }
        }
        
        if let view = self.delegate?.depthChartShowItemView?(chart: self, Selected: item) {
            if self.selectedItemInfoLayer == nil{
                self.selectedItemInfoLayer = CHShapeLayer()
            }
            _ = self.selectedItemInfoLayer!.sublayers?.map { $0.removeFromSuperlayer() }
            self.selectedItemInfoLayer!.frame = frame
            self.selectedItemInfoLayer!.addSublayer(view.layer)
            self.drawLayer.addSublayer(self.selectedItemInfoLayer!)
        }else{
            if self.selectedItemInfoLayer == nil{
                self.selectedItemInfoLayer = CHShapeLayer()
                self.selectedItemInfoLayer!.borderColor = UIColor(red: 46 / 255, green: 63 / 255, blue: 83 / 255, alpha: 1).cgColor
                self.selectedItemInfoLayer!.backgroundColor = UIColor(red: 23 / 255, green: 36 / 255, blue: 50 / 255, alpha: 1).cgColor
                self.selectedItemInfoLayer!.borderWidth = 1
                self.selectedItemInfoLayer!.cornerRadius = 5
            }
            self.selectedItemInfoLayer!.frame = frame
            
            //spacing
            let padding:CGFloat = 4
            let textHeight:CGFloat = height / 3
            var textRect = CGRect(x: padding, y: 2, width: width - padding, height: textHeight)
            
            //Buying and selling type
            let typelayer = CHTextLayer()
            if item.type == .bid{
                typelayer.string = "otc_text_tradeObjectBuy".localized()
            }else{
                typelayer.string = "otc_text_tradeObjectSell".localized()
            }
            typelayer.frame = textRect
            typelayer.alignmentMode = CATextLayerAlignmentMode.left
            typelayer.fontSize = UIFont.systemFont(ofSize: 10).pointSize
            typelayer.foregroundColor =  UIColor.ThemekLine.viewBg.cgColor
            typelayer.backgroundColor = UIColor.clear.cgColor
            typelayer.contentsScale = UIScreen.main.scale
            
            //price
            let pricelayer = CHTextLayer()
            pricelayer.string = item.value.ch_toString(maxF:self.decimal)//String(Double(iteme.value))
            textRect = CGRect(x: textRect.origin.x, y: textRect.origin.y + textHeight, width: width - padding, height: textHeight)
            pricelayer.frame = textRect
            pricelayer.alignmentMode = CATextLayerAlignmentMode.left
            pricelayer.fontSize = UIFont.systemFont(ofSize: 10).pointSize
            pricelayer.foregroundColor =  UIColor.ThemekLine.viewBg.cgColor
            pricelayer.backgroundColor = UIColor.clear.cgColor
            pricelayer.contentsScale = UIScreen.main.scale
            
            //amount
            let vollayer = CHTextLayer()
            let amount = item.depthAmount
            var amountStr = ""
            if amount >= 1000{
                let newValue = amount / 1000
                amountStr = String(format: "%.0fK", newValue)
            }else {
                amountStr = amount.ch_toString(maxF:self.numDecimal)//String(Double(amount))
            }
            vollayer.string = amountStr
            textRect = CGRect(x: textRect.origin.x, y: textRect.origin.y + textHeight, width: width - padding, height: textHeight)
            vollayer.frame = textRect
            vollayer.alignmentMode = CATextLayerAlignmentMode.left
            vollayer.fontSize = UIFont.systemFont(ofSize: 10).pointSize
            vollayer.foregroundColor =  UIColor.ThemekLine.viewBg.cgColor
            vollayer.backgroundColor = UIColor.clear.cgColor
            vollayer.contentsScale = UIScreen.main.scale
            
            _ = self.selectedItemInfoLayer!.sublayers?.map { $0.removeFromSuperlayer() }
            self.selectedItemInfoLayer!.addSublayer(typelayer)
            self.selectedItemInfoLayer!.addSublayer(pricelayer)
            self.selectedItemInfoLayer!.addSublayer(vollayer)
            
            self.drawLayer.addSublayer(self.selectedItemInfoLayer!)
        }
    }
    
    /**
Draw dotted lines on the chart
     
     - parameter section:
     */
    func drawChart() -> [(CGRect, String)]{
        
        var startIndex = 0
        var xAxisToDraw = [(CGRect,String)]()
        guard self.plotCount > 0 else {
            return []
        }
        
        if self.bidChartOnDirection == .right{
            
            //Sales Order Price Coordinates/Values
            let asksX = self.bounds.origin.x + self.padding.left + CGFloat(startIndex) * plotWidth
            let asksY = self.bounds.origin.y + self.bounds.size.height
            let asksRect = CGRect(x: asksX, y: asksY, width: 100, height: 18)
            if askItems.count > 0{
                if let askValue = NSString.init(string: "\(self.askItems[self.askItems.startIndex].value)".decimalNumberWithDouble()).decimalString1(decimal){
                    xAxisToDraw.append((asksRect, askValue))
                }
            }
            
            //Draw seller depth layer
            self.askItems = self.askItems.reversed()
            if let askChartLayer = self.drawDepthChart(items: self.askItems, startIndex: startIndex, strokeColor: self.askColor.stroke, fillColor: self.askColor.fill, lineWidth: self.askColor.lineWidth) {
                self.drawLayer.addSublayer(askChartLayer)
                startIndex = self.askItems.count
            }
            
//            //Intermediate price coordinates/values
//            let sell1X = self.bounds.origin.x + self.padding.left + CGFloat(startIndex) * plotWidth - 100 - 8
//            let sell1Y = asksY
//            let sell1Rect = CGRect(x: sell1X, y: sell1Y, width: 100, height: 18)
//            xAxisToDraw.append((sell1Rect, self.askItems[self.askItems.endIndex - 1].value.ch_toString()))
//
//            let buy1X = self.bounds.origin.x + self.padding.left + CGFloat(startIndex) * plotWidth + 8
//            let buy1Y = asksY
//            let buy1Rect = CGRect(x: buy1X, y: buy1Y, width: 100, height: 18)
//            xAxisToDraw.append((buy1Rect, self.bidItems[self.bidItems.endIndex - 1].value.ch_toString()))
            
            //Draw buyer depth layer
            self.bidItems = self.bidItems.reversed()
            if let bidChartLayer = self.drawDepthChart(items: self.bidItems, startIndex: startIndex, strokeColor: self.bidColor.stroke, fillColor: self.bidColor.fill, lineWidth: self.bidColor.lineWidth) {
                self.drawLayer.addSublayer(bidChartLayer)
                startIndex += self.bidItems.count
            }
            
            //Purchase Order Price Coordinates/Values
            let bidsX = self.bounds.origin.x + self.padding.left + CGFloat(startIndex) * plotWidth - 100
            let bidsY = asksY
            let bidsRect = CGRect(x: bidsX, y: bidsY, width: 100, height: 18)
            if bidItems.count > 0{
                if let bidValue = NSString.init(string: "\(self.bidItems[self.bidItems.endIndex - 1].value)".decimalNumberWithDouble()).decimalString1(decimal){
                    xAxisToDraw.append((bidsRect, bidValue))
                }
            }
            
            return xAxisToDraw
        }else{
            
            //Purchase Order Price Coordinates/Values
            let bidsX = self.bounds.origin.x + self.padding.left + CGFloat(startIndex) * plotWidth
            let bidsY = self.bounds.origin.y + self.bounds.size.height
            let bidsRect = CGRect(x: bidsX, y: bidsY, width: 100, height: 18)
            if bidItems.count > 0{
                if let bidValue = NSString.init(string: "\(self.bidItems[self.bidItems.startIndex].value)".decimalNumberWithDouble()).decimalString1(decimal){
                    xAxisToDraw.append((bidsRect, bidValue))
                }
            }
            
            //Draw buyer depth layer
            if let bidChartLayer = self.drawDepthChart(items: self.bidItems, startIndex: startIndex, strokeColor: self.bidColor.stroke, fillColor: self.bidColor.fill, lineWidth: self.bidColor.lineWidth) {
                self.drawLayer.addSublayer(bidChartLayer)
                startIndex = self.bidItems.count
            }
            
            //There are two values in the middle price coordinate/value section
            //I need to include the latest price here
//            let buy1X = self.bounds.origin.x + self.padding.left + CGFloat(startIndex) * plotWidth - 100 - 8
//            let buy1Y = bidsY
//            let buy1Rect = CGRect(x: buy1X, y: buy1Y, width: 100, height: 18)
//            if bidItems.count > 0{
//                xAxisToDraw.append((buy1Rect, self.bidItems[self.bidItems.endIndex - 1].value.ch_toString()))
//            }
//
//            let sell1X = self.bounds.origin.x + self.padding.left + CGFloat(startIndex) * plotWidth + 8
//            let sell1Y = bidsY
//            let sell1Rect = CGRect(x: sell1X, y: sell1Y, width: 100, height: 18)
//            if askItems.count > 0{
//
//                xAxisToDraw.append((sell1Rect, self.askItems[self.askItems.startIndex].value.ch_toString()))
//            }

            //Draw seller depth layer
            if let askChartLayer = self.drawDepthChart(items: self.askItems, startIndex: startIndex, strokeColor: self.askColor.stroke, fillColor: self.askColor.fill, lineWidth: self.askColor.lineWidth) {
                self.drawLayer.addSublayer(askChartLayer)
                startIndex += self.askItems.count
            }
            
            //Sales Order Price Coordinates/Values
            let asksX = self.bounds.origin.x + self.padding.left + CGFloat(startIndex) * plotWidth - 100
            let asksY = bidsY
            let asksRect = CGRect(x: asksX, y: asksY, width: 100, height: 18)
            if askItems.count > 0{
                if let askValue = NSString.init(string: "\(self.askItems[self.askItems.endIndex - 1].value)".decimalNumberWithDouble()).decimalString1(decimal){
                    xAxisToDraw.append((asksRect, askValue))
                }
            }
            
            return xAxisToDraw
        }
        //        //Draw buyer depth layer
        //        if let bidChartLayer = self.drawDepthChart(items: self.bidItems, startIndex: 0, strokeColor: self.bidColor.stroke, fillColor: self.bidColor.fill, lineWidth: self.bidColor.lineWidth) {
        //            self.drawLayer.addSublayer(bidChartLayer)
        //            startIndex = self.bidItems.count
        //        }
        //
        //        //Draw seller depth layer
        //        if let askChartLayer = self.drawDepthChart(items: self.askItems, startIndex: startIndex, strokeColor: self.askColor.stroke, fillColor: self.askColor.fill, lineWidth: self.askColor.lineWidth) {
        //            self.drawLayer.addSublayer(askChartLayer)
        //        }
    }
    
    
    
    ///Draw purchase order depth layer
    ///
    /// - Parameters:
    ///- items: Dataset
    ///- startIndex: Data start position
    ///- strokeColor: Line color
    ///- fillColor: Fill color
    func drawDepthChart(items: [CHKDepthChartItem],
                        startIndex: Int,
                        strokeColor: UIColor,
                        fillColor: UIColor,
                        lineWidth: CGFloat) -> CAShapeLayer? {
        
        guard self.plotCount > 0 else {
            return nil
        }
        
        let depthChart = CAShapeLayer()
        let lineLayer = CAShapeLayer()
        let fillLayer = CAShapeLayer()
        
        //【1】 Draw line segments
        
        //Draw line segments using bezierPath
        let linePath = UIBezierPath()
        var isStartDraw = false
        
        //Draw a line segment from the beginning to the end of the loop
        var index: Int = 0
        var startX: CGFloat = 0
        var endX: CGFloat = 0
        for (i, item) in items.enumerated() {
            
            //Starting point
            index = startIndex + i
            
            //Start X
            var ix = self.bounds.origin.x + self.padding.left + CGFloat(index) * plotWidth
            
            //Convert specific numerical values to y-values in the coordinate system
            let iys = self.getLocalY(item.depthAmount)
            
            //Start of the first point movement path
            switch i {
            case 0: //Special treatment for the first point, closing the line
                ix += 0
                startX = ix
            case items.count - 1:   //Special treatment for the last point, closing the line
                ix += plotWidth
            default:                //Take the center of other points
                ix += plotWidth / 2
            }
            
            let point = CGPoint(x: ix, y: iys)
            
            if !isStartDraw {
                linePath.move(to: point)
                isStartDraw = true
            } else {
                linePath.addLine(to: point)
            }
            //If there is only one data
            if items.count != 1{
                endX = point.x
            }else{
                endX = ix + plotWidth
                linePath.addLine(to: CGPoint(x: endX, y: iys))
            }
            
        }
        
        lineLayer.path = linePath.cgPath
        lineLayer.strokeColor = strokeColor.cgColor
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.lineWidth = lineWidth
        lineLayer.lineCap = CAShapeLayerLineCap.round
        lineLayer.lineJoin = CAShapeLayerLineJoin.bevel
        depthChart.addSublayer(lineLayer)
        
        //【2】 Draw filled area
        
        linePath.addLine(to: CGPoint(x: endX, y: self.bounds.maxY - self.padding.bottom))
        linePath.addLine(to: CGPoint(x: startX, y: self.bounds.maxY - self.padding.bottom))
        fillLayer.path = linePath.cgPath
        fillLayer.fillColor = fillColor.cgColor
        fillLayer.strokeColor = UIColor.clear.cgColor
        fillLayer.zPosition -= 1 //Place the layer to the next level, so that the marker line at the bottom is displayed
        depthChart.addSublayer(fillLayer)
        
        return depthChart
        
    }
    
    //Cancel depiction
    func removeDescribeLayer(){
        showInfo = false
        self.selectedItemYLayer?.removeFromSuperlayer()
        self.selectedItemXLayer?.removeFromSuperlayer()
        self.selectedTagCenterlayer?.removeFromSuperlayer()
        self.selectedTagGraphslayer?.removeFromSuperlayer()
    }
    
}

//MARK: - Public Method
extension CHDepthChartView {
    
    /**
refresh the view
     */
    public func reloadData() {
        self.resetData()
        self.drawLayerView()
    }
    
    
    ///Refresh Style
    ///
    ///- Parameter style: New style
    public func resetStyle(style: CHKLineChartStyle) {
        self.style = style
        self.reloadData()
    }
    
    ///Generate screenshots
    var image: UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let capturedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return capturedImage!
    }
}


//MARK: - Gesture operation
extension CHDepthChartView: UIGestureRecognizerDelegate {
    
    
    ///Control gesture switch
    ///
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        switch gestureRecognizer {
        case is UITapGestureRecognizer:
            return self.enablePan
        case is UILongPressGestureRecognizer:
            return self.enablePan
        default:
            return false
        }
    }
    
    /**
*Click Event Handling
     *
     *  @param sender
     */
    @objc func doTapAction(_ sender: UITapGestureRecognizer) {
//        guard self.enableTap else {
//            return
//        }
//        let point = sender.location(in: self)
//        //Display the selected content by clicking
//        self.setSelectedIndexByPoint(point)
        if self.showInfo {
            self.removeDescribeLayer()
        }
    }
    
    @objc func doLongAction(_ sender : UILongPressGestureRecognizer){
        guard self.enablePan else{
            return
        }
        let point = sender.location(in: self)
        if sender.state == .changed || sender.state == .began || sender.state == .ended{
            showInfo = true
            self.setSelectedIndexByPoint(point)
        }else{
            self.removeDescribeLayer()
        }
    }
    
    
}

