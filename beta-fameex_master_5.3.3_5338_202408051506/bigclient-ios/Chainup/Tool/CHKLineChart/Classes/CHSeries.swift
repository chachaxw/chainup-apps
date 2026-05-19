//
//  CHSeries.swift
//  CHKLineChart
//
//  Created by Chance on 2023/9/13.
//  Copyright © 2023年 Chance. All rights reserved.
//

import UIKit

/**
Key value corresponding to the series
 */
public struct CHSeriesKey {
    public static let candle = "Candle"
    public static let timeline = "Timeline"
    public static let volume = "Volume"
    public static let ma = "MA"
    public static let ema = "EMA"
    public static let kdj = "KDJ"
    public static let macd = "MACD"
    public static let boll = "BOLL"
    public static let sar = "SAR"
    public static let sam = "SAM"
    public static let rsi = "RSI"
    public static let wr = "WR"

}


///Line segment group
///Each "line segment" to be displayed in the chart is encapsulated in a CHSeries.
///Candle plot line segment: Contains a candle plot dot line model (CHCandleModel)
///Time division line segment: includes a line point line model (CHLineModel)
///Trading volume segment: Contains a trading volume dot line model (CHColumnModel)
///MA/EMA segment: contains a line point line model (CHLineModel)
///KDJ line segment: contains 3 line point line models (CHLineModel), and the values of the 3 point lines are calculated based on the KDJ index algorithm
///MACD line segment: includes 2 line point line models (CHLineModel) and 1 bar point line model
open class CHSeries: NSObject {
    
    open var key = ""
    open var title: String = ""
    open var chartModels = [CHChartModel]()          //Each series contains multiple dotted line models
    open var hidden: Bool = false
    open var showTitle: Bool = true                                 //Show Title Text
    open var baseValueSticky = false                 //Is the minimum or maximum value displayed as a fixed base value, if it exceeds the range
    open var symmetrical = false                     //Whether to use a fixed base value as the median and display the maximum and minimum values symmetrically
    var seriesLayer: CHShapeLayer = CHShapeLayer()      //The drawing layer of the point line model
    
    public var algorithms: [CHChartAlgorithmProtocol] = [CHChartAlgorithmProtocol]()
    
    ///Clear sub layers of the chart
    func removeLayerView() {
        _ = self.seriesLayer.sublayers?.map { $0.removeFromSuperlayer() }
        self.seriesLayer.sublayers?.removeAll()
    }
}

//MARK: - Factory method pattern
extension CHSeries {
    
    
    ///Returns a standard time division price series style
    ///
    /// - Parameters:
    ///- color: Line segment color
    ///- section: Partition
    ///- showGuide: Whether to display the maximum and minimum values
    ///- Returns: Line series model
    public class func getTimelinePrice(color: UIColor, section: CHSection, showGuide: Bool = false, ultimateValueStyle: CHUltimateValueStyle = .none, lineWidth: CGFloat = 1) -> CHSeries {
        let series = CHSeries()
        series.key = CHSeriesKey.timeline
        let timeline = CHChartModel.getLine(color, title: NSLocalizedString("Price", comment: ""), key: "\(CHSeriesKey.timeline)_\(CHSeriesKey.timeline)")
        timeline.section = section
        timeline.useTitleColor = false
        timeline.ultimateValueStyle = .none
        timeline.showMaxVal = showGuide
        timeline.showMinVal = showGuide
        timeline.lineWidth = lineWidth
        series.chartModels = [timeline]
        return series
    }
    
    /**
Returns a standard candle column price series style
     */
    public class func getCandlePrice(upStyle: (color: UIColor, isSolid: Bool),
                                     downStyle: (color: UIColor, isSolid: Bool),
                                     titleColor: UIColor,
                                     section: CHSection,
                                     showGuide: Bool = false,
                                     ultimateValueStyle: CHUltimateValueStyle = .none) -> CHSeries {
        let series = CHSeries()
        series.key = CHSeriesKey.candle
        let candle = CHChartModel.getCandle(upStyle: upStyle, downStyle: downStyle, titleColor: titleColor)
        candle.section = section
        candle.useTitleColor = false
        candle.showMaxVal = showGuide
        candle.showMinVal = showGuide
        candle.ultimateValueStyle = ultimateValueStyle
        series.chartModels = [candle]
        return series
    }
    
    /**
Returns a standard trading volume series style
     */
    public class func getDefaultVolume(upStyle: (color: UIColor, isSolid: Bool),
                                       downStyle: (color: UIColor, isSolid: Bool),
                                       section: CHSection) -> CHSeries {
        let series = CHSeries()
        series.key = CHSeriesKey.volume
        let vol = CHChartModel.getVolume(upStyle: upStyle, downStyle: downStyle)
        vol.section = section
        vol.useTitleColor = false
        series.chartModels = [vol]
        return series
    }
    
    
    ///MA line for obtaining transaction volume
    ///
    public class func getVolumeMA(isEMA: Bool = false, num: [Int], colors: [UIColor], section: CHSection) -> CHSeries {
        let valueKey = CHSeriesKey.volume
        let series = self.getMA(isEMA: isEMA, num: num, colors: colors, valueKey: valueKey, section: section)
        return series
    }
    
    /**
Returns a trading volume+MA combination series style
     */
    public class func getVolumeWithMA(upStyle: (color: UIColor, isSolid: Bool),
                                       downStyle: (color: UIColor, isSolid: Bool),
                                       isEMA: Bool = false,
                                       num: [Int],
                                       colors: [UIColor],
                                       section: CHSection) -> CHSeries {
        let series = CHSeries()
        series.key = CHSeriesKey.volume
        let volumeSeries = CHSeries.getDefaultVolume(upStyle: upStyle, downStyle: downStyle, section: section)
        
        let volumeMASeries = CHSeries.getVolumeMA(
            isEMA: isEMA,
            num: num,
            colors: colors,
            section: section)
        
        series.chartModels.append(contentsOf: volumeSeries.chartModels)
        series.chartModels.append(contentsOf: volumeMASeries.chartModels)
        return series
    }
    
    /**
Return a transaction volume+SAM combination series style
     */
    public class func getVolumeWithSAM(upStyle: (color: UIColor, isSolid: Bool),
                                      downStyle: (color: UIColor, isSolid: Bool),
                                      num: Int,
                                      barStyle: (color: UIColor, isSolid: Bool),
                                      lineColor: UIColor,
                                      section: CHSection) -> CHSeries {
        let series = CHSeries()
        series.key = CHSeriesKey.sam
        let volumeSeries = CHSeries.getDefaultVolume(upStyle: upStyle, downStyle: downStyle, section: section)
        
        let volumeSAMSeries = CHSeries.getVolumeSAM(num: num, barStyle: barStyle, lineColor: lineColor, section: section)
        
        series.chartModels.append(contentsOf: volumeSeries.chartModels)
        series.chartModels.append(contentsOf: volumeSAMSeries.chartModels)
        return series
    }
    
    ///MA line for obtaining transaction volume
    ///
    public class func getPriceMA(isEMA: Bool = false, num: [Int], colors: [UIColor], section: CHSection) -> CHSeries {
        let valueKey = CHSeriesKey.timeline
        let series = self.getMA(isEMA: isEMA, num: num, colors: colors, valueKey: valueKey, section: section)
        return series
    }
    
    /**
Returns a moving average series style
     */
    public class func getMA(isEMA: Bool = false, num: [Int], colors: [UIColor], valueKey: String, section: CHSection) -> CHSeries {
        var key = ""
        if isEMA {
            key = CHSeriesKey.ema
        } else {
            key = CHSeriesKey.ma
        }
        
        let series = CHSeries()
        series.key = key
        for (i, n) in num.enumerated() {
            
            let ma = CHChartModel.getLine(colors[i], title: "\(key)\(n)", key: "\(key)_\(n)_\(valueKey)")
            ma.section = section
            series.chartModels.append(ma)
        }
        return series
    }
    
        
    /**
Returns a moving average series style
     */
    public class func getRSI(num: [Int], colors: [UIColor], section: CHSection) -> CHSeries {
        let series = CHSeries()
        series.key = CHSeriesKey.rsi
        for (i, n) in num.enumerated() {
            let ma = CHChartModel.getLine(colors[i], title: "\(series.key)\(n)", key: "\(series.key)_\(n)_\(CHSeriesKey.timeline)")
            ma.section = section
            series.chartModels.append(ma)
        }
        return series
    }
    /**
Return to WR Averaging Series Style
    */
    public class func getWR(num: [Int], colors: [UIColor], section: CHSection) -> CHSeries {
        let series = CHSeries()
        series.key = CHSeriesKey.wr
        for (i, n) in num.enumerated() {
            let ma = CHChartModel.getLine(colors[i], title: "\(series.key)\(n)", key: "\(series.key)_\(n)_\(CHSeriesKey.timeline)")
            ma.section = section
            series.chartModels.append(ma)
        }
        return series
    }
    
    /**
Returns a KDJ series style
     */
    public class func getKDJ(_ kc: UIColor, dc: UIColor, jc: UIColor, section: CHSection) -> CHSeries {
        let series = CHSeries()
        series.key = CHSeriesKey.kdj
        let k = CHChartModel.getLine(kc, title: "K", key: "\(CHSeriesKey.kdj)_K")
        k.section = section
        let d = CHChartModel.getLine(dc, title: "D", key: "\(CHSeriesKey.kdj)_D")
        d.section = section
        let j = CHChartModel.getLine(jc, title: "J", key: "\(CHSeriesKey.kdj)_J")
        j.section = section
        series.chartModels = [k, d, j]
        return series
    }
    
    /**
Returns a MACD series style
     */
    public class func getMACD(_ difc: UIColor,
                              deac: UIColor,
                              barc: UIColor,
                              upStyle: (color: UIColor, isSolid: Bool),
                              downStyle: (color: UIColor, isSolid: Bool),
                              section: CHSection) -> CHSeries {
        let series = CHSeries()
        series.key = CHSeriesKey.macd
        let dif = CHChartModel.getLine(difc, title: "DIF", key: "\(CHSeriesKey.macd)_DIF")
        dif.section = section
        let dea = CHChartModel.getLine(deac, title: "DEA", key: "\(CHSeriesKey.macd)_DEA")
        dea.section = section
        let bar = CHChartModel.getBar(upStyle: upStyle, downStyle: downStyle, titleColor: barc, title: "MACD", key: "\(CHSeriesKey.macd)_BAR")
        bar.section = section
        series.chartModels = [bar, dif, dea]
        return series
    }
    
    /**
Returns a BOLL series style
     */
    public class func getBOLL(_ bollc: UIColor, ubc: UIColor, lbc: UIColor, section: CHSection) -> CHSeries {
        let series = CHSeries()
        series.key = CHSeriesKey.boll
        let boll = CHChartModel.getLine(bollc, title: "BOLL", key: "\(CHSeriesKey.boll)_BOLL")
        boll.section = section
        let ub = CHChartModel.getLine(ubc, title: "UB", key: "\(CHSeriesKey.boll)_UB")
        ub.section = section
        let lb = CHChartModel.getLine(lbc, title: "LB", key: "\(CHSeriesKey.boll)_LB")
        lb.section = section
        series.chartModels = [boll, ub, lb]
        return series
    }
    
    
    /**
Returns a SAR series style
     */
    public class func getSAR(
        upStyle: (color: UIColor, isSolid: Bool),
        downStyle: (color: UIColor, isSolid: Bool),
        titleColor: UIColor,
        plotPaddingExt: CGFloat = 0.3,
        section: CHSection) -> CHSeries {
        
        let series = CHSeries()
        series.key = CHSeriesKey.sar
        let sar = CHChartModel.getRound(upStyle: upStyle, downStyle: downStyle, titleColor: titleColor, title: "SAR", plotPaddingExt: plotPaddingExt, key: "\(CHSeriesKey.sar)")
        sar.section = section
        sar.useTitleColor = true
        series.chartModels = [sar]
        return series
    }
    
    ///SAM line for obtaining transaction volume
    ///
    public class func getVolumeSAM(num: Int,
                                   barStyle: (color: UIColor, isSolid: Bool),
                                   lineColor: UIColor,
                                   section: CHSection) -> CHSeries {
        let valueKey = CHSeriesKey.volume
        
        let series = CHSeries()
        series.key = CHSeriesKey.sam
        
        let sam = CHChartModel.getLine(lineColor, title: "\(CHSeriesKey.sam)\(num)", key: "\(CHSeriesKey.sam)_\(num)_\(valueKey)")
        sam.section = section
        sam.useTitleColor = true
        
        let vol = CHChartModel.getVolume(upStyle: barStyle, downStyle: barStyle, key: "\(CHSeriesKey.sam)_\(num)_\(valueKey)_BAR")
        vol.section = section
        
        series.chartModels = [sam, vol]
        
        return series
    }
    
    ///Obtain SAM line for main image price
    ///
    public class func getPriceSAM(num: Int,
                                  barStyle: (color: UIColor, isSolid: Bool),
                                  lineColor: UIColor,
                                  section: CHSection) -> CHSeries {
        let valueKey = CHSeriesKey.timeline
        
        let series = CHSeries()
        series.key = CHSeriesKey.sam
        
        let sam = CHChartModel.getLine(lineColor, title: "\(CHSeriesKey.sam)\(num)", key: "\(CHSeriesKey.sam)_\(num)_\(valueKey)")
        sam.section = section
        sam.useTitleColor = true
        
        let candle = CHChartModel.getCandle(upStyle: barStyle, downStyle: barStyle, titleColor: barStyle.color, key: "\(CHSeriesKey.sam)_\(num)_\(valueKey)_BAR")
        candle.drawShadow = false
        candle.section = section
        
        series.chartModels = [sam, candle]
        return series
    }
    
}

