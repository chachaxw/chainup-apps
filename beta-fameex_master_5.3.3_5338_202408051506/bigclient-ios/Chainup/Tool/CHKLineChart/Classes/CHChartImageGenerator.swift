//
//  CHImageGenerator.swift
//  CHKLineChart
//
//  Created by Chance on 2023/6/22.
//  Copyright © 2023年 bitbank. All rights reserved.
//

import UIKit

///Simple Trend Chart Generator
public class CHChartImageGenerator: NSObject {

    public var values: [(Int, Double)] = [(Int, Double)]()
    public var chartView: CHKLineChartView!
    public var style: CHKLineChartStyle = CHKLineChartStyle.lineIMG
    
    
    ///Create a global singleton to generate screenshots of the chart
    public static let share: CHChartImageGenerator = {
        let generator = CHChartImageGenerator()
        return generator
    }()
    
    public override init() {
        super.init()
        self.chartView = CHKLineChartView(frame: CGRect.zero)
        self.chartView.style = CHKLineChartStyle.lineIMG
        self.chartView.delegate = self
    }
    
    
    ///Generate a screenshot of a chart using data sources and chart styles
    ///
    /// - Parameters:
    ///- values: data source
    ///- lineWidth: Line thickness
    ///- backgroundColor: Background color
    ///- lineColor: Line color
    ///- size: Image size
    ///- Returns: Chart image
    public func getImage(by values: [(Int, Double)],
                  lineWidth: CGFloat = 1,
                  backgroundColor: UIColor = UIColor.ThemekLine.viewBg,
                  lineColor: UIColor = UIColor.lightGray,
                  size: CGSize) -> UIImage {
        self.values = values
        self.style.backgroundColor = backgroundColor
        let section = self.style.sections[0]
        let model = section.series[0].chartModels[0]
        section.backgroundColor = backgroundColor
        model.upStyle = (lineColor, true)
        model.downStyle = (lineColor, true)
        model.lineWidth = lineWidth
        var frame = self.chartView.frame
        frame.size.width = size.width
        frame.size.height = size.height
        self.chartView.frame = frame
        self.chartView.style = self.style
        self.chartView.reloadData()
        return self.chartView.image
    }
    
}


//MARK: - Custom Style
extension CHKLineChartStyle {
   
    
    //Implement a simple chart with dots and lines for image display
    public static var lineIMG: CHKLineChartStyle {
        
        
        let style = CHKLineChartStyle()
        //font size
        style.labelFont = UIFont.systemFont(ofSize: 10)
        //Zone Border Color
        style.lineColor = UIColor.clear
        //background color 
        style.backgroundColor = UIColor.ch_hex(0xF5F5F5)
        //Text color
        style.textColor = UIColor(white: 0.8, alpha: 1)
        //The inner margin of the entire chart
        style.padding = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        //Is the Y-axis embedded
        style.isInnerYAxis = true
        //Display the X-axis coordinate content in which partition
        style.showXAxisOnSection = 0
        //The Y-axis is displayed on the right
        style.showYAxisLabel = .none
        //Display X-axis
        style.showXAxisLabel = false
        
        //Do you want to display all points
        style.isShowAll = true
        //Prohibit all gesture operations
        style.enablePan = false
        style.enableTap = false
        style.enablePinch = false
        
        
        //Configure Chart Processing Algorithm
        style.algorithms = [
            CHChartAlgorithm.timeline
        ]
        
        let priceSection = CHSection()
        priceSection.backgroundColor = style.backgroundColor
        //Whether the data text of the selected point displayed on the partition is displayed outside the partition
        priceSection.titleShowOutSide = false
        //Display data text for selected points
        priceSection.showTitle = false
        //Type of partition
        priceSection.valueType = .master
        //Partition Unique Key Value
        priceSection.key = "price"
        //Whether to hide partitions
        priceSection.hidden = false
        //The proportion of the partition to the chart, where 0 represents not using proportion and using a fixed height
        priceSection.ratios = 1
        //Style of Y-axis auxiliary line, solid line
        priceSection.yAxis.referenceStyle = .none
        //Partition Inner Margin
        priceSection.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        ///Time division line
        let timelineSeries = CHSeries.getTimelinePrice(
            color: UIColor.ch_hex(0xA4AAB3),
            section: priceSection,
            showGuide: true,
            ultimateValueStyle: .none,
            lineWidth: 1)
        
        priceSection.series = [timelineSeries]
        
        style.sections = [priceSection]
        
        
        return style
    }
    
}


//MARK: - Implement delegate method
extension CHChartImageGenerator: CHKLineChartDelegate {
    
    public func numberOfPointsInKLineChart(chart: CHKLineChartView) -> Int {
        return self.values.count
    }
    
    public func kLineChart(chart: CHKLineChartView, valueForPointAtIndex index: Int) -> CHChartItem {
        let data = self.values[index]
        let item = CHChartItem()
        item.time = Int(data.0 / 1000)
        item.closePrice = CGFloat(data.1)
        return item
    }
    
    ///Adjust the width of the Y-axis label
    ///
    /// - parameter chart:
    ///
    /// - returns:
    public func widthForYAxisLabelInKLineChart(in chart: CHKLineChartView) -> CGFloat {
        return chart.kYAxisLabelWidth
    }
    
    public func kLineChart(chart: CHKLineChartView, labelOnYAxisForValue value: CGFloat, atIndex index: Int, section: CHSection) -> String {
//        let strValue = value.ch_toString(maxF: section.decimal)
        return ""
    }
    
    public func kLineChart(chart: CHKLineChartView, labelOnXAxisForIndex index: Int) -> String {
        return ""
    }
    
    public func heightForXAxisInKLineChart(in chart: CHKLineChartView) -> CGFloat {
        return 0
    }

}

