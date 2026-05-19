//
//  NumberHandler.swift
//  EXKit
//
//  Created by liuxuan on 2022/7/12.
//

import UIKit

public class NumberHandler: NSObject {
    public class func handleDouble(_ a : Any) -> Double{
        switch a {
        case let val as Double:
            return Double(val)
        case let val as String:
            return (val as NSString).doubleValue
        case let val as Int:
            return Double(val)
        case let val as Float:
            return Double(val)
        case let val as CGFloat:
            return Double(val)
        default:
            print("error double")
        }
        return 0
    }
    
    public class func depthToDouble(_ i : Int) -> String{
        var d = "0."
        if i > 0{
            for _ in 0..<i-1{
                d = d + "0"
            }
            d = d + "1"
        }else{
            d = "1"
        }
        return d
    }
    
    //处理数量精度-盘口专用(私有化)
    public class func dealPanKouVolume(_ str: String, precision:Int = 4) -> String {
        let decimals = 8
        //如果是0，则返回0
        if Double(str) == 0{
            return "0.0000".decimalString1(precision)
        }
        //如果小于0.0001 则返回0
        if let poor = (str as NSString).subtracting("0.0001", decimals: decimals) , poor.contains("-"){
            return "0.0000".decimalString1(precision)
        }else if let f = Float((str as NSString).dividing(by: "1000", decimals: 2)) , f > 1 {
            return dealDataFormate(str)
        }else{
            return str.decimalString1(precision)
        }
        
    }
    
    //处理数量精度-盘口专用
     public class func dealPanKouVolume(_ str:String) -> String {
         let decimals = 8
         //如果是0，则返回0
         if Double(str) == 0{
             return "0.0000"
         }
         //如果小于0.0001 则返回0
         if let poor = (str as NSString).subtracting("0.0001", decimals: decimals) , poor.contains("-"){
             return "0.0000"
         }else if let f = Float((str as NSString).dividing(by: "1000", decimals: 2)) , f > 1 {
             return dealDataFormate(str)
         }else{
             return NumberHandler.dealDecimalPoint(str,digits: 6, precision: 4)
         }
     }
     
     //处理数量精度
     public class func dealVolumFormate(_ str : String) -> String{
         let decimals = 8
         //如果是0，则返回0
         if Double(str) == 0{
             return "0"
         }
         //如果小于0.001 则返回0
         if let poor = (str as NSString).subtracting("0.001", decimals: decimals) , poor.contains("-"){
             return "0.000"
         }else if let f = Float((str as NSString).dividing(by: "1000", decimals: 2)) , f > 1 {
             return dealDataFormate(str)
         }else{
             return NumberHandler.dealDecimalPoint(str)
         }
     }
     
     //处理数据格式(要求处理成KMB小数点之后统一截取2位)
    public class func dealDataFormate(_ str : String, toCurrencyFormat:Bool = false) -> String{
         
         if let millionStr = NSString.init(string: str).dividing(by: "1000000000", decimals: 2){
             if let m = Float(millionStr) , m >= 1{
                 return millionStr.decimalString1(2).transformToCurrencyFormat(toCurrencyFormat) + "B"
             }
         }
         
         if let millionStr = NSString.init(string: str).dividing(by: "1000000", decimals: 2){
             if let m = Float(millionStr) , m >= 1{
                 return millionStr.decimalString1(2).transformToCurrencyFormat(toCurrencyFormat) + "M"
             }
         }
         
         if let kStr = NSString.init(string: str).dividing(by: "1000", decimals: 2){
             if let k = Float(kStr) , k >= 1{
                 return kStr.decimalString1(2).transformToCurrencyFormat(toCurrencyFormat) + "K"
             }
         }
         
         return str
     }
     
    
    //处理数据格式
   public class func privateDealDataFormate(_ str : String) -> String{
       if let millionStr = NSString.init(string: str).dividing(by: "1000000000", decimals: 2){
            if let m = Float(millionStr) , m >= 1{
                return "\(m)".formatAmountUseDecimal("2",holdZero: true) + "B"
            }
        }
        
        if let millionStr = NSString.init(string: str).dividing(by: "1000000", decimals: 2){
            if let m = Float(millionStr) , m >= 1{
                return "\(m)".formatAmountUseDecimal("2",holdZero: true) + "M"
            }
        }
        
        if let kStr = NSString.init(string: str).dividing(by: "1000", decimals: 2){
            if let k = Float(kStr) , k >= 1{
                    return "\(k)".formatAmountUseDecimal("2",holdZero: true) + "K"
            }
        }
        return str.formatAmountUseDecimal("2",holdZero: true)
    }
    
    
    
     //digits必须大于0
     //看懂了,digits是字符串总长度,precision是默认精度.
     //永远保持总长度一致.
     public class func dealDecimalPoint(_ str : String,digits : Int = 5 , precision : Int = 3) -> String{
         var tmpStr = (str as NSString).decimalString1(precision)
         if let s = tmpStr , s.count > digits{
             tmpStr = s[0...digits]
         }
         if let last = tmpStr?.last, last == "."{
             tmpStr?.removeLast()
         }
         
         if tmpStr != nil{
             return tmpStr!
         }
         return str
     }
    
    //把精度转成小数
    public class func strToPrecision(_ str : String) -> String{
        var precision = "0"
        let num = Int(NumberHandler.handleDouble(str))
        if num == 0{
            return "1"
        }else{
            precision = precision + "."
            for _ in 0..<num{
                precision = precision + "0"
            }
            return precision + "1"
        }
    }
     
    //处理数字的颜色
    public class func dealNumColor(_ num : String) -> UIColor{
        var color = UIColor.ThemeLabel.colorLite
        if num.contains("-"){
            color = UIColor.ThemekLine.down
        }else{
            if let n = Int(num) , n > 0{
                color = UIColor.ThemekLine.up
            }
        }
        return color
    }
    

}

extension String {
    fileprivate func transformToCurrencyFormat(_ flag:Bool = true) -> String {
        return flag ? toCurrencyFormat() : self
    }
    /// 货币字符串添加千分位分隔符
    public func toCurrencyFormat(isSwap: Bool = false) -> String {
        if isSwap{
            return self
        }
        /**
         方案一:NumberFormatter
         方案二:字符串分割处理,保持数据精度
         */
        //
        if isEmpty {
            return self
        }
        guard let douleValue = Double(self), douleValue.isNormal || douleValue.isZero else {
            return self
        }
        //
        var string = self
        var sign = ""
        if douleValue.sign == .minus, let str = components(separatedBy: "-").last {
            sign = "-"
            string = str
        }
        //
        var integerPart = string
        var decimalPart:String? = nil
        //
        if let idx = string.firstIndex(of: ".") {
            let leftSubString = string[string.startIndex..<idx]
            integerPart = String(leftSubString)
            let rightSubString = string[string.index(idx, offsetBy: 1)..<string.endIndex]
            decimalPart = String(rightSubString)
        }
        let step = 3
        if integerPart.trimmingCharacters(in: .whitespacesAndNewlines).count <= step {
            return self
        }
        let offset = integerPart.count - step
        for offset in stride(from: offset, to: 0, by: -step) {
            integerPart.insert(",", at: index(integerPart.startIndex, offsetBy: offset))
        }
        //
        var result = sign + integerPart
        if let decimalPart = decimalPart {
            result.append(".")
            result.append(decimalPart)
        }
        //
        return result
    }
    
    /// format string to percent mode
    /// - Parameters:
    ///   - decimal: decimal digit count for percent, 4 as default due to `jira-31805`
    ///   - holdZero: hold zero of decimal
    ///   - appendSign: append % or not
    /// - Returns: percent mode string
    public func toPercentFormat(decimal:Int = 4, holdZero:Bool = false, appendSign:Bool = true) -> String {
        guard let douleValue = Double(self), douleValue.isNormal || douleValue.isZero else {
            return self
        }
        var result = self
        if isEmpty || douleValue.isZero {
            result = "0"
            if holdZero, decimal > 0 {
                result = result.formatAmountUseDecimal(String(decimal), holdZero: holdZero)
            }
        }else{
            result = result.stringByMultiplying(multiple: "100", decimal: decimal, holdZero: holdZero)
        }
        if appendSign {
            result += "%"
        }
        return result
    }
}
