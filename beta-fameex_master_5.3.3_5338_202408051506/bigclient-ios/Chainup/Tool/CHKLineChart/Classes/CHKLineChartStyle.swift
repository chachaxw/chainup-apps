//
//  CHKLineChartStyle.swift
//  CHKLineChart
//
//  Created by 麦志泉 on 2023/9/19.
//  Copyright © 2023年 Chance. All rights reserved.
//

import Foundation
import UIKit


///Max Min Display Style
///
///- none: Do not display
///- arrow: Arrow style
///- Circle: Hollow Circle Style
///- tag: Label style
public enum CHUltimateValueStyle {
    
    case none
    case arrow(UIColor)
    case circle(UIColor, Bool)
    case tag(UIColor)
}

//MARK: - Chart Style Configuration Class
open class CHKLineChartStyle {
    
    ///Partition Style Configuration
    open var sections: [CHSection] = [CHSection]()
    
    ///Algorithm to be processed
    open var algorithms: [CHChartAlgorithmProtocol] = [CHChartAlgorithmProtocol]()
    
    
    ///Background color
    open var backgroundColor: UIColor = UIColor.ThemekLine.viewBg
    
    ///Show edges with upper and lower left edges
    open var borderWidth: (top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) = (0.5, 0.5, 0.5, 0.5)
    
    /**
Margins
     
     - returns:
     */
    open var padding: UIEdgeInsets!
    
    //font size
    open var labelFont: UIFont!
    
    //line color
    open var lineColor: UIColor = UIColor.clear
    
    //Text color
    open var textColor: UIColor = UIColor.clear
    
    //The background color of the displayed box for the selected point
    open var selectedBGColor: UIColor = UIColor.clear
    
    //The text color displayed for the selected point
    open var selectedTextColor: UIColor = UIColor.clear
    
    //Display the position of y, default to the right
    open var showYAxisLabel = CHYAxisShowPosition.right
    
    ///Is the y-coordinate embedded in the chart
    open var isInnerYAxis: Bool = false
    
    //Is it scalable
    open var enablePinch: Bool = true
    //Can it slide
    open var enablePan: Bool = true
    //Can I click to select
    open var enableTap: Bool = true
    
    ///Whether to display the selected content
    open var showSelection: Bool = true
    
    ///Display the X coordinate content on which index partition, with a default value of -1, indicating the last one. If the user sets an overflow value, the last one will also be used
    open var showXAxisOnSection: Int = -1
    
    ///Display X-axis labels
    open var showXAxisLabel: Bool = true
    
    ///Do you want to display all content
    open var isShowAll: Bool = false
    
    
    ///Buyer's deep layer color
    open var bidColor: (stroke: UIColor, fill: UIColor, lineWidth: CGFloat) = (.white, .white, 1)
    
    ///Seller's deep layer color
    open var askColor: (stroke: UIColor, fill: UIColor, lineWidth: CGFloat) = (.white, .white, 1)
    
    ///Buying a single bedroom on the right
    open var bidChartOnDirection:CHKDepthChartOnDirection = .right
    
    public init() {
        
    }
}

//MARK: - Extended Style
public extension CHKLineChartStyle {
    
    //Implement a basic style that developers can freely extend and configure
    public static var base: CHKLineChartStyle {
        let style = CHKLineChartStyle()
        style.labelFont = UIFont.systemFont(ofSize: 10)
        style.lineColor = UIColor(white: 0.2, alpha: 1)
        style.textColor = UIColor(white: 0.8, alpha: 1)
        style.selectedBGColor = UIColor(white: 0.4, alpha: 1)
        style.selectedTextColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        style.padding = UIEdgeInsets(top: 32, left: 8, bottom: 4, right: 0)
        style.backgroundColor = UIColor.ch_hex(0x1D1C1C)
        style.showYAxisLabel = .right
        
        //Configure Chart Processing Algorithm
        style.algorithms = [
            CHChartAlgorithm.timeline,
            CHChartAlgorithm.sar(4, 0.02, 0.2), //Default cycle 4, minimum acceleration of 0.02, maximum acceleration of 0.2
            CHChartAlgorithm.ma(5),
            CHChartAlgorithm.ma(10),
            CHChartAlgorithm.ma(20),        //To calculate BOLL, it is necessary to first calculate MA of the same period
            CHChartAlgorithm.ma(30),
            CHChartAlgorithm.ema(5),
            CHChartAlgorithm.ema(10),
            CHChartAlgorithm.ema(12),       //To calculate MACD, it is necessary to first calculate the EMA of the same period
            CHChartAlgorithm.ema(26),       //To calculate MACD, it is necessary to first calculate the EMA of the same period
            CHChartAlgorithm.ema(30),
            CHChartAlgorithm.boll(20, 2),
            CHChartAlgorithm.macd(12, 26, 9),
            CHChartAlgorithm.kdj(9, 3, 3),
        ]
        
        //Zone Dot Line Style
        let upcolor = (UIColor.ch_hex(0xF80D1F), true)
        let downcolor = (UIColor.ch_hex(0x1E932B), true)
        let priceSection = CHSection()
        priceSection.backgroundColor = style.backgroundColor
        priceSection.titleShowOutSide = true
        priceSection.valueType = .master
        priceSection.key = "master"
        priceSection.hidden = false
        priceSection.ratios = 3
        priceSection.padding = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        
        ///Time division line
        let timelineSeries = CHSeries.getTimelinePrice(
            color: UIColor.ch_hex(0xAE475C),
            section: priceSection,
            showGuide: true,
            ultimateValueStyle: .circle(UIColor.ch_hex(0xAE475C), true),
            lineWidth: 2)
        
        timelineSeries.hidden = true
        
        ///Candle line
        let priceSeries = CHSeries.getCandlePrice(
            upStyle: upcolor,
            downStyle: downcolor,
            titleColor: UIColor(white: 0.8, alpha: 1),
            section: priceSection,
            showGuide: true,
            ultimateValueStyle: .arrow(UIColor(white: 0.8, alpha: 1)))
        
        priceSeries.showTitle = true
        
        priceSeries.chartModels.first?.ultimateValueStyle = .arrow(UIColor(white: 0.8, alpha: 1))
        
        let priceMASeries = CHSeries.getPriceMA(
            isEMA: false,
            num: [5,10,30],
            colors: [
                UIColor.ch_hex(0xDDDDDD),
                UIColor.ch_hex(0xF9EE30),
                UIColor.ch_hex(0xF600FF),
                ],
            section: priceSection)
        priceMASeries.hidden = false
        
        let priceEMASeries = CHSeries.getPriceMA(
            isEMA: true,
            num: [5,10,30],
            colors: [
                UIColor.ch_hex(0xDDDDDD),
                UIColor.ch_hex(0xF9EE30),
                UIColor.ch_hex(0xF600FF),
                ],
            section: priceSection)
        
        priceEMASeries.hidden = true
        
        let priceBOLLSeries = CHSeries.getBOLL(
            UIColor.ch_hex(0xDDDDDD),
            ubc: UIColor.ch_hex(0xF9EE30),
            lbc: UIColor.ch_hex(0xF600FF),
            section: priceSection)
        
        priceBOLLSeries.hidden = true
        
        let priceSARSeries = CHSeries.getSAR(
            upStyle: upcolor,
            downStyle: downcolor,
            titleColor: UIColor.ch_hex(0xDDDDDD),
            section: priceSection)
        
        priceSARSeries.hidden = true
        
        priceSection.series = [
            timelineSeries,
            priceSeries,
            priceMASeries,
            priceEMASeries,
            priceBOLLSeries,
            priceSARSeries
        ]
        
        let volumeSection = CHSection()
        volumeSection.backgroundColor = style.backgroundColor
        volumeSection.valueType = .assistant
        volumeSection.key = "volume"
        volumeSection.hidden = false
        volumeSection.ratios = 1
        volumeSection.yAxis.tickInterval = 4
        volumeSection.padding = UIEdgeInsets(top: 16, left: 0, bottom: 8, right: 0)
        let volumeSeries = CHSeries.getDefaultVolume(upStyle: upcolor, downStyle: downcolor, section: volumeSection)
        
        let volumeMASeries = CHSeries.getVolumeMA(
            isEMA: false,
            num: [5,10,30],
            colors: [
                UIColor.ch_hex(0xDDDDDD),
                UIColor.ch_hex(0xF9EE30),
                UIColor.ch_hex(0xF600FF),
                ],
            section: volumeSection)
        
        let volumeEMASeries = CHSeries.getVolumeMA(
            isEMA: true,
            num: [5,10,30],
            colors: [
                UIColor.ch_hex(0xDDDDDD),
                UIColor.ch_hex(0xF9EE30),
                UIColor.ch_hex(0xF600FF),
                ],
            section: volumeSection)
        
        volumeEMASeries.hidden = true
        volumeSection.series = [volumeSeries, volumeMASeries, volumeEMASeries]
        
        let trendSection = CHSection()
        trendSection.backgroundColor = style.backgroundColor
        trendSection.valueType = .assistant
        trendSection.key = "analysis"
        trendSection.hidden = false
        trendSection.ratios = 1
        trendSection.paging = true
        trendSection.yAxis.tickInterval = 4
        trendSection.padding = UIEdgeInsets(top: 16, left: 0, bottom: 8, right: 0)
        let kdjSeries = CHSeries.getKDJ(
            UIColor.ch_hex(0xDDDDDD),
            dc: UIColor.ch_hex(0xF9EE30),
            jc: UIColor.ch_hex(0xF600FF),
            section: trendSection)
        kdjSeries.title = "KDJ(9,3,3)"
        
        let macdSeries = CHSeries.getMACD(
            UIColor.ch_hex(0xDDDDDD),
            deac: UIColor.ch_hex(0xF9EE30),
            barc: UIColor.ch_hex(0xF600FF),
            upStyle: upcolor, downStyle: downcolor,
            section: trendSection)
        macdSeries.title = "MACD(12,26,9)"
        macdSeries.symmetrical = true
        trendSection.series = [
            kdjSeries,
            macdSeries]
        
        style.sections = [priceSection, volumeSection, trendSection]
        
        
        return style
    }
}

