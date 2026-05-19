//
//  CHChartAlgorithm.swift
//  CHKLineChart
//
//  Created by Chance on 2023/9/14.
//  Copyright © 2023年 Chance. All rights reserved.
//

import UIKit



///Indicator algorithm protocol for future developers to freely expand and write their own algorithms
public protocol CHChartAlgorithmProtocol {
    
    ///Implement the processing of this algorithm
    ///By passing in a basic set of K-line data models to the delegate, the metric algorithm calculation is completed,
    ///And record the results in the extVal dictionary of CHChartItem
    ///- Parameter data: Incoming K-line data model set
    ///- Returns: The results of the algorithm are recorded in the extVal dictionary of CHChartItem, returning a processed set
    func handleAlgorithm(_ datas: [CHChartItem]) -> [CHChartItem]
    
}

//MARK: - Equatable
//public func ==(lhs: CHChartAlgorithm, rhs: CHChartAlgorithm) -> Bool {
//    return lhs.hashValue == rhs.hashValue
//}

/**
Common technical indicator algorithms
 */
public enum CHChartAlgorithm: CHChartAlgorithmProtocol {
    
    case none                                   //No algorithm
    case timeline                               //time division
    case ma(Int)                                //Simple Moving Average
    case ema(Int)                               //Exponential moving average
    case kdj(Int, Int, Int)                     //Random indicators
    case macd(Int, Int, Int)                    //Exponential Smoothing Difference Average
    case boll(Int, Int)                         //Boll 
    case sar(Int, CGFloat, CGFloat)             //Stop loss turning operation point indicators (judgment period, initial value of acceleration factor, maximum value of acceleration factor)
    case sam(Int)                               //SAM Indicator Formula
    case rsi(Int)                               //RSI indicator formula
    case wr(Int)                                //WR indicator
    
    /**
Obtain the name of the Key value
     
-Parameter name: Optional secondary key
     
     - returns:
     */
    public func key(_ name: String = "") -> String {
        switch self {
        case .none:
            return ""
        case .timeline:
            return "\(CHSeriesKey.timeline)_\(name)"
        case let .ma(num):
            return "\(CHSeriesKey.ma)_\(num)_\(name)"
        case let .ema(num):
            return "\(CHSeriesKey.ema)_\(num)_\(name)"
        case .kdj(_, _, _):
            return "\(CHSeriesKey.kdj)_\(name)"
        case .macd(_, _, _):
            return "\(CHSeriesKey.macd)_\(name)"
        case .boll(_, _):
            return "\(CHSeriesKey.boll)_\(name)"
        case .sar(_, _, _):
            return "\(CHSeriesKey.sar)\(name)"
        case let .sam(num):
            return "\(CHSeriesKey.sam)_\(num)_\(name)"
        case let .rsi(num):
            return "\(CHSeriesKey.rsi)_\(num)_\(name)"
        case let  .wr(num):
            return "\(CHSeriesKey.wr)_\(num)_\(name)"
        }
    }
    
    /**
Processing algorithm
     
     - parameter datas:
     
     - returns:
     */
    public func handleAlgorithm(_ datas: [CHChartItem]) -> [CHChartItem] {
        switch self {
        case .none:
            return datas
        case .timeline:
            return self.handleTimeline(datas: datas)
        case let .ma(num):
            return self.handleMA(num, datas: datas)
        case let .ema(num):
            return self.handleEMA(num, datas: datas)
        case let .kdj(p1, p2, p3):
            return self.handleKDJ(p1, p2: p2, p3: p3, datas: datas)
        case let .macd(p1, p2, p3):
            return self.handleMACD(p1, p2: p2, p3: p3, datas: datas)
        case let .boll(num, k):
            return self.handleBOLL(num, k: k, datas: datas)
        case let .sar(num, minAF, maxAF):
            return self.handleSAR(num,minAF: minAF, maxAF: maxAF, datas: datas)
        case let .sam(num):
            return self.handleSAM(num, datas: datas)
        case let .rsi(num):
            return self.handleRSI(num, datas: datas)
        case let .wr(num):
            return self.handleWR(num, datas: datas)
        }
    }
    
    
}


//MARK: - RSI processing algorithm
extension CHChartAlgorithm {

    fileprivate func getAAndB(_ a: Int, _ b: Int, datas: [CHChartItem]) -> [CGFloat] { 
        var tA = a
        if tA < 0 {
            tA = 0
        }
        var sum: CGFloat = 0
        var dif: CGFloat = 0
        var closeT: CGFloat!
        var closeY: CGFloat!
        var result: [CGFloat] = [0, 0]
        for index in tA...b {
            if (index > tA) {
                closeT = datas[index].closePrice
                closeY = datas[index - 1].closePrice
                let c:CGFloat = closeT - closeY
                if (c > 0) {
                    sum = sum + c
                } else {
                    dif = sum + c
                }
                dif = abs(dif)
            }
        }
        result[0] = sum
        result[1] = dif
        return result
    }

    fileprivate func handleRSI(_ num: Int, datas: [CHChartItem]) -> [CHChartItem] {
    
        let defaultVal: CGFloat = 100
        let index = num - 1
        var sum: CGFloat = 0
        var dif: CGFloat = 0
        var rsi: CGFloat = 0
        
        for (i, data) in datas.enumerated() {
            if (num == 0) {
                sum = 0
                dif = 0
            } else {
                let k = i - num + 1
                let wrs:[CGFloat] = self.getAAndB(k, i, datas: datas)
                sum = wrs[0]
                dif = wrs[1]
            }
            if (dif != 0) {
                let h = sum + dif
                rsi = sum / h * 100
            } else {
                rsi = 100
            }
            
            if (i < index) {
                rsi = defaultVal
            }
            data.extVal["\(self.key(CHSeriesKey.timeline))"] = rsi
        }
        return datas
    }
}

//MARK: - "Time Division Price" processing algorithm
extension CHChartAlgorithm {
    
    /**
Processing Time Division Price Calculation
Use closing price as time division price
-Parameter data: dataset
     */
    fileprivate func handleTimeline(datas: [CHChartItem]) -> [CHChartItem] {
        for (_, data) in datas.enumerated() {
            data.extVal["\(self.key(CHSeriesKey.timeline))"] = data.closePrice
            data.extVal["\(self.key(CHSeriesKey.volume))"] = data.vol
        }
        return datas
    }
    
}

//MARK: - MA Simple Moving Average Processing Algorithm
extension CHChartAlgorithm {
    
    /**
Processing MA operations
     
-Parameter num: number of days
-Parameter data: dataset
     */
    fileprivate func handleMA(_ num: Int, datas: [CHChartItem]) -> [CHChartItem] {
        for (index, data) in datas.enumerated() {
            let value = self.getMAValue(num, index: index, datas: datas)
            data.extVal["\(self.key(CHSeriesKey.timeline))"] = value.0
            data.extVal["\(self.key(CHSeriesKey.volume))"] = value.1
        }
        return datas
    }
    
    /**
Calculate moving average MA
     
     - parameter num:   N
-Parameter index: Location of data
     
-Returns: MA number (price, transaction volume)
     */
    fileprivate func getMAValue(_ num: Int, index: Int, datas: [CHChartItem]) -> (CGFloat?, CGFloat?) {
        var priceVal: CGFloat = 0
        var volVal: CGFloat = 0
        if index + 1 >= num {       //Index+1>=N, accumulated within N days
            for i in stride(from: index, through: index + 1 - num, by: -1) {
                volVal += datas[i].vol
                priceVal += datas[i].closePrice
            }
            volVal = volVal / CGFloat(num)
            priceVal = priceVal / CGFloat(num)
            return (priceVal, volVal)
        } else {                    //Index+1<N, cumulative index+within 1 day
            for i in stride(from: index, through: 0, by: -1) {
                volVal += datas[i].vol
                priceVal += datas[i].closePrice
            }
            volVal = volVal / CGFloat(index + 1)
            priceVal = priceVal / CGFloat(index + 1)
            return (priceVal, volVal)
            // return (nil, nil)
        }
        
    }
    
}

//MARK: - EMA Index Moving Average Processing Algorithm
extension CHChartAlgorithm {
    
    /**
Processing EMA operations
EMA (N)=2/(N+1) * (C - Yesterday's EMA)+Yesterday's EMA;
EMA (12)=Yesterday EMA (12) * 11/13+C * 2/13;
-Parameter num: number of days
-Parameter data: dataset
     */
    fileprivate func handleEMA(_ num: Int, datas: [CHChartItem]) -> [CHChartItem] {
        var prev_ema_price: CGFloat = 0
        var prev_ema_vol: CGFloat = 0
        for (index, data) in datas.enumerated() {
            
            let c = datas[index].closePrice
            let v = datas[index].vol
            
            var ema_price: CGFloat = 0
            var ema_vol: CGFloat = 0
            //EMA (N)=2/(N+1) * (C - Yesterday's EMA)+Yesterday's EMA;
            if index > 0 {
                //EMA (N)=2/(N+1) * (C - Yesterday's EMA)+Yesterday's EMA;
                ema_price = prev_ema_price + (c - prev_ema_price) * 2 / (CGFloat(num) + 1)
                ema_vol = prev_ema_vol + (v - prev_ema_vol) * 2 / (CGFloat(num) + 1)
                
            } else {
                ema_price = c
                ema_vol = v
            }
            
            data.extVal["\(self.key(CHSeriesKey.timeline))"] = ema_price
            data.extVal["\(self.key(CHSeriesKey.volume))"] = ema_vol
            
            prev_ema_price = ema_price
            prev_ema_vol = ema_vol
        }
        return datas
    }
    
}

//MARK: - KDJ Random Index Processing Algorithm
extension CHChartAlgorithm {
    
    /**
Processing KDJ operations
     
-Parameter p1: Index analysis cycle
-Parameter p2: Indicator analysis cycle
-Parameter p3: Index analysis cycle
-Parameter data: unprocessed collection
     
-Returns: Processed collection
     */
    fileprivate func handleKDJ(_ p1: Int, p2: Int,p3: Int, datas: [CHChartItem]) -> [CHChartItem] {
        var prev_k: CGFloat = 50
        var prev_d: CGFloat = 50
        for (index, data) in datas.enumerated() {
            //Calculate RSV value
            if let rsv = self.getRSV(p1, index: index, datas: datas) {
                //Calculate K, D, and J values
                let k: CGFloat = (2 * prev_k + rsv) / 3
                let d: CGFloat = (2 * prev_d + k) / 3
                let j: CGFloat = 3 * k - 2 * d
                
                prev_k = k
                prev_d = d
                
                data.extVal["\(self.key("K"))"] = k
                data.extVal["\(self.key("D"))"] = d
                data.extVal["\(self.key("J"))"] = j
            }
        }
        return datas
    }
    
    /**
RSV calculation
     
-Parameter num: Calculate the range of days
-Parameter index: The current index bit
     
     - returns:
     */
    fileprivate func getRSV(_ num: Int, index: Int, datas: [CHChartItem]) -> CGFloat? {
        var rsv: CGFloat = 0
        let c = datas[index].closePrice
        var h = datas[index].highPrice
        var l = datas[index].lowPrice
        
        let block: (Int) -> Void = {
            (i) -> Void in
            
            let item = datas[i]
            
            if item.highPrice > h {
                h = item.highPrice
            }
            
            if item.lowPrice < l {
                l = item.lowPrice
            }
        }
        
        if index + 1 >= num {    //Index+1>=N, accumulated within N days
            //Calculate the lowest and highest prices within num days
            for i in stride(from: index, through: index + 1 - num, by: -1) {
                block(i)
            }
        } else {                //Index+1<N, cumulative index+within 1 day
            //Calculate the lowest and highest prices within index days
            for i in stride(from: index, through: 0, by: -1) {
                block(i)
            }
        }
        
        if h != l {
            rsv = (c - l) / (h - l) * 100
        }
        return rsv
    }
    
}

//MARK: - MACD Smoothing Similarity Moving Average Processing Algorithm
extension CHChartAlgorithm {
    
    /**
Processing MACD operations
EMA (N)=2/(N+1) * (C - Yesterday's EMA)+Yesterday's EMA;
EMA (12)=Yesterday EMA (12) * 11/13+C * 2/13;
-Parameter num: number of days
-Parameter data: dataset
     */
    fileprivate func handleMACD(_ p1: Int, p2: Int,p3: Int, datas: [CHChartItem]) -> [CHChartItem] {
        var pre_dea: CGFloat = 0
        for (index, data) in datas.enumerated() {
            //EMA (p1)=2/(p1+1) * (C - Yesterday's EMA)+Yesterday's EMA;
            let (ema1, _) = self.getEMA(p1, index: index, datas: datas)
            //EMA (p2)=2/(p2+1) * (C - Yesterday's EMA)+Yesterday's EMA;
            let (ema2, _) = self.getEMA(p2, index: index, datas: datas)
            
            if ema1 != nil && ema2 != nil {
                //DIF=Today's EMA (p1) - Today's EMA (p2)
                let dif = ema1! - ema2!
                //Dea (p3)=2/(p3+1) * (dif - yesterday's dea)+yesterday's dea;
                let dea = pre_dea + (dif - pre_dea) * 2 / (CGFloat(p3) + 1)
                //BAR=2×(DIF－DEA)
//                let bar = 2 * (dif - dea)
                let bar =  (dif - dea)
                data.extVal["\(self.key("DIF"))"] = dif
                data.extVal["\(self.key("DEA"))"] = dea
                data.extVal["\(self.key("BAR"))"] = bar
                
                pre_dea = dea
            }
        }
        return datas
    }
    
    /**
Obtain EMA data for a certain day
     
-Parameter num: Days period
     - parameter index:
     - parameter datas:
     
     - returns: //Transaction price and volume of EMA
     */
    fileprivate func getEMA(_ num: Int, index: Int, datas: [CHChartItem]) -> (CGFloat?, CGFloat?) {
        let ema = CHChartAlgorithm.ema(num)
        let data = datas[index]
        let ema_price = data.extVal["\(ema.key(CHSeriesKey.timeline))"]
        let ema_vol = data.extVal["\(ema.key(CHSeriesKey.volume))"]
        return (ema_price, ema_vol)
    }
    
    /**
Obtain MA data for a certain day
     
-Parameter num: Days period
     - parameter index:
     - parameter datas:
     
     - returns: //MA's transaction price and volume
     */
    fileprivate func getMA(_ num: Int, index: Int, datas: [CHChartItem]) -> (CGFloat?, CGFloat?) {
        let ma = CHChartAlgorithm.ma(num)
        let data = datas[index]
        let ma_price = data.extVal["\(ma.key(CHSeriesKey.timeline))"]
        let ma_vol = data.extVal["\(ma.key(CHSeriesKey.volume))"]
        return (ma_price, ma_vol)
    }
}

//MARK: - "BOLL Bollinger Line" processing algorithm
extension CHChartAlgorithm {
    
    
    ///Bollinger Line Processing Method
    ///
    ///Calculation formula
    ///Mid orbit=moving average of N days
    ///Upper rail line=middle rail line+twice the standard deviation
    ///Lower rail line=middle rail line - twice the standard deviation
    ///Calculation process
    ///(1) Calculate MA
    ///MA=Sum of closing prices within N days ÷ N
    ///(2) Calculate standard deviation MD
    ///MD=sum of the two powers of (C-MA) on the square root (N) day divided by N
    ///(3) Calculate MB, UP, DN lines
    ///MB=MA of (N) day
    /// UP=MB+k×MD
    /// DN=MB－k×MD
    ///(K is a parameter that can be adjusted according to the characteristics of the stock, usually defaulting to 2)
    ///
    /// - Parameters:
    ///- num: number of days
    ///- k: The parameter defaults to 2
    ///- data: data to be processed
    ///- Returns: processed data
    fileprivate func handleBOLL(_ num: Int, k: Int = 2, datas: [CHChartItem]) -> [CHChartItem] {
        var md: CGFloat = 0, mb: CGFloat = 0, up: CGFloat = 0, dn: CGFloat = 0
        for (index, data) in datas.enumerated() {
            //Calculate standard deviation
            md = self.handleBOLLSTD(num, index: index, datas: datas)
            mb = self.getMA(num, index: index, datas: datas).0 ?? 0
            up = mb + CGFloat(k) * md
            dn = mb - CGFloat(k) * md
            
            data.extVal["\(self.key("BOLL"))"] = mb
            data.extVal["\(self.key("UB"))"] = up
            data.extVal["\(self.key("LB"))"] = dn
        }
        
        return datas
    }
    
    
    ///Calculate MA Difference of two squares in Bollinger line
    ///
    /// - Parameters:
    ///- num: Accumulated number of days
    ///- index: Date of the day
    ///- data: data set
    ///- Returns: Results
    fileprivate func handleBOLLSTD(_ num: Int, index: Int, datas: [CHChartItem]) -> CGFloat {
        var dx: CGFloat = 0, md: CGFloat = 0
        let ma = self.getMA(num, index: index, datas: datas).0 ?? 0
        if index + 1 >= num {       //Index+1>=N, calculate the Difference of two squares of day N
            for i in stride(from: index, through: index + 1 - num, by: -1) {
                dx += pow(datas[i].closePrice - ma, 2)
            }
            md = dx / CGFloat(num)
        } else {                    //Index+1<N, calculate the Difference of two squares of index+1 day
            for i in stride(from: index, through: 0, by: -1) {
                dx += pow(datas[i].closePrice - ma, 2)
            }
            md = dx / CGFloat(index + 1)
        }
        //square root
        md = pow(md, 0.5)
        return md
    }
}

//MARK: - SAR Index Processing Algorithm
extension CHChartAlgorithm {
    
    
    
    ///SAR index is also called Parabolic SAR or stop loss steering operating point index
    ///
    ///Taking the SAR value of Tn period as an example, the calculation formula is as follows:
    /// SAR(Tn)=SAR(Tn-1)+AF(Tn)*[EP(Tn-1)-SAR(Tn-1)]
    ///Among them, SAR (Tn) is the SAR value of the Tn th cycle, and SAR (Tn-1) is the value of the (Tn-1) th cycle
    ///AF is the acceleration factor (or acceleration coefficient), EP is the extreme price (highest or lowest price)
    ///When calculating SAR values, the following principles should be noted:
    ///1. Determination of initial value SAR (T0)
    ///If SAR (T1) shows an upward trend in the T1 cycle, then SAR (T0) is the lowest price in the T0 cycle. If the T1 cycle shows a downward trend, then SAR (T0) is the highest price in the T0 cycle;
    ///2. Determination of Extreme Price EP
    ///If the Tn cycle shows an upward trend (SAR below the K-line), EP (Tn-1) is the highest price of the Tn-1 cycle. If the Tn cycle shows a downward trend (SAR above the K-line), EP (Tn-1) is the lowest price of the Tn-1 cycle;
    ///3. Determination of acceleration factor AF
    ///(a) The initial value of the acceleration factor is 0.02, that is, AF (T0)=0.02;
    ///(b) If both Tn-1 and Tn cycles show an upward trend, if the highest price of the Tn cycle is greater than the highest price of the Tn-1 cycle, then AF (Tn)=AF (Tn-1)+0.02. If the highest price of the Tn cycle is less than or equal to the highest price of the Tn-1 cycle, then AF (Tn)=AF (Tn-1), but the highest acceleration factor AF does not exceed 0.2;
    ///(c) If both Tn-1 and Tn cycles show a downward trend, if the lowest point of the Tn cycle is less than the lowest point of the Tn-1 cycle, then AF (Tn)=AF (Tn-1)+0.02; if the lowest point of the Tn cycle is greater than or equal to the lowest point of the Tn-1 cycle, then AF (Tn)=AF (Tn-1);
    ///(d) For any market change, the acceleration factor AF must be recalculated from 0.02;
    ///For example, if the Tn-1 cycle shows an upward trend and the Tn cycle shows a downward trend (or if Tn-1 falls and Tn rises), AF (Tn) needs to be recalculated based on 0.02, that is, AF (Tn)=AF (T0)=0.02;
    ///(e) The maximum acceleration factor AF shall not exceed 0.2, and when AF>0.2, the maximum value shall be maintained;
    ///4. Determine today's SAR value
    ///(a) Calculate the value of Tn period by using the formula SAR (Tn)=SAR (Tn-1)+AF (Tn) * [EP (Tn-1) - SAR (Tn-1)];
    ///(b) If the Tn cycle shows an upward trend, when SAR (Tn) is greater than the closing price of the Tn cycle, the final SAR value of the Tn cycle should be the highest value among the highest prices in the benchmark period,
    ///When SAR (Tn)<=the closing price of the Tn cycle, the final SAR value of the Tn cycle is SAR (Tn), that is, SAR=SAR (Tn);
    ///(c) If the Tn cycle shows a downward trend, when SAR (Tn) is less than the closing price of the Tn cycle, the final SAR value of the Tn cycle should be the minimum value of the lowest prices in the benchmark period,
    ///When SAR (Tn)>=the closing price of the Tn cycle, the final SAR value of the Tn cycle is SAR (Tn), that is, SAR=SAR (Tn);
    ///5. The parameter for calculating the reference period of SAR indicators is 2, such as 2 days, 2 weeks, February, etc. The parameter variation range for the calculation period is 2-8. (Most recommended 4)
    ///6. The calculation method and process of SAR indicators are quite cumbersome. For investors, as long as they master the calculation process and principles, they do not need to calculate SAR values themselves in practical operations. More importantly, investors need to flexibly grasp and apply the research methods and functions of SAR indicators.
    ///
    ///- Parameter num: Number of reference cycles N
    ///- Parameter minAF: Minimum value of acceleration factor AF (initial value)
    ///- Parameter maxAF: maximum acceleration factor AF
    ///- Parameter data: Set of data to be processed
    ///- Returns: processed data set
    fileprivate func handleSAR(_ num: Int, minAF: CGFloat, maxAF: CGFloat, datas: [CHChartItem]) -> [CHChartItem] {
        
        var sar: CGFloat = 0, af: CGFloat = minAF, ep: CGFloat = 0
        var pre_data: CHChartItem!
        var isUP: Bool = true              //True: upward trend, false: downward trend
        
        //At least 2 pieces of data are displayed for this indicator
        guard num >= 2 && datas.count >= 2 else {
            return datas
        }
        
        ///1. Determination of initial value SAR (T0)
        ///If SAR (T1) shows an upward trend in the T1 cycle, then SAR (T0) is the lowest price in the T0 cycle. If the T1 cycle shows a downward trend, then SAR (T0) is the highest price in the T0 cycle;
        if datas[1].closePrice > datas[0].closePrice {
            sar = datas[0].lowPrice
            isUP = true
        } else {
            sar = datas[0].highPrice
            isUP = false
        }
        
        //Record Day 1
        pre_data = datas[0]
        
        for (index, data) in datas.enumerated() {
            
            if index > 0 {      //Ignore first day
                
                //Determine today's SAR values
                let finalSAR = self.getFinalSAR(num: num, sar: sar, index: index, isUP: isUP, datas: datas)
                
                //Market reversal occurs, recharge AF acceleration factor
                if isUP != finalSAR.1 {
                    af = minAF
                }
                
                sar = finalSAR.0
                isUP = finalSAR.1
                
            }
            
            data.extVal["\(self.key())"] = sar
            
            //Budget the SAR value for the next day
            
            /// SAR(Tn)=SAR(Tn-1)+AF(Tn)*[EP(Tn-1)-SAR(Tn-1)]
            ///SAR (1)=SAR (0)+AF (1) * [EP (0) - SAR (0)] Day 1
            ///2. Determination of Extreme Price EP
            ///If the Tn cycle shows an upward trend (SAR below the K-line), EP (Tn-1) is the highest price of the Tn-1 cycle. If the Tn cycle shows a downward trend (SAR above the K-line), EP (Tn-1) is the lowest price of the Tn-1 cycle;
            
            if isUP {
                ep = pre_data.highPrice
            } else {
                ep = pre_data.lowPrice
            }
            
            ///3. Determination of acceleration factor AF
            ///(a) The initial value of the acceleration factor is 0.02, that is, AF (T0)=0.02;
            ///(b) If both Tn-1 and Tn cycles show an upward trend, if the highest price of the Tn cycle is greater than the highest price of the Tn-1 cycle, then AF (Tn)=AF (Tn-1)+0.02. If the highest price of the Tn cycle is less than or equal to the highest price of the Tn-1 cycle, then AF (Tn)=AF (Tn-1), but the highest acceleration factor AF does not exceed 0.2;
            ///(c) If both Tn-1 and Tn cycles show a downward trend, if the lowest point of the Tn cycle is less than the lowest point of the Tn-1 cycle, then AF (Tn)=AF (Tn-1)+0.02; if the lowest point of the Tn cycle is greater than or equal to the lowest point of the Tn-1 cycle, then AF (Tn)=AF (Tn-1);
            ///(d) For any market change, the acceleration factor AF must be recalculated from 0.02;
            ///For example, if the Tn-1 cycle shows an upward trend and the Tn cycle shows a downward trend (or if Tn-1 falls and Tn rises), AF (Tn) needs to be recalculated based on 0.02, that is, AF (Tn)=AF (T0)=0.02;
            ///(e) The maximum acceleration factor AF shall not exceed 0.2, and when AF>0.2, the maximum value shall be maintained;
            if isUP {
                if data.highPrice > pre_data.highPrice {
                    af = af + minAF
                }
            } else {
                if data.lowPrice < pre_data.lowPrice {
                    af = af + minAF
                }
            }
            
            if af > maxAF {
                af = maxAF
            }
            

            sar = sar + af * (ep - sar)
            
            //Record tomorrow's SAR value
            data.extVal["\(self.key("tomorrow"))"] = sar
            

            pre_data = data
            
            
        }
        
        return datas
    }
    
    
    ///Determine the final SAR value for the day
    ///
    /// - Parameters:
    ///- num: Trend judgment cycle
    ///- sar: budgeted sar value
    ///- index: Position of the cycle
    ///- isUP: Trend
    ///- data: data set
    ///- Returns: Final value, whether the market has flipped
    func getFinalSAR(num: Int, sar: CGFloat, index: Int, isUP: Bool, datas: [CHChartItem]) -> (CGFloat, Bool) {
        
        ///4. Determine today's SAR value
        ///(a) Calculate the value of Tn period by using the formula SAR (Tn)=SAR (Tn-1)+AF (Tn) * [EP (Tn-1) - SAR (Tn-1)];
        ///(b) If the Tn cycle shows an upward trend, when SAR (Tn) is greater than the closing price of the Tn cycle, the final SAR value of the Tn cycle should be the highest of the highest prices in the num day period,
        ///When SAR (Tn)<=the closing price of the Tn cycle, the final SAR value of the Tn cycle is SAR (Tn), that is, SAR=SAR (Tn);
        ///(c) If the Tn cycle shows a downward trend, when SAR (Tn) is less than the closing price of the Tn cycle, the final SAR value of the Tn cycle should be the minimum of the lowest prices in the num day cycle,
        ///When SAR (Tn)>=the closing price of the Tn cycle, the final SAR value of the Tn cycle is SAR (Tn), that is, SAR=SAR (Tn);
        
        
        var finalSAR: CGFloat = sar
        var finalIsUP: Bool = isUP
        var start = index
        if isUP {
            if sar > datas[index].closePrice {  //Closing below SAR and turning to short selling
                //Starting from today, the highest price of num days ago
                repeat {
                    finalSAR = max(datas[start].highPrice, finalSAR) //Get maximum value
                    start -= 1  //Decreasing until num days ago
                } while start >= max(index - num + 1, 0)
                
                finalIsUP = false
            }
        } else {
            if sar < datas[index].closePrice {  //Closing above SAR and turning long
                //Starting from today, the lowest price of num days ago
                repeat {
                    finalSAR = min(datas[start].lowPrice, finalSAR) //Obtain minimum value
                    start -= 1  //Decreasing until num days ago
                } while start >= max(index - num + 1, 0)
                
                finalIsUP = true
            }
        }
        
        return (finalSAR, finalIsUP)
    }
}

//MARK: - Processing Algorithm for SAM Frontline Indicators
extension CHChartAlgorithm {
    
    /**
Process SAM operations
1. Calculate the highest trading volume for each point in the subsequent num period. For the last number of transactions less than num, only the highest trading volume for the last number will be calculated
2. Add color to the border of the candle column in the main image for display
3. Record dots and lines at the closing price on the main chart
4. Add color to the border of the transaction volume column in the secondary image for display
5. Record transaction volume points and lines on the secondary chart
-Parameter num: number of days
-Parameter data: dataset
     */
    fileprivate func handleSAM(_ num: Int, datas: [CHChartItem]) -> [CHChartItem] {
        var max_vol_price: CGFloat = 0  //Closing price of maximum trading volume
        var max_vol: CGFloat = 0        //Maximum transaction volume
        var max_index: Int = 0          //Location of maximum transaction volume
        for (index, data) in datas.enumerated() {
            
            //Exceeded the num cycle and did not find the maximum value. Please search for num after the index again
            if index - max_index == num {
                max_vol_price = 0
                max_vol = 0
                max_index = 0
                for j in (index - num + 1)...index {
                    
                    let c = datas[j].closePrice
                    let v = datas[j].vol
                    
                    if v > max_vol {
                        max_vol_price = c
                        max_vol = v
                        max_index = j
                    }
                }
                
                //Calculated value after resetting the maximum value
                for j in max_index...index {
                    datas[j].extVal["\(self.key(CHSeriesKey.timeline))"] = max_vol_price
                    datas[j].extVal["\(self.key(CHSeriesKey.volume))"] = max_vol
                }
                
            } else {
                //Calculate the maximum transaction volume by moving one number per transaction
                let c = datas[index].closePrice
                let v = datas[index].vol
                
                if v > max_vol {
                    max_vol_price = c
                    max_vol = v
                    max_index = index
                }
                
            }
            
            if index > num - 1 {
                data.extVal["\(self.key(CHSeriesKey.timeline))"] = max_vol_price
                data.extVal["\(self.key(CHSeriesKey.volume))"] = max_vol
                
                //Record the maximum value of fill color
                let priceName = "\(CHSeriesKey.timeline)_BAR"
                let volumeName = "\(CHSeriesKey.volume)_BAR"
                let maxData = datas[max_index]
                maxData.extVal["\(self.key(priceName))"] = max_vol_price
                maxData.extVal["\(self.key(volumeName))"] = max_vol
            } else if index == num - 1 {
                //Add lines not drawn at the beginning
                for j in max_index...index {
                    datas[j].extVal["\(self.key(CHSeriesKey.timeline))"] = max_vol_price
                    datas[j].extVal["\(self.key(CHSeriesKey.volume))"] = max_vol
                }
            }
            
        }
        
        //Draw the last line segment
        for j in max_index..<datas.count {
            datas[j].extVal["\(self.key(CHSeriesKey.timeline))"] = max_vol_price
            datas[j].extVal["\(self.key(CHSeriesKey.volume))"] = max_vol
        }
        
        return datas
    }
    
}

extension CHChartAlgorithm {
    
    fileprivate func handleWR(_ num: Int, datas: [CHChartItem]) -> [CHChartItem] {
        
        //Formula (hn cn/hn ln) * 100
        var rst:CGFloat?
        
        for (index, data) in datas.enumerated() {
            var startIdx = index - 14
            if (startIdx < 0) {
                startIdx = 0
            }
            var max14:CGFloat = CGFloat.leastNonzeroMagnitude
            var min14:CGFloat = CGFloat.greatestFiniteMagnitude
            
            for _ in startIdx...index {
                max14 = max(max14, data.highPrice)
                min14 = min(min14,data.lowPrice)
            }
            if index  < 13 {
                // = -10
                data.extVal["\(self.key(CHSeriesKey.timeline))"] = -10
            }else {
                // -100
                rst = -100 * ((max14 -  data.closePrice)/(max14 - min14))
                if let result = rst {
                    if result.isNaN {
                        data.extVal["\(self.key(CHSeriesKey.timeline))"] = 0
                    }else {
                        data.extVal["\(self.key(CHSeriesKey.timeline))"] = rst
                    }
                }else {
                    data.extVal["\(self.key(CHSeriesKey.timeline))"] = 0
                }
            }
        }
        return datas
    }
}

