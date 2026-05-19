//
//  EXSTools.swift
//  CoNetworkTest
//
//  Created by ZYJ on 2023/1/8.
//

import UIKit
import EXKit
class EXSTools {
    
    static func generateLeverAndMaxCoinDic(maxLever:String,minLever:String,leverCeiling:[String:NSNumber]) -> [String:String] {
        
        guard let maxLeverage = Int(maxLever),let minLeverage = Int(minLever), maxLeverage > 0, leverCeiling.count > 0 else {
            return [:]
        }
        
       let sortLeverCeilingKeys = leverCeiling.keys.sorted(by: { (first, second) -> Bool in
            return Int(first) ?? 0 < Int(second) ?? 0
        })
       
        var maxIndex = 0
        var leverAndMaxCoinDic = [String:String]()

        for currentLeverage  in minLeverage ... maxLeverage {
            let key = sortLeverCeilingKeys[maxIndex]
            
            if let coinValue = leverCeiling[key] {
                
                leverAndMaxCoinDic["\(currentLeverage)"] = "\(coinValue)"
            }
            if currentLeverage == Int(key) ?? 0 {
                maxIndex += 1
            }
        }
//        //print("杠杆 = leverAndMaxCoinDic =\(leverAndMaxCoinDic)") English: Print ("lever=leverAndMaxCoinDic=\ (leverAndMaxCoinDic)")
        return leverAndMaxCoinDic
    }
    //处理数据格式 English: Processing data formats
    class func dealDataFormate(_ str : String) -> String{
        let bStr = str.bigDiv("1000000000",decimals:2)
        if bStr.count > 0 {
            if let m = Float(bStr) , m >= 1{
                return dealDecimalPoint(bStr,digits:4) + "B"
            }
        }
        let millionStr = str.bigDiv("1000000", decimals: 2)
        if millionStr.count > 0 {
            if let m = Float(millionStr) , m >= 1{
                return dealDecimalPoint(millionStr,digits:4) + "M"
            }
        }
        let kStr = str.bigDiv("1000", decimals: 2)
        if kStr.count > 0 {
            if let k = Float(kStr) , k >= 1{
                return dealDecimalPoint(kStr,digits:4) + "K"
            }
        }
        
        return str
    }
    class func dealDecimalPoint(_ str : String,digits : Int = 5 , precision : Int = 3) -> String{
        var tmpStr = str.exs_decimalString1(precision)
        if  tmpStr.count > digits{
            tmpStr = (tmpStr as NSString).substring(to: digits)
        }
        if let last = tmpStr.last, last == "."{
            tmpStr.removeLast()
        }
        if tmpStr.count > 0 {
            return tmpStr
        }
        return str
    }
    
    class func handleDouble(_ a : Any) -> Double{
        switch a {
        case let val as Double:
            //            //print("\(val)是个数字类型") English: Print ("\ (val) is a numeric type")
            return Double(val)
        case let val as String:
            //            //print("\(val)是个字符串") English: Print ("\ (val) is a string")
            return (val as NSString).doubleValue
        case let val as Int:
            //            //print("\(val)是int") English: Print ("\ (val) is int")
            return Double(val)
            
        case let val as Float:
            //            //print("\(val)是个float") English: Print ("\ (val) is a float")
            return Double(val)
        default:
            //print("啥都不是")
            break
        }
        return 0
    }
    //处理数量精度 English: Processing quantity accuracy
    class func dealVolumFormate(_ str : String) -> String{
        let decimals = 8
        //如果是0，则返回0 English: If 0, return 0
        if Double(str) == 0{
            return "0"
        }
        
        //如果小于0.001 则返回0 English: If less than 0.001, return 0
        let poor = str.bigSub("0.001", decimals: Int16(decimals))
        if poor.contains("-"){
            return "0.000"
        }else if str.bigDiv("1000", decimals: 2).greaterThan("1") {
            return dealDataFormate(str)
        }else{
            return EXSTools.dealDecimalPoint(str)
        }
    }
    //把精度转成小数 English: Convert precision to decimals
    class func strToPrecision(_ str : String) -> String{
        var precision = "0"
        let num = Int(EXSTools.handleDouble(str))
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
//    //四拾伍入 English: Forty five
//    class func decimalFormat(scale:Int16,floatV:Double) -> String? {
//        let handler = NSDecimalNumberHandler.init(roundingMode: .up,
//                                                  scale: scale,
//                                                  raiseOnExactness: false,
//                                                  raiseOnOverflow: false,
//                                                  raiseOnUnderflow: false,
//                                                  raiseOnDivideByZero: false)
//        let ouncesDecimal = NSDecimalNumber(floatLiteral: floatV)
//        let roundedOunces = ouncesDecimal.rounding(accordingToBehavior: handler)
//        return String(format: "%@", roundedOunces)
//    }
    class var isCoin : Bool {
        return EXStoreData.storeBool(forKey: EXS_UNIT_VOL)
    }
    /*
     成交额的处理 English: Handling of transaction volume
     */
    
    class func isChineseLan() -> Bool{
        let isChinese = LanguageHandler.priviatePhoneLanguage.hasPrefix("zh") || LanguageHandler.priviatePhoneLanguage == "el_GR"
        return isChinese
    }
    
    
    class func getAdlUrl() -> String {
        let chineseUrl = "https://futuresdoc.gitbook.io/help-center/v/cn/yong-xu-he-yue/untitled-1/zi-dong-jian-cang-adl"
        let englishUrl = "https://futuresdoc.gitbook.io/help-center/perpetual/overview/adl"
        
        if isChineseLan(){
            return chineseUrl
        }
        return englishUrl
    }
    
    class func dealValueAmountformat(orginAmount: String, model:EXContractsModel?) -> String{
        var amount = orginAmount
        var result = "0"
        var decimal = 2
        if let info = model {
            decimal = info.volumeDecial.to_Precision()
            amount = amount.bigMul(info.face_value)
        }
        let isChinese = LanguageHandler.phoneLanguage.hasPrefix("zh") || LanguageHandler.phoneLanguage == "el_GR"
        if isChinese{ //中文 English: chinese
            if amount.greaterThanOrEqual(ch_yiUnit){ //亿 English: Billion
                result = amount.bigDiv(ch_yiUnit).exs_decimalString(2) + "亿"
            }else if amount.greaterThanOrEqual(ch_wanUnit) && amount.lessThan(ch_yiUnit){//万 English: ten thousand
                result = amount.bigDiv(ch_wanUnit).exs_decimalString(2) + "万"
            }else if amount.greaterThan("0") && amount.lessThan(ch_wanUnit){//
                result = amount.exs_decimalString(decimal)
            }
        }else{ //其他语言 English: Other languages
            if amount.greaterThanOrEqual(b_unit){ //B
                result = amount.bigDiv(b_unit).exs_decimalString(2) + "B"
            }else if amount.greaterThanOrEqual(m_unit) && amount.lessThan(b_unit){//M
                result = amount.bigDiv(m_unit).exs_decimalString(2) + "M"
            }else if amount.greaterThan("0") && amount.lessThan(m_unit){//
                result = amount.exs_decimalString(decimal)
            }
        }
//        //print("成交额 amount = \(amount) => \(result)") English: Print ("Transaction amount=\ (amount)=>\ (result)")
        return result
    }
    /*
     24小时成交量的处理 English: Processing of 24-hour trading volume
     decimal: 配置的精度 English: Decimal: the precision of the configuration
     isKine:  是否k线常按的弹框里的交易量显示 English: IsKind: Is the transaction volume displayed in the pop-up box that is frequently pressed by the candlestick
     */
    class func dealVolumeAmountformat(amount: String,model:EXContractsModel?,isKine: Bool = false,deci: Int = 2) -> String{
        var result = "0"
        var decimal = deci
        var newAmount = amount
        if isKine == false {
            if let info = model {
                decimal = info.volumeDecial.to_Precision()
                if isCoin{ //币 English: currency
                    newAmount = EXFormula.ticket(toCoin: amount, contract: info)
                }
            }
        }
        let isChinese = LanguageHandler.phoneLanguage.hasPrefix("zh") || LanguageHandler.phoneLanguage == "el_GR"
        if isChinese{ //中文 English: chinese
            if newAmount.greaterThanOrEqual(ch_yiUnit){ //亿 English: Billion
                result = newAmount.bigDiv(ch_yiUnit).exs_decimalString(2) + "亿"
            }else if newAmount.greaterThanOrEqual(ch_wanUnit) && newAmount.lessThan(ch_yiUnit){//万 English: ten thousand
                result = newAmount.bigDiv(ch_wanUnit).exs_decimalString(2) + "万"
            }else if newAmount.greaterThan("0") && newAmount.lessThan(ch_wanUnit){//
                result = newAmount.exs_decimalString(decimal)
                if isKine == false {
                    if !isCoin { //张取整数 English: Zhang takes an integer
                        result = newAmount.exs_decimalString(0)
                    }
                }
            }
        }else{ //其他语言 English: Other languages
            if newAmount.greaterThanOrEqual(b_unit){ //B
                result = newAmount.bigDiv(b_unit).exs_decimalString(2) + "B"
            }else if newAmount.greaterThanOrEqual(m_unit) && newAmount.lessThan(b_unit){//M
                result = newAmount.bigDiv(m_unit).exs_decimalString(2) + "M"
            }else if newAmount.greaterThan("0") && newAmount.lessThan(m_unit){//
                result = newAmount.exs_decimalString(decimal)
                if isKine == false {
                    if !isCoin { //
                        result = newAmount.exs_decimalString(0)
                    }
                }
            }
        }
//        if isKine{
//            //print("成交量 k线 amount = \(amount) => \(result)") English: Print ("Trading volume k-line amount=\ (amount)=>\ (result)")
//        }else{
//            //print("成交量 amount = \(amount) => \(result)") English: Print ("Transaction volume amount=\ (amount)=>\ (result)")
//        }
        
        return result
    }
}
let ch_wanUnit = "10000"
let ch_yiUnit = "100000000"
let b_unit = "1000000000"
let m_unit = "1000000"

extension EXSTools {
    
//   class func getLocalBundlePath() -> String? {
//        if let bundlePath = Bundle.main.path(forResource: "EXContractSDK", ofType: ".bundle") {
//            return bundlePath
//        }
//        return nil
//    }
    
    @objc public class func SwapFrameworkBundle() -> Bundle {
        let framework = Bundle.main.url(forResource: "Frameworks", withExtension: nil)
        let swap = framework?.appendingPathComponent("Swap.framework")
//        //print("framework=>\(framework)")
//        //print("swap=>\(swap)")
        return Bundle(url: swap!)!
    }
    class func getSwapBunlde() -> String? {
        let sdk = self.SwapFrameworkBundle()
        if let bundlePath = sdk.path(forResource: "Swap", ofType: ".bundle") {
//            //print("bundlePath=\(bundlePath)")
            return bundlePath
        }
        return nil
    }
    class func getLocalBundlePath(name: String = "EXContractSDK") -> String? {
       // return getSwapBunlde()
        if let bundlePath = self.getSwapBunlde() {
//            //print("bundlePath=\(bundlePath)")
            if let b = Bundle(path: bundlePath) {
                let contractPath = b.path(forResource: "EXContractSDK", ofType: ".bundle")
//                //print("contractPath=\(contractPath)")
                return contractPath
            }
        }
        return nil
    }
    
   
}

extension StoryBoardLoadable {
    public static func exs_instanceFromStoryboard(name:String) -> Self {
        //identifier 为类名，在stoyboard里配置 English: The identifier is the class name and is configured in the Stoyboard
        let identifier = String(describing:self)
        return UIStoryboard.init(name: name, bundle: EXSTools.SwapFrameworkBundle()).instantiateViewController(withIdentifier: identifier) as! Self
    }
}

public class UIDeviceManger{
    public var blockRotation: UIInterfaceOrientationMask = .portrait{
        didSet{
            if blockRotation.contains(.portrait){
                //强制设置成竖屏 English: Force vertical screen setting
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            }else{
                //强制设置成横屏 English: Force to landscape
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
                
            }
        }
    }
    //MARK:单例 English: MARK: Single Example
    static public let shared = UIDeviceManger()
    private init() {}
    
    func reset() {
        
    }
}

