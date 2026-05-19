//
//  CHKLineChart.swift
//  CHKLineChart
//
//  Created by Chance on 2023/9/6.
//  Copyright © 2023年 Chance. All rights reserved.
//

import UIKit
import YYWebImage
import RxSwift
import EXKit

/**
Scroll the chart to that position
 
-Top: Head
-End: tail
-None: Do not handle
 */
public enum CHChartViewScrollPosition {
    case top, end, none
}


///Display position of the selected cross y-axis in the chart
///
///- free: Freedom is at the displayed point
///- onClosePrice: At the closing price
public enum CHChartSelectedPosition {
    case free
    case onClosePrice
}

/**
*K-line data source agent
 */
@objc public protocol CHKLineChartDelegate: class {
    
    /**
Total number of data sources
     
     - parameter chart:
     
     - returns:
     */
    func numberOfPointsInKLineChart(chart: CHKLineChartView) -> Int
    
    /**
The data source index is the corresponding object
     
     - parameter chart:
-Parameter index: index bit
     
-Returns: K-line data object
     */
    func kLineChart(chart: CHKLineChartView, valueForPointAtIndex index: Int) -> CHChartItem
    
    /**
Obtain the display content of the Y-axis of the chart
     
     - parameter chart:
-Parameter value: The calculated y value
     
     - returns:
     */
    func kLineChart(chart: CHKLineChartView, labelOnYAxisForValue value: CGFloat, atIndex index: Int, section: CHSection) -> String
    
    /**
Obtain the display content of the X-axis of the chart
     
     - parameter chart:
-Parameter index: index bit
     
     - returns:
     */
    @objc optional func kLineChart(chart: CHKLineChartView, labelOnXAxisForIndex index: Int) -> String
    
    /**
Complete drawing chart
     
     */
    @objc optional func didFinishKLineChartRefresh(chart: CHKLineChartView)
    
    
    ///Configure the number of decimal places reserved for each partition
    ///
    /// - parameter chart:
    ///- parameter decimalForSection: Partition
    ///
    /// - returns:
    @objc optional func kLineChart(chart: CHKLineChartView, decimalAt section: Int) -> Int
    
    
    ///Set the width of the y-axis label
    ///
    /// - parameter chart:
    ///
    /// - returns:
    @objc optional func widthForYAxisLabelInKLineChart(in chart: CHKLineChartView) -> CGFloat
    
    
    ///Click on the chart column to respond to the method
    ///
    /// - Parameters:
    ///- chart: chart
    ///- index: clicked location
    ///- item: data object
    @objc optional func kLineChart(chart: CHKLineChartView, didSelectAt index: Int, item: CHChartItem)
    
    
    ///Layout height of the X-axis
    ///
    ///- Parameter chart: Chart
    ///- Returns: Returns the customized height
    @objc optional func heightForXAxisInKLineChart(in chart: CHKLineChartView) -> CGFloat
    
    
    ///Display range length during initialization
    ///
    ///- Parameter chart: Chart
    @objc optional func initRangeInKLineChart(in chart: CHKLineChartView) -> Int
    
    
    ///Customize the label style that appears when selecting points
    ///
    /// - Parameters:
    ///- chart: chart
    ///- yAxis: customizable y-axis display label for users
    ///- viewOfXAxis: Customizable x-axis display label for users
    @objc optional func kLineChart(chart: CHKLineChartView, viewOfYAxis yAxis: UILabel, viewOfXAxis: UILabel)
    
    
    ///Customize the header view of the section to display content
    ///
    /// - Parameters:
    ///- chart: chart
    ///- section: Index bits of the partition
    ///- Returns: Customized View
    @objc optional func kLineChart(chart: CHKLineChartView, viewForHeaderInSection section: Int) -> UIView?
    
    ///Customize the header view of the section to display content
    ///
    /// - Parameters:
    ///- chart: chart
    ///- section: Index bits of the partition
    ///- Returns: Customized View
    @objc optional func kLineChart(chart: CHKLineChartView, titleForHeaderInSection section: CHSection, index: Int, item: CHChartItem) -> NSAttributedString?
    
    
    ///Switch the line groups displayed in pagination for partitions
    ///
    @objc optional func kLineChart(chart: CHKLineChartView, didFlipPageSeries section: CHSection, series: CHSeries, seriesIndex: Int)
    
    
    @objc optional func kLineChartScrolled()
    @objc optional func kLineChartPinched()
    @objc optional func kLinePrePage()

}

open class CHKLineChartView: UIView {
    
    ///MARK: - Constant
    let kMinRange = 13       //Minimum zoom range
    let kMaxRange = 133     //Maximum zoom range
    let kPerInterval = 4    //Scaled interval for each segment
    public let kYAxisLabelWidth: CGFloat = 50        //Default width
    public let kXAxisHegiht: CGFloat = 16        //The height of the default X coordinate
    
    ///MARK: - Member variable
    @IBInspectable open var upColor: UIColor = UIColor.green     //Color of liters
    @IBInspectable open var downColor: UIColor = UIColor.red     //Falling Color
    @IBInspectable open var labelFont = UIFont.ThemeFont.MinimumRegular
    @IBInspectable open var lineColor: UIColor = UIColor(white: 0.2, alpha: 1) //line color
    @IBInspectable open var textColor: UIColor = UIColor(white: 0.8, alpha: 1) //Text color
    @IBInspectable open var xAxisPerInterval: Int = 5                        //Number of discontinuities on the x-axis
    
    open var yAxisLabelWidth: CGFloat = 0                    //Width of Y-axis
    open var handlerOfAlgorithms: [CHChartAlgorithmProtocol] = [CHChartAlgorithmProtocol]()
    open var padding: UIEdgeInsets = UIEdgeInsets.zero    //padding 
    open var showYAxisLabel = CHYAxisShowPosition.right      //Display the position of y, default to the right
    open var isInnerYAxis: Bool = false                     //Is the y-coordinate embedded in the chart
    open var selectedPosition: CHChartSelectedPosition = .free         //Select the location where the y value is displayed

    @IBOutlet open weak var delegate: CHKLineChartDelegate?             //agent
    
    open var sections = [CHSection]()
    open var selectedIndex: Int = -1                      //Select index bit
    open var scrollToPosition: CHChartViewScrollPosition = .none  //Start displaying position after chart refresh
    var selectedPoint: CGPoint = CGPoint.zero
    open var minDataCount:Int = 41
    open var normalPlotWidth: CGFloat =  10

    //Is it scalable
    open var enablePinch: Bool = true
    //Can it slide
    open var enablePan: Bool = true
    //Can I click to select
    open var enableTap: Bool = true {
        didSet {
            self.showSelection = self.enableTap
        }
    }
    
    ///Whether to display the selected content
    open var showSelection: Bool = true {
        didSet {
            self.selectedXAxisLabel?.isHidden = !self.showSelection
            self.selectedYAxisLabel?.isHidden = !self.showSelection
            self.verticalLineView?.isHidden = !self.showSelection
            self.horizontalLineView?.isHidden = !self.showSelection
//            self.sightView?.isHidden = !self.showSelection
        }
    }
    
    ///Display the X coordinate content on which index partition, with a default value of -1, indicating the last one. If the user sets an overflow value, the last one will also be used
    open var showXAxisOnSection: Int = -1
    
    ///Display X-axis labels
    open var showXAxisLabel: Bool = true
    
    ///Do you want to display all content
    open var isShowAll: Bool = false
    
    ///Show edges with upper and lower left edges
    open var borderWidth: (top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) = (0.25, 0.25, 0.25, 0.25)
    
    var lineWidth: CGFloat = 0.5
    var plotCount: Int = 0
    var rangeFrom: Int = 0                          //Starting index bit of visible area
    var rangeTo: Int = 0                            //End index bit of visible area
    open var range: Int = 40                             //Number of displayed in visible area
    var borderColor: UIColor = UIColor.gray
    open var labelSize = CGSize(width: 40, height: 16)
    
    var datas: [CHChartItem] = [CHChartItem]()      //data source
    
    open var selectedBGColor: UIColor = UIColor.ThemekLine.labcolorMedium   //The background color of the displayed box for the selected point
    open var selectedTextColor: UIColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1) //The text color displayed for the selected point
    var verticalLineView: UIView?
    var horizontalLineView: HorizontalXLineView?
    var selectedXAxisLabel: UILabel?
    var selectedYAxisLabel: SelectedYAxisLabel?
    var sightView: UIView?       //Click on the sight star that appears
    
//    lazy var pan:UIPanGestureRecognizer = {
//        let pan = UIPanGestureRecognizer(
//            target: self,
//            action: #selector(doPanAction(_:)))
//        pan.delegate = self
//        return pan
//    }()
    
    lazy var pan:PanDirectionGestureRecognizer = {
        let pan = PanDirectionGestureRecognizer.init(direction: .horizontal,
                                                     target: self,
                                                     action: #selector(doPanAction(_:)))
        pan.delegate = self
        return pan
    }()
    
    lazy var vertiPan:PanDirectionGestureRecognizer = {
        let pan = PanDirectionGestureRecognizer.init(direction: .vertical, target: self, action: #selector(doPanAction(_:)))
        pan.delegate = self
        return pan
    }()
    
    //Dynamics engine
    lazy var animator: UIDynamicAnimator = UIDynamicAnimator(referenceView: self)
    
    //The point of action of power
    lazy var dynamicItem = CHDynamicItem()
    
    //Used to handle linear deceleration when scrolling charts
    weak var decelerationBehavior: UIDynamicItemBehavior?
    
    //Used to bounce back after rolling release
    weak var springBehavior: UIAttachmentBehavior?
    
    //Deceleration start x
    var decelerationStartX: CGFloat = 0
    
    ///Layer used for charts
    var drawLayer: CHShapeLayer = CHShapeLayer()
    
    ///Dot Line Layer
    var chartModelLayer: CHShapeLayer = CHShapeLayer()
    
    ///Chart data information display layer, displaying the numerical content of each partition
    var chartInfoLayer: CHShapeLayer = CHShapeLayer()
    
    var nowLineView = EXCurrentLine()
    
    var nowValue: CGFloat = 0.0 {
        didSet {
            self.drawLayerView()
        }
    }
    
    
    
    lazy var nowValueLabel: UILabel = {
        let label = UILabel.init(frame: CGRect.zero)
        label.font = UIFont.ThemeFont.TagRegular
        label.textColor = UIColor.ThemeLabel.colorHighlight
        label.backgroundColor = UIColor.ThemekLine.viewBg
        label.textAlignment = NSTextAlignment.left
        return label
    }()
    
    open var style: CHKLineChartStyle! {           //Display Style
        didSet {
            //Reconfigure Style
            self.sections = self.style.sections
            self.backgroundColor = self.style.backgroundColor
            self.padding = self.style.padding
            self.handlerOfAlgorithms = self.style.algorithms
            self.lineColor = self.style.lineColor
            self.textColor = self.style.textColor
            self.labelFont = self.style.labelFont
            self.showYAxisLabel = self.style.showYAxisLabel
            self.selectedBGColor = self.style.selectedBGColor
            self.selectedTextColor = self.style.selectedTextColor
            self.isInnerYAxis = self.style.isInnerYAxis
            self.enableTap = self.style.enableTap
            self.enablePinch = self.style.enablePinch
            self.enablePan = self.style.enablePan
            self.showSelection = self.style.showSelection
            self.showXAxisOnSection = self.style.showXAxisOnSection
            self.isShowAll = self.style.isShowAll
            self.showXAxisLabel = self.style.showXAxisLabel
            self.borderWidth = self.style.borderWidth
        }
        
    }
    
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
    
//    convenience init(style: CHKLineChartStyle) {
//        self.init()
//        self.initUI()
//        self.style = style
//    }
    
    /**
Initialize UI
     
     - returns:
     */
    fileprivate func initUI() {
        
        self.isMultipleTouchEnabled = true
        
        //Initialize the display of auxiliary lines selected by clicking
        self.verticalLineView = UIView(frame: CGRect(x: 0, y: 0, width: lineWidth, height: 0))
        self.verticalLineView?.backgroundColor = self.selectedBGColor
        self.verticalLineView?.isHidden = true
        self.addSubview(self.verticalLineView!)
        
        self.horizontalLineView = HorizontalXLineView()
        self.horizontalLineView?.backgroundColor = UIColor.ThemekLine.labcolorMedium
        self.horizontalLineView?.isHidden = true
        self.addSubview(self.horizontalLineView!)
        
        //The user clicks on the chart to display the actual value of the current y-axis
        self.selectedYAxisLabel = SelectedYAxisLabel()
        self.selectedYAxisLabel?.fillcolor = self.selectedBGColor
        self.selectedYAxisLabel?.isHidden = true
        self.selectedYAxisLabel?.indexLabel.font = self.labelFont
        self.selectedYAxisLabel?.indexLabel.minimumScaleFactor = 0.5
        self.selectedYAxisLabel?.indexLabel.lineBreakMode = .byClipping
        self.selectedYAxisLabel?.indexLabel.adjustsFontSizeToFitWidth = true
        self.selectedYAxisLabel?.indexLabel.textColor = self.selectedTextColor
        self.selectedYAxisLabel?.indexLabel.textAlignment = NSTextAlignment.center
        self.addSubview(self.selectedYAxisLabel!)
        
        //The user clicks on the chart to display the actual value of the current x-axis
        self.selectedXAxisLabel = UILabel(frame: CGRect.zero)
        self.selectedXAxisLabel?.backgroundColor = self.selectedBGColor
        self.selectedXAxisLabel?.isHidden = true
        self.selectedXAxisLabel?.font = self.labelFont
        self.selectedXAxisLabel?.textColor = self.selectedTextColor
        self.selectedXAxisLabel?.textAlignment = NSTextAlignment.center
        self.addSubview(self.selectedXAxisLabel!)
        
        self.sightView = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        self.sightView?.backgroundColor = self.selectedBGColor
        self.sightView?.isHidden = true
        self.sightView?.layer.cornerRadius = 3
        self.addSubview(self.sightView!)
        
        //Paint Layer
        self.layer.addSublayer(self.drawLayer)
        
        
        //Add gesture action
  
        
        self.addGestureRecognizer(pan)
        
        //Click gesture operation
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(doTapAction(_:)))
        tap.delegate = self
        self.addGestureRecognizer(tap)
        
        
        //Double finger zoom operation
        let pinch = UIPinchGestureRecognizer(
            target: self,
            action: #selector(doPinchAction(_:)))
        pinch.delegate = self
        self.addGestureRecognizer(pinch)
        
        //Long press gesture operation
        let longPress = UILongPressGestureRecognizer(target: self,
                                                     action: #selector(doLongPressAction(_:)))
        //Long press for 1 second
        longPress.minimumPressDuration = 0.5
        self.addGestureRecognizer(longPress)
        
        
        //Load an initialized Range value
        if let userRange = self.delegate?.initRangeInKLineChart?(in: self) {
            self.range = userRange
        }
        
        //Initial data
        self.resetData()
    
        nowLineView.actionButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = `self` else { return }
            self.rangeTo = self.plotCount               //The default is the end of the last data entry
            if self.rangeTo - self.range > 0 {          //If the end - default display number is greater than 0
                self.rangeFrom = self.rangeTo - self.range   //Calculate the position of the display at the beginning
            } else {
                self.rangeFrom = 0
            }
            self.selectedIndex = -1
            self.drawLayerView()
        }).disposed(by: disposeBag)
        
//        nowLineView.frame = CGRect.init(x: 0, y: 0, width: self.bounds.width, height: 12)
        nowLineView.isHidden = true
        addSubview(nowLineView)
        
        nowValueLabel.isHidden = true
        addSubview(nowValueLabel)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        //Layout complete redraw
        self.drawLayerView()
        nowLineView.frame = CGRect.init(x: 0, y: 0, width: self.bounds.width, height: 12)
    }
    
    /**
Initialize data
     */
    fileprivate func resetData() {
        self.datas.removeAll()
        self.plotCount = self.delegate?.numberOfPointsInKLineChart(chart: self) ?? 0
        
        if plotCount > 0 {
            
            //Obtain the data source on the agent
            for i in 0...self.plotCount - 1 {
                let item = self.delegate?.kLineChart(chart: self, valueForPointAtIndex: i)
                self.datas.append(item!)
            }
            
            //Execute algorithm equations to calculate values and add them to objects
            for algorithm in self.handlerOfAlgorithms {
                //Execute the algorithm to calculate indicator data
                self.datas = algorithm.handleAlgorithm(self.datas)
            }
        }
    }
    
    
    /**
Obtain the partition location of the clicked area
     
-Parameter point: Click on the coordinate
     
-Returns: Returns the section and index bit
     */
    func getSectionByTouchPoint(_ point: CGPoint) -> (Int, CHSection?) {
        for (i, section) in self.sections.enumerated() {
            if section.frame.contains(point) {
                return (i, section)
            }
        }
        return (-1, nil)
    }
    
    
    ///Partition displaying X-axis coordinates
    ///
    /// - Returns:
    func getSecionWhichShowXAxis() -> CHSection {
        let visiableSection = self.sections.filter { !$0.hidden }
        var showSection: CHSection?
        for (i, section) in visiableSection.enumerated() {
            //User defined display of X-axis partitions
            if section.index == self.showXAxisOnSection {
                showSection = section
            }
            //If none are found in the end, take the last one for display
            if i == visiableSection.count - 1 && showSection == nil{
                showSection = section
            }
        }
        
        return showSection!
    }
    
    /**
Set selected data points
     
     - parameter point:
     */
    func setSelectedIndexByPoint(_ point: CGPoint) {
        
        
        guard self.enableTap else {
            return
        }
        
        if self.datas.count == 0 {
            return
        }
        
        if point.equalTo(CGPoint.zero) {
            return
        }
        
        let (_, section) = self.getSectionByTouchPoint(point)
        if section == nil {
            return
        }
        
        let visiableSections = self.sections.filter { !$0.hidden }
        guard let lastSection = visiableSections.last else {
            return
        }
        
        let showXAxisSection = self.getSecionWhichShowXAxis()
        
        //Reset text color and font
        self.selectedYAxisLabel?.indexLabel.font = self.labelFont
        self.selectedYAxisLabel?.fillcolor = self.selectedBGColor
        self.selectedYAxisLabel?.indexLabel.textColor = self.selectedTextColor
        self.selectedXAxisLabel?.font = self.labelFont
        self.selectedXAxisLabel?.backgroundColor = self.selectedBGColor
        self.selectedXAxisLabel?.textColor = self.selectedTextColor
        
        let yaxis = section!.yAxis
        let format = "%.".appendingFormat("%df", yaxis.decimal)
        
        self.selectedPoint = point
 
        //Interval width of each point
        var showLast = rangeTo == self.datas.count
    
        var plotWidth = (section!.frame.size.width - section!.padding.left - section!.padding.right) / CGFloat(self.rangeTo - self.rangeFrom)
        if plotWidth.isNaN == true{
            return
        }
        
        if self.datas.count < minDataCount {
            plotWidth = normalPlotWidth
            showLast = false
        }
        
        var yVal: CGFloat = 0        //Obtain the actual value of the y-axis coordinate

        for i in self.rangeFrom...self.rangeTo - 1 {
            let ixs = plotWidth * CGFloat(i - self.rangeFrom) + section!.padding.left + self.padding.left
            let ixe = plotWidth * CGFloat(i - self.rangeFrom + 1) + section!.padding.left + self.padding.left
            
            if ixs <= selectedPoint.x && selectedPoint.x < ixe {
                self.selectedIndex = i
                let item = self.datas[i]
                var hx = section!.frame.origin.x + section!.padding.left
                hx = hx + plotWidth * CGFloat(i - self.rangeFrom) + plotWidth / 2 - (showLast ? 60 : 0)
                let hy = self.padding.top
                
                let hheight = lastSection.frame.maxY - section!.padding.top
                //Show Guides
//                self.horizontalLineView?.frame = CGRect(x: hx, y: hy, width: self.lineWidth, height: hheight)
//                self.horizontalLineView?.frame = CGRect(x: hx - plotWidth/2, y: hy, width: plotWidth, height: hheight)
                let newreact = CGRect(x: hx - 0.75, y: hy, width: 1.5, height:hheight - 30)
                if newreact.origin.x !=  self.horizontalLineView?.frame.origin.x {
                    feedbackGenerator()
                }
                self.horizontalLineView?.frame = newreact

                let vx = section!.frame.origin.x + section!.padding.left
                var vy: CGFloat = 0
                
                
                
                //Process the value of horizontal line y
                switch self.selectedPosition {
                case .free:
                    vy = point.y
                    yVal = section!.getRawValue(point.y)        //Obtain the actual value of the y-axis coordinate
                case .onClosePrice:
                    if let series = section?.getSeries(key: CHSeriesKey.candle), !series.hidden {
                        yVal = item.closePrice          //Obtain the closing price as the actual value
                    } else if let series = section?.getSeries(key: CHSeriesKey.timeline), !series.hidden {
                        yVal = item.closePrice          //Obtain the closing price as the actual value
                    } else if let series = section?.getSeries(key: CHSeriesKey.volume), !series.hidden {
                        yVal = item.vol                 //Obtain transaction volume as actual value
                    }
                    
                    vy = section!.getLocalY(yVal)
                    
                }
                let hwidth = section!.frame.size.width - section!.padding.left - section!.padding.right
                //Show Guides
                self.verticalLineView?.frame = CGRect(x: vx, y: vy - self.lineWidth / 2, width: hwidth, height: self.lineWidth)
                //                self.verticalLineView?.isHidden = false
                
                //Display auxiliary content on the y-axis
                //Control whether the label of the y-axis is displayed on the left or right
                var yAxisStartX: CGFloat = 0
                //                self.selectedYAxisLabel?.isHidden = false
                //                self.selectedXAxisLabel?.isHidden = false
                switch self.showYAxisLabel {
                case .left:
                    yAxisStartX = section!.frame.origin.x
                case .right:
                    yAxisStartX = section!.frame.maxX - self.yAxisLabelWidth
                case .none:
                    self.selectedYAxisLabel?.isHidden = true
                }
                
                let labelHeight = self.labelSize.height + 6
                self.selectedYAxisLabel?.indexLabel.text = String(format: format, yVal)     //Show actual values
                self.selectedYAxisLabel?.frame = CGRect(x: yAxisStartX, y: vy - labelHeight / 2, width: self.yAxisLabelWidth, height: labelHeight)
                let time = Date.ch_getTimeByStamp(item.time, format: "yyyy-MM-dd HH:mm") //Show actual values
                let size = time.ch_sizeWithConstrained(self.labelFont)
                self.selectedXAxisLabel?.text = time
                
                //Determine if x exceeds the left and right boundaries
                let labelWidth = size.width  + 6
                var x = hx - (labelWidth) / 2
                
                if x < section!.frame.origin.x {
                    x = section!.frame.origin.x
                } else if x + labelWidth > section!.frame.origin.x + section!.frame.size.width {
                    x = section!.frame.origin.x + section!.frame.size.width - labelWidth
                }
                
                self.selectedXAxisLabel?.frame = CGRect(x: x, y: showXAxisSection.frame.maxY, width: size.width  + 6, height: self.labelSize.height)
                
                self.sightView?.center = CGPoint(x: hx, y: vy)
                
                //Final customization for users
                self.delegate?.kLineChart?(chart: self, viewOfYAxis: self.selectedXAxisLabel!, viewOfXAxis: self.selectedYAxisLabel!.indexLabel)
                self.showSelection = true
                self.sightView?.isHidden = !self.showSelection

                self.bringSubviewToFront(self.verticalLineView!)
                self.bringSubviewToFront(self.horizontalLineView!)
                self.bringSubviewToFront(self.selectedXAxisLabel!)
                self.bringSubviewToFront(self.selectedYAxisLabel!)
                self.bringSubviewToFront(self.sightView!)
                
                //Set Selection Point
                self.setSelectedIndexByIndex(i)
                
                break
            }
            
        }
    }

//    ///Vibration feedback after iOS10
//     func feedbackGenerator() {
//         let gen = UIImpactFeedbackGenerator.init(style: .light);//The strength of the light vibration effect
//         gen.prepare();//Minimize feedback delay
//         gen.impactOccurred()//Trigger effect
//     }
    
    /**
Set selected data points
     
-Parameter index: selected location
     */
    func setSelectedIndexByIndex(_ index: Int) {
        
        guard index >= self.rangeFrom && index < self.rangeTo else {
            return
        }
        
        self.selectedIndex = index
        let item = self.datas[index]
        
        //Display the header title of the partition
        for (_, section) in self.sections.enumerated() {
            if section.hidden {
                continue
            }
            
            if let titleString = self.delegate?.kLineChart?(chart: self,
                                                            titleForHeaderInSection: section,
                                                            index: index,
                                                            item: self.datas[index]) {
                //Display user-defined titles
                section.drawTitleForHeader(title: titleString)
            } else {
                //Show default
                section.drawTitle(index)
            }
        }
        
        
        
        //Callback to proxy delegate method
        self.delegate?.kLineChart?(chart: self, didSelectAt: index, item: item)
        
    }
    
    func getFirstCandleIdx() -> Int {
        let idx = -1
        if self.datas.count == 0 {
            return idx
        }
        //Default to a leftmost point, in order to get the first candle
        var pointA = CGPoint(x: 10, y: 50)
        let (_, section) = self.getSectionByTouchPoint(pointA)
        
        if section == nil {
            return idx
        }

        //Interval width of each point
        
        var plotWidth = (section!.frame.size.width - section!.padding.left - section!.padding.right) / CGFloat(self.rangeTo - self.rangeFrom)
        if plotWidth.isNaN == true{
            return  idx
        }
        
        let maxScrennWidth = SCREEN_WIDTH - 60
        let overlapped = (plotWidth * CGFloat(self.datas.count) > maxScrennWidth)
        
        if self.datas.count < minDataCount {
            if !overlapped {
                plotWidth = normalPlotWidth
            }else {
                if self.rangeTo == self.datas.count {
                    pointA.x  += 60
                }
            }
        }else {
            if self.rangeTo == self.datas.count {
                pointA.x  += 60
            }
        }
        
        for i in self.rangeFrom...self.rangeTo - 1 {
            let ixs = plotWidth * CGFloat(i - self.rangeFrom) + section!.padding.left + self.padding.left
            let ixe = plotWidth * CGFloat(i - self.rangeFrom + 1) + section!.padding.left + self.padding.left
            if ixs <= pointA.x && pointA.x < ixe {
                return i
            }
        }
        return idx
    }
}

//MARK: - Drawing related methods
extension CHKLineChartView {
    
    
    ///Clear sub layers of the chart
    func removeLayerView() {
        for section in self.sections {
            section.removeLayerView()
            for series in section.series {
                series.removeLayerView()
            }
        }
        _ = self.drawLayer.sublayers?.map { $0.removeFromSuperlayer() }
        self.drawLayer.sublayers?.removeAll()
    }
    
    ///Drawing charts through CALayer
    func drawLayerView() {
        
        //Clear the layer first
        self.removeLayerView()
        
        //Initialize data
        if self.initChart() {
            
            
            ///X coordinate label to be drawn
            var xAxisToDraw = [(CGRect, String)]()
            
            //Establish each partition
            self.buildSections {
                (section, index) in
                
                //Obtain the decimal places for each section
                let decimal = self.delegate?.kLineChart?(chart: self, decimalAt: index) ?? 2
                section.decimal = decimal
                
                //Initial Y-axis data
                self.initYAxis(section)
                
                //Draw each area
                self.drawSection(section)
                
                //Draw the X-axis coordinate system, first draw the auxiliary line, record the label position,
                //Return and finally draw on the partition that needs to be displayed
                xAxisToDraw = self.drawXAxis(section)
     
                //Draw the Y-axis coordinate system, but the final y-axis label is not made until the line segment is drawn
                let yAxisToDraw = self.drawYAxis(section)
                //Add logo
                self.drawLogo(section)
                //Draw dotted lines for charts
                self.drawChart(section)
                //Draw labels on Y-axis coordinates
                self.drawYAxisLabel(yAxisToDraw)
                
                if section.key == "master" {
                    self.drawNow(section)
                }
                
                //Add the title to the main drawing layer
                self.drawLayer.addSublayer(section.titleLayer)
                
                //Whether to adopt user customization
                if let titleView = self.delegate?.kLineChart?(chart: self, viewForHeaderInSection: index) {
                    
                    //Display user-defined views, with the display content entrusted to the delegate
                    section.showTitle = false
                    section.addCustomView(titleView, inView: self)
                    
                } else {
                    
                    if let titleString = self.delegate?.kLineChart?(chart: self,
                                                                   titleForHeaderInSection: section,
                                                                   index: self.selectedIndex,
                                                                   item: self.datas[self.selectedIndex]) {
                        //Display user-defined section titles
                        section.drawTitleForHeader(title: titleString)
                    } else {
                        //Display the content of the last point in the range
                        section.drawTitle(self.selectedIndex)
                    }
                }
            }
            
            let showXAxisSection = self.getSecionWhichShowXAxis()
            //Draw X-axis coordinates below the partition
            self.drawXAxisLabel(showXAxisSection, xAxisToDraw: xAxisToDraw)
            
            //Redisplay the coordinates selected by clicking
            //self.setSelectedIndexByPoint(self.selectedPoint)
            
            self.delegate?.didFinishKLineChartRefresh?(chart: self)
        }
        
    }
    
    /**
Draw a chart
     
     - parameter rect:
 
    override open func draw(_ rect: CGRect) {
        
    }
    */
    
    /**
Initialize Chart Structure
     
-Returns: Whether to initialize data
     */
    fileprivate func initChart() -> Bool {
        
        self.plotCount = self.delegate?.numberOfPointsInKLineChart(chart: self) ?? 0
        
        //Inconsistent number of data entries, need to recalculate
        if self.plotCount != self.datas.count {
            self.resetData()
        }
        
        if plotCount > 0 {
            
            //If all are displayed, the display range is the total amount of data
            if self.isShowAll {
                self.range = self.plotCount
                self.rangeFrom = 0
                self.rangeTo = self.plotCount
            }
            
            //When refreshing the chart and scrolling to the default, if it is initialized for the first time, it will scroll to the last display by default
            if self.scrollToPosition == .none {
                //If the index at the end of the chart is 0, initialize it
                if self.rangeTo == 0 || self.plotCount < self.rangeTo {
                    self.scrollToPosition = .end
                }
            }
            
            
            if self.scrollToPosition == .top {
                self.rangeFrom = 0
                if self.rangeFrom + self.range < self.plotCount {
                    self.rangeTo = self.rangeFrom + self.range   //The position of the display at the end of the calculation
                } else {
                    self.rangeTo = self.plotCount
                }
                self.selectedIndex = -1
            } else if self.scrollToPosition == .end {
                //Less than 41
//                if plotCount < minDataCount {
//                    self.rangeTo = self.plotCount - 1             //The default is the end of the last data entry
//                    if plotCount > 36 {
//                        self.rangeFrom = plotCount - 36
//                    }else {
//                        self.rangeFrom = 0
//                    }
//                }else {
                    self.rangeTo = self.plotCount               //The default is the end of the last data entry
                    if self.rangeTo - self.range > 0 {          //If the end - default display number is greater than 0
                        self.rangeFrom = self.rangeTo - range   //Calculate the position of the display at the beginning
                    } else {
                        self.rangeFrom = 0
                    }
                    self.selectedIndex = -1
//                }
            }
            
        }
//        #if DEBUG
//Print (" nTotal of  (self. plotCount) candles,  n draw from  (self. rangeFrom) to  (self. rangeTo),  n range  (self. range),  n sliding trend is  (self. scrollToPosition)")
//        #endif
      
        
        //Reset chart refresh scrolling default not handled
        self.scrollToPosition = .none
        
        //Select the last element to select
        if selectedIndex == -1 {
            self.selectedIndex = self.rangeTo - 1
        }
        
        let backgroundLayer = CHShapeLayer()
        let backgroundPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.bounds.size.width,height: self.bounds.size.height), cornerRadius: 0)
        backgroundLayer.path = backgroundPath.cgPath
        backgroundLayer.fillColor = self.backgroundColor?.cgColor
        self.drawLayer.addSublayer(backgroundLayer)
//        let context = UIGraphicsGetCurrentContext()
//        context?.setFillColor(self.backgroundColor!.cgColor)
//        context?.fill (CGRect (x: 0, y: 0, width: self.bounds.size.width,height: self.bounds.size.height))
        
        if EXThemeManager.current != .day {
            let gradLayer = CAGradientLayer()
            gradLayer.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width,height: self.bounds.size.height)
            gradLayer.colors = [
                UIColor.extColorWithHex("#010101").cgColor,
                UIColor.extColorWithHex("#111111").cgColor,
            ]
            self.drawLayer.addSublayer(gradLayer)
        }

        return self.datas.count > 0 ? true : false
    }
    
    /**
Initialize each partition
     
-Parameter complete: After initialization, perform each partition drawing
     */
    fileprivate func buildSections(
        _ complete:(_ section: CHSection, _ index: Int) -> Void) {
        //Calculate the actual display height and width
        var height = self.frame.size.height - (self.padding.top + self.padding.bottom)
        let width  = self.frame.size.width - (self.padding.left + self.padding.right)
        
        let xAxisHeight = self.delegate?.heightForXAxisInKLineChart?(in: self) ?? self.kXAxisHegiht
        height = height - xAxisHeight
        
        var total = 0
        for (index, section) in self.sections.enumerated() {
            section.index = index
            if !section.hidden {
                //If using fixHeight, set to 0
                if section.ratios > 0 {
                    total = total + section.ratios
                }
            }
            
        }
        
        var offsetY: CGFloat = self.padding.top
        //Calculate the height of each area and draw
        for (index, section) in self.sections.enumerated() {

            var heightOfSection: CGFloat = 0
            let WidthOfSection = width
            if section.hidden {
                continue
            }
            //Calculate the height of each area
            //If fixHeight is greater than 0, limited use of fixHeight to set the height,
            if section.fixHeight > 0 {
                heightOfSection = section.fixHeight
                height = height - heightOfSection
            } else {
                heightOfSection = height * CGFloat(section.ratios) / CGFloat(total)
            }
            
            
            self.yAxisLabelWidth = (self.delegate?.widthForYAxisLabelInKLineChart?(in: self) ?? self.kYAxisLabelWidth)
            
            //Label display orientation on the y-axis
            switch self.showYAxisLabel {
            case .left:         //Left display
                section.padding.left = self.isInnerYAxis ? section.padding.left : self.yAxisLabelWidth
                section.padding.right = 0
            case .right:        //Display on the right
                section.padding.left = 0
                section.padding.right = self.isInnerYAxis ? section.padding.right : self.yAxisLabelWidth
            case .none:         //Not displayed
                section.padding.left = 0
                section.padding.right = 0
            }
            
            //Calculate the coordinates of each section
            section.frame = CGRect(x: 0 + self.padding.left,
                                       y: offsetY, width: WidthOfSection, height: heightOfSection)
            offsetY = offsetY + section.frame.height
            
            //If this partition is set to display the X-axis, the Y starting position of the next partition should be added with the X-axis height
            if self.showXAxisOnSection == index {
                offsetY = offsetY + xAxisHeight
            }
            
            complete(section, index)
            
        }
        
        
        
    }
    
    
    /**
Draw labels on the X-axis
     
-Parameter padding: inner margin
-Parameter width: total width
     */
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
        var xTickInterval: Int = dataRange / self.xAxisPerInterval
        if xTickInterval <= 0 {
            xTickInterval = 1
        }
    
        //Draw x-axis labels
        //Interval width of each point
        let perPlotWidth: CGFloat = (secWidth - secPaddingLeft - secPaddingRight) / CGFloat(self.rangeTo - self.rangeFrom)
        let startY = section.frame.maxY
        var k: Int = 0
        var showXAxisReference = true
        
        var loopStartIdx = 0
        let loopEndIdx = (self.rangeTo - self.rangeFrom)/xTickInterval
        
//        if section.valueType == .master {
//            print("master StartX=\(startX),plotWidth=\(perPlotWidth)")
//            print("master secWidth=\(secWidth),secPaddingLeft=\(secPaddingLeft),secPaddingRight=\(secPaddingRight)")
//            print("master rangeTo=\(rangeTo),rangeFrom=\(rangeFrom)")
//
//        }else if section.valueType == .assistant {
//            print("assis StartX=\(startX),plotWidth=\(perPlotWidth)")
//            print("assis secWidth=\(secWidth),secPaddingLeft=\(secPaddingLeft),secPaddingRight=\(secPaddingRight)")
//            print("assis rangeTo=\(rangeTo),rangeFrom=\(rangeFrom)")
//        }
        
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
                xPox = endX - textSize.width
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
            case let .dash(color: dashColor, pattern: _):
                referenceLayer.strokeColor = dashColor.cgColor
//                referenceLayer.lineDashPattern = pattern
                showXAxisReference = true
            case let .solid(color: solidColor):
                referenceLayer.strokeColor = solidColor.cgColor
                showXAxisReference = true
            default:
                showXAxisReference = false
            }
            
            //Need to draw auxiliary lines on the x-axis
            if loopStartIdx > 0, loopStartIdx < loopEndIdx {
                if showXAxisReference {
                     referencePath.move(to: CGPoint(x: xPox + textSize.width / 2, y: 0))
                    referencePath.addLine(to: CGPoint(x: xPox + textSize.width / 2, y: section.frame.maxY))
                    referenceLayer.path = referencePath.cgPath
                    xAxis.addSublayer(referenceLayer)
                }
                
            }
            loopStartIdx += 1
            k = k + xTickInterval
            startX = perPlotWidth * CGFloat(k)
        }
        
        self.drawLayer.addSublayer(xAxis)

        return xAxisToDraw
    }
    
    
    ///Draw X-coordinate labels
    ///
    /// - Parameters:
    ///- section: Which partition is drawn
    ///- xAxisToDraw: The content to be drawn
    fileprivate func drawXAxisLabel(_ section: CHSection, xAxisToDraw: [(CGRect, String)]) {
        
        guard self.showXAxisLabel else {
            return
        }
        
        guard xAxisToDraw.count > 0 else {
            return
        }
        
        let xAxis = CHShapeLayer()
        
        let startY = section.frame.maxY //The partition that needs to display the name of the x-coordinate label is displayed at the bottom
        //Draw an x coordinate label, and calculate the position of x by drawing an auxiliary line
        for (var barLabelRect, xLabel) in xAxisToDraw {
            
            barLabelRect.origin.y = startY
            
            //Draw Text
            let xLabelText = CHTextLayer()
            xLabelText.frame = barLabelRect
            xLabelText.string = xLabel
            xLabelText.alignmentMode = .center
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
Draw partition
     
     - parameter section:
     */
    fileprivate func drawSection(_ section: CHSection) {
        
        //Draw the background of the partition
//        print("========== Draw Section")
        let sectionPath = UIBezierPath(rect: section.frame)
        let sectionLayer = CHShapeLayer()
        sectionLayer.fillColor = section.backgroundColor.cgColor
        sectionLayer.path = sectionPath.cgPath
        self.drawLayer.addSublayer(sectionLayer)
        
        let borderPath = UIBezierPath()
        //Draw lower edge lines
        if self.borderWidth.bottom > 0 {
            
            borderPath.append(UIBezierPath(rect: CGRect(x: section.frame.origin.x + section.padding.left, y: section.frame.size.height + section.frame.origin.y, width: section.frame.size.width - section.padding.left, height: self.borderWidth.bottom)))
        
        }


        //Draw top edge line
        if self.borderWidth.top > 0 {
            
            borderPath.append(UIBezierPath(rect: CGRect(x: section.frame.origin.x + section.padding.left, y: section.frame.origin.y, width: section.frame.size.width - section.padding.left, height: self.borderWidth.top)))
            
        }
        
        //Draw right line
        if self.borderWidth.right > 0 {
            borderPath.append(UIBezierPath(rect: CGRect(x: section.frame.origin.x + section.frame.size.width - section.padding.right, y: 0, width: self.borderWidth.left, height: section.frame.maxY)))
        }
        
        //Add to Layer
        let borderLayer = CHShapeLayer()
        borderLayer.lineWidth = self.lineWidth
        borderLayer.strokeColor = UIColor.ThemekLine.viewSeperator.cgColor
        borderLayer.path = borderPath.cgPath  //Obtaining Shape from Bezier Curve
        borderLayer.fillColor = self.lineColor.cgColor //Color of closed-loop filling
        self.drawLayer.addSublayer(borderLayer)
        
        if EXThemeManager.current != .day {
            let gradLayer = CAGradientLayer()
            gradLayer.frame = section.frame
            gradLayer.colors = [
                UIColor.extColorWithHex("#010101").cgColor,
                UIColor.extColorWithHex("#111111").cgColor,
            ]
            self.drawLayer.addSublayer(gradLayer)
        }
    }
    
    /**
Initialize the Y-axis of each line on the partition
     */
    fileprivate func initYAxis(_ section: CHSection) {
        
        if section.series.count > 0 {
            //Establish a coordinate system for each line in the partition
//            print("======== initYAxis")
            section.buildYAxis(startIndex: self.rangeFrom, endIndex: self.rangeTo, datas: self.datas)
        }
        
    }
    
    /**
Draw the left side of the Y-axis
     
-Parameter section: partition
     */
    fileprivate func drawYAxis(_ section: CHSection) -> [(CGRect, String)] {
        
        var yAxisToDraw = [(CGRect, String)]()
        var valueToDraw = Set<CGFloat>()
 
        var startX: CGFloat = 0, startY: CGFloat = 0, extrude: CGFloat = 0
        var showYAxisLabel: Bool = true
        var showYAxisReference: Bool = true

        //The labels of each y-axis dashed line and y-axis in the partition
        //Control whether the label of the y-axis is displayed on the left or right
        switch self.showYAxisLabel {
        case .left:
            startX = section.frame.origin.x - 3 * (self.isInnerYAxis ? -1 : 1)
            extrude = section.frame.origin.x + section.padding.left - 2
        case .right:
            startX = section.frame.maxX - self.yAxisLabelWidth + 3 * (self.isInnerYAxis ? -1 : 1) - 2
            extrude = section.frame.origin.x + section.padding.left + section.frame.size.width - section.padding.right
            
        case .none:
            showYAxisLabel = false
        }
        

        let yaxis = section.yAxis
        
        //Maintain even number of Y-axis labels displayed
//        if (yaxis.tickInterval % 2 == 1) {
//            yaxis.tickInterval += 1
//        }
        
        //Calculate how many segments the y-axis labels and dashed lines are divided into
        let step = (yaxis.max - yaxis.min) / CGFloat(yaxis.tickInterval)
        
        //Draw Y-axis labels from base value to maximum value
        var i = 0
        var yVal = yaxis.baseValue + CGFloat(i) * step
        while yVal <= yaxis.max && i <= yaxis.tickInterval {
            
            valueToDraw.insert(yVal)
            
            //Increment Next
            i =  i + 1
            yVal = yaxis.baseValue + CGFloat(i) * step
            
        }
        
        i = 0
        yVal = yaxis.baseValue - CGFloat(i) * step
        while yVal >= yaxis.min && i <= yaxis.tickInterval {
            
            valueToDraw.insert(yVal)
            
            //Increment Next
            i =  i + 1
            yVal = yaxis.baseValue - CGFloat(i) * step
        }
        let minValue = valueToDraw.min()
        let maxValue = valueToDraw.max()

        for (i, yVal) in valueToDraw.enumerated() {
            
            
            //Draw dashed lines and Y label values
            let iy = section.getLocalY(yVal)
            
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
            switch section.yAxis.referenceStyle {
            case let .dash(color: dashColor, pattern: _):
                referenceLayer.strokeColor = dashColor.cgColor
//                referenceLayer.lineDashPattern = pattern
                showYAxisReference = true
            case let .solid(color: solidColor):
                referenceLayer.strokeColor = solidColor.cgColor
                showYAxisReference = true
            default:
                showYAxisReference = false
                startY = iy - 7
            }
            
            if showYAxisReference {
                if let min = minValue,let max = maxValue {
                    if yVal > min, yVal < max {
                        if !self.isInnerYAxis {
                            referencePath.move(to: CGPoint(x: extrude, y: iy))
                            referencePath.addLine(to: CGPoint(x: extrude + 2, y: iy))
                        }
                        
                        referencePath.move(to: CGPoint(x: section.frame.origin.x + section.padding.left, y: iy))
                        referencePath.addLine(to: CGPoint(x: section.frame.origin.x + section.frame.size.width , y: iy))
                        
                        referenceLayer.path = referencePath.cgPath
                        self.drawLayer.addSublayer(referenceLayer)
                    }
                }
            }
            
            if showYAxisLabel {
                
                //Obtain the label string value of the caller callback
                let strValue = self.delegate?.kLineChart(chart: self, labelOnYAxisForValue: yVal, atIndex: i, section: section) ?? ""
                
                var labelY = startY
                if yVal == minValue {
                    labelY = startY + 6
                }else if yVal == maxValue {
                    labelY = startY + 10
                }
//                let labelY = (yVal == maxValue) ? startY + 10 : startY
                
                let yLabelRect = CGRect(x: startX,
                                        y: labelY,
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
            yAxisLabel.string = strValue
            yAxisLabel.fontSize = self.labelFont.pointSize
            yAxisLabel.foregroundColor =  self.textColor.cgColor
            yAxisLabel.backgroundColor = UIColor.clear.cgColor
            yAxisLabel.alignmentMode = alignmentMode
            yAxisLabel.contentsScale = UIScreen.main.scale
            yAxisLabel.zPosition = 101
            self.drawLayer.addSublayer(yAxisLabel)
            
            //NSString(string: strValue).draw(in: yLabelRect, withAttributes: fontAttributes)
        }
    }
    
    /**
Draw dotted lines on the chart
     
     - parameter section:
     */
    func drawChart(_ section: CHSection) {
//        print("============ drawChart")
        if section.paging {
            //If the section is displayed in pagination, read the currently displayed series
            let serie = section.series[section.selectedIndex]
            let seriesLayer = self.drawSerie(serie)
            section.sectionLayer.addSublayer(seriesLayer)
            
        } else {
            //Display without pagination, draw all series on the chart
            for serie in section.series {
                let seriesLayer = self.drawSerie(serie)
                section.sectionLayer.addSublayer(seriesLayer)
            }
        }
        section.sectionLayer.zPosition = 100
        self.drawLayer.addSublayer(section.sectionLayer)
    }
    
//
    func drawLogo(_ section: CHSection) {
//        guard let imgStr = section.logo else {return}
//        if let imgUrl = URL.init(string: imgStr) {
//            let logoLayer = CALayer()
//            if EXHomeViewModel.homepageStyle() == .king{
//                logoLayer.yy_setImage(with: nil, placeholder: UIImage.themeImageNamedFromPod(imageName: "king_logo"))
//            }else {
//                logoLayer.yy_setImage(with:imgUrl, options: YYWebImageOptions.setImageWithFadeAnimation)
//            }
//            logoLayer.frame = section.frame
//            logoLayer.zPosition = 100
//            logoLayer.contentsScale = UIScreen.main.scale
//            logoLayer.contentsGravity = CALayerContentsGravity.topLeft
//            self.drawLayer .addSublayer(logoLayer)
//        }
    }
    
    /**
Draw a series of points on a chart partition first
     */
    func drawSerie(_ serie: CHSeries) -> CHShapeLayer {
//        print("============ drawSerie")

        if !serie.hidden {
            //Loop the lines of each model
            for model in serie.chartModels {
//                print("============ rangeFrom\(self.rangeFrom)")
//                print("============ rangeTo\(self.rangeTo)")
                
                let serieLayer = model.drawSerie(self.rangeFrom, endIndex: self.rangeTo)
                serie.seriesLayer.addSublayer(serieLayer)
            }
        }
        
        return serie.seriesLayer
    }
    

    
}

//MARK: - Public Method
extension CHKLineChartView {
    
    /**
refresh the view
     */
    public func reloadData(toPosition: CHChartViewScrollPosition = .none, resetData: Bool = true) {
        self.scrollToPosition = toPosition
        self.range = 40
        if resetData {
            self.resetData()
        }
        self.drawLayerView()
    }
    
    public func reloadPreData(){
        self.scrollToPosition = .none
        self.range = 40
        self.rangeFrom += 300
        self.rangeTo += 300
        self.resetData()
        self.drawLayerView()
    }
    
    
    ///Refresh Style
    ///
    ///- Parameter style: New style
    public func resetStyle(style: CHKLineChartStyle) {
        self.style = style
        self.showSelection = false
        self.reloadData()
    }
    
    ///Hide or display line series through key
    ///When inSection=-1, all sections are hidden, otherwise only the corresponding indexed sections are hidden
    ///When key="", set all lines to be displayed or hidden
    public func setSerie(hidden: Bool, by key: String = "", inSection: Int = -1) {
        
        var hideSections = [CHSection]()
        if inSection < 0 {
            hideSections = self.sections
        } else {
            if inSection >= self.sections.count {
                return //Beyond limits
            }
            hideSections.append(self.sections[inSection])
        }
        for section in hideSections {
            for (index, serie)  in section.series.enumerated() {
                if key == "" {
                    if section.paging {
                        section.selectedIndex = 0
                    } else {
                        serie.hidden = hidden
                    }
                } else if serie.key == key {
                    if section.paging {
                        if hidden == false {
                            section.selectedIndex = index
                        }
                    } else {
                        serie.hidden = hidden
                    }
                    
                    break
                }
            }
        
        }
  
//        self.drawLayerView()
    }
    
    /**
Hiding or displaying partitions through key
     */
    public func setSection(hidden: Bool, byKey key: String) {
        for section in self.sections {
            //Only secondary images can be hidden
            if section.key == key && section.valueType == .assistant {
                section.hidden = hidden
                break
            }
        }

        
//        self.drawLayerView()
    }
    
    /**
Hide or show partitions through index bits
     */
    public func setSection(hidden: Bool, byIndex index: Int) {
        //Only secondary images can be hidden
        guard let section = self.sections[safe: index], section.valueType == .assistant else {
            return
        }
        
        section.hidden = hidden
        
        
//        self.drawLayerView()
    }
    
    
    ///Zoom Chart
    ///
    /// - Parameters:
    ///- interval: offset
    ///- enlarge: Whether to enlarge the operation
    public func zoomChart(by interval: Int, enlarge: Bool) {
//        print("Departure scale  (interval), behavior:  (enlarge)")
        
        var newRangeTo = 0
        var newRangeFrom = 0
        var newRange = 0
        
        if enlarge {
            //Open both fingers
            newRangeTo = self.rangeTo - interval
            newRangeFrom = self.rangeFrom + interval
            newRange = self.rangeTo - self.rangeFrom
            if newRange >= kMinRange {
                
                if self.plotCount > self.rangeTo - self.rangeFrom {
                    if newRangeFrom < self.rangeTo {
                        self.rangeFrom = newRangeFrom
                    }
                    if newRangeTo > self.rangeFrom {
                        self.rangeTo = newRangeTo
                    }
                }else{
                    if newRangeTo > self.rangeFrom {
                        self.rangeTo = newRangeTo
                    }
                }
                self.range = self.rangeTo - self.rangeFrom
                self.drawLayerView()
            }
            
        } else {
            //Double finger closure
            newRangeTo = self.rangeTo + interval
            newRangeFrom = self.rangeFrom - interval
            newRange = self.rangeTo - self.rangeFrom
            if newRange <= kMaxRange {
                
                if newRangeFrom >= 0 {
                    self.rangeFrom = newRangeFrom
                } else {
                    self.rangeFrom = 0
                    newRangeTo = newRangeTo - newRangeFrom //Add negative digits to the header
                }
                if newRangeTo <= self.plotCount {
                    self.rangeTo = newRangeTo
                    
                } else {
                    self.rangeTo = self.plotCount
                    newRangeFrom = newRangeFrom - (newRangeTo - self.plotCount)
                    if newRangeFrom < 0 {
                        self.rangeFrom = 0
                    } else {
                        self.rangeFrom = newRangeFrom
                    }
                }
                self.range = self.rangeTo - self.rangeFrom
                self.drawLayerView()
            }
        }
        
    }
    
    
    ///Pan Chart Left and Right
    ///
    /// - Parameters:
    ///- interval: Move the number of columns
    ///- direction: direction, true: right sliding operation, false: left sliding operation
    public func moveChart(by interval: Int, direction: Bool) {
        self.delegate?.kLineChartScrolled?()
        self.showSelection = false
        self.sightView?.isHidden = true
        
        if (interval > 0) {                     //Only move when there is a movement interval
            
            if direction {
                //Single point right drag to view data backwards
                if self.plotCount > (self.rangeTo-self.rangeFrom) {
                    if self.rangeFrom - interval >= 0 {
                        self.rangeFrom -= interval
                        self.rangeTo   -= interval
                        
                    } else {
                        self.rangeFrom = 0
                        self.rangeTo -= self.rangeFrom
                        
                    }
                    if self.rangeFrom == 0,self.datas.count >= 300 {
                        self.delegate?.kLinePrePage?()
                    }

                    #if DEBUG
//Print (" nTotal of  (self. plotCount) candles,  n draw from  (self. rangeFrom) to  (self. rangeTo),  n range  (self. range),  n sliding trend is  (self. scrollToPosition)")
                    #endif
                    
                    self.drawLayerView()
                }
            } else {
                //Single point left drag to view data forward
                if self.plotCount > (self.rangeTo-self.rangeFrom) {
                    if self.rangeTo + interval <= self.plotCount {
                        self.rangeFrom += interval
                        self.rangeTo += interval
                    } else {
                        self.rangeFrom += self.plotCount - self.rangeTo
                        self.rangeTo  = self.plotCount
                    }

                    self.drawLayerView()
                }
            }
        }
        self.range = self.rangeTo - self.rangeFrom
    }
    
    ///Generate screenshots
    open var image: UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let capturedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return capturedImage!
    }
    
    
    ///Manually set the display content of partition header text
    ///
    /// - Parameters:
    ///- titles: Text content and color tuples
    ///- section: Partition location
    open func setHeader(titles: [(title: String, color: UIColor)], inSection section: Int)  {
        guard let section = self.sections[safe: section] else {
            return
        }
        
        //Set Title
        section.setHeader(titles: titles)
    }
    
    
    ///Add a new segment to the partition
    ///
    /// - Parameters:
    ///- series: line segments
    ///- section: Partition location
    open func addSeries(_ series: CHSeries, inSection section: Int) {
        guard let section = self.sections[safe: section] else {
            return
        }
        section.series.append(series)
        
        self.drawLayerView()
    }
    
    
    ///Delete segment to partition through primary key name
    ///
    /// - Parameters:
    ///- key: primary key
    ///- section: Partition location
    open func removeSeries(key: String, inSection section: Int) {
        guard let section = self.sections[safe: section] else {
            return
        }
        
        section.removeSeries(key: key)
        
        self.drawLayerView()
    }
}


//MARK: - Gesture operation
extension CHKLineChartView: UIGestureRecognizerDelegate {
    
    
    ///Control gesture switch
    ///
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        switch gestureRecognizer {
        case is UITapGestureRecognizer:
            return self.enableTap
        case is UIPanGestureRecognizer:
            return self.enablePan
        case is UIPinchGestureRecognizer:
            return self.enablePinch
        default:
            return false
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        //Long press, zoom in, and zoom out, all by yourself
        if gestureRecognizer is UILongPressGestureRecognizer ||
            gestureRecognizer is UIPinchGestureRecognizer {
            return false
        }
        if let vertipan = gestureRecognizer as? PanDirectionGestureRecognizer {
            return vertipan.direction == .vertical
        }else {
            return true
        }
    }
    
    
    ///Pan drag operation
    ///
    ///- Parameter sender: gesture
    @objc func doPanAction(_ sender: PanDirectionGestureRecognizer) {
        
        guard self.enablePan else {
            return
        }
        if sender.direction == .vertical {
            return
        }
        
        self.showSelection = false
        self.sightView?.isHidden = true
        //Total translation of finger sliding
        let translation = sender.translation(in: self)
        //Sliding force, used to achieve inertial rolling effect when releasing fingers
        let velocity =  sender.velocity(in: self)
        
        //Obtain one of the visible partitions
        let visiableSection = self.sections.filter { !$0.hidden }
        guard let section = visiableSection.first else {
            return
        }
        
        //The interval width of each point in this partition
        let plotWidth = (section.frame.size.width - section.padding.left - section.padding.right) / CGFloat(self.rangeTo - self.rangeFrom)
        
        switch sender.state {
        case .began:
            self.animator.removeAllBehaviors()
            self.delegate?.kLineChartScrolled?()
        case .changed:
            
            //Calculate the absolute value of the movement distance. If the distance exceeds the line width, perform chart translation refresh
            let distance = fabs(translation.x)
//            print("translation.x = \(translation.x)")
//            print("distance = \(distance)")
            if distance > plotWidth {
                let isRight = translation.x > 0 ? true : false
                let interval = lroundf(fabs(Float(distance / plotWidth)))
                self.moveChart(by: interval, direction: isRight)
                //Recalculate start bit
                sender.setTranslation(CGPoint(x: 0, y: 0), in: self)
            }
            self.delegate?.kLineChartScrolled?()

        case .ended, .cancelled:
            
            //Reset deceleration start
            self.decelerationStartX = 0
            //Add deceleration behavior
            self.dynamicItem.center = self.bounds.origin
            let decelerationBehavior = UIDynamicItemBehavior(items: [self.dynamicItem])
            decelerationBehavior.addLinearVelocity(velocity, for: self.dynamicItem)
            decelerationBehavior.resistance = 2.0
            decelerationBehavior.action = {
                [weak self]() -> Void in
                //print("self.dynamicItem.x = \(self?.dynamicItem.center.x ?? 0)")
                
                //Do not perform movement to the boundary
//                if self?.rangeFrom == 0 || self?.rangeTo == self?.plotCount{
//                    return
//                }
                if self?.rangeFrom == 0 {
                    return
                }

                let itemX = self?.dynamicItem.center.x ?? 0
                let startX = self?.decelerationStartX ?? 0
                //Calculate the absolute value of the movement distance. If the distance exceeds the line width, perform chart translation refresh
                let distance = fabs(itemX - startX)
                //            print("distance = \(distance)")
                if distance > plotWidth {
                    let isRight = itemX > 0 ? true : false
                    let interval = lroundf(fabs(Float(distance / plotWidth)))
                    self?.moveChart(by: interval, direction: isRight)
                    //Recalculate start bit
                    self?.decelerationStartX = itemX
                }
            }
            
            //Add dynamic behavior
            self.animator.addBehavior(decelerationBehavior)
            self.decelerationBehavior = decelerationBehavior
            self.delegate?.kLineChartScrolled?()

        default:
            break
        }
    }
    
    /**
*Click Event Handling
     *
     *  @param sender
     */
    @objc func doTapAction(_ sender: UITapGestureRecognizer) {
        
        guard self.enableTap else {
            return
        }
   
        
        var point = sender.location(in: self)
        let (_, section) = self.getSectionByTouchPoint(point)
        if let tapSection = section{
            if tapSection.paging {
                //Show Next Page
                tapSection.nextPage()
                self.drawLayerView()
                self.delegate?.kLineChart?(chart: self, didFlipPageSeries: tapSection, series: tapSection.series[tapSection.selectedIndex], seriesIndex: section!.selectedIndex)
            } else {
                //Display the selected content by clicking
                if tapSection.valueType == .master {
                    
                    if self.datas.count > self.range {
                        let showLast = (rangeTo == self.datas.count)
                        if showLast {
                            point.x += 60
                        }
                    }
                    self.setSelectedIndexByPoint(point)
                }else {
                    self.showSelection = false
                    self.sightView?.isHidden = !self.showSelection
                    self.delegate?.kLineChartPinched?()
                }
            }
            
        }
    }
    
    
    
    ///Double Finger Gesture Zoom Chart
    ///
    ///- Parameter sender: gesture
    @objc func doPinchAction(_ sender: UIPinchGestureRecognizer) {
        
        guard self.enablePinch else {
            return
        }
        self.showSelection = false
        self.sightView?.isHidden = !self.showSelection

        //Obtain one of the visible partitions
        let visiableSection = self.sections.filter { !$0.hidden }
        guard let section = visiableSection.first else {
            return
        }
        
        if self.datas.count < minDataCount {
            return
        }
        
        //The interval width of each point in this partition
        let plotWidth = (section.frame.size.width - section.padding.left - section.padding.right) / CGFloat(self.rangeTo - self.rangeFrom)
        
        if plotWidth.isNaN {
            return
        }
        
        //Close or open both fingers
        let scale = sender.scale
        var newRange = 0
        
        
        
        //Calculate a new column width based on the magnification ratio
        let newPlotWidth = plotWidth * scale
        
        let newRangeF = (section.frame.size.width - section.padding.left - section.padding.right) / newPlotWidth
        newRange = scale > 1 ? Int(newRangeF + 1) : Int(newRangeF)
        let distance = abs(self.range - newRange)
        //Enlarge and reduce the distance to an even number
        if distance % 2 == 0 && distance > 0 {
//            print("scale = \(scale)")
            let enlarge = scale > 1 ? true : false
            self.zoomChart(by: distance / 2, enlarge: enlarge)
            sender.scale = 1    //Recovery ratio
        }

        self.delegate?.kLineChartPinched?()
    }
    
    
    ///Long press operation for processing
    ///
    /// - Parameter sender:
    @objc func doLongPressAction(_ sender: UILongPressGestureRecognizer) {
        var point = sender.location(in: self)
        let (_, section) = self.getSectionByTouchPoint(point)
        if section != nil {
            if !section!.paging {
                //Display the selected content by clicking
                //Display the selected content by clicking
                if section?.valueType == .master {
                    if self.datas.count > self.range {
                        let showLast = (rangeTo == self.datas.count)
                        if showLast {
                            point.x += 60
                        }
                    }
                    self.setSelectedIndexByPoint(point)
                }
            }
            
//            self.drawLayerView()
        }
    }
}
///Cross H
class HorizontalXLineView:UIView {
    
    override var isHidden: Bool {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func layoutSubviews() {
        self.alpha = 0.3
    }
    
    override func draw(_ rect: CGRect) {
       
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        let colors = [UIColor.ThemekLine.viewBg.cgColor,UIColor.ThemekLine.viewbgIcon25.cgColor]
        
//        let colors = [UIColor.red.cgColor,UIColor.green.cgColor]

        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let colorLocations: [CGFloat] = [0.0, 0.4]
        
        let gradient = CGGradient(colorsSpace: colorSpace,
                                  colors: colors as CFArray,
                                  locations: colorLocations)!
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x: 0, y: bounds.height)
        context.drawLinearGradient(gradient,
                                   start: startPoint,
                                   end: endPoint,
                                   options: [])
        
    }

}
///Cross Sign V
class SelectedYAxisLabel :UIView {
    
    @IBInspectable var topInset: CGFloat = 0
    @IBInspectable var bottomInset: CGFloat = 0
    @IBInspectable var leftInset: CGFloat = 12.0
    @IBInspectable var rightInset: CGFloat = 0.0
    var indexLabel = UILabel()
    
    var fillcolor = UIColor.clear{
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configSubLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configSubLabel() {
        self.backgroundColor = UIColor.ThemekLine.viewBg
        self.addSubview(indexLabel)
        indexLabel.textAlignment = .right
        indexLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-2)
            make.height.equalToSuperview()
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(14)
        }
    }
    

    override func draw(_ rect: CGRect) {
        self.backgroundColor = UIColor.clear
        let path = UIBezierPath.init()
        path .lineWidth = 1.0
        path .move(to: CGPoint(x: leftInset, y: 1))
        path .addLine(to:CGPoint(x:rect.width,y:1))
        path .addLine(to:CGPoint(x:rect.width,y:rect.height - 1))
        path .addLine(to:CGPoint(x:leftInset,y:rect.height - 1))
        path .addLine(to:CGPoint(x:0,y:rect.height/2))
        path .close()
        UIColor.ThemekLine.viewborder.setStroke()
        self.fillcolor.setFill()
        path.stroke()
        path.fill()

//        super.drawText(in: rect)

    }
    
    
//    override func drawText(in rect: CGRect) {
//        let labelInset = UIEdgeInsetsMake(0, leftInset, 0, 0)
//        super.drawText(in: UIEdgeInsetsInsetRect(rect, labelInset))
//    }
//
//    override var intrinsicContentSize: CGSize {
//        let size = super.intrinsicContentSize
//        return CGSize(width: size.width + leftInset + rightInset,
//                      height: size.height + topInset + bottomInset)
//    }
}

extension CHKLineChartView {
    
    func drawNow(_ section: CHSection) {
        
        var y = section.getLocalY(nowValue)
        

        if y < section.getLocalY(section.yAxis.max) {
            y = section.getLocalY(section.yAxis.max)
        }
        
        if y > section.frame.size.height + padding.top + padding.bottom {
            y = section.frame.size.height + padding.top + padding.bottom
        }
        
        if plotCount == self.rangeTo {
            
            nowLineView.isHidden = true

            var plotWidth = (section.frame.size.width - section.padding.left - section.padding.right) / CGFloat(self.rangeTo - self.rangeFrom)
            var hasLastOne = rangeTo == plotCount

            if self.datas.count < 41 {
                plotWidth = 10
                hasLastOne = false
            }
            let x = section.frame.origin.x + section.padding.left + CGFloat(self.rangeTo - self.rangeFrom) * plotWidth - (hasLastOne ? 60 : 0)
            let strValue = "\(nowValue)"
            nowValueLabel.text = strValue.decimalString1(section.decimal)
//            nowValueLabel.text = String(Double(nowValue))
            nowValueLabel.frame = CGRect.init(x: self.bounds.width - nowValueLabel.size.width - 5, y: y - 5, width: 70, height: 10)
            nowValueLabel.sizeToFit()
            
            nowValueLabel.isHidden = false
            let shapeLayer:CAShapeLayer = CHShapeLayer()
            
            shapeLayer.frame = CGRect.init(x: x, y: y, width: self.bounds.width - x - nowValueLabel.bounds.width - 5, height: 6)
            
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.strokeColor = UIColor.ThemekLine.viewHighlight.cgColor

            shapeLayer.lineWidth = 1
            shapeLayer.lineJoin = CAShapeLayerLineJoin.round
            shapeLayer.lineDashPhase = 0
            shapeLayer.lineDashPattern = [NSNumber(value: 3), NSNumber(value: 3)]

            
            
            let path:UIBezierPath = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: self.bounds.width - x - nowValueLabel.bounds.width - 5, y: 0))
            shapeLayer.path = path.cgPath
            
            self.drawLayer.addSublayer(shapeLayer)
        }
        else {
            nowLineView.centerY = y
//            nowLineView.valueLabel.text = String(Double(nowValue))
            let strValue = "\(nowValue)"
            nowLineView.valueLabel.text = strValue.decimalString1(section.decimal)
            nowValueLabel.isHidden = true
            nowLineView.isHidden = false
        }
    }
    
}

///Dragging gesture
class PanDirectionGestureRecognizer: UIPanGestureRecognizer {

    enum PanDirection {
        case vertical
        case horizontal
    }

    let direction: PanDirection

    init(direction: PanDirection, target: AnyObject, action: Selector) {
        self.direction = direction
        super.init(target: target, action: action)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        guard let view = self.view else { return }

        if state == .began {
            let velocity = self.velocity(in: view)
            switch direction {
            case .horizontal where abs(velocity.y) > abs(velocity.x):
                state = .cancelled
            case .vertical where abs(velocity.x) > abs(velocity.y):
                state = .cancelled
            default:
                break
            }
        }
    }
}

