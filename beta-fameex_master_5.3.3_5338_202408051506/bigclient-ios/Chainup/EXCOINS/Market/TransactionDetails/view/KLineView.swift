//
//  KLineView.swift
//  Chainup
//
//  Created by zewu wang on 2023/8/15.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit

class KLineView: UIView , CHKLineChartDelegate{
    var chartXAxisPrevDay = ""
    
    var kLineDatas : [KlineChartData] = []
    
    lazy var chartView : CHKLineChartView = {
        let chartView = CHKLineChartView(frame: CGRect.zero)
        chartView.style = loadStyle()       //Default Style
        chartView.delegate = self
        chartView.extUseAutoLayout()
//        chartView.backgroundColor = UIColor.ThemekLine.viewBg
        
        return chartView
    }()
    
    lazy var waterImage : UIImageView = {
        let img = UIImageView.init()
        img.extUseAutoLayout()
        img.isHidden = true
//        img.backgroundColor = UIColor.red
        img.image = UIImage.init(named: "waterImage")
        return img
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.ThemekLine.viewBg
        addSubViews([waterImage])
        addSubViews([chartView])
        chartView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        waterImage.snp.makeConstraints { (make) in
            
            make.left.equalTo(20)
            make.centerY.equalToSuperview().offset(10)
            make.width.equalTo(70)
            make.height.equalTo(20)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Implement a basic style that developers can freely extend and configure
    public func loadStyle() -> CHKLineChartStyle {
        let style = CHKLineChartStyle()
        style.labelFont = UIFont.systemFont(ofSize: 10)
        style.lineColor = UIColor(white: 0.2, alpha: 1)
        style.textColor = UIColor(white: 0.8, alpha: 1)
        style.selectedBGColor = UIColor(white: 0.4, alpha: 1)
        style.selectedTextColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        style.padding = UIEdgeInsets(top: 32, left: 8, bottom: 4, right: 0)
        style.backgroundColor = UIColor.clear//Background color
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
        let upcolor = (UIColor.ch_hex(0x0CC2A4), true)
        let downcolor = (UIColor.ch_hex(0xF25858), true)
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
                UIColor.ch_hex(0x2B89E1),
                ],
            section: priceSection)
        priceMASeries.hidden = false
        
        let priceEMASeries = CHSeries.getPriceMA(
            isEMA: true,
            num: [5,10,30],
            colors: [
                UIColor.ch_hex(0xDDDDDD),
                UIColor.ch_hex(0xF9EE30),
                UIColor.ch_hex(0x2B89E1),
                ],
            section: priceSection)
        
        priceEMASeries.hidden = true
        
        let priceBOLLSeries = CHSeries.getBOLL(
            UIColor.ch_hex(0xDDDDDD),
            ubc: UIColor.ch_hex(0xF9EE30),
            lbc: UIColor.ch_hex(0x2B89E1),
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
                UIColor.ch_hex(0x2B89E1),
                ],
            section: volumeSection)
        
        let volumeEMASeries = CHSeries.getVolumeMA(
            isEMA: true,
            num: [5,10,30],
            colors: [
                UIColor.ch_hex(0xDDDDDD),
                UIColor.ch_hex(0xF9EE30),
                UIColor.ch_hex(0x2B89E1),
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
            jc: UIColor.ch_hex(0x2B89E1),
            section: trendSection)
        kdjSeries.title = "KDJ(9,3,3)"
        
        let macdSeries = CHSeries.getMACD(
            UIColor.ch_hex(0xDDDDDD),
            deac: UIColor.ch_hex(0xF9EE30),
            barc: UIColor.ch_hex(0x2B89E1),
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
    
    ///Chart displays the total number of data
    func numberOfPointsInKLineChart(chart: CHKLineChartView) -> Int {
        return self.kLineDatas.count
    }
    
    ///Provide chart data sources
    func kLineChart(chart: CHKLineChartView, valueForPointAtIndex index: Int) -> CHChartItem {
        let data = self.kLineDatas[index]
        let item = CHChartItem()
        item.time = data.time
        item.openPrice = CGFloat(data.openPrice)
        item.highPrice = CGFloat(data.highPrice)
        item.lowPrice = CGFloat(data.lowPrice)
        item.closePrice = CGFloat(data.closePrice)
        item.vol = CGFloat(data.vol)
        return item
    }
    
    ///Customize the display content of Y-axis coordinate values
    func kLineChart(chart: CHKLineChartView, labelOnYAxisForValue value: CGFloat, atIndex index: Int, section: CHSection) -> String {
        var strValue = ""
        if section.key == "volume" {
            if value / 1000 > 1 {
                strValue = (value / 1000).ch_toString(maxF: section.decimal) + "K"
            } else {
                strValue = value.ch_toString(maxF: section.decimal)
            }
        } else {
            strValue = value.ch_toString(maxF: section.decimal)
        }
        
        return strValue
    }
    
    ///Customize the display content of X-axis coordinate values
    func kLineChart(chart: CHKLineChartView, labelOnXAxisForIndex index: Int) -> String {
        let data = self.kLineDatas[index]
        let timestamp = data.time
        let dayText = Date.ch_getTimeByStamp(timestamp, format: "MM-dd")
        let timeText = Date.ch_getTimeByStamp(timestamp, format: "HH:mm")
        var text = ""
        //Cross day, display date
        if dayText != self.chartXAxisPrevDay && index > 0 {
            text = dayText
        } else {
            text = timeText
        }
        self.chartXAxisPrevDay = dayText
        return text
    }
    
    ///Adjust the number of decimal places reserved for each partition
    ///
    /// - parameter chart:
    /// - parameter section:
    ///
    /// - returns:
    func kLineChart(chart: CHKLineChartView, decimalAt section: Int) -> Int {
        return 8
    }
}

